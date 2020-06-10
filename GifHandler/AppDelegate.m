//
//  AppDelegate.m
//  GifHandler
//
//  Created by Irfan Ali on 07/04/2020.
//  Copyright © 2020 Whizpool. All rights reserved.
//

#import "AppDelegate.h"


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    return YES;
}


+ (NSString*) GetApplicationDirectory : (BOOL)bCreateDir
{
    NSString *pGifHandlerAppDirectory = @"";
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    if ([paths count] > 0)
    {
        NSString *libraryDirectory = [paths objectAtIndex:0];
        pGifHandlerAppDirectory = [libraryDirectory stringByAppendingPathComponent:@"GifHandler"];
        if (bCreateDir)
        {
            NSFileManager *pFileManager = [NSFileManager defaultManager];
            if (![pFileManager fileExistsAtPath:pGifHandlerAppDirectory])
            {
                BOOL bCreated = [pFileManager createDirectoryAtPath:pGifHandlerAppDirectory withIntermediateDirectories:NO attributes:nil error:nil];
                if (bCreated)
                {
                    NSError *error = nil;
                    BOOL success = [[NSURL fileURLWithPath:pGifHandlerAppDirectory] setResourceValue: [NSNumber numberWithBool: YES] forKey: NSURLIsExcludedFromBackupKey error: &error];
                    if(!success)
                        NSLog(@"Error excluding %@ from backup %@", @"GifHandler", error);
                }
                else
                    NSLog(@"Failed to create %@ directory", @"GifHandler");
            }
        }
    }
    
    return pGifHandlerAppDirectory;
}

+ (NSString*) getSaveOrigionalImageMataDataFilePath
{
    NSString *appDir = [AppDelegate GetApplicationDirectory:YES];
    NSString *filePath = [appDir stringByAppendingPathComponent:@"canvas_hd_image_metadata.bin"];
    return filePath;
}

+ (NSString*) getSaveOrigionalImagePath
{
    NSString *appDir = [AppDelegate GetApplicationDirectory:YES];
    NSString *filePath = [appDir stringByAppendingPathComponent:@"canvas_hd_image.gif"];
    return filePath;
}

+ (void) removeFilePathsAtPath: (NSString *)filePath
{
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath])
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
}

+ (void) DeleteCanavsSourceImage
{
    NSString* pAppDir = [AppDelegate GetApplicationDirectory:YES];
    
    NSError *error = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *files = [fileManager contentsOfDirectoryAtPath:pAppDir error:&error];
    for (NSString *csFileName in files)
    {
        // Delete kCanvasHDImagePrefix image as we are going to add new one
        if (csFileName && ([csFileName hasPrefix:@"canvas_hd_image"]) && (![csFileName isEqualToString:@"canvas_hd_image_metadata.bin"]))
        {
            NSString *imagePath = [pAppDir stringByAppendingPathComponent:csFileName];
            if([[NSFileManager defaultManager] fileExistsAtPath:imagePath])
            {
                BOOL bRes = [[NSFileManager defaultManager] removeItemAtPath:imagePath error:nil];
                if(!bRes)
                    NSLog(@"DeleteAllNotRequiredCanavsImages deletion failed");
            }
            
        }
    }
}

#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
