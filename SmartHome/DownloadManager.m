#import "DownloadManager.h"

@interface DownloadManager ()


@end

@implementation DownloadManager

+ (id)defaultManager {
    static DownloadManager *sharedInstance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

#pragma mark-下载文件
//演示1
-(void)download:(NSURL *)url
{
    
}

//演示2
-(void)download:(NSURL *)url completion:(void (^)())completion
{

}

@end