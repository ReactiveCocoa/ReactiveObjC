//
//  Deprecations+Removals.swift
//  ReactiveObjC
//
//  Created by Adam Sharp on 26/12/18.
//  Copyright © 2018 GitHub. All rights reserved.
//

@available(*, deprecated, renamed: "RACSignalError.notEnabled")
public let RACCommandErrorNotEnabled = RACCommandError.notEnabled.rawValue

@available(*, deprecated, renamed: "RACSignalError.methodSwizzlingRace")
public let RACSelectorSignalErrorMethodSwizzlingRace = RACSelectorSignalError.methodSwizzlingRace

@available(*, deprecated, renamed: "RACSignalError.noMatchingCase")
public let RACSignalErrorNoMatchingCase = RACSignalError.noMatchingCase.rawValue

@available(*, deprecated, renamed: "RACSignalError.timedOut")
public let RACSignalErrorTimedOut = RACSignalError.timedOut.rawValue
