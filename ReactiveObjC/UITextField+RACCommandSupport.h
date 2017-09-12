//
//  UITextField+RACCommandSupport.h
//  ReactiveObjC
//
//  Created by Andrew Urban on 9/12/17.
//  Copyright © 2017 GitHub. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RACCommand<__contravariant InputType, __covariant ValueType>;

NS_ASSUME_NONNULL_BEGIN

@interface UITextField (RACCommandSupport)

/// Sets the command for the text field's return key. When the return key is clicked, the command is
/// executed with the sender of the event. The text field's enabledness is bound
/// to the command's `canExecute`.
@property (nonatomic, strong, nullable) RACCommand<__kindof UITextField *, id> *rac_returnCommand;

@end

NS_ASSUME_NONNULL_END
