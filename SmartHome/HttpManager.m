//
//  HttpManager.m
//  SmartHome
//
//  Created by Brustar on 16/7/7.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "HttpManager.h"
#import <AFNetworking.h>
#import "MBProgressHUD+NJ.h"
#import "NetStatusManager.h"

@implementation HttpManager

+ (id)defaultManager
{
    static HttpManager *sharedInstance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (void) sendPost:(NSString *)url param:(NSDictionary *)params
{
    if (![NetStatusManager reachable]) {
        [MBProgressHUD showError:@"当前网络不可用，请检查你的网络设置"];
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
        [MBProgressHUD showError:@"当前网络不可用，请检查你的网络设置"];
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

@end
