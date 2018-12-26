import Quick
import Nimble
import ReactiveObjC

final class RACSwiftBridgingSpec: QuickSpec {
	override func spec() {
		describe("RACCommandError") {
			it("bridges RACCommandErrorNotEnabled to a Swift error code") {
				let error: Error = NSError(domain: RACCommandErrorDomain, code: 1)
				expect(RACCommandError.notEnabled ~= error).to(beTrue())
			}
		}

		describe("RACSelectorSignalError") {
			it("bridges RACSelectorSignalErrorMethodSwizzlingRace to a Swift error code") {
				let error: Error = NSError(domain: RACSelectorSignalErrorDomain, code: 1)
				expect(RACSelectorSignalError.methodSwizzlingRace ~= error).to(beTrue())
			}
		}

		describe("RACSignalError") {
			it("bridges RACSignalErrorTimedOut to a Swift error code") {
				let error: Error = NSError(domain: RACSignalErrorDomain, code: 1)
				expect(RACSignalError.timedOut ~= error).to(beTrue())
			}

			it("bridges RACSignalErrorNoMatchingCase to a Swift error code") {
				let error: Error = NSError(domain: RACSignalErrorDomain, code: 2)
				expect(RACSignalError.noMatchingCase ~= error).to(beTrue())
			}
		}
	}
}
