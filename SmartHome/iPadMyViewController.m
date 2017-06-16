//
//  iPadMyViewController.m
//  SmartHome
//
//  Created by KobeBryant on 2017/6/12.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "iPadMyViewController.h"

@interface iPadMyViewController ()

@end

@implementation iPadMyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //初始化分割视图控制器
    UISplitViewController *splitViewController = [[UISplitViewController alloc] init];
    //初始化左边视图控制器
    _leftVC = [[LeftViewController alloc] init];
    _leftVC.delegate = self;
    _leftVC.view.frame = CGRectMake(0, 0, UI_SCREEN_WIDTH/4, UI_SCREEN_HEIGHT-80);
    //初始化右边视图控制器
    _rootVC = [[CustomViewController alloc] init];
    [_rootVC setNaviBarLeftBtn:nil];
    _rightVC = [[UINavigationController alloc] initWithRootViewController:_rootVC];
    _rightVC.navigationBar.hidden = YES;
    // 设置分割面板的 2 个视图控制器
    splitViewController.viewControllers = @[_leftVC, _rightVC];
    // 添加到窗口
    [self addChildViewController:splitViewController];
    //配置分屏视图界面外观
    splitViewController.preferredDisplayMode = UISplitViewControllerDisplayModeAutomatic;
    //调整masterViewController的宽度，按百分比调整
    splitViewController.preferredPrimaryColumnWidthFraction = 0.25;
    
    [self.view addSubview:splitViewController.view];
    _leftVC.bgButton.hidden = YES;
    _leftVC.myTableView.frame = _leftVC.view.frame;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    BaseTabBarController *baseTabbarController =  (BaseTabBarController *)self.tabBarController;
    baseTabbarController.tabbarPanel.hidden = YES;
    baseTabbarController.tabBar.hidden = YES;
    [_rootVC setNaviBarLeftBtn:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    BaseTabBarController *baseTabbarController =  (BaseTabBarController *)self.tabBarController;
    baseTabbarController.tabbarPanel.hidden = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_rootVC.m_viewNaviBar setBackBtn:nil];
    _rootVC.m_viewNaviBar.m_viewCtrlParent = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//进入聊天页面
-(void)setRCIM
{
    NSString *groupID = [[UD objectForKey:@"HostID"] description];
    NSString *homename = [UD objectForKey:@"homename"];
    
    RCGroup *aGroupInfo = [[RCGroup alloc]initWithGroupId:groupID groupName:homename portraitUri:@""];
    ConversationViewController *_conversationVC = [[ConversationViewController alloc] init];
    _conversationVC.conversationType = ConversationType_GROUP;
    _conversationVC.targetId = aGroupInfo.groupId;
    [_conversationVC setTitle: [NSString stringWithFormat:@"%@",aGroupInfo.groupName]];
    _conversationVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:_conversationVC animated:YES];
}

#pragma mark - LeftViewControllerDelegate
- (void)didSelectItem:(NSString *)item {
    
    if (_currentItem.length >0 && [_currentItem isEqualToString:item]) {
        return;
    }else {
        _currentItem = [NSString stringWithString:item];
    
    [NC postNotificationName:@"StopTimerNotification" object:nil];  
    [_rightVC popToRootViewControllerAnimated:NO];
    UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIStoryboard *myInfoStoryBoard  = [UIStoryboard storyboardWithName:@"MyInfo" bundle:nil];
    UIStoryboard *familyStoryBoard = [UIStoryboard storyboardWithName:@"Family" bundle:nil];
    UIStoryboard *loginStoryBoard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    if ([item isEqualToString:@"故障及保修记录"]) {
        ProfileFaultsViewController *profileFaultsVC = [mainStoryBoard instantiateViewControllerWithIdentifier:@"MyDefaultViewController"];
        profileFaultsVC.hidesBottomBarWhenPushed = YES;
        [_rightVC pushViewController:profileFaultsVC animated:YES];
        
    }else if ([item isEqualToString:@"家庭成员"]) {
        //家庭成员(聊天页面)
        [self setRCIM];
        
    }else if ([item isEqualToString:@"智能账单"]) {
        
        MySubEnergyVC *mySubEnergyVC = [myInfoStoryBoard instantiateViewControllerWithIdentifier:@"MySubEnergyVC"];
        mySubEnergyVC.hidesBottomBarWhenPushed = YES;
        [_rightVC pushViewController:mySubEnergyVC animated:YES];
        
    }else if ([item isEqualToString:@"视频动态"]) {
        //视频动态
        [MBProgressHUD showMessage:@"请稍候..."];
        FamilyDynamicViewController *vc = [familyStoryBoard instantiateViewControllerWithIdentifier:@"FamilyDynamicVC"];
        vc.hidesBottomBarWhenPushed = YES;
        [_rightVC pushViewController:vc animated:YES];
        
    }else if ([item isEqualToString:@"通知"]) {
        MSGController *msgVC = [mainStoryBoard instantiateViewControllerWithIdentifier:@"MSGController"];
        msgVC.hidesBottomBarWhenPushed = YES;
        [_rightVC pushViewController:msgVC animated:YES];
        
    }else if ([item isEqualToString:@"切换家庭账号"]) {
        
        HostListViewController *vc = [loginStoryBoard instantiateViewControllerWithIdentifier:@"HostListVC"];
        vc.hidesBottomBarWhenPushed = YES;
        [_rightVC pushViewController:vc animated:YES];
    }else if ([item isEqualToString:@"头像"]) {
        UIViewController *vc = [loginStoryBoard instantiateViewControllerWithIdentifier:@"userinfoVC"];
        vc.hidesBottomBarWhenPushed = YES;
        [_rightVC pushViewController:vc animated:YES];
    }else if ([item isEqualToString:@"设置"]) {
        MySettingViewController *mysettingVC = [mainStoryBoard instantiateViewControllerWithIdentifier:@"MySettingViewController"];
        mysettingVC.hidesBottomBarWhenPushed = YES;
        [_rightVC pushViewController:mysettingVC animated:YES];
    }else if ([item isEqualToString:@"返回"]) {
        [NC postNotificationName:@"StopTimerNotification" object:nil];
        [self.navigationController popViewControllerAnimated:YES];
    }
        
  }
}

@end
