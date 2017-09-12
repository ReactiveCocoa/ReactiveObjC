//
//  UITextField+RACCommandSupport.m
//  ReactiveObjC
//
//  Created by Andrew Urban on 9/12/17.
//  Copyright © 2017 GitHub. All rights reserved.
//

#import "UITextField+RACCommandSupport.h"
#import <ReactiveObjC/EXTKeyPathCoding.h>
#import "RACCommand.h"
#import "RACDisposable.h"
#import "RACSignal+Operations.h"
#import <objc/runtime.h>

static void *UITextFieldRACReturnCommandKey = &UITextFieldRACReturnCommandKey;
static void *UITextFieldEnabledDisposableKey = &UITextFieldEnabledDisposableKey;

@implementation UITextField (RACCommandSupport)

- (RACCommand *)rac_returnCommand {
	return objc_getAssociatedObject(self, UITextFieldRACReturnCommandKey);
}

- (void)setRac_returnCommand:(RACCommand *)command {
	objc_setAssociatedObject(self, UITextFieldRACReturnCommandKey, command, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	
	// Check for stored signal in order to remove it and add a new one
	RACDisposable *disposable = objc_getAssociatedObject(self, UITextFieldEnabledDisposableKey);
	[disposable dispose];
	
	if (command == nil) return;
	
	disposable = [command.enabled setKeyPath:@keypath(self.enabled) onObject:self];
	objc_setAssociatedObject(self, UITextFieldEnabledDisposableKey, disposable, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	
	[self rac_hijackActionAndTargetIfNeeded];
}

- (void)rac_hijackActionAndTargetIfNeeded {
	SEL hijackSelector = @selector(rac_commandPerformAction:);
	
	for (NSString *selector in [self actionsForTarget:self forControlEvent:UIControlEventEditingDidEndOnExit]) {
		if (hijackSelector == NSSelectorFromString(selector)) {
			return;
		}
	}
	
	[self addTarget:self action:hijackSelector forControlEvents:UIControlEventEditingDidEndOnExit];
}

- (void)rac_commandPerformAction:(id)sender {
	[self.rac_returnCommand execute:sender];
}

@end
