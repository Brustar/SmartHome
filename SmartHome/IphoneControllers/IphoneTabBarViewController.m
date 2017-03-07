//
//  IphoneTabBarViewController.m
//  SmartHome
//
//  Created by zhaona on 2017/2/15.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "IphoneTabBarViewController.h"
#import "IphoneSceneController.h"
#import "IphoneDeviceListController.h"
#import "IphoneRealSceneController.h"
#import "IphoneProfileController.h"
#import "IphoneFamilyViewController.h"
#import "MySettingViewController.h"
#import "UITabBar+BadgeValue.h"

@interface IphoneTabBarViewController ()

@end

@implementation IphoneTabBarViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self creaTabBarController];
    //显示
//    [self.tabBarController.tabBar showBadgeOnItemIndex:3];
    
    //隐藏
//    [self.tabBarController.tabBar hideBadgeOnItemIndex:2];
}
-(void)creaTabBarController
{
    IphoneFamilyViewController * familyVC = [[UIStoryboard storyboardWithName:@"iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"iphoneFamilyViewController"];
    UINavigationController * naVC1= [[UINavigationController alloc] initWithRootViewController:familyVC];
    familyVC.title = @"家庭";
    familyVC.tabBarItem.image = [UIImage imageNamed:@"family-Mysetting"];
    IphoneSceneController *scene = [[UIStoryboard storyboardWithName:@"iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"iphoneSceneController"];
    UINavigationController * naVC2 = [[UINavigationController alloc] initWithRootViewController:scene];
    scene.title = @"场景";
    scene.tabBarItem.image = [UIImage imageNamed:@"scene-MySetting"];
    IphoneDeviceListController *deviceList = [[UIStoryboard storyboardWithName:@"iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"IphoneDeviceListController"];
    UINavigationController * naVC3= [[UINavigationController alloc] initWithRootViewController:deviceList];
    deviceList.title = @"设备";
    deviceList.tabBarItem.image = [UIImage imageNamed:@"device_MySetting"];
    
    MySettingViewController *realVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"MySettingViewController"];
    UINavigationController * naVC4= [[UINavigationController alloc] initWithRootViewController:realVC];
    realVC.title = @"设置";
    realVC.tabBarItem.image = [UIImage imageNamed:@"shezhi4"];
    
    IphoneProfileController *profireList = [[UIStoryboard storyboardWithName:@"iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"IphoneProfileController"];
    UINavigationController * naVC5= [[UINavigationController alloc] initWithRootViewController:profireList];
    profireList.title = @"我的";
    profireList.tabBarItem.image = [UIImage imageNamed:@"me-Mysetting"];
    if (profireList.imageView.hidden == NO) {
          profireList.tabBarItem.badgeValue =@"1";
    }else{
          profireList.tabBarItem.badgeValue =nil;
    }
  
    
    self.viewControllers = @[naVC1,naVC3,naVC4,naVC5];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
