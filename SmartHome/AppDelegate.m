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
#import "MSGController.h"
#import "RCDataManager.h"
#import "IphoneSceneController.h"
#import "VoiceOrderController.h"
#import "IphoneFavorController.h"
#import "WXApi.h"
#import "WeChatPayManager.h"
#import "IpadFirstViewController.h"


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    //注册微信
    [WXApi registerApp:@"wxc5cab7f2a6ed90b3" withDescription:@"EcloudApp2.1"];
    
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
   
    //登录后每次系统启动自动更新云端配置，第一次安装此处不更新，登录的时候再更新
    [device initConfig];
    
    
    [self loadingLaunchingViewController];
    [self performSelector:@selector(loadingLoginViewController) withObject:nil afterDelay:6];//动画启动页执行完毕后，执行登录／tabbar页面
    
    IQKeyboardManager *manager = [IQKeyboardManager sharedManager];
    manager.enable = YES;
    manager.shouldResignOnTouchOutside = YES;
    manager.shouldToolbarUsesTextFieldTintColor = YES;
    manager.enableAutoToolbar = YES;
   
    //动态加载自定义的ShortcutItem
    if (application.shortcutItems.count == 0) {
        UIMutableApplicationShortcutItem *itemVoice =[[UIMutableApplicationShortcutItem alloc]initWithType:[NSString stringWithFormat:@"%@.second",[[NSBundle mainBundle] bundleIdentifier]] localizedTitle:@"语音控制" localizedSubtitle:nil icon:[UIApplicationShortcutIcon iconWithType:UIApplicationShortcutIconTypeCloud] userInfo:nil];
        
        application.shortcutItems = @[itemVoice];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kickout) name:KICK_OUT object:nil];
    
    [[RCIM sharedRCIM] initWithAppKey:@"8brlm7uf8tsb3"];
    [RCIM sharedRCIM].userInfoDataSource = [RCDataManager shareManager];
    return YES;
}

- (void)loadingLaunchingViewController {
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        LaunchingViewController *launchingVC = [[LaunchingViewController alloc] init];
        self.window.rootViewController = launchingVC;
        [self.window makeKeyAndVisible];
}

- (void)loadingLoginViewController {
    
    DeviceInfo *device=[DeviceInfo defaultManager];
    [device deviceGenaration];
        
        if (self.window == nil) {
            self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        }

        UIStoryboard *loginStoryBoard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
        
        //已登录时,自动登录
        if ([UD objectForKey:@"AuthorToken"]) {
            
            self.mainTabBarController = [[BaseTabBarController alloc] init];
            LeftViewController *leftVC = [[LeftViewController alloc] init];
            self.LeftSlideVC = [[LeftSlideViewController alloc] initWithLeftView:leftVC andMainView:self.mainTabBarController];
            self.window.rootViewController = self.LeftSlideVC;
            if (device.masterID == 0) {
                device.masterID = [[[NSUserDefaults standardUserDefaults] objectForKey:@"HostID"] intValue];
            }
        }else {
            UIViewController *vc = [loginStoryBoard instantiateViewControllerWithIdentifier:@"loginNavController"];//未登录，进入登录页面
            self.window.rootViewController = vc;
        }
        
        [self.window makeKeyAndVisible];
  
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
    [[RCIMClient sharedRCIMClient] setDeviceToken:info.pushToken];
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
            }else{
                [self gotoConversation];
            }
            
            [alertVC dismissViewControllerAnimated:YES completion:nil];
        }];
        [alertVC addAction:cancelAction];
        [alertVC addAction:sureAction];
        
        
        return;
    }
    [self handlePush:userInfo];
}

-(void) gotoConversation
{
    NSString *groupID = [[UD objectForKey:@"HostID"] description];
    NSString *homename = [UD objectForKey:@"homename"];
    
    RCGroup *aGroupInfo = [[RCGroup alloc]initWithGroupId:groupID groupName:homename portraitUri:@""];
    ConversationViewController *conversationVC = [[ConversationViewController alloc] init];
    conversationVC.conversationType = ConversationType_GROUP;
    conversationVC.targetId = aGroupInfo.groupId;
    [conversationVC setTitle: [NSString stringWithFormat:@"%@",aGroupInfo.groupName]];
    
    [self.mainTabBarController.selectedViewController pushViewController:conversationVC animated:YES];
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
    }else{
        [self gotoConversation];
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
        if (ON_IPAD) {
                return UIInterfaceOrientationMaskLandscape;
        }else{
            return UIInterfaceOrientationMaskPortrait;
        }
    }
}

- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void(^)(BOOL succeeded))completionHandler{
    
    NSString *auothorToken = [UD objectForKey:@"AuthorToken"];
    if (auothorToken.length >0) {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"iPhone" bundle:nil];
        UIViewController *voiceOrderVC = [storyBoard instantiateViewControllerWithIdentifier:@"VoiceOrderController"];
        
        [self loadingLoginViewController];
        [self.mainTabBarController.selectedViewController pushViewController:voiceOrderVC animated:YES];

        
    }else {
        [MBProgressHUD showError:@"请先登录"];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
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

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options {
    
    
    if ([url.absoluteString hasPrefix:@"wxc5cab7f2a6ed90b3"]) {
        
        return [WXApi handleOpenURL:url delegate:[WeChatPayManager sharedInstance]];
    }
    //注册微信
    [WXApi registerApp:@"wxc5cab7f2a6ed90b3" withDescription:@"EcloudApp2.1"];
    [[DeviceInfo defaultManager] initConfig];
    
    [self loadingLaunchingViewController];
    [self performSelector:@selector(loadingLoginViewController) withObject:nil afterDelay:6];//动画启动页执行完毕后，执行登录／tabbar页面
    [[RCIM sharedRCIM] initWithAppKey:@"8brlm7uf8tsb3"];
    [RCIM sharedRCIM].userInfoDataSource = [RCDataManager shareManager];
    
    return YES;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KICK_OUT object:nil];
}

@end
