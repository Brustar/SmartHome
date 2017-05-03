//
//  LeftViewController.m
//
//  Created by kobe on 17/3/15.
//  Copyright © 2017年 Ecloud. All rights reserved.
//


#import "LeftViewController.h"
#import "AppDelegate.h"


@interface LeftViewController ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation LeftViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    _itemArray = @[@"家庭成员",@"家庭动态",@"智能账单",@"通知",@"故障及保修记录",@"切换家庭账号"];

    
    UIImageView *imageview = [[UIImageView alloc] initWithFrame:self.view.bounds];
    imageview.image = [UIImage imageNamed:@"background"];
    [self.view addSubview:imageview];
    
    UITableView *tableview = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    tableview.dataSource = self;
    tableview.delegate  = self;
    tableview.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    tableview.tableFooterView = [self setupTableFooter];
    [self.view addSubview:tableview];

}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _itemArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *Identifier = @"Identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.font = [UIFont systemFontOfSize:16.0f];
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.text = [_itemArray objectAtIndex:indexPath.row];
    if (indexPath.row == 0) {
        cell.imageView.image = [UIImage imageNamed:@"my_family"];
    }else if (indexPath.row == 1) {
        cell.imageView.image = [UIImage imageNamed:@"my_scene"];
    }else if (indexPath.row == 2) {
        cell.imageView.image = [UIImage imageNamed:@"my_cloud"];
    }else if (indexPath.row == 3) {
        cell.imageView.image = [UIImage imageNamed:@"my_msg"];
    }else if (indexPath.row == 4) {
        cell.imageView.image = [UIImage imageNamed:@"my_alert"];
    }else if (indexPath.row == 5) {
        cell.imageView.image = [UIImage imageNamed:@"my_exchange"];
    }
    
   
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIStoryboard *myInfoStoryBoard  = [UIStoryboard storyboardWithName:@"MyInfo" bundle:nil];
    UIStoryboard *familyStoryBoard = [UIStoryboard storyboardWithName:@"Family" bundle:nil];
    UIStoryboard *loginStoryBoard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.LeftSlideVC closeLeftView];//关闭左侧抽屉
    
    NSString *item = [_itemArray objectAtIndex:indexPath.row];
    if ([item isEqualToString:@"故障及保修记录"]) {
        ProfileFaultsViewController *profileFaultsVC = [mainStoryBoard instantiateViewControllerWithIdentifier:@"MyDefaultViewController"];
        profileFaultsVC.hidesBottomBarWhenPushed = YES;
        [appDelegate.mainTabBarController.selectedViewController pushViewController:profileFaultsVC animated:YES];

    }else if ([item isEqualToString:@"家庭成员"]) {
        //家庭成员
        DeliveryAddressViewController *vc = [myInfoStoryBoard instantiateViewControllerWithIdentifier:@"DeliveryAddressVC"];
        vc.hidesBottomBarWhenPushed = YES;
        [appDelegate.mainTabBarController.selectedViewController pushViewController:vc animated:YES];
        
    }else if ([item isEqualToString:@"智能账单"]) {

        MySubEnergyVC *mySubEnergyVC = [mainStoryBoard instantiateViewControllerWithIdentifier:@"MyEnergyViewController"];
        mySubEnergyVC.hidesBottomBarWhenPushed = YES;
        [appDelegate.mainTabBarController.selectedViewController pushViewController:mySubEnergyVC animated:YES];
        
    }else if ([item isEqualToString:@"家庭动态"]) {
        //家庭动态
        FamilyDynamicViewController *vc = [familyStoryBoard instantiateViewControllerWithIdentifier:@"FamilyDynamicVC"];
        vc.hidesBottomBarWhenPushed = YES;
        [appDelegate.mainTabBarController.selectedViewController pushViewController:vc animated:YES];
        
    }else if ([item isEqualToString:@"通知"]) {
        MSGController *msgVC = [mainStoryBoard instantiateViewControllerWithIdentifier:@"MSGController"];
        msgVC.hidesBottomBarWhenPushed = YES;
        [appDelegate.mainTabBarController.selectedViewController pushViewController:msgVC animated:YES];
        
    }else if ([item isEqualToString:@"切换家庭账号"]) {
       
        HostListViewController *vc = [loginStoryBoard instantiateViewControllerWithIdentifier:@"HostListVC"];
        vc.hidesBottomBarWhenPushed = YES;
        [appDelegate.mainTabBarController.selectedViewController pushViewController:vc animated:YES];
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 180;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 180)];
    view.backgroundColor = [UIColor clearColor];

    UIButton *headButton = [UIButton buttonWithType:UIButtonTypeCustom];
    headButton.frame = CGRectMake(CGRectGetWidth(view.frame)/2-25, 40, 50, 50);
    headButton.layer.cornerRadius = 25;
    [headButton setBackgroundImage:[UIImage imageNamed:@"logo"] forState:UIControlStateNormal];
    [view addSubview:headButton];
    [headButton addTarget:self action:@selector(headButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    
    UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(headButton.frame)+5, tableView.bounds.size.width, 20)];
    nameLabel.text = [UD objectForKey:@"UserName"];
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    [view addSubview:nameLabel];
    
    return view;
}

- (UIView *)setupTableFooter {
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UI_SCREEN_WIDTH, 100)];
    footer.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
    UIButton *settingBtn = [[UIButton alloc] initWithFrame:CGRectMake(30, 20, 50, 20)];
    [settingBtn setTitle:@"设置" forState:UIControlStateNormal];
    [settingBtn setImage:[UIImage imageNamed:@"my_setting"] forState:UIControlStateNormal];
    settingBtn.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    [settingBtn addTarget:self action:@selector(settingBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [footer addSubview:settingBtn];
    return footer;
}

- (void)settingBtnClicked:(UIButton *)btn {
     UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.LeftSlideVC closeLeftView];//关闭左侧抽屉
    
    MySettingViewController *mysettingVC = [mainStoryBoard instantiateViewControllerWithIdentifier:@"MySettingViewController"];
    mysettingVC.hidesBottomBarWhenPushed = YES;
    [appDelegate.mainTabBarController.selectedViewController pushViewController:mysettingVC animated:YES];
}


- (void)headButtonClicked:(UIButton *)btn {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [appDelegate.LeftSlideVC closeLeftView];//关闭左侧抽屉
    
    UIStoryboard *loginStoryBoard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    UIViewController *vc = [loginStoryBoard instantiateViewControllerWithIdentifier:@"userinfoVC"];
    vc.hidesBottomBarWhenPushed = YES;
    [appDelegate.mainTabBarController.selectedViewController pushViewController:vc animated:YES];
    
}


@end
