//
//  ViewController.m
//  GifHandler
//
//  Created by Irfan Ali on 07/04/2020.
//  Copyright © 2020 Whizpool. All rights reserved.
//

#import "ViewController.h"
#import <Photos/Photos.h>
#import "AppDelegate.h"
#import "UIImage+animatedGIF.h"
#import "ImageAnimator.h"
#import "ApplyEffectsViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSBundle *thisBundle = [NSBundle bundleForClass:[self class]];
    NSString *gifFilePath = [thisBundle pathForResource:@"bird_blue_flying" ofType:@"gif"];
    if (gifFilePath)
    {
        [self spinnerStartAnimating];

        [self proceedToSaveAndDisplayGif:[NSURL fileURLWithPath:gifFilePath]];
    }
}

- (IBAction) moveToNext:(id)sender
{
    NSString * storyboardIdentifier = @"Main";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardIdentifier bundle: nil];
    ApplyEffectsViewController *UIVC = [storyboard instantiateViewControllerWithIdentifier:@"ApplyEffectsViewController"];
    UIVC.sourceFilePath = self->sourceFilePath;
    [self.navigationController pushViewController:UIVC animated:true];
}

- (IBAction) showImagePickerForLibrary:(id)sender
{
    [newImageAnimator setStopPlayback:YES];
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusDenied)
    {
        [self showAccessNotForLibraryFoundAlert];
    }
    else
    {
        // asking for permission first if already permission is not allowed and show picker if allowed.
        if (status == PHAuthorizationStatusAuthorized) {
            // Present the picker if status found authorized.
            [self showImagePickerIfPermissionAllowed];
        }
        else
        {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                dispatch_async(dispatch_get_main_queue(), ^{
                   if (status == PHAuthorizationStatusAuthorized)
                    {
                        // Access has been granted.
                        [self showImagePickerIfPermissionAllowed];
                    }
                    else
                    {
                        // Access has been denied.
                        [self showAccessNotForLibraryFoundAlert];
                    }
                });
            }];
        }
    }
}

-(void) showAccessNotForLibraryFoundAlert
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UIAlertController *alertCont = [UIAlertController alertControllerWithTitle:@"Authorization Failure" message:@"It seems that you have denied GifHandler to access Photo Library. Please goto Settings and then allow access to Photos."  preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelButton = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil];
        
        UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:@"Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
                    
                }];
            });
        }];
        
        [alertCont addAction:cancelButton];
        [alertCont addAction:settingsAction];
        [self presentViewController:alertCont animated:true completion:nil];

    });
}

-(void)showImagePickerIfPermissionAllowed
{
    UIImagePickerController * picker = [UIImagePickerController new];
    picker.delegate = self;
    picker.allowsEditing = FALSE;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    PHAsset *imageAsset = [info objectForKey:UIImagePickerControllerPHAsset];
    if (imageAsset)
    {
        [self spinnerStartAnimating];
        
        NSString *orignalFileName = [imageAsset valueForKey:@"filename"];
        NSLog(@"orignalFileName: %@", orignalFileName);
        
        PHContentEditingInputRequestOptions *options = [[PHContentEditingInputRequestOptions alloc] init];
        options.networkAccessAllowed = YES; //download asset metadata from iCloud if needed

        [imageAsset requestContentEditingInputWithOptions:options completionHandler:^(PHContentEditingInput *contentEditingInput, NSDictionary *info) {
            
            BOOL bFileExist = false;
            NSURL *sourceFileURL = contentEditingInput.fullSizeImageURL;
            if (sourceFileURL)
                bFileExist = [[NSFileManager defaultManager] fileExistsAtPath:sourceFileURL.path];
            
            if (bFileExist)
            {
                [self proceedToSaveAndDisplayGif:sourceFileURL];
            }
            else
            {
                // Proceed to get it from request image data
                [self performSelectorInBackground:@selector(getCanvaseImageFromPHAssetIfURLNotFound:) withObject:imageAsset];
            }
        }];
        
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void) proceedToSaveAndDisplayGif: (NSURL *)sourceFileURL
{
    BOOL bFileExist = false;
    if (sourceFileURL)
        bFileExist = [[NSFileManager defaultManager] fileExistsAtPath:sourceFileURL.path];
    
    if (bFileExist)
    {
        NSString *sourceFileExtension = [sourceFileURL.pathExtension lowercaseString];
        if (![[sourceFileExtension lowercaseString] isEqualToString:@"gif"])
        {
            [self spinnerStopAnimating];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                UIAlertController *alertCont = [UIAlertController alertControllerWithTitle:@"Image Select" message:@"Select GIF image only to procced."  preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancelButton = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil];
                [alertCont addAction:cancelButton];
                [self presentViewController:alertCont animated:true completion:nil];

            });
            return;
        }
        
        CIImage *fullImage = [CIImage imageWithContentsOfURL:sourceFileURL];
        
        NSLog(@"%@", fullImage.properties.description);
        NSDictionary *metadata = [[NSMutableDictionary alloc] initWithDictionary:fullImage.properties];
        if (metadata)
            [self performSelectorInBackground:@selector(saveOriginalImageMetatData:) withObject:metadata];
        
        fullImage = nil;
        
        NSString *filePath = [AppDelegate getSaveOrigionalImagePath];
        NSString *sourceFilePathToWrite = [[filePath stringByDeletingPathExtension] stringByAppendingPathExtension:sourceFileExtension];
        
        [AppDelegate removeFilePathsAtPath:sourceFilePathToWrite];
        
        // Remove any other canvas image
        [AppDelegate DeleteCanavsSourceImage];
        
        // Stop spinner
        [self spinnerStopAnimating];
        
        NSError *error;
        BOOL bRes = [[NSFileManager defaultManager] copyItemAtURL:sourceFileURL toURL:[NSURL fileURLWithPath:sourceFilePathToWrite] error:&error];
        if (!bRes)
        {
            [self showImportFailureAlert];
            return;
        }
        
        [self performSelector:@selector(displayGifImageAtPath:) withObject:sourceFilePathToWrite afterDelay:0.3];
        
    }
    else
    {
        [self spinnerStopAnimating];
    }
}

