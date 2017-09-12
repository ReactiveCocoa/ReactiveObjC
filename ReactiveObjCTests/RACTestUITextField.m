//
//  RACTestUITextField.m
//  ReactiveObjC
//
//  Created by Andrew Urban on 9/12/17.
//  Copyright © 2017 GitHub. All rights reserved.
//

#import "RACTestUITextField.h"

@implementation RACTestUITextField

+ (instancetype)textField {
	RACTestUITextField *textField = [self new];
	return textField;
}

// Required for unit testing – controls don't work normally
// outside of normal apps.
-(void)sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
	[target performSelector:action withObject:self];
#pragma clang diagnostic pop
}

@end
