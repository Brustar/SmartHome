//
//  LeftViewController.h
//
//  Created by kobe on 17/3/15.
//  Copyright © 2017年 Ecloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProfileFaultsViewController.h"
#import "ServiceRecordViewController.h"
#import "MySubEnergyVC.h"
#import "IphoneFavorController.h"
#import "MSGController.h"
#import "MySettingViewController.h"
#import "MBProgressHUD+NJ.h"
#import "FamilyDynamicViewController.h"
#import "ShortcutKeyViewController.h"
#import "SceneShortcutsViewController.h"
#import "DeliveryAddressViewController.h"
#import "HostListViewController.h"
#import <RongIMKit/RongIMKit.h>
#import "ConversationViewController.h"
#import "UIButton+WebCache.h"

@interface LeftViewController : UIViewController
@property(nonatomic, strong) NSArray *itemArray;
@property(nonatomic, strong) UserInfo *userInfo;
@property(nonatomic, strong) UIButton *headerBtn;
@property(nonatomic, strong) UITableView *myTableView;
@end
