//
//  ImageAnimator.m
//  GifHandler
//
//  Created by Irfan Ali on 07/04/2020.
//  Copyright © 2020 Whizpool. All rights reserved.
//


#import "ImageAnimator.h"
#import "ImageIO/CGImageAnimation.h"
#import <UIKIT/UIKit.h>

@implementation ImageAnimator

#pragma mark - Initializer

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        self.beginningFrameIndex = 0;
        self.delayPerFrame = 0.1f;
        self.loopCount = 0;
    }
    
    return self;
}

#pragma mark - Public

- (void)animateImageAtURL:(NSURL *)url onAnimate:(onAnimate)animationBlock
{
//    __weak typeof(self) weakSelf = self;
    NSDictionary *options = [self animationOptionsDictionary];
    
    if (@available(iOS 13.0, *)) {
        CGAnimateImageAtURLWithBlock((CFURLRef)url, (CFDictionaryRef)options, ^(size_t index, CGImageRef  _Nonnull image, bool * _Nonnull stop) {
            *stop = self.stopPlayback;
            animationBlock([UIImage imageWithCGImage:image], nil /* report any relevant OSStatus if needed*/);
        });
    } else {
        // Fallback on earlier versions
    }
}

- (void)animateImageWithData:(NSData *)data onAnimate:(onAnimate)animationBlock
{
//    __weak typeof(self) weakSelf = self;
    NSDictionary *options = [self animationOptionsDictionary];
    
    if (@available(iOS 13.0, *)) {
        CGAnimateImageDataWithBlock((CFDataRef)data, (CFDictionaryRef)options, ^(size_t index, CGImageRef  _Nonnull image, bool * _Nonnull stop) {
            *stop = self.stopPlayback;
            animationBlock([UIImage imageWithCGImage:image], nil /* report any relevant OSStatus if needed*/);
        });
    } else {
        // Fallback on earlier versions
    }
}

#pragma mark - Private

- (NSDictionary *)animationOptionsDictionary
{
    NSMutableDictionary <NSString *, NSNumber *> *options = [NSMutableDictionary new];
    if (@available(iOS 13.0, *)) {
        [options addEntriesFromDictionary:@{(NSString *)kCGImageAnimationStartIndex:@(self.beginningFrameIndex),
                                            (NSString *)kCGImageAnimationDelayTime:@(self.delayPerFrame)}];
    } else {
        // Fallback on earlier versions
    }
    if (self.loopCount > 0)
    {
        if (@available(iOS 13.0, *)) {
            options[(NSString *)kCGImageAnimationLoopCount] = @(self.loopCount);
        } else {
            // Fallback on earlier versions
        }
    }
    
    return [options copy];
}

@end
