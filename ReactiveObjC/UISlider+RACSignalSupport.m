//
//  UISlider+RACSignalSupport.m
//  ReactiveObjC
//
//  Created by Uri Baghin on 20/07/2013.
//  Copyright (c) 2013 GitHub, Inc. All rights reserved.
//

#import <ReactiveObjC/EXTKeyPathCoding.h>
#import "UIControl+RACSignalSupportPrivate.h"
#import "UISlider+RACSignalSupport.h"

@implementation UISlider (RACSignalSupport)

- (RACChannelTerminal *)rac_newValueChannelWithNilValue:(NSNumber *)nilValue {
  return [self rac_channelForControlEvents:UIControlEventValueChanged
                                       key:@keypath(self.value)
                                  nilValue:nilValue];
}

@end
