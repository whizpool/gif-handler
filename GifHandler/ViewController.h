//
//  ViewController.h
//  GifHandler
//
//  Created by Irfan Ali on 07/04/2020.
//  Copyright © 2020 Whizpool. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ImageAnimator;

@interface ViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    IBOutlet UIActivityIndicatorView    *pLoadingSpinner;
    
    IBOutlet UIImageView                *pDisplayImageView;
    
    NSString                            *sourceFilePath;
    
    ImageAnimator                       *newImageAnimator;
}


@end

