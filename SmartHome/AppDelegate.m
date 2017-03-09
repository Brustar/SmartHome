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
#import "IphoneFamilyViewController.h"
#import "IphoneTabBarViewController.h"

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
//
        }
        UIViewController* viewcontroller = [secondStoryBoard instantiateViewControllerWithIdentifier:UIname];
       self.window.rootViewController = viewcontroller;
        [self.window makeKeyAndVisible];
        
        
        // 当前顶层窗口
        UIWindow *window = [[UIApplication sharedApplication].windows lastObject];
        
        CGFloat cusTabbarHeight = 80.0;
        UIView *aView = [[UIView alloc] initWithFrame:CGRectMake(0, window.bounds.size.height-cusTabbarHeight, window.bounds.size.width, cusTabbarHeight)];
        aView.backgroundColor = [UIColor grayColor];
        
        //三个按钮（设备，HOME，场景）
        CGFloat gap = 20.0f;
        NSInteger n = 3;
        CGFloat btnWidth = (aView.frame.size.width-gap*2)/n;
        CGFloat btnHeight = 50.0f;
        
        for (int i = 0; i < n; i++) {
            UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(gap +i*btnWidth, (cusTabbarHeight-btnHeight)/2, btnWidth, btnHeight)];
            btn.layer.cornerRadius = 4.0;
            btn.layer.masksToBounds = YES;
            [btn setBackgroundImage:[self createImageWithColor:[UIColor grayColor]] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [btn setBackgroundImage:[self createImageWithColor:[UIColor blueColor]] forState:UIControlStateSelected];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
            [btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
            if (i==0) {
                [btn setTitle:@"设备" forState:UIControlStateNormal];
                btn.selected = NO;
                _deviceBtn = btn;
            }else if (i == 1) {
                [btn setTitle:@"HOME" forState:UIControlStateNormal];
                btn.selected = YES;
                _homeBtn = btn;
            }else if (i == 2) {
                [btn setTitle:@"场景" forState:UIControlStateNormal];
                btn.selected = NO;
                _sceneBtn = btn;
            }
            
            [aView addSubview:btn];
        }
        
        
        aView.hidden = YES;
        // 添加到窗口
        [window addSubview:aView];
        
        
    }else {
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
        UIMutableApplicationShortcutItem *itemVoice =[[UIMutableApplicationShortcutItem alloc]initWithType:[NSString stringWithFormat:@"%@.second",[[NSBundle mainBundle] bundleIdentifier]] localizedTitle:@"语音控制" localizedSubtitle:nil icon:[UIApplicationShortcutIcon iconWithType:UIApplicationShortcutIconTypeCloud] userInfo:nil];
        UIMutableApplicationShortcutItem *itemFavor =[[UIMutableApplicationShortcutItem alloc]initWithType:[NSString stringWithFormat:@"%@.third",[[NSBundle mainBundle] bundleIdentifier]] localizedTitle:@"收藏场景" localizedSubtitle:nil icon:[UIApplicationShortcutIcon iconWithType:UIApplicationShortcutIconTypeAlarm] userInfo:nil];
        
        application.shortcutItems = @[itemFavor,itemVoice];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kickout) name:KICK_OUT object:nil];

    return YES;
}

- (UIImage*) createImageWithColor:(UIColor*) color
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

- (void)btnClicked:(UIButton *)btn {
    if (!btn.selected) {
        btn.selected = YES;
       if ([btn.titleLabel.text isEqualToString:@"设备"]) {
        _homeBtn.selected = NO;
        _sceneBtn.selected = NO;
        NSLog(@"设备页面");
       }else if ([btn.titleLabel.text isEqualToString:@"HOME"]) {
           _deviceBtn.selected = NO;
           _sceneBtn.selected = NO;
        NSLog(@"HOME页面");
       }else if ([btn.titleLabel.text isEqualToString:@"场景"]) {
           _deviceBtn.selected = NO;
           _homeBtn.selected = NO;
        NSLog(@"场景页面");
       }
        
        //跳转页面
        
    }
}

-(void)kickout
{
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"重复登录" message:@"你的帐号已在其他地方登录，请确认是否本人登录" preferredStyle:UIAlertControllerStyleAlert];
    [self.window.rootViewController presentViewController: alertVC animated:YES completion:nil];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"是本人" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        //退出登录
        
        [alertVC dismissViewControllerAnimated:YES completion:nil];
    }];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"不是我" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //改密码
        
        [alertVC dismissViewControllerAnimated:YES completion:nil];
    }];
    [alertVC addAction:cancelAction];
    [alertVC addAction:sureAction];
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

    NSString *ident=@"iphoneSceneNaviController";
    UINavigationController *vc = [secondStoryBoard instantiateViewControllerWithIdentifier:ident];
    self.window.rootViewController = vc;
    if ([shortcutItem isEqual:application.shortcutItems[0]]){
        ident=@"IphoneFavorController";
    }else if ([shortcutItem isEqual:application.shortcutItems[1]]){
        ident=@"VoiceOrderController";
    }
    UIViewController *target = [secondStoryBoard instantiateViewControllerWithIdentifier:ident];
    [vc pushViewController:target animated:YES];
    
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"ShortCut" object:nil];
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

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KICK_OUT object:nil];
}

@end
