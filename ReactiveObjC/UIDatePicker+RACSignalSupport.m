//
//  UIDatePicker+RACSignalSupport.m
//  ReactiveObjC
//
//  Created by Uri Baghin on 20/07/2013.
//  Copyright (c) 2013 GitHub, Inc. All rights reserved.
//

#import <ReactiveObjC/EXTKeyPathCoding.h>
#import "UIControl+RACSignalSupportPrivate.h"
#import "UIDatePicker+RACSignalSupport.h"

@implementation UIDatePicker (RACSignalSupport)

- (RACChannelTerminal *)rac_newDateChannelWithNilValue:(NSDate *)nilValue {
  return [self rac_channelForControlEvents:UIControlEventValueChanged
                                       key:@keypath(self.date)
                                  nilValue:nilValue];
}

@end
