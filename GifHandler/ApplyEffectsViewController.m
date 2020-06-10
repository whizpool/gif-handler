//
//  ApplyEffectsViewController.m
//  GifHandler
//
//  Created by Irfan Ali on 07/04/2020.
//  Copyright © 2020 Whizpool. All rights reserved.
//

#import "ApplyEffectsViewController.h"
#import "AppDelegate.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <Photos/Photos.h>

@interface ApplyEffectsViewController ()

@end

@implementation ApplyEffectsViewController

@synthesize sourceFilePath;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    gifMergingPathsBeforeMerge = [NSMutableArray new];
    gifMergingPathsAfterMerge = [NSMutableArray new];

    eFilterOption = eNone;
    
    [self updateSelectedView];
    
    self->pExportImageURL = [NSURL fileURLWithPath:self->sourceFilePath];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self spinnerStartAnimating];
    
    [self generateGifIndividualImagesWithCompletionBlock];
    
    if (gifMergingTotalIndex > 0)
    {
        NSDictionary *tDict = gifMergingPathsBeforeMerge[0];
        if (tDict && tDict.count > 0)
        {
            NSString *sourceImagePath = tDict[@"path"];
            NSString *displayImagePath = [[AppDelegate GetApplicationDirectory:YES] stringByAppendingPathComponent:GIF_DISPLAY_IMAGE_NAME];
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:displayImagePath])
                [[NSFileManager defaultManager] removeItemAtPath:displayImagePath error:nil];
            
            BOOL bSucess = [[NSFileManager defaultManager] copyItemAtPath:sourceImagePath toPath:displayImagePath error:nil];
            if (bSucess)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self->pImageView.image = [UIImage imageWithContentsOfFile:displayImagePath];
                });
            }
        }
    }
    
    [self spinnerStopAnimating];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void) updateSelectedView
{
    if (eFilterOption == eNone)
    {
        pOriginalImageView.image = [UIImage imageNamed:@"borderdBGSelected"];
        pSepiaImageView.image = [UIImage imageNamed:@"borderdBG"];
        pPhotoEffectImageView.image = [UIImage imageNamed:@"borderdBG"];
        pSpotColorImageView.image = [UIImage imageNamed:@"borderdBG"];
    }
    else if (eFilterOption == eSepia)
    {
        pOriginalImageView.image = [UIImage imageNamed:@"borderdBG"];
        pSepiaImageView.image = [UIImage imageNamed:@"borderdBGSelected"];
        pPhotoEffectImageView.image = [UIImage imageNamed:@"borderdBG"];
        pSpotColorImageView.image = [UIImage imageNamed:@"borderdBG"];
    }
    else if (eFilterOption == ePhotoEffect)
    {
        pOriginalImageView.image = [UIImage imageNamed:@"borderdBG"];
        pSepiaImageView.image = [UIImage imageNamed:@"borderdBG"];
        pPhotoEffectImageView.image = [UIImage imageNamed:@"borderdBGSelected"];
        pSpotColorImageView.image = [UIImage imageNamed:@"borderdBG"];
    }
    else if (eFilterOption == eSpotColor)
    {
        pOriginalImageView.image = [UIImage imageNamed:@"borderdBG"];
        pSepiaImageView.image = [UIImage imageNamed:@"borderdBG"];
        pPhotoEffectImageView.image = [UIImage imageNamed:@"borderdBG"];
        pSpotColorImageView.image = [UIImage imageNamed:@"borderdBGSelected"];
    }
}

- (IBAction) applyOriginalEffect:(id)sender
{
    [self spinnerStartAnimating];
    
    eFilterOption = eNone;
    [self updateSelectedView];
    
    self->pExportImageURL = [NSURL fileURLWithPath:self->sourceFilePath];
    
    NSDictionary *tDict = gifMergingPathsBeforeMerge[0];
    if (tDict && tDict.count > 0)
    {
        NSString *sourceImagePath = tDict[@"path"];
        NSString *displayImagePath = [[AppDelegate GetApplicationDirectory:YES] stringByAppendingPathComponent:GIF_DISPLAY_IMAGE_NAME];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:displayImagePath])
            [[NSFileManager defaultManager] removeItemAtPath:displayImagePath error:nil];
        
        BOOL bSucess = [[NSFileManager defaultManager] copyItemAtPath:sourceImagePath toPath:displayImagePath error:nil];
        if (bSucess)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                self->pImageView.image = [UIImage imageWithContentsOfFile:displayImagePath];
            });
        }
    }
    
    [self spinnerStopAnimating];
}

