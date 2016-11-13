//
//  NSObjectRACSelectorSignalPerformanceTests.m
//  ReactiveObjC
//
//  Created by Anders Ha on 13/11/2016.
//  Copyright © 2016 GitHub. All rights reserved.
//

@import Nimble;

#import <XCTest/XCTest.h>
#import "RACTestObject.h"
#import "NSObject+RACSelectorSignal.h"
#import "RACSignal.h"
#import "NSObject+RACPropertySubscribing.h"

@interface NSObjectRACSelectorSignalPerformanceTests : XCTestCase

@end

@implementation NSObjectRACSelectorSignalPerformanceTests

- (void)testKVORACStressTest {
	RACTestObject* object = [[RACTestObject alloc] init];

	[self measureBlock:^{
		__block unsigned int racCount = 0, kvoCount = 0;

		[RACObserve(object, objectValue) subscribeNext:^(id value) {
			kvoCount += 1;
		}];

		[[object rac_signalForSelector:@selector(setObjectValue:)] subscribeNext:^(id value) {
			racCount += 1;
		}];

		unsigned int iterations = 2500;

		for (unsigned int i = 0; i < iterations; i++) {
			[object setObjectValue:@(i)];
		}

		expect(object.objectValue).to(equal(@(iterations - 1)));
		expect(@(racCount)).to(equal(@(iterations)));
		expect(@(kvoCount)).to(equal(@(iterations + 1)));
	}];
}

- (void)testRACKVOStressTest {
	RACTestObject* object = [[RACTestObject alloc] init];

	[self measureBlock:^{
		__block unsigned int racCount = 0, kvoCount = 0;

		[[object rac_signalForSelector:@selector(setObjectValue:)] subscribeNext:^(id value) {
			racCount += 1;
		}];

		[RACObserve(object, objectValue) subscribeNext:^(id value) {
			kvoCount += 1;
		}];

		unsigned int iterations = 2500;

		for (unsigned int i = 0; i < iterations; i++) {
			[object setObjectValue:@(i)];
		}

		expect(object.objectValue).to(equal(@(iterations - 1)));
		expect(@(racCount)).to(equal(@(iterations)));
		expect(@(kvoCount)).to(equal(@(iterations + 1)));
	}];
}

@end
