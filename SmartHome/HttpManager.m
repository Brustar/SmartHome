//
//  HttpManager.m
//  SmartHome
//
//  Created by Brustar on 16/7/7.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "HttpManager.h"
#import "AFNetworking.h"
#import "MBProgressHUD+NJ.h"
#import "NetStatusManager.h"

@implementation HttpManager

+ (instancetype)defaultManager
{
    static HttpManager *sharedInstance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (void) sendPost:(NSString *)url param:(NSDictionary *)params showProgressHUD:(BOOL)show
{
    if (![NetStatusManager reachable]) {
        [MBProgressHUD showError:@"网络异常，请检查你的网络"];
        return;
    }
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    
    if (show) {
        [MBProgressHUD showMessage:@"请稍候..."];
    }
    
    
    [mgr POST:url parameters:params progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        [MBProgressHUD hideHUD];
        NSLog(@"success:%@",responseObject);
        if (self.tag>0) {
            [self.delegate httpHandler:responseObject tag:self.tag];
        }else{
            [self.delegate httpHandler:responseObject];
        }
        
        if (show) {
            [MBProgressHUD hideHUD];
        }
        
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"failure:%@",error.userInfo);
        
        if (show) {
            [MBProgressHUD hideHUD];
        }
        
        [MBProgressHUD showError:@"网络请求错误"];
        
    }];
    
}

- (void) sendPost:(NSString *)url param:(NSDictionary *)params
{
    if (![NetStatusManager reachable]) {
        [MBProgressHUD showError:@"网络异常，请检查你的网络"];
        return;
    }
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    [MBProgressHUD showMessage:@"请稍候..."];
    [mgr POST:url parameters:params progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        [MBProgressHUD hideHUD];
        NSLog(@"success:%@",responseObject);
        if (self.tag>0) {
            [self.delegate httpHandler:responseObject tag:self.tag];
        }else{
            [self.delegate httpHandler:responseObject];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"failure:%@",error.userInfo);
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"网络请求错误"];
        
    }];
    
}

- (void) sendGet:(NSString *)url param:(NSDictionary *)params
{
    if (![NetStatusManager reachable]) {
        [MBProgressHUD showError:@"网络异常，请检查你的网络"];
        return;
    }
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    [MBProgressHUD showMessage:@"请稍候..."];
    
    [mgr GET:url parameters:params progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        [MBProgressHUD hideHUD];
        NSLog(@"success:%@",responseObject);
        if (self.tag>0) {
            [self.delegate httpHandler:responseObject tag:self.tag];
        }else{
            [self.delegate httpHandler:responseObject];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"failure:%@",error);
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"网络请求错误"];
    }];
}

//带请求头的GET请求
- (void)sendGet:(NSString *)url param:(NSDictionary *)params header:(NSDictionary *)header
{
    if (![NetStatusManager reachable]) {
        [MBProgressHUD showError:@"网络异常，请检查你的网络"];
        return;
    }
    [MBProgressHUD showMessage:@"请稍候..."];
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    
    //设置请求头
    [mgr.requestSerializer setValue:header[@"X-nl-protocol-version"] forHTTPHeaderField:@"X-nl-protocol-version"];
    [mgr.requestSerializer setValue:header[@"X-nl-user-id"] forHTTPHeaderField:@"X-nl-user-id"];
    [mgr.requestSerializer setValue:header[@"Authorization"] forHTTPHeaderField:@"Authorization"];
    
    [mgr GET:url parameters:params progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        [MBProgressHUD hideHUD];
        NSLog(@"success:%@",responseObject);
        if (self.tag>0) {
            [self.delegate httpHandler:responseObject tag:self.tag];
        }else{
            [self.delegate httpHandler:responseObject];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"failure:%@",error);
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"网络请求错误"];
    }];
}

@end
