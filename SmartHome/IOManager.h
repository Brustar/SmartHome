//
//  IOManager.h
//  SmartHome
//
//  Created by Brustar on 16/5/6.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Scene.h"
#import "PrintObject.h"

@interface IOManager : NSObject

+ (NSString *) scenesPath;
+ (NSString *) favoritePath;
+ (NSString *) sqlitePath;
+ (void) copyFile:(NSString *)file to:(NSString *)newFile;

+ (void) writeScene:(NSString *)sceneFile string:(NSString *)sceneData;
+ (void) writeScene:(NSString *)sceneFile dictionary:(NSDictionary *)sceneData;
+ (void) writeScene:(NSString *)sceneFile scene:(Scene *)sceneData;
+ (void) writeJpg:(UIImage *)jpg path:(NSString *)jpgPath;
+ (void) writePng:(UIImage *)png path:(NSString *)pngPath;
+ (void) removeFile:(NSString *)file;

@end
