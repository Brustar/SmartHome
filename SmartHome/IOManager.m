//
//  IOManager.m
//  SmartHome
//
//  Created by Brustar on 16/5/6.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "IOManager.h"

@implementation IOManager

+(NSString *)newPath:(NSString *)path
{
    NSString *docPath=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];//NSHomeDirectory();
    NSString *scenesPath=[docPath stringByAppendingPathComponent:path];
    BOOL ret = [[NSFileManager defaultManager] createDirectoryAtPath:scenesPath withIntermediateDirectories:YES attributes:nil error:nil];
    NSAssert(ret,@"创建目录失败");
    return scenesPath;
}

+ (NSString *) scenesPath
{
    return [IOManager newPath:@"scenes"];
}




+ (NSString *) favoritePath
{
    return [IOManager newPath:@"favorite"];
}

+ (NSString *) sqlitePath
{
    return [IOManager newPath:@"db"];
}

+ (NSString *) httpAddr
{
    NSString *path=[[NSBundle mainBundle] pathForResource:@"netconfig" ofType:@"plist"];
    NSDictionary *dic = [[NSDictionary alloc] initWithContentsOfFile:path];
    NSString *server= [NSString stringWithFormat:@"http://%@" , dic[@"httpServer"]];
    int port=[dic[@"httpPort"] intValue];
    if(port == 0 || port == 80){
        return server;
    }
    return [NSString stringWithFormat:@"%@:%d/",server,port];
}

+ (NSString *) tcpAddr
{
    NSString *path=[[NSBundle mainBundle] pathForResource:@"netconfig" ofType:@"plist"];
    NSDictionary *dic = [[NSDictionary alloc] initWithContentsOfFile:path];
    return [NSString stringWithFormat:@"%@",dic[@"tcpServer"]];
}

+ (int) tcpPort
{
    NSString *path=[[NSBundle mainBundle] pathForResource:@"netconfig" ofType:@"plist"];
    NSDictionary *dic = [[NSDictionary alloc] initWithContentsOfFile:path];
    return [dic[@"tcpPort"] intValue];
}

+ (int) udpPort
{
    NSString *path=[[NSBundle mainBundle] pathForResource:@"netconfig" ofType:@"plist"];
    NSDictionary *dic = [[NSDictionary alloc] initWithContentsOfFile:path];
    return [dic[@"udpPort"] intValue];
}

+ (void) copyFile:(NSString *)file to:(NSString *)newFile
{
    NSString *path = [[NSBundle mainBundle] pathForResource:file ofType:@""];
    NSString *newPath=[[IOManager sqlitePath] stringByAppendingPathComponent:newFile];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:newPath]== NO){
        NSError *error;
        [fileManager copyItemAtPath:path toPath:newPath error:&error];
        NSLog(@"%@",error);
    }
}

+ (void) writeScene:(NSString *)sceneFile string:(NSString *)sceneData
{
    NSString *scenePath=[[IOManager scenesPath] stringByAppendingPathComponent:sceneFile];
    BOOL ret = [sceneData writeToFile:scenePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    NSAssert(ret,@"写文件失败");
}

+ (void) writeScene:(NSString *)sceneFile dictionary:(NSDictionary *)sceneData
{
    NSString *scenePath=[[IOManager scenesPath] stringByAppendingPathComponent:sceneFile];
    BOOL ret = [sceneData writeToFile:scenePath atomically:YES];
    NSAssert(ret,@"写文件失败");
}

+ (void) writeScene:(NSString *)sceneFile scene:(Scene *)sceneData
{
    NSString *scenePath=[[IOManager scenesPath] stringByAppendingPathComponent:sceneFile];
    NSDictionary *dic = [PrintObject getObjectData:sceneData];
    BOOL ret = [dic writeToFile:scenePath atomically:YES];
    NSAssert(ret,@"写文件失败");
}



+ (void) writeJpg:(UIImage *)jpg path:(NSString *)jpgPath
{
    NSString *path=[[IOManager scenesPath] stringByAppendingPathComponent:jpgPath];
    BOOL ret = [UIImageJPEGRepresentation(jpg, 1.0) writeToFile:path atomically:YES];
    NSAssert(ret,@"写JPEG失败");
}

+ (void) writePng:(UIImage *)png path:(NSString *)pngPath
{
    NSString *path=[[IOManager scenesPath] stringByAppendingPathComponent:pngPath];
    BOOL ret = [UIImagePNGRepresentation(png) writeToFile:path atomically:YES];
    NSAssert(ret,@"写PNG失败");
}

+ (void) removeFile:(NSString *)file
{
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    BOOL ret=[defaultManager removeItemAtPath:file error: nil];
    NSAssert(ret,@"删除文件失败");
}

+(void) removeTempFile
{
    NSString *filePath=[NSString stringWithFormat:@"%@/%@_0.plist",[self scenesPath], SCENE_FILE_NAME];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:filePath] == YES){
        [self removeFile:filePath];
    }
}

+ (void) writeUserdefault:(id)object forKey:(NSString *)key
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:object forKey:key];
    [defaults synchronize];
}


@end
