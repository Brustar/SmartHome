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
#import "LoadMaskHelper.h"
#import "UploadManager.h"

@protocol LeftViewControllerDelegate;

@interface LeftViewController : UIViewController<SingleMaskViewDelegate>
@property(nonatomic, strong) NSArray *itemArray;
@property(nonatomic, strong) UserInfo *userInfo;
@property(nonatomic, strong) UIButton *headerBtn;
@property (nonatomic,strong) UILabel * nickNameLabel;
@property(nonatomic, strong) UITableView *myTableView;
@property(nonatomic, assign) id<LeftViewControllerDelegate>delegate;
@property(nonatomic, strong) UIButton *bgButton;
@property(nonatomic,assign)int sum;


@end



@protocol LeftViewControllerDelegate <NSObject>

@optional

- (void)onBackgroundBtnClicked:(UIButton *)btn;
- (void)didSelectItem:(NSString *)item;

@end
