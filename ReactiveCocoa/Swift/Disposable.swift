//
//  Disposable.swift
//  ReactiveCocoa
//
//  Created by Justin Spahr-Summers on 2014-06-02.
//  Copyright (c) 2014 GitHub. All rights reserved.
//

/// Represents something that can be “disposed”, usually associated with freeing
/// resources or canceling work.
public protocol Disposable: class {
	/// Whether this disposable has been disposed already.
	var isDisposed: Bool { get }

	/// Method for disposing of resources when appropriate.
	func dispose()
}

/// A disposable that only flips `isDisposed` upon disposal, and performs no other
/// work.
public final class SimpleDisposable: Disposable {
	private let _isDisposed = Atomic(false)

	public var isDisposed: Bool {
		return _isDisposed.value
	}

	public init() {}

	public func dispose() {
		_isDisposed.value = true
	}
}

/// A disposable that will run an action upon disposal.
public final class ActionDisposable: Disposable {
	private let action: Atomic<(() -> Void)?>

	public var isDisposed: Bool {
		return action.value == nil
	}

	/// Initialize the disposable to run the given action upon disposal.
	///
	/// - parameters:
	///   - action: A closure to run when calling `dispose()`.
	public init(action: () -> Void) {
		self.action = Atomic(action)
	}

	public func dispose() {
		let oldAction = action.swap(nil)
		oldAction?()
	}
}

/// A disposable that will dispose of any number of other disposables.
public final class CompositeDisposable: Disposable {
	private let disposables: Atomic<Bag<Disposable>?>

	/// Represents a handle to a disposable previously added to a
	/// CompositeDisposable.
	public final class DisposableHandle {
		private let bagToken: Atomic<RemovalToken?>
		private weak var disposable: CompositeDisposable?

		private static let empty = DisposableHandle()

		private init() {
			self.bagToken = Atomic(nil)
		}

		private init(bagToken: RemovalToken, disposable: CompositeDisposable) {
			self.bagToken = Atomic(bagToken)
			self.disposable = disposable
		}

		/// Remove the pointed-to disposable from its `CompositeDisposable`.
		///
		/// - note: This is useful to minimize memory growth, by removing
		///         disposables that are no longer needed.
		public func remove() {
			if let token = bagToken.swap(nil) {
				_ = disposable?.disposables.modify { bag in
					bag?.remove(using: token)
				}
			}
		}
	}

	public var isDisposed: Bool {
		return disposables.value == nil
	}

	/// Initialize a `CompositeDisposable` containing the given sequence of
	/// disposables.
	///
	/// - parameters:
	///   - disposables: A collection of objects conforming to the `Disposable`
	///                  protocol
	public init<S: Sequence where S.Iterator.Element == Disposable>(_ disposables: S) {
		var bag: Bag<Disposable> = Bag()

		for disposable in disposables {
			bag.insert(disposable)
		}

		self.disposables = Atomic(bag)
	}
	
	/// Initialize a `CompositeDisposable` containing the given sequence of
	/// disposables.
	///
	/// - parameters:
	///   - disposables: A collection of objects conforming to the `Disposable`
	///                  protocol
	public convenience init<S: Sequence where S.Iterator.Element == Disposable?>(_ disposables: S) {
		self.init(disposables.flatMap { $0 })
	}

	/// Initializes an empty `CompositeDisposable`.
	public convenience init() {
		self.init([Disposable]())
	}

	public func dispose() {
		if let ds = disposables.swap(nil) {
			for d in ds.reversed() {
				d.dispose()
			}
		}
	}

