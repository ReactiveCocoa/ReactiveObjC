//
//  RACTestUITextField.h
//  ReactiveObjC
//
//  Created by Andrew Urban on 9/12/17.
//  Copyright © 2017 GitHub. All rights reserved.
//

#import <UIKit/UIKit.h>

// Enables use of -sendActionsForControlEvents: in unit tests.
@interface RACTestUITextField : UITextField

+ (instancetype)textField;

@end
