//
//  UITextFieldRACSupportSpec.m
//  ReactiveObjC
//
//  Created by Andrew Urban on 9/12/17.
//  Copyright © 2017 GitHub. All rights reserved.
//

@import Quick;
@import Nimble;

#import "RACControlCommandExamples.h"
#import "RACTestUITextField.h"

#import "UITextField+RACCommandSupport.h"
#import "RACCommand.h"
#import "RACDisposable.h"

QuickSpecBegin(UITextFieldRACSupportSpec)

qck_describe(@"UITextField", ^{
	__block UITextField *textField;
	
	qck_beforeEach(^{
		textField = [RACTestUITextField textField];
		expect(textField).notTo(beNil());
	});
	
	qck_itBehavesLike(RACControlCommandExamples, ^{
		return @{
				 RACControlCommandExampleControl: textField,
				 RACControlCommandExampleActivateBlock: ^(UITextField *textField) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
					 [textField sendActionsForControlEvents:UIControlEventEditingDidEndOnExit];
#pragma clang diagnostic pop
				 }
				 };
	});
});

QuickSpecEnd
