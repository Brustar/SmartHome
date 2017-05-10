//
//  AppDelegate.h
//  SmartHome
//
//  Created by Brustar on 16/4/22.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "LeftSlideViewController.h"
#import "BaseTabBarController.h"
#import "LeftViewController.h"
#import "LaunchingViewController.h"
#import "MBProgressHUD+NJ.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) LeftSlideViewController *LeftSlideVC;//侧滑视图VC
@property (strong, nonatomic) BaseTabBarController *mainTabBarController;//主视图TabBarVC

@end