	/// Add the given disposable to the list, then return a handle which can
	/// be used to opaquely remove the disposable later (if desired).
	///
	/// - parameters:
	///   - d: Optional disposable.
	///
	/// - returns: An instance of `DisposableHandle` that can be used to
	///            opaquely remove the disposable later (if desired).
	@discardableResult
	public func add(_ d: Disposable?) -> DisposableHandle {
		guard let d = d else {
			return DisposableHandle.empty
		}

		var handle: DisposableHandle? = nil
		disposables.modify { ds in
			if let token = ds?.insert(d) {
				handle = DisposableHandle(bagToken: token, disposable: self)
			}
		}

		if let handle = handle {
			return handle
		} else {
			d.dispose()
			return DisposableHandle.empty
		}
	}

	/// Add an ActionDisposable to the list.
	///
	/// - parameters:
	///   - action: A closure that will be invoked when `dispose()` is called.
	///
	/// - returns: An instance of `DisposableHandle` that can be used to
	///            opaquely remove the disposable later (if desired).
	public func add(_ action: () -> Void) -> DisposableHandle {
		return add(ActionDisposable(action: action))
	}
}

/// A disposable that, upon deinitialization, will automatically dispose of
/// another disposable.
public final class ScopedDisposable: Disposable {
	/// The disposable which will be disposed when the ScopedDisposable
	/// deinitializes.
	public let innerDisposable: Disposable

	public var isDisposed: Bool {
		return innerDisposable.isDisposed
	}

	/// Initialize the receiver to dispose of the argument upon
	/// deinitialization.
	///
	/// - parameters:
	///   - disposable: A disposable to dispose of when deinitializing.
	public init(_ disposable: Disposable) {
		innerDisposable = disposable
	}

	deinit {
		dispose()
	}

	public func dispose() {
		innerDisposable.dispose()
	}
}

/// A disposable that will optionally dispose of another disposable.
public final class SerialDisposable: Disposable {
	private struct State {
		var innerDisposable: Disposable? = nil
		var isDisposed = false
	}

	private let state = Atomic(State())

	public var isDisposed: Bool {
		return state.value.isDisposed
	}

	/// The inner disposable to dispose of.
	///
	/// Whenever this property is set (even to the same value!), the previous
	/// disposable is automatically disposed.
	public var innerDisposable: Disposable? {
		get {
			return state.value.innerDisposable
		}

		set(d) {
			let oldState = state.modify { state in
				state.innerDisposable = d
			}

			oldState.innerDisposable?.dispose()
			if oldState.isDisposed {
				d?.dispose()
			}
		}
	}

	/// Initializes the receiver to dispose of the argument when the
	/// SerialDisposable is disposed.
	///
	/// - parameters:
	///   - disposable: Optional disposable.
	public init(_ disposable: Disposable? = nil) {
		innerDisposable = disposable
	}

	public func dispose() {
		let orig = state.swap(State(innerDisposable: nil, isDisposed: true))
		orig.innerDisposable?.dispose()
	}
}

/// Adds the right-hand-side disposable to the left-hand-side
/// `CompositeDisposable`.
///
/// ````
///  disposable += producer
///      .filter { ... }
///      .map    { ... }
///      .start(observer)
/// ````
///
/// - parameters:
///   - lhs: Disposable to add to.
///   - rhs: Disposable to add.
///
/// - returns: An instance of `DisposableHandle` that can be used to opaquely
///            remove the disposable later (if desired).
@discardableResult
public func +=(lhs: CompositeDisposable, rhs: Disposable?) -> CompositeDisposable.DisposableHandle {
	return lhs.add(rhs)
}

/// Adds the right-hand-side `ActionDisposable` to the left-hand-side
/// `CompositeDisposable`.
///
/// ````
/// disposable += { ... }
/// ````
///
/// - parameters:
///   - lhs: Disposable to add to.
///   - rhs: Closure to add as a disposable.
///
/// - returns: An instance of `DisposableHandle` that can be used to opaquely
///            remove the disposable later (if desired).
@discardableResult
public func +=(lhs: CompositeDisposable, rhs: () -> ()) -> CompositeDisposable.DisposableHandle {
	return lhs.add(rhs)
}
