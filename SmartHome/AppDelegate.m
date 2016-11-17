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
#import "HttpManager.h"
#import "IOManager.h"
#import "IQKeyboardManager.h"
#import "ECloudTabBarController.h"
#import "IphoneMainController.h"
#import "MSGController.h"
#import "ECloudTabBar.h"
#import "IphoneSceneController.h"
#import "VoiceOrderController.h"
#import "IphoneFavorController.h"

@interface AppDelegate ()<UIViewControllerPreviewingDelegate >

@property (nonatomic,strong) NSArray * AppArr;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //app未开启时处理推送
    if (launchOptions) {
        //截取apns推送的消息
        NSDictionary* userInfo = [launchOptions objectForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"];
        //获取推送详情
        [self handlePush:userInfo];
        return YES;
    }
    
    DeviceInfo *device=[DeviceInfo defaultManager];
    [device netReachbility];
    [device deviceGenaration];
    device.db=SMART_DB;
   
    //登录后每次系统启动自动更新云端配置，第一次安装此处不更新，登录的时候再更新
    [device initConfig];
    
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        UIStoryboard *secondStoryBoard = [UIStoryboard storyboardWithName:@"iPhone" bundle:nil];
        NSString *UIname=@"main";
        //已登录时,自动登录
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"]) {
            UIname=@"IphoneMainController";
        }
        UIViewController* viewcontroller = [secondStoryBoard instantiateViewControllerWithIdentifier:UIname];
        self.window.rootViewController = viewcontroller;
        [self.window makeKeyAndVisible];
    }else{
        //已登录时
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"]) {
            ECloudTabBarController *ecloudVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ECloudTabBarController"];
            self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
            self.window.rootViewController = ecloudVC;
            return YES;
        }
    }
    
    IQKeyboardManager *manager = [IQKeyboardManager sharedManager];
    manager.enable = YES;
    manager.shouldResignOnTouchOutside = YES;
    manager.shouldToolbarUsesTextFieldTintColor = YES;
    manager.enableAutoToolbar = YES;
   
    //动态加载自定义的ShortcutItem
    if (application.shortcutItems.count == 0) {
        UIMutableApplicationShortcutItem *itemThor =[[UIMutableApplicationShortcutItem alloc]initWithType:[NSString stringWithFormat:@"%@.second",[[NSBundle mainBundle] bundleIdentifier]] localizedTitle:@"语音控制" localizedSubtitle:nil icon:[UIApplicationShortcutIcon iconWithType:UIApplicationShortcutIconTypeCloud] userInfo:nil];
        UIMutableApplicationShortcutItem *itemBlack =[[UIMutableApplicationShortcutItem alloc]initWithType:[NSString stringWithFormat:@"%@.third",[[NSBundle mainBundle] bundleIdentifier]] localizedTitle:@"收藏场景" localizedSubtitle:nil icon:[UIApplicationShortcutIcon iconWithType:UIApplicationShortcutIconTypeAlarm] userInfo:nil];
        
        application.shortcutItems = @[itemBlack,itemThor];
        _AppArr= [NSArray arrayWithObjects:itemBlack,itemThor, nil];
    }

    return YES;
}

#pragma mark - 推送代理
-(void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken{
    DeviceInfo *info=[DeviceInfo defaultManager];
    info.pushToken=[PackManager hexStringFromData:deviceToken];
    NSLog(@"deviceToken: %@", info.pushToken);
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    NSLog(@"token error:  %@",err);
}

//app在后台运行时
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"userInfo:  %@",userInfo);
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        //alert
        NSString *msg=[[[userInfo objectForKey:@"aps"] objectForKey:@"alert"] description];
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"是否查看推送的消息" message:msg preferredStyle:UIAlertControllerStyleAlert];
        [self.window.rootViewController presentViewController: alertVC animated:YES completion:nil];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [alertVC dismissViewControllerAnimated:YES completion:nil];
        }];
        UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //跳转
            int type=[[userInfo objectForKey:@"typeID"] intValue];
            int item=[[userInfo objectForKey:@"itemID"] intValue];
            if(item && type)
            {
                //跳转
                NSDictionary *dic = @{@"type":[NSNumber numberWithInt:2],@"subType":[NSNumber numberWithInt:0]};
                NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
                [center postNotificationName:@"myMsg" object:nil userInfo:dic];
            }
            
            [alertVC dismissViewControllerAnimated:YES completion:nil];
        }];
        [alertVC addAction:cancelAction];
        [alertVC addAction:sureAction];
        
        
        return;
    }
    [self handlePush:userInfo];
}

//处理推送及跳转,发送请求更新badge 消息itemID = 123;类型typeID = 456;
-(void) handlePush:(NSDictionary *)userInfo
{
    int type=[[userInfo objectForKey:@"typeID"] intValue];
    int item=[[userInfo objectForKey:@"itemID"] intValue];
    
    if(item && type)
    {
        //跳转
        NSDictionary *dic = @{@"type":[NSNumber numberWithInt:2],@"subType":[NSNumber numberWithInt:0]};
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center postNotificationName:@"myMsg" object:nil userInfo:dic];
        
    }
}

//向服务器申请发送token 判断事前有没有发送过
- (void)registerForRemoteNotificationToGetToken
{
    NSLog(@"Registering for push notifications...");
    //注册Device Token, 需要注册remote notification
    DeviceInfo *info=[DeviceInfo defaultManager];
    if (!info.pushToken)   //如果没有注册到令牌 则重新发送注册请求
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
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    });
    
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    if ([DeviceInfo defaultManager].isPhotoLibrary) {
        return UIInterfaceOrientationMaskAll;
    }else {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                return UIInterfaceOrientationMaskLandscape;
        }else{
            return UIInterfaceOrientationMaskPortrait;
        }
    }
}

- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void(^)(BOOL succeeded))completionHandler{
    //判断先前我们设置的唯一标识
     UIStoryboard *secondStoryBoard = [UIStoryboard storyboardWithName:@"iPhone" bundle:nil];

        
     if ([shortcutItem isEqual:_AppArr[0]]){
         IphoneFavorController *childVC = [secondStoryBoard instantiateViewControllerWithIdentifier:@"IphoneFavorController"];
        [self.window.rootViewController presentViewController:childVC animated:YES completion:^{
            
        }];
    }else if ([shortcutItem isEqual:_AppArr[1]]){
        VoiceOrderController *voicVC = [secondStoryBoard instantiateViewControllerWithIdentifier:@"VoiceOrderController"];
        [self.window.rootViewController presentViewController:voicVC animated:YES completion:^{
            
        }];
    }
    

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

#pragma mark - UIViewControllerPreviewingDelegate

- (nullable UIViewController *)previewingContext:(id <UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location
{
    
    VoiceOrderController *detailVC =[[VoiceOrderController alloc] init];
   
    
    return detailVC;
}

- (void)previewingContext:(id <UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit
{
    [self.window.rootViewController presentViewController:viewControllerToCommit animated:YES completion:nil];
}

@end
