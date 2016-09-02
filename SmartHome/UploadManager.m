//
//  UploadFile.m
//  02.Post上传
//
//  Created by apple on 14-4-29.
//  Copyright (c) 2014年 itcast. All rights reserved.
//

#import "UploadManager.h"

@implementation UploadManager

+ (id)defaultManager {
    static UploadManager *sharedInstance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (void)uploadImage:(UIImage *) img url:(NSURL*) url completion:(void (^)())completion
{
    /*
    NSData *data = UIImagePNGRepresentation(img);
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setData:data  withFileName:@"tmp.png" andContentType:@"image/png" forKey:@"headimage"];
    [request startAsynchronous];
    [request setCompletionBlock:completion];
     */
}

- (void)uploadScene:(NSString *)sceneFile url:(NSURL*) url completion:(void (^)())completion
{
    
//    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
//    [request setFile:sceneFile forKey:@"scene"];
//    [request startAsynchronous];
//    [request setCompletionBlock:completion];
    
}

@end