- (IBAction) applySepiaEffect:(id)sender
{
    [self spinnerStartAnimating];
    
    eFilterOption = eSepia;
    
    [self updateSelectedView];
    
    [self mergeGifCurrentIndexWithCompletionBlock:^(NSURL *doneAtUrl) {
        
        // Final url of gif
        self->pExportImageURL = doneAtUrl;
        [self spinnerStopAnimating];
    }];
}

- (IBAction) applyPhotoEffect:(id)sender
{
    [self spinnerStartAnimating];
    
    eFilterOption = ePhotoEffect;
    
    [self updateSelectedView];
    
    [self mergeGifCurrentIndexWithCompletionBlock:^(NSURL *doneAtUrl) {
        
        // Final url of gif
        self->pExportImageURL = doneAtUrl;
        [self spinnerStopAnimating];
    }];
}

- (IBAction) applySpotColorEffect:(id)sender
{
    [self spinnerStartAnimating];
    
    eFilterOption = eSpotColor;
    
    [self updateSelectedView];
    
    [self mergeGifCurrentIndexWithCompletionBlock:^(NSURL *doneAtUrl) {
        
        // Final url of gif
        self->pExportImageURL = doneAtUrl;
        [self spinnerStopAnimating];
    }];
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

-(void) generateGifIndividualImagesWithCompletionBlock {
    
    [gifMergingPathsAfterMerge removeAllObjects];
    gifMergingCurrentIndex = 0;
    
    if (sourceFilePath)
    {
        NSURL *gifURL = [NSURL fileURLWithPath:sourceFilePath];
        NSFileManager *pFileManager = [NSFileManager defaultManager];
        if (![pFileManager fileExistsAtPath:[gifURL path]])
        {
            return;
        }
        
        gifMergingPathsBeforeMerge = [self animatedSequenceOfImagesOfGIFImageURL:gifURL];
        gifMergingTotalIndex = (int)gifMergingPathsBeforeMerge.count;
    }

}

-(NSMutableArray *) animatedSequenceOfImagesOfGIFImageURL: (NSURL *)gifURL
{
    NSMutableArray* images = [[NSMutableArray alloc] init];
    
    NSData *imageData = [NSData dataWithContentsOfURL:gifURL];
    if (imageData)
    {
        CGImageSourceRef source = CGImageSourceCreateWithData((CFDataRef)imageData, nil);
        size_t imagesCount = CGImageSourceGetCount(source);
         
        NSString *pathDirectory = [[AppDelegate GetApplicationDirectory:YES] stringByAppendingPathComponent:GIF_BEFORE_MERGE_DIR_NAME];
        
        bool isDir;
        if ([[NSFileManager defaultManager] fileExistsAtPath:pathDirectory isDirectory:&isDir])
             [[NSFileManager defaultManager] removeItemAtPath:pathDirectory error:nil];
        
        NSError *error;
        BOOL bDirCreated = [[NSFileManager defaultManager] createDirectoryAtPath:pathDirectory withIntermediateDirectories:NO attributes:nil error:&error];
        if (bDirCreated)
        {
            pathDirectory = [pathDirectory stringByAppendingPathComponent:GIF_BEFORE_MERGE_IMAGE_NAME];
            
            for (size_t i = 0; i<imagesCount; i++) {
                CGImageRef cgImage = CGImageSourceCreateImageAtIndex(source, i, nil);
                NSString *writePath = [NSString stringWithFormat:@"%@-%lu.jpg",pathDirectory,i+1];
                BOOL isWritten = [self CGImageWriteToFile:cgImage andPathString:writePath];
                int delay = delayCentisecondsForGifImageAtIndex(source, i);
                if (isWritten)
                {
                    [images addObject:@{@"path":writePath, @"duration":[NSNumber numberWithInt:delay]}];
                }
            }
        }
        else
        {
            NSLog(@"GIF_AnimatedImages : Unable to create gifProcessing dir [%@].", error.localizedDescription);
        }
         
    }
    else
    {
        NSLog(@"GIF_AnimatedImages : Orgional Image data not found.");
    }

    return images;
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

-(void) mergeGifCurrentIndexWithCompletionBlock:(void (^)(NSURL *doneAtUrl))completionBlock{
    
    if (gifMergingCurrentIndex == 0)
    {
        NSString *pathDirectory = [[AppDelegate GetApplicationDirectory:YES] stringByAppendingPathComponent:GIF_AFTER_MERGE_DIR_NAME];
        
        bool isDir;
        if ([[NSFileManager defaultManager] fileExistsAtPath:pathDirectory isDirectory:&isDir])
             [[NSFileManager defaultManager] removeItemAtPath:pathDirectory error:nil];
        
        NSError *error;
        BOOL bDirCreated = [[NSFileManager defaultManager] createDirectoryAtPath:pathDirectory withIntermediateDirectories:NO attributes:nil error:&error];
        if (!bDirCreated)
        {
            NSLog(@"mergeGifCurrentIndexWithCompletionBlock : Failed to create processing directory.");
            [self showImportFailureAlertWithMessage:@" Failed to create processing directory"];
            completionBlock(nil);
        }
    }
    
    if (gifMergingCurrentIndex < gifMergingTotalIndex)
    {
        NSDictionary *tDict = gifMergingPathsBeforeMerge[gifMergingCurrentIndex];
        if (tDict && tDict.count > 0)
        {
            NSURL *writtenPath = [self mergeEffectsInSourceImageFromURL:[NSURL fileURLWithPath:tDict[@"path"]]];
            if (writtenPath)
            {
                NSString *duration = tDict[@"duration"] ? tDict[@"duration"] : @"0";
                [gifMergingPathsAfterMerge addObject:@{@"path":writtenPath.path, @"delay":duration}];
            }
            else
            {
               NSLog(@"GIF_mergeGifCurrentIndex: Merge failed at index %d from total count %d.", gifMergingCurrentIndex, gifMergingTotalIndex);
            }
            
            gifMergingCurrentIndex += 1;
            [self performSelector:@selector(mergeGifCurrentIndexWithCompletionBlock:) withObject:completionBlock afterDelay:0.1];
        }
        else
        {
            // Check for the next index if its data is available or not
            NSLog(@"GIF_mergeGifCurrentIndex: Data at index %d from total count %d not found.", gifMergingCurrentIndex, gifMergingTotalIndex);
            //completionBlock(nil);
            gifMergingCurrentIndex += 1;
            [self performSelector:@selector(mergeGifCurrentIndexWithCompletionBlock:) withObject:completionBlock afterDelay:0.1];
        }
    }
    else
    {
        NSURL *gifFinalURL =  [self makeAnimatedGifWithImagesArray:gifMergingPathsAfterMerge];
        completionBlock(gifFinalURL);
        
        gifMergingCurrentIndex = 0;
        [gifMergingPathsAfterMerge removeAllObjects];
    }
}

-(NSURL *) makeAnimatedGifWithImagesArray: (NSMutableArray *)imgArray {
    
    NSUInteger kFrameCount = imgArray.count;
    NSDictionary *fileProperties = @{
                                     (__bridge id)kCGImagePropertyGIFDictionary: @{
                                             (__bridge id)kCGImagePropertyGIFLoopCount: @0, // 0 means loop forever
                                             (__bridge id)kCGImagePropertyGIFHasGlobalColorMap: [NSNumber numberWithBool:NO]
                                             }
                                     };
    
    NSURL *appDirectoryURL = [NSURL fileURLWithPath:[AppDelegate GetApplicationDirectory:YES]];
    NSURL *fileURL = [appDirectoryURL URLByAppendingPathComponent:GIF_IMAGE_FINAL_NAME];
    
    CGImageDestinationRef destination = CGImageDestinationCreateWithURL((__bridge CFURLRef)fileURL, kUTTypeGIF, kFrameCount, NULL);
    
    CGImageDestinationSetProperties(destination, (__bridge CFDictionaryRef)fileProperties);
    
    for (NSUInteger i = 0; i < kFrameCount; i++) {
            NSLog(@"%@",imgArray[i]);
            NSDictionary *tempDict = imgArray[i];
            int delay = [tempDict[@"delay"] intValue];
            NSString *path = tempDict[@"path"];
            float deleyInCenti = (float)delay/100.0;
        
        
            NSDictionary *frameProperties = @{
                                              (__bridge id)kCGImagePropertyGIFDictionary: @{
                                                      (__bridge id)kCGImagePropertyGIFDelayTime: [NSNumber numberWithFloat:deleyInCenti] // a float (not double!) in seconds, rounded to centiseconds in the GIF data
                                                      }
                                              };
        
        UIImage *image = [UIImage imageWithContentsOfFile:path];
        CGImageDestinationAddImage(destination, image.CGImage, (__bridge CFDictionaryRef)frameProperties);
    }
    
    if (!CGImageDestinationFinalize(destination)) {
        NSLog(@"failed to finalize image destination");
    }
    
    CFRelease(destination);
    
    
    NSDictionary *tDict = imgArray[0];
    NSString *sourceImagePath = tDict[@"path"];
    NSString *displayImagePath = [[AppDelegate GetApplicationDirectory:YES] stringByAppendingPathComponent:GIF_DISPLAY_IMAGE_NAME];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:displayImagePath])
        [[NSFileManager defaultManager] removeItemAtPath:displayImagePath error:nil];
    
    BOOL bSucess = [[NSFileManager defaultManager] copyItemAtPath:sourceImagePath toPath:displayImagePath error:nil];
    if (bSucess)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            self->pImageView.image = [UIImage imageWithContentsOfFile:displayImagePath];
        });
    }
    
    NSString *pathDirectory = [[AppDelegate GetApplicationDirectory:YES] stringByAppendingPathComponent:GIF_AFTER_MERGE_DIR_NAME];
    if ([[NSFileManager defaultManager]fileExistsAtPath:pathDirectory])
        [[NSFileManager defaultManager]removeItemAtPath:pathDirectory error:nil];
    
    return fileURL;
}

