#import "DownloadManager.h"
#import "ASIHTTPRequest.h"

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
{    //1.创建请求对象
    ASIHTTPRequest *request=[ASIHTTPRequest requestWithURL:url];
    
    //2.添加请求参数（请求体中的参数）
    [request setDataReceivedBlock:^(NSData *data) {
        NSLog(@"%lu",(unsigned long)data.length);
    }];
    
    //3.异步发送网络请求
    [request startAsynchronous];
}

//演示2
-(void)download:(NSURL *)url completion:(void (^)())completion
{
    //1.创建请求对象
    ASIHTTPRequest *request=[ASIHTTPRequest requestWithURL:url];
    
    //2.设置下载文件保存的路径
    NSString *cachepath=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject];
    NSString *filename=[cachepath stringByAppendingPathComponent:[[url absoluteString] lastPathComponent]];
    request.downloadDestinationPath=filename;
    
    //3.发送网络请求（异步）
    [request startAsynchronous];
    
    //4.当下载完成后通知
    [request setCompletionBlock:completion];
}

@end