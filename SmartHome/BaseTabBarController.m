//
//  BaseTabBarController.m
//
//
//  Created by kobe on 17/3/15.
//  Copyright © 2017年 Ecloud. All rights reserved.
//

#import "BaseTabBarController.h"
#import "BaseNavController.h"
#import "IpadFirstViewController.h"
#import "IpadSceneViewController.h"

@interface BaseTabBarController ()

@end

@implementation BaseTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    //创建子控制器
    [self createSubCtrls];
    //创建TabbarPanel
    [self createTabbarPanel];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)setupAnimationViewForLaunching {
    // 设定位置和大小
    CGRect frame = CGRectMake(0,0,UI_SCREEN_WIDTH, UI_SCREEN_HEIGHT);
    //frame.size = [UIImage imageNamed:@"welcome.gif"].size;
    //    frame.size.width = [UIImage imageNamed:@"启动页640.gif"].size.width / 2;
    //    frame.size.height = [UIImage imageNamed:@"启动页640.gif"].size.height / 2;
    // 读取gif图片数据
    NSData *gif = [NSData dataWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"welcome" ofType:@"gif"]];
    // view生成
    UIWebView *webView = [[UIWebView alloc] initWithFrame:frame];
    webView.userInteractionEnabled = NO;//用户不可交互
    [webView loadData:gif MIMEType:@"image/gif" textEncodingName:nil baseURL:nil];
    webView.scalesPageToFit = YES;
    webView.tag = 20171;
    [self.view addSubview:webView];
}

- (void)createTabbarPanel {
    
    self.tabBar.hidden = YES;
    
    _tabbarPanel = [[TabbarPanel alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-TabbarHeight, UI_SCREEN_WIDTH, TabbarHeight)];
    _tabbarPanel.delegate = self;
    [self.view addSubview:_tabbarPanel];
}

- (void)createSubCtrls{
    
    //iPhone故事板
    UIStoryboard *iPhoneStoryBoard  = [UIStoryboard storyboardWithName:@"iPhone" bundle:nil];
    UIStoryboard *HomeStoryBoard  = [UIStoryboard storyboardWithName:@"Home" bundle:nil];
    UIStoryboard *devicesStoryBoard  = [UIStoryboard storyboardWithName:@"Devices" bundle:nil];
    UIStoryboard * HomeIpadStoryBoard = [UIStoryboard storyboardWithName:@"Home-iPad" bundle:nil];
    UIStoryboard * SceneIpadStoryBoard = [UIStoryboard storyboardWithName:@"Scene-iPad" bundle:nil];
    //第三级控制器
    //设备
    IphoneDeviceListController *deviceListVC = [devicesStoryBoard instantiateViewControllerWithIdentifier:@"devicesController"];
    
    //HOME
    UIViewController * familyVC;
 if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
     familyVC = [HomeStoryBoard instantiateViewControllerWithIdentifier:@"FirstViewController"];
 }else{
     familyVC = [HomeIpadStoryBoard instantiateViewControllerWithIdentifier:@"IpadFirstViewController"];
 }
    //场景
    UIViewController * sceneVC;
 if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
     
     sceneVC = [iPhoneStoryBoard instantiateViewControllerWithIdentifier:@"iphoneSceneController"];
 }else{
     sceneVC = [SceneIpadStoryBoard instantiateViewControllerWithIdentifier:@"IpadSceneViewController"];
 }
    
    //创建数组
    NSArray *viewCtrls = @[deviceListVC, familyVC, sceneVC];
    
    //创建可变数组,存储导航控制器
    NSMutableArray *navs = [NSMutableArray arrayWithCapacity:viewCtrls.count];
    
    //创建二级控制器导航控制器
    for (UIViewController *ctrl in viewCtrls) {
        BaseNavController *nav = [[BaseNavController alloc] initWithRootViewController:ctrl];
        
        //将导航控制器加入到数组中
        [navs addObject:nav];
    }
    
    //将导航控制器交给标签控制器管理
    self.viewControllers = navs;
    self.selectedIndex = 1;
}

#pragma mark - TabbarPanel Delegate
- (void)changeViewController:(UIButton *)sender {
    self.selectedIndex = sender.tag;
    [NC postNotificationName:@"NetWorkDidChangedNotification" object:nil];
}

- (void)onSliderBtnClicked:(UIButton *)sender {
    [NC postNotificationName:@"NetWorkDidChangedNotification" object:nil];
}

@end
