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
#include <netdb.h>

@implementation HttpManager

+ (id)defaultManager {
    static HttpManager *sharedInstance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

+ (BOOL) reachable
{
    // Create zero addy
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    // Recover reachability flags
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
    
    if (!didRetrieveFlags)
    {
        printf("Error. Could not recover network reachability flags\n");
        return NO;
    }
    
    BOOL isReachable = ((flags & kSCNetworkFlagsReachable) != 0);
    BOOL needsConnection = ((flags & kSCNetworkFlagsConnectionRequired) != 0);
    return (isReachable && !needsConnection) ? YES : NO;
}

- (void) sendPost:(NSString *)url param:(NSDictionary *)params
{
    if (![HttpManager reachable]) {
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
        NSLog(@"failure:%@",error);
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"网络请求错误"];
    }];
}

- (void) sendGet:(NSString *)url param:(NSDictionary *)params
{
    if (![HttpManager reachable]) {
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
