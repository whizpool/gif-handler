//
//  ImageAnimator.h
//  GifHandler
//
//  Created by Irfan Ali on 07/04/2020.
//  Copyright © 2020 Whizpool. All rights reserved.
//


#import <Foundation/Foundation.h>

#import <CoreGraphics/CoreGraphics.h>
@class UIImage;

typedef void (^ _Nullable onAnimate)(UIImage * _Nullable img, NSError * _Nullable error);

NS_ASSUME_NONNULL_BEGIN

@interface ImageAnimator : NSObject

@property (nonatomic) NSUInteger beginningFrameIndex;
@property (nonatomic) CGFloat delayPerFrame;
@property (nonatomic) NSUInteger loopCount;
@property (nonatomic) BOOL stopPlayback;

- (void)animateImageWithData:(NSData *)data onAnimate:(onAnimate)animationBlock;
- (void)animateImageAtURL:(NSURL *)url onAnimate:(onAnimate)animationBlock;

@end

NS_ASSUME_NONNULL_END
