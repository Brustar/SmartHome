//
//  BaseTabBarController.m
//
//
//  Created by kobe on 17/3/15.
//  Copyright © 2017年 Ecloud. All rights reserved.
//

#import "BaseTabBarController.h"

#import "BaseNavController.h"

@interface BaseTabBarController ()

@end

@implementation BaseTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    //创建子控制器
    [self createSubCtrls];
    //创建TabbarPanel
    [self createTabbarPanel];
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
    UIStoryboard *SceneStoryBoard  = [UIStoryboard storyboardWithName:@"Scene" bundle:nil];
    UIStoryboard *devicesStoryBoard  = [UIStoryboard storyboardWithName:@"Devices" bundle:nil];
    //第三级控制器
    //设备
    IphoneDeviceListController *deviceListVC = [devicesStoryBoard instantiateViewControllerWithIdentifier:@"devicesController"];
    

    //HOME
    IphoneFamilyViewController *familyVC;
         if ([[UD objectForKey:@"HostID"] intValue] == 258) {
            familyVC = [iPhoneStoryBoard instantiateViewControllerWithIdentifier:@"iphoneFamilyViewController"];
         }else{
            familyVC = [HomeStoryBoard instantiateViewControllerWithIdentifier:@"FirstViewController"];
         }

    //场景
    IphoneSceneController *sceneVC = [iPhoneStoryBoard instantiateViewControllerWithIdentifier:@"iphoneSceneController"];
    
    
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
}

- (void)onSliderBtnClicked:(UIButton *)sender {
    
}

@end
