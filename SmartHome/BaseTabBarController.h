//
//  BaseTabBarController.h
//
//  Created by kobe on 17/3/15.
//  Copyright © 2017年 Ecloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IphoneSceneController.h"
#import "IphoneDeviceListController.h"
#import "FirstViewController.h"
#import "TabbarPanel.h"

@interface BaseTabBarController : UITabBarController<TabbarPanelDelegate>

@property(nonatomic, strong) TabbarPanel *tabbarPanel;

@end
