//
//  UISlider+RACSignalSupport.h
//  ReactiveObjC
//
//  Created by Uri Baghin on 20/07/2013.
//  Copyright (c) 2013 GitHub, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RACChannelTerminal<__covariant ValueType>;

NS_ASSUME_NONNULL_BEGIN

@interface UISlider (RACSignalSupport)

/// Creates a new RACChannel-based binding to the receiver.
///
/// nilValue - The value to set when the terminal receives `nil`.
///
/// Returns a RACChannelTerminal that sends the receiver's value whenever the
/// UIControlEventValueChanged control event is fired, and sets the value to the
/// values it receives.
- (RACChannelTerminal<NSNumber *> *)rac_newValueChannelWithNilValue:(nullable NSNumber *)nilValue;

@end

NS_ASSUME_NONNULL_END