-(BOOL)CGImageWriteToFile:(CGImageRef)image andPathString:(NSString *)path {
    CFURLRef url = (__bridge CFURLRef)[NSURL fileURLWithPath:path];
    CGImageDestinationRef destination = CGImageDestinationCreateWithURL(url, kUTTypeJPEG, 1, NULL);
    if (!destination) {
        NSLog(@"Failed to create CGImageDestination for %@", path);
        return NO;
    }
    
    CGImageDestinationAddImage(destination, image, nil);
    
    if (!CGImageDestinationFinalize(destination)) {
        NSLog(@"Failed to write image to %@", path);
        CFRelease(destination);
        return NO;
    }
    
    CFRelease(destination);
    return YES;
}

#define fromCF (__bridge id)
int delayCentisecondsForGifImageAtIndex(CGImageSourceRef const source, size_t const i) {
    int delayCentiseconds = 1;
    CFDictionaryRef const properties = CGImageSourceCopyPropertiesAtIndex(source, i, NULL);
    if (properties) {
        CFDictionaryRef const gifProperties = CFDictionaryGetValue(properties, kCGImagePropertyGIFDictionary);
        if (gifProperties) {
            NSNumber *number = fromCF CFDictionaryGetValue(gifProperties, kCGImagePropertyGIFUnclampedDelayTime);
            if (number == NULL || [number doubleValue] == 0) {
                number = fromCF CFDictionaryGetValue(gifProperties, kCGImagePropertyGIFDelayTime);
            }
            if ([number doubleValue] > 0) {
                // Even though the GIF stores the delay as an integer number of centiseconds, ImageIO “helpfully” converts that to seconds for us.
                delayCentiseconds = (int)lrint([number doubleValue] * 100);
            }
        }
        CFRelease(properties);
    }
    return delayCentiseconds;
}


