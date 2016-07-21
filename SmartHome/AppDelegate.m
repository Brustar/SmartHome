//
//  AppDelegate.m
//  SmartHome
//
//  Created by Brustar on 16/4/22.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "AppDelegate.h"
#import "SocketManager.h"
#import "PackManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
    {
        //IOS8
        //创建UIUserNotificationSettings，并设置消息的显示类类型
        UIUserNotificationSettings *notiSettings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeAlert | UIUserNotificationTypeSound) categories:nil];
        
        [application registerUserNotificationSettings:notiSettings];
        
    } else{
        UIUserNotificationType notificationTypes = (UIUserNotificationTypeAlert|
                                                    UIUserNotificationTypeSound|
                                                    UIUserNotificationTypeBadge);
        
        UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:notificationTypes
                                                                                             categories:nil];
        [application registerUserNotificationSettings:notificationSettings];
    } ;
    
    [IOManager copyFile:@"smartDB" to:@"smartDB"];
    
    DeviceInfo *device=[DeviceInfo defaultManager];
    [device netReachbility];
    [device deviceGenaration];
    
    //登录后每次系统启动自动更新云端配置，第一次安装此处不更新，登录的时候再更新
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"masterID"]) {
        [device initConfig];
    }
    
    return YES;
}

-(void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken{
    NSLog(@"deviceToken: %@", deviceToken);
    DeviceInfo *info=[DeviceInfo defaultManager];
    info.pushToken=[PackManager hexStringFromData:deviceToken];
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    
    NSString *str = [NSString stringWithFormat: @"Error: %@", err];
    NSLog(@"token error:  %@",str);
    
    //如果device token获取失败则需要重新获取一次
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(registerForRemoteNotificationToGetToken) userInfo:nil repeats:NO];
}

//向服务器申请发送token 判断事前有没有发送过
- (void)registerForRemoteNotificationToGetToken
{
    NSLog(@"Registering for push notifications...");
    
    //注册Device Token, 需要注册remote notification
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (![userDefaults boolForKey:@"DeviceTokenRegisteredKEY"])   //如果没有注册到令牌 则重新发送注册请求
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            if([[[UIDevice currentDevice]systemVersion]floatValue] >=8.0)
            {
                [[UIApplication sharedApplication]registerUserNotificationSettings:[UIUserNotificationSettings
                                                                                   settingsForTypes:(UIUserNotificationTypeSound|UIUserNotificationTypeAlert|UIUserNotificationTypeBadge)
                                                                                   categories:nil]];
                [[UIApplication sharedApplication]registerForRemoteNotifications];
            }
        });
    }
    
    //将远程通知的数量置零
    dispatch_async(dispatch_get_global_queue(0,0), ^{
        //1 hide the local badge
        if ([[UIApplication sharedApplication] applicationIconBadgeNumber] == 0) {
            return;
        }
        // [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
        
        //2 ask the provider to set the BadgeNumber to zero
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *deviceTokenStr = [userDefaults objectForKey:@"DeviceTokenStringKEY"];
        //[self resetBadgeNumberOnProviderWithDeviceToken:deviceTokenStr];
    });
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    //每次醒来都需要去判断是否得到device token
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(registerForRemoteNotificationToGetToken) userInfo:nil repeats:NO];
    //hide the badge
    application.applicationIconBadgeNumber = 0;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
