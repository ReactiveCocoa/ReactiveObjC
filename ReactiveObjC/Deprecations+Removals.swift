//
//  Deprecations+Removals.swift
//  ReactiveObjC
//
//  Created by Adam Sharp on 26/12/18.
//  Copyright © 2018 GitHub. All rights reserved.
//

@available(*, deprecated, renamed: "RACSignalError.noMatchingCase")
public let RACSignalErrorNoMatchingCase = RACSignalError.noMatchingCase.rawValue

@available(*, deprecated, renamed: "RACSignalError.timedOut")
public let RACSignalErrorTimedOut = RACSignalError.timedOut.rawValue