-(NSURL *) mergeEffectsInSourceImageFromURL:(NSURL*)fromURL
{
    NSURL *preparedFileURL = nil;
    if (fromURL)
    {
        // Directly loading CIImage from URL may contain invalid orientation,thats why we need to change it to UIImage and then CIImage.
        UIImage *imageObjectBeforeMerge = [[UIImage alloc] initWithContentsOfFile:fromURL.path];
        if (imageObjectBeforeMerge)
        {
            CIImage *ciImageToMerge = [[CIImage alloc] initWithImage:imageObjectBeforeMerge];
            
            // If image orientation is not correct, then we need to fix it
            if (imageObjectBeforeMerge.imageOrientation != UIImageOrientationUp)
            {
                ciImageToMerge = [ciImageToMerge imageByApplyingOrientation:[self getCoreImageOrientationFromUIImage:imageObjectBeforeMerge.imageOrientation]];
            }
            
            if (eFilterOption ==  eSepia)
            {
                ciImageToMerge = [self sepiaFilterImage:ciImageToMerge withIntensity:0.9];
            }
            else if (eFilterOption ==  ePhotoEffect)
            {
                ciImageToMerge = [self photoEffectFilterImage:ciImageToMerge];
            }
            else if (eFilterOption ==  eSpotColor)
            {
                ciImageToMerge = [self spotColorFilterImage:ciImageToMerge];
            }
            
            NSString *pathDirectory = [[AppDelegate GetApplicationDirectory:YES] stringByAppendingPathComponent:GIF_AFTER_MERGE_DIR_NAME];
            NSString *tempWritePath = [pathDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%d.jpg", GIF_AFTER_MERGE_IMAGE_NAME, gifMergingCurrentIndex+1]];
           
            //Check and remove file if already exist at path.
            if ([[NSFileManager defaultManager] fileExistsAtPath:tempWritePath])
            {
                [[NSFileManager defaultManager] removeItemAtPath:tempWritePath error:nil];
            }
            
            [self saveCIImageToPath:ciImageToMerge atPath:tempWritePath];
            
            imageObjectBeforeMerge = nil;
            ciImageToMerge = nil;
            
            preparedFileURL = [NSURL fileURLWithPath:tempWritePath];
        }
        else
        {
            NSLog(@"MergeInCanvasImage: Merge source image not found.");
        }
    }
    
    return preparedFileURL;
}

-(BOOL) saveCIImageToPath:(CIImage*)ciImageToMerge atPath:(NSString *)filePath {

    BOOL bSuccess = false;
    if (CGRectIsEmpty(ciImageToMerge.extent))
    {
        return bSuccess;
    }
        
    CIContext *context = [CIContext contextWithOptions:nil];

    CGImageRef imageRef = [context createCGImage:ciImageToMerge fromRect:ciImageToMerge.extent];

    ciImageToMerge = [CIImage imageWithCGImage:imageRef];
    CFRelease(imageRef);
    
    NSURL *urlToWrite = [NSURL fileURLWithPath:filePath];

    // Apply meta data if available
    NSDictionary *metaData = (NSDictionary *)[self getMutableMetaDataFromPath];
    if (metaData)
    {
        ciImageToMerge = [ciImageToMerge imageBySettingProperties:metaData];
    }
        
    // for jpeg Images,we need to write jpeg directly from context to URL as for jpeg methods is available in iOS 10 and later.
    // We got a jpg,jpeg image,write it directly through CIContext writeJPEGRepresentationOfImage method by providing a temp URL.
    // Apply quality from setting's slider to write jpeg's with compressed quality.
    NSDictionary* compressOptions = @{ (__bridge NSString*)kCGImageDestinationLossyCompressionQuality : [NSNumber numberWithFloat:1.0] };
        
    NSError *jpgError = nil;
    BOOL bRes = [context writeJPEGRepresentationOfImage:ciImageToMerge toURL:urlToWrite colorSpace:CGColorSpaceCreateDeviceRGB() options:compressOptions error:&jpgError];
    if (!bRes || jpgError)
    {
        NSLog(@"BULKSAVE_PATH_saveCIImageToPath_Error: %@", jpgError.localizedDescription);
    }
    else
    {
        // Image is written successfully
        bSuccess = true;
    }
        
    context = nil;
    return bSuccess;
}

-(NSMutableDictionary*) getMutableMetaDataFromPath
{
    NSString *filePath = [AppDelegate getSaveOrigionalImageMataDataFilePath];
    NSMutableDictionary *metaDataMutable = [[NSMutableDictionary alloc]initWithContentsOfFile:filePath];

    [metaDataMutable setValue:[NSNumber numberWithInt:1] forKey:@"Orientation"];
    
    if (metaDataMutable[@"{TIFF}"])
    {
        metaDataMutable[@"{TIFF}"][@"Orientation"] = [NSNumber numberWithInt:1];
    }
    
    return metaDataMutable;
}

- (NSString *) getFileNameToSave
{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"dd-MM-yyyy_hh-mm-ssa"];
    NSString *savingDate = [dateFormatter stringFromDate:[NSDate date]];
    
    NSString *csFileNameToSave = @"";
    csFileNameToSave = [csFileNameToSave stringByAppendingFormat:@"%@_%@.jpg", @"gifhandler", savingDate];
    
    return csFileNameToSave;
}

