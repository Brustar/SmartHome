//
//  IOManager.m
//  SmartHome
//
//  Created by Brustar on 16/5/6.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "IOManager.h"
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonDigest.h>
#import <RegexKitLite/RegexKitLite.h>

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

+ (NSString *)realScenePath {
    return [IOManager newPath:@"realScene"];
}

+ (NSString *)planeScenePath {
    return [IOManager newPath:@"planeScene"];
}

+ (NSString *)sceneShortcutsPath {
    return [IOManager newPath:@"sceneShortcuts"];
}

+ (NSString *)sceneNonShortcutsPath {
    return [IOManager newPath:@"sceneNonShortcuts"];
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

+ (void) writeScene:(NSString *)sceneFile scene:(id)sceneData
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
    BOOL ret = [defaultManager removeItemAtPath:file error: nil];
    NSAssert(ret,@"删除文件失败");
}

+ (BOOL) createFile:(NSString *)filePath {
    BOOL createFileSucceed = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    createFileSucceed = [fileManager createFileAtPath:filePath contents:nil attributes:nil];
    return createFileSucceed;
}

+(void) removeTempFile
{
    NSString *filePath=[NSString stringWithFormat:@"%@/%@_0.plist",[self scenesPath], SCENE_FILE_NAME];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:filePath] == YES){
        [self removeFile:filePath];
    }
}

+ (BOOL)createTempFile {
    BOOL createSucceed = NO;
    NSString *filePath=[NSString stringWithFormat:@"%@/%@_0.plist",[self scenesPath], SCENE_FILE_NAME];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:filePath] == NO){
        createSucceed = [self createFile:filePath];
    }
    
    return createSucceed;
}


+ (void) writeUserdefault:(id)object forKey:(NSString *)key
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (object) {
        [defaults setObject:object forKey:key];
        [defaults synchronize];
    }
}

+ (id)getUserDefaultForKey:(NSString *)key
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    return [ud objectForKey:key];
}

+ (NSString *) md5JsonByScenes:(NSString *)master
{
    NSString *temp = @"{";
    NSString *path =  [self scenesPath];
    NSFileManager *myFileManager=[NSFileManager defaultManager];
    
    NSDirectoryEnumerator *myDirectoryEnumerator;
    
    myDirectoryEnumerator=[myFileManager enumeratorAtPath:path];
    
    //列举目录内容，可以遍历子目录
    while((path=[myDirectoryEnumerator nextObject])!=nil)
    {
  
        if([path isMatchedByRegex:[NSString stringWithFormat:@"%@_\\d+\\.plist",master]])
        {
            NSLog(@"%@",path);
            temp =[temp stringByAppendingString:[NSString stringWithFormat:@"\"%@\":\"",path]];
            temp =[temp stringByAppendingString:[self fileMD5:[[self scenesPath] stringByAppendingPathComponent:path]]];
            temp =[temp stringByAppendingString:@"\","];
        }
    }
    
    if ([temp length]>1) {
        temp =[temp substringToIndex:temp.length-1];
    }
    
    return [temp stringByAppendingString:@"}"];
}

+ (NSString*) fileMD5:(NSString*)path
{
    return (__bridge_transfer NSString *)FileMD5HashCreateWithPath((__bridge CFStringRef)path, FileHashDefaultChunkSizeForReadingData);
}

CFStringRef FileMD5HashCreateWithPath(CFStringRef filePath,size_t chunkSizeForReadingData)
{
    // Declare needed variables
    CFStringRef result = NULL;
    CFReadStreamRef readStream = NULL;
    // Get the file URL
    CFURLRef fileURL =CFURLCreateWithFileSystemPath(kCFAllocatorDefault,
                                  (CFStringRef)filePath,
                                  kCFURLPOSIXPathStyle,
                                  (Boolean)false);
    if (!fileURL) goto done;
    // Create and open the read stream
    readStream = CFReadStreamCreateWithFile(kCFAllocatorDefault,(CFURLRef)fileURL);
    if (!readStream) goto done;
    bool didSucceed = (bool)CFReadStreamOpen(readStream);
    if (!didSucceed) goto done;
    // Initialize the hash object
    CC_MD5_CTX hashObject;
    CC_MD5_Init(&hashObject);
    // Make sure chunkSizeForReadingData is valid
    if (!chunkSizeForReadingData) {
        chunkSizeForReadingData = FileHashDefaultChunkSizeForReadingData;
    }
    
    // Feed the data to the hash object
    bool hasMoreData = true;
    while (hasMoreData) {
        uint8_t buffer[chunkSizeForReadingData];
        CFIndex readBytesCount = CFReadStreamRead(readStream,(UInt8 *)buffer,(CFIndex)sizeof(buffer));
        if (readBytesCount == -1) break;
        if (readBytesCount == 0) {
            hasMoreData = false;
            continue;
        }
        CC_MD5_Update(&hashObject,(const void *)buffer,(CC_LONG)readBytesCount);
    }
    
    // Check if the read operation succeeded
    didSucceed = !hasMoreData;
    // Compute the hash digest
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &hashObject);
    // Abort if the read operation failed
    if (!didSucceed) goto done;
    // Compute the string result
    char hash[2 * sizeof(digest) + 1];
    for (size_t i = 0; i < sizeof(digest); ++i) {
        snprintf(hash + (2 * i), 3, "%02x", (int)(digest[i]));
    }
    result = CFStringCreateWithCString(kCFAllocatorDefault,(const char *)hash,kCFStringEncodingUTF8);
    
done:
    if (readStream) {
        CFReadStreamClose(readStream);
        CFRelease(readStream);
    }
    if (fileURL) {
        CFRelease(fileURL);
    }
    return result;
}


@end
