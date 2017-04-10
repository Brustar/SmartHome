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
    _itemArray = @[@"我的故障",@"我的保修记录",@"我的能耗",@"我的收藏",@"我的消息",@"我的家庭成员",@"首页场景快捷键",@"我的设置"];
    
    UIImageView *imageview = [[UIImageView alloc] initWithFrame:self.view.bounds];
    imageview.image = [UIImage imageNamed:@"leftbackiamge"];
    [self.view addSubview:imageview];
    
    UITableView *tableview = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    tableview.dataSource = self;
    tableview.delegate  = self;
    tableview.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
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
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.font = [UIFont systemFontOfSize:16.0f];
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.text = [_itemArray objectAtIndex:indexPath.row];
   
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIStoryboard *iPhoneStoryBoard  = [UIStoryboard storyboardWithName:@"iPhone" bundle:nil];
    UIStoryboard *MyInfoStoryBoard  = [UIStoryboard storyboardWithName:@"MyInfo" bundle:nil];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.LeftSlideVC closeLeftView];//关闭左侧抽屉
    
    NSString *item = [_itemArray objectAtIndex:indexPath.row];
    if ([item isEqualToString:@"我的故障"]) {
        ProfileFaultsViewController *profileFaultsVC = [mainStoryBoard instantiateViewControllerWithIdentifier:@"MyDefaultViewController"];
        profileFaultsVC.hidesBottomBarWhenPushed = YES;
        [appDelegate.mainTabBarController.selectedViewController pushViewController:profileFaultsVC animated:YES];
    }else if ([item isEqualToString:@"我的保修记录"]) {
        ServiceRecordViewController *serviceRecordVC = [mainStoryBoard instantiateViewControllerWithIdentifier:@"ServiceRecordViewController"];
        serviceRecordVC.hidesBottomBarWhenPushed = YES;
        [appDelegate.mainTabBarController.selectedViewController pushViewController:serviceRecordVC animated:YES];
        
    }else if ([item isEqualToString:@"我的能耗"]) {
        MySubEnergyVC *mySubEnergyVC = [mainStoryBoard instantiateViewControllerWithIdentifier:@"MyEnergyViewController"];
        mySubEnergyVC.hidesBottomBarWhenPushed = YES;
        [appDelegate.mainTabBarController.selectedViewController pushViewController:mySubEnergyVC animated:YES];
        
    }else if ([item isEqualToString:@"我的收藏"]) {
        IphoneFavorController *favorVC = [iPhoneStoryBoard instantiateViewControllerWithIdentifier:@"IphoneFavorController"];
        favorVC.hidesBottomBarWhenPushed = YES;
        [appDelegate.mainTabBarController.selectedViewController pushViewController:favorVC animated:YES];
        
    }else if ([item isEqualToString:@"我的消息"]) {
        MSGController *msgVC = [mainStoryBoard instantiateViewControllerWithIdentifier:@"MSGController"];
        msgVC.hidesBottomBarWhenPushed = YES;
        [appDelegate.mainTabBarController.selectedViewController pushViewController:msgVC animated:YES];
        
    }else if ([item isEqualToString:@"我的设置"]) {
        MySettingViewController *mysettingVC = [mainStoryBoard instantiateViewControllerWithIdentifier:@"MySettingViewController"];
        mysettingVC.hidesBottomBarWhenPushed = YES;
        [appDelegate.mainTabBarController.selectedViewController pushViewController:mysettingVC animated:YES];
        
    }else if ([item isEqualToString:@"我的家庭成员"]) {
        [MBProgressHUD showError:@"开发中"];
    }else if ([item isEqualToString:@"首页场景快捷键"]){
        ShortcutKeyViewController *ShortcutKeyVC = [MyInfoStoryBoard instantiateViewControllerWithIdentifier:@"ShortcutKeyViewController"];
        ShortcutKeyVC.hidesBottomBarWhenPushed = YES;
        [appDelegate.mainTabBarController.selectedViewController pushViewController:ShortcutKeyVC animated:YES];
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


- (void)headButtonClicked:(UIButton *)btn {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [appDelegate.LeftSlideVC closeLeftView];//关闭左侧抽屉
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MyInfo" bundle:nil];
    UIViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"VipServiceListVC"];
    vc.hidesBottomBarWhenPushed = YES;
    [appDelegate.mainTabBarController.selectedViewController pushViewController:vc animated:YES];
    
}


@end
