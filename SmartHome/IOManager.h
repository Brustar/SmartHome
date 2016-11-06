//
//  IOManager.h
//  SmartHome
//
//  Created by Brustar on 16/5/6.
//  Copyright © 2016年 Brustar. All rights reserved.
//
#import "Scene.h"
#import "PrintObject.h"

#define FileHashDefaultChunkSizeForReadingData 1024*8

@interface IOManager : NSObject

+ (NSString *) scenesPath;
+ (NSString *) favoritePath;
+ (NSString *) sqlitePath;
+ (NSString *) httpAddr;
+ (NSString *) tcpAddr;

+ (int) tcpPort;
+ (int) udpPort;

+ (id)getUserDefaultForKey:(NSString *)key;

+ (void) writeScene:(NSString *)sceneFile string:(NSString *)sceneData;
+ (void) writeScene:(NSString *)sceneFile dictionary:(NSDictionary *)sceneData;
+ (void) writeScene:(NSString *)sceneFile scene:(Scene *)sceneData;
+ (void) writeJpg:(UIImage *)jpg path:(NSString *)jpgPath;
+ (void) writePng:(UIImage *)png path:(NSString *)pngPath;
+ (void) removeFile:(NSString *)file;
+ (void) removeTempFile;
+ (void) writeUserdefault:(id)object forKey:(NSString *)key;
+ (NSString*) fileMD5:(NSString*)path;

@end