- (void) getCanvaseImageFromPHAssetIfURLNotFound: (PHAsset *)imageAsset
{
    
    PHImageRequestOptions *requestOptions = [PHImageRequestOptions new];
    requestOptions.networkAccessAllowed = YES;
    
    [[PHImageManager defaultManager] requestImageDataForAsset:imageAsset options:requestOptions resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info)
    {
        
        if ([info objectForKey:PHImageErrorKey] == nil && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue])
        {
            if (imageData)
            {
                
                NSString *sourceFileExtension = [dataUTI.pathExtension lowercaseString];
                
                CGImageSourceRef source = CGImageSourceCreateWithData((CFMutableDataRef)imageData, NULL);
                NSDictionary *metadata = (NSDictionary *)CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(source,0,NULL));
                [self performSelectorInBackground:@selector(saveOriginalImageMetatData:) withObject:metadata];
                CFRelease(source);

                if (![[sourceFileExtension lowercaseString] isEqualToString:@"gif"])
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        UIAlertController *alertCont = [UIAlertController alertControllerWithTitle:@"Image Select" message:@"Select GIF image only to procced."  preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction *cancelButton = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil];
                        [alertCont addAction:cancelButton];
                        [self presentViewController:alertCont animated:true completion:nil];

                    });
                    return;
                }
                
                [self proceedForWriteGifAndMoveAhead:imageData];
                
            }
            else
            {
                [self showImportFailureAlert];
            }
            
            [self spinnerStopAnimating];
        }
        else
        {
            [self spinnerStopAnimating];
            
            if ([info objectForKey:PHImageErrorKey] != nil)
            {
                [self showImportFailureAlertWithMessage:[info objectForKey:PHImageErrorKey]];
                
            }
            else
            {
                [self showImportFailureAlertWithMessage:@"PHImageResultIsDegradedKey failed to get source image data"];
            }
        }
        
    }];
}

// Save the metadata of origional image
-(void) saveOriginalImageMetatData:(NSMutableDictionary*)imageMetadata
{
    @autoreleasepool
    {
        if (imageMetadata)
        {
            NSString *filePath = [AppDelegate getSaveOrigionalImageMataDataFilePath];
            if([[NSFileManager defaultManager] fileExistsAtPath:filePath])
                [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
            
            BOOL bRes = [imageMetadata writeToFile:filePath atomically:YES];
            if (!bRes)
            {
                NSLog(@"saveOriginalImageMetatData: Failed to write metadata.");
            }
        }
    }
}

-(void) proceedForWriteGifAndMoveAhead:(NSData*)imageSourceData
{
    NSString *sourcefilePath = [AppDelegate getSaveOrigionalImagePath];
    sourcefilePath = [[sourcefilePath stringByDeletingPathExtension] stringByAppendingPathExtension:@"gif"];
    [AppDelegate removeFilePathsAtPath:sourcefilePath];
    
    // Remove any other canvas image
    [AppDelegate DeleteCanavsSourceImage];
        
    BOOL bRes = [imageSourceData writeToFile:sourcefilePath atomically:true];
    if (!bRes)
    {
        [self showImportFailureAlert];
        
        return;
    }
    
    imageSourceData = nil;
    
    // For GIF images, we do not go to editing and preview screen
    [self performSelector:@selector(displayGifImageAtPath:) withObject:sourcefilePath afterDelay:0.3];
}

-(void) showImportFailureAlert
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"ERROR" message:@"Unable to get media file" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
        {
            
        }];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:true completion:nil];
        
    });
}

-(void) showImportFailureAlertWithMessage: (NSString*)errorMessage
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"ERROR" message:errorMessage preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
        {
            
        }];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:true completion:nil];
        
    });
}

- (void) spinnerStopAnimating
{
    dispatch_async(dispatch_get_main_queue(), ^{
    
        [self->pLoadingSpinner stopAnimating];
    });
}


- (void) spinnerStartAnimating
{
    dispatch_async(dispatch_get_main_queue(), ^{
    
        [self->pLoadingSpinner startAnimating];
    });
}


- (void) displayGifImageAtPath:(NSString*)sourceFilePath
{
    self->sourceFilePath = sourceFilePath;
    NSLog(@"SourcePath: %@", self->sourceFilePath);
    if (@available(iOS 13.0, *)) {
        
        newImageAnimator = [[ImageAnimator alloc] init];
        [newImageAnimator animateImageAtURL:[NSURL fileURLWithPath:sourceFilePath] onAnimate:^(UIImage * _Nullable img, NSError * _Nullable error) {
            
            if (!self->newImageAnimator.stopPlayback)
                self->pDisplayImageView.image = img;
        }];
    }
    else
    {
        pDisplayImageView.image = [UIImage animatedImageWithAnimatedGIFURL:[NSURL fileURLWithPath:sourceFilePath]];
    }
}

@end
