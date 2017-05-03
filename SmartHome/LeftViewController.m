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
        //家庭成员(聊天页面)
        [self setRCIM];
        
    }else if ([item isEqualToString:@"智能账单"]) {

        MySubEnergyVC *mySubEnergyVC = [myInfoStoryBoard instantiateViewControllerWithIdentifier:@"MySubEnergyVC"];
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

//进入聊天页面
-(void)setRCIM
{
    
    [[RCIM sharedRCIM] logout]; 
    NSString *token = [UD objectForKey:@"rctoken"];
    NSString *groupID = [[UD objectForKey:@"HostID"] description];
    NSString *homename = [UD objectForKey:@"homename"];
    [MBProgressHUD showMessage:@"login..."];
    [[RCIM sharedRCIM] connectWithToken:token success:^(NSString *userId) {
        NSLog(@"登陆成功。当前登录的用户ID：%@", userId);
        
        RCGroup *aGroupInfo = [[RCGroup alloc]initWithGroupId:groupID groupName:homename portraitUri:@""];
        ConversationViewController *_conversationVC = [[ConversationViewController alloc] init];
        _conversationVC.conversationType = ConversationType_GROUP;
        _conversationVC.targetId = aGroupInfo.groupId;
        [_conversationVC setTitle: [NSString stringWithFormat:@"%@",aGroupInfo.groupName]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUD];
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [appDelegate.LeftSlideVC closeLeftView];//关闭左侧抽屉
            _conversationVC.hidesBottomBarWhenPushed = YES;
            [appDelegate.mainTabBarController.selectedViewController pushViewController:_conversationVC animated:YES];
        });
    } error:^(RCConnectErrorCode status) {
        NSLog(@"登陆的错误码为:%ld", (long)status);
        [MBProgressHUD hideHUD];
    } tokenIncorrect:^{
        //token过期或者不正确。
        //如果设置了token有效期并且token过期，请重新请求您的服务器获取新的token
        //如果没有设置token有效期却提示token错误，请检查您客户端和服务器的appkey是否匹配，还有检查您获取token的流程。
        NSLog(@"token错误");
        [MBProgressHUD hideHUD];
    }];
    
}

@end
