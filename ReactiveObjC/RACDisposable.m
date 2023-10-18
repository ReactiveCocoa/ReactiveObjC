//
//  RACDisposable.m
//  ReactiveObjC
//
//  Created by Josh Abernathy on 3/16/12.
//  Copyright (c) 2012 GitHub, Inc. All rights reserved.
//

#import "RACDisposable.h"
#import <libkern/OSAtomic.h>
#import "RACScopedDisposable.h"

#include <stdatomic.h>
@interface RACDisposable () {
  // A copied block of type void (^)(void) containing the logic for disposal,
  // a pointer to `self` if no logic should be performed upon disposal, or
  // NULL if the receiver is already disposed.
  //
  // This should only be used atomically.
  void *volatile _disposeBlock;
}

@end

@implementation RACDisposable

#pragma mark Properties

- (BOOL)isDisposed {
  return _disposeBlock == NULL;
}

#pragma mark Lifecycle

- (instancetype)init {
  self = [super init];

  _disposeBlock = (__bridge void *)self;
  atomic_thread_fence(memory_order_seq_cst);

  return self;
}

- (instancetype)initWithBlock:(void (^)(void))block {
  NSCParameterAssert(block != nil);

  self = [super init];

  _disposeBlock = (void *)CFBridgingRetain([block copy]);
  atomic_thread_fence(memory_order_seq_cst);

  return self;
}

+ (instancetype)disposableWithBlock:(void (^)(void))block {
  return [[self alloc] initWithBlock:block];
}

- (void)dealloc {
  if (_disposeBlock == NULL || _disposeBlock == (__bridge void *)self) return;

  CFRelease(_disposeBlock);
  _disposeBlock = NULL;
}

#pragma mark Disposal

- (void)dispose {
  void (^disposeBlock)(void) = NULL;
  _Atomic(void *) *disposeBlockPtr = (_Atomic(void *) *)&_disposeBlock;
  while (YES) {
    void *blockPtr = _disposeBlock;
    if (atomic_compare_exchange_strong(disposeBlockPtr, &blockPtr, NULL)) {
      if (blockPtr != (__bridge void *)self) {
        disposeBlock = CFBridgingRelease(blockPtr);
      }

      break;
    }
  }

  if (disposeBlock != nil) disposeBlock();
}

#pragma mark Scoped Disposables

- (RACScopedDisposable *)asScopedDisposable {
  return [RACScopedDisposable scopedDisposableWithDisposable:self];
}

@end
