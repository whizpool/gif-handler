//
//  AppDelegate.h
//  GifHandler
//
//  Created by Irfan Ali on 07/04/2020.
//  Copyright © 2020 Whizpool. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    
}

+ (NSString*) GetApplicationDirectory : (BOOL)bCreateDir;
+ (NSString*) getSaveOrigionalImageMataDataFilePath;
+ (NSString*) getSaveOrigionalImagePath;
+ (void) removeFilePathsAtPath: (NSString *)filePath;
+ (void) DeleteCanavsSourceImage;

@end

