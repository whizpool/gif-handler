//
//  ApplyEffectsViewController.h
//  GifHandler
//
//  Created by Irfan Ali on 07/04/2020.
//  Copyright © 2020 Whizpool. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define GIF_BEFORE_MERGE_DIR_NAME               @"BeforeMerge"
#define GIF_BEFORE_MERGE_IMAGE_NAME             @"BeforeMerging"
#define GIF_AFTER_MERGE_DIR_NAME                @"AfterMerge"
#define GIF_AFTER_MERGE_IMAGE_NAME              @"AfterMerging"
#define GIF_IMAGE_FINAL_NAME                    @"finalmerged.gif"
#define GIF_DISPLAY_IMAGE_NAME                  @"displayimage.jpg"

enum filterOption {
    eNone           = 0,
    eSepia          = 1,
    ePhotoEffect    = 2,
    eSpotColor      = 3
};

@interface ApplyEffectsViewController : UIViewController
{
    IBOutlet UIImageView                *pImageView;
    
    IBOutlet UIActivityIndicatorView    *pLoadingSpinner;
    
    int                                 gifMergingCurrentIndex;
    
    int                                 gifMergingTotalIndex;
    
    NSMutableArray                      *gifMergingPathsBeforeMerge,*gifMergingPathsAfterMerge;
    
    enum filterOption                   eFilterOption;
    
    NSURL                               *pExportImageURL;
    
    IBOutlet UIImageView                *pOriginalImageView;
    IBOutlet UIImageView                *pSepiaImageView;
    IBOutlet UIImageView                *pPhotoEffectImageView;
    IBOutlet UIImageView                *pSpotColorImageView;
}

@property (nonatomic, strong) NSString *sourceFilePath;


@end

NS_ASSUME_NONNULL_END
