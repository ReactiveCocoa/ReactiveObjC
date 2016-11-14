//
//  NSOrderedSet+RACSequenceAdditions.h
//  ReactiveObjC
//
//  Created by Justin Spahr-Summers on 2012-10-29.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RACSequence;

NS_ASSUME_NONNULL_BEGIN

@interface NSOrderedSet (RACSequenceAdditions)

/// Creates and returns a sequence corresponding to the receiver.
///
/// Mutating the receiver will not affect the sequence after it's been created.
@property (nonatomic, copy, readonly) RACSequence *rac_sequence;

@end

NS_ASSUME_NONNULL_END
