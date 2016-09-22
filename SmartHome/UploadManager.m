 //
//  UploadFile.m
//  02.Post上传
//
//  Created by apple on 14-4-29.
//  Copyright (c) 2014年 itcast. All rights reserved.
//

#import "UploadManager.h"
#import <AFNetworking.h>
#import "MBProgressHUD+NJ.h"
@implementation UploadManager

+ (instancetype)defaultManager {
    static UploadManager *sharedInstance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}



- (void)uploadImage:(UIImage *) img url:(NSString *) url dic:(NSDictionary *)dic fileName:(NSString *)fileName completion:(void (^)(id responseObject))completion
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    // 实际上就是AFN没有对响应数据做任何处理的情况
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    // formData是遵守了AFMultipartFormData的对象
    [manager POST:url parameters:dic constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        // 将本地的文件上传至服务器
        [formData appendPartWithFileData:UIImagePNGRepresentation(img) name:@"ImgFile" fileName:fileName mimeType:@"multipart/form-data"];
    } progress:nil success:^(NSURLSessionDataTask *operation, id responseObject) {
        
        //NSString *result = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
       
        id result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        int resultValue =[result[@"Result"] intValue];
        NSLog(@"完成 %d", resultValue);
        if (resultValue == 0) {
            completion(result);
        }else{
            [MBProgressHUD showError:result[@"Msg"]];
        }
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        NSLog(@"错误 %@", error.localizedDescription);
    }];
}


- (void)uploadScene:(NSData *)sceneData url:(NSString *) url dic:(NSDictionary *)dic fileName:(NSString *)fileName imgData:(NSData *)imgData imgFileName:(NSString *)imgFileName completion:(void (^)(id responseObject))completion

{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    // 实际上就是AFN没有对响应数据做任何处理的情况
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    // formData是遵守了AFMultipartFormData的对象
    [manager POST:url parameters:dic constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        // 将本地的文件上传至服务器
        if(sceneData)
        {
            [formData appendPartWithFileData:sceneData name:@"ScenceFile" fileName:fileName mimeType:@"multipart/form-data"];
            
        }
        
    
        if(imgData)
        {
            [formData appendPartWithFileData:imgData name:@"ImgFile" fileName:imgFileName mimeType:@"multipart/form-data"];
        }
            
        
        
    } progress:nil success:^(NSURLSessionDataTask *operation, id responseObject) {
        
        NSString *str = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        id result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        int resultValue =[result[@"Result"] intValue];
        NSLog(@"完成 %@", str);
        if (resultValue == 0) {
            completion(result);
        }else{
            [MBProgressHUD showError:result[@"Msg"]];
        }

        
       
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        NSLog(@"错误 %@", error.localizedDescription);
        [MBProgressHUD showError:error.localizedDescription];
    }];

}

@end