- (int)getCoreImageOrientationFromUIImage:(UIImageOrientation)orientation
{
    
    // CoreImage correnpondence value for rotation parallel to UIImage.
    if (orientation == UIImageOrientationUp )
    {
        return 1;
    }
    else if (orientation == UIImageOrientationDown)
    {
        return 3;
    }
    else if (orientation == UIImageOrientationLeft)
    {
        return 8;
    }
    else if (orientation == UIImageOrientationRight)
    {
        return 6;
    }
    else if (orientation == UIImageOrientationUpMirrored)
    {
        return 2;
    }
    else if (orientation == UIImageOrientationDownMirrored)
    {
        return 4;
    }
    else if (orientation == UIImageOrientationLeftMirrored)
    {
        return 5;
    }
    else
    {
        return 7;
    }
}

- (CIImage*) sepiaFilterImage: (CIImage*)inputImage withIntensity:(CGFloat)intensity
{
    CIFilter* sepiaFilter = [CIFilter filterWithName:@"CISepiaTone"];
    [sepiaFilter setValue:inputImage forKey:kCIInputImageKey];
    [sepiaFilter setValue:@(intensity) forKey:kCIInputIntensityKey];
    return sepiaFilter.outputImage;
}

- (CIImage*) photoEffectFilterImage: (CIImage*)inputImage
{
    
    CIFilter* photoEffectFilter = [CIFilter filterWithName:@"CIPhotoEffectTransfer"];
    [photoEffectFilter setValue:inputImage forKey:kCIInputImageKey];
    return photoEffectFilter.outputImage;
}

- (CIImage*) spotColorFilterImage: (CIImage*)inputImage
{
    CIFilter* spotColorFilter = [CIFilter filterWithName:@"CISpotColor"];
    [spotColorFilter setValue:inputImage forKey:kCIInputImageKey];
    return spotColorFilter.outputImage;
    
}

-(IBAction) saveImagetoLibrary:(id)sender
{
    [self spinnerStartAnimating];
    
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        [PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:self->pExportImageURL];
    } completionHandler:^(BOOL success, NSError *error) {
        
        [self spinnerStopAnimating];
        
        if (success) {
            
            NSLog(@"Success");
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"SUCCESS" message:@"Image saved in Photo Library" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                {
                    
                }];
                [alertController addAction:okAction];
                [self presentViewController:alertController animated:true completion:nil];
            });
            
        }
        else {
            NSLog(@"write error : %@",error);
            [self showImportFailureAlertWithMessage:[NSString stringWithFormat:@"Failed to save image with error %@", error.localizedDescription]];
        }
    }];
    
}


@end
