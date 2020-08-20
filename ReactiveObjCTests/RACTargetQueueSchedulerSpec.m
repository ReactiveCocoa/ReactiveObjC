//
//  RACTargetQueueSchedulerSpec.m
//  ReactiveObjC
//
//  Created by Josh Abernathy on 6/7/13.
//  Copyright (c) 2013 GitHub, Inc. All rights reserved.
//

@import Quick;
@import Nimble;

#import "RACTargetQueueScheduler.h"
#import <stdatomic.h>

QuickSpecBegin(RACTargetQueueSchedulerSpec)

qck_it(@"should have a valid current scheduler", ^{
	dispatch_queue_t queue = dispatch_queue_create("test-queue", DISPATCH_QUEUE_SERIAL);
	RACScheduler *scheduler = [[RACTargetQueueScheduler alloc] initWithName:@"test-scheduler" targetQueue:queue];
	__block RACScheduler *currentScheduler;
	[scheduler schedule:^{
		currentScheduler = RACScheduler.currentScheduler;
	}];

	expect(currentScheduler).toEventually(equal(scheduler));
});

qck_it(@"should schedule blocks FIFO even when given a concurrent queue", ^{
	dispatch_queue_t queue = dispatch_queue_create("test-queue", DISPATCH_QUEUE_CONCURRENT);
	RACScheduler *scheduler = [[RACTargetQueueScheduler alloc] initWithName:@"test-scheduler" targetQueue:queue];
	__block atomic_int startedCount = 0;
	__block atomic_uint waitInFirst = 1;
	[scheduler schedule:^{
		atomic_fetch_add(&startedCount, 1);
		while (waitInFirst == 1) ;
	}];

	[scheduler schedule:^{
		atomic_fetch_add(&startedCount, 1);
	}];

	expect(@(startedCount)).toEventually(equal(@1));

	atomic_fetch_and(&waitInFirst, 0);

	expect(@(startedCount)).toEventually(equal(@2));
});

QuickSpecEnd
