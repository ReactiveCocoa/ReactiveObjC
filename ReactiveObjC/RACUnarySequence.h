//
//  RACUnarySequence.h
//  ReactiveObjC
//
//  Created by Justin Spahr-Summers on 2013-05-01.
//  Copyright (c) 2013 GitHub, Inc. All rights reserved.
//

#import "RACSequence.h"

// Private class representing a sequence of exactly one value.
@interface RACUnarySequence : RACSequence

+ (RACUnarySequence *)return:(id)value;

@end
