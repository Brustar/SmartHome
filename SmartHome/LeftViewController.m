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
    [self addNotifications];
    [self getUserInfoFromDB];
    _itemArray = @[@"家庭成员",@"家庭动态",@"智能账单",@"通知",@"故障及保修记录",@"切换家庭账号"];

    
    UIButton *bgButton = [[UIButton alloc] initWithFrame:self.view.frame];
    [bgButton setBackgroundImage:[UIImage imageNamed:@"my_bg_side_nol"] forState:UIControlStateNormal];
    [bgButton addTarget:self action:@selector(bgButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:bgButton];
    
    _myTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:_myTableView.frame];
    imageView.image = [UIImage imageNamed:@"background"];
    _myTableView.backgroundView = imageView;
   // _myTableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
    _myTableView.dataSource = self;
    _myTableView.delegate  = self;
    _myTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _myTableView.tableHeaderView = [self setupTableHeader];
    _myTableView.tableFooterView = [self setupTableFooter];
    [self.view addSubview:_myTableView];
}

- (void)bgButtonClicked:(UIButton *)btn {
    if (_delegate && [_delegate respondsToSelector:@selector(onBackgroundBtnClicked:)]) {
        [_delegate onBackgroundBtnClicked:btn];
    }
}

- (void)getUserInfoFromDB {
    int userID = [[UD objectForKey:@"UserID"] intValue];
    _userInfo = [SQLManager getUserInfo:userID];
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

- (UIView *)setupTableHeader {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UI_SCREEN_WIDTH-100, 250)];
    view.backgroundColor = [UIColor clearColor];
    
    UIButton *headButton = [UIButton buttonWithType:UIButtonTypeCustom];
    headButton.frame = CGRectMake((CGRectGetWidth(view.frame)-100)/2, 60, 100, 100);
    headButton.layer.cornerRadius = 50;
    headButton.layer.masksToBounds = YES;
    [headButton sd_setImageWithURL:[NSURL URLWithString:_userInfo.headImgURL] forState:UIControlStateNormal placeholderImage:nil];
    [view addSubview:headButton];
    [headButton addTarget:self action:@selector(headButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    _headerBtn = headButton;
    
    UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(headButton.frame)+10, UI_SCREEN_WIDTH-100, 20)];
    nameLabel.text = _userInfo.userName;
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.font = [UIFont systemFontOfSize:15.0];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    [view addSubview:nameLabel];
    
    //VIP
    if ([_userInfo.vip isEqualToString:@"1"]) {  //VIP: 1(会员)   0(非会员)
        UIButton *vipBtn = [[UIButton alloc] initWithFrame:CGRectMake(FX(headButton)+10, CGRectGetMaxY(nameLabel.frame)+10, 30, 15)];
        vipBtn.userInteractionEnabled = NO;
        [vipBtn setBackgroundImage:[UIImage imageNamed:@"VIP_icon"] forState:UIControlStateNormal];
        vipBtn.titleLabel.font = [UIFont boldSystemFontOfSize:11];
        vipBtn.titleLabel.textColor = [UIColor whiteColor];
        [vipBtn setTitle:@"VIP" forState:UIControlStateNormal];
        [view addSubview:vipBtn];
        
        UILabel *vipLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(vipBtn.frame)+10, FY(vipBtn), 50, FH(vipBtn))];
        vipLabel.font = [UIFont boldSystemFontOfSize:11];
        vipLabel.textAlignment = NSTextAlignmentLeft;
        vipLabel.backgroundColor = [UIColor clearColor];
        vipLabel.textColor = [UIColor whiteColor];
        vipLabel.text = @"VIP会员";
        [view addSubview:vipLabel];
    }
    
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (UIView *)setupTableFooter {
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UI_SCREEN_WIDTH, 100)];
    footer.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
    
    //设置
    UIButton *settingBtn = [[UIButton alloc] initWithFrame:CGRectMake(40, 80, 50, 20)];
    [settingBtn setTitle:@"设置" forState:UIControlStateNormal];
    [settingBtn setImage:[UIImage imageNamed:@"my_setting"] forState:UIControlStateNormal];
    settingBtn.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    [settingBtn addTarget:self action:@selector(settingBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [footer addSubview:settingBtn];
    
    //皮肤
    UIButton *skinBtn = [[UIButton alloc] initWithFrame:CGRectMake(180, 80, 50, 20)];
    [skinBtn setTitle:@"皮肤" forState:UIControlStateNormal];
    [skinBtn setImage:[UIImage imageNamed:@"skin"] forState:UIControlStateNormal];
    skinBtn.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    [skinBtn addTarget:self action:@selector(skinBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [footer addSubview:skinBtn];
    
    return footer;
}

- (void)skinBtnClicked:(UIButton *)btn {
    [MBProgressHUD showError:@"待开发"];
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
    NSString *groupID = [[UD objectForKey:@"HostID"] description];
    NSString *homename = [UD objectForKey:@"homename"];

    RCGroup *aGroupInfo = [[RCGroup alloc]initWithGroupId:groupID groupName:homename portraitUri:@""];
    ConversationViewController *_conversationVC = [[ConversationViewController alloc] init];
    _conversationVC.conversationType = ConversationType_GROUP;
    _conversationVC.targetId = aGroupInfo.groupId;
    [_conversationVC setTitle: [NSString stringWithFormat:@"%@",aGroupInfo.groupName]];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.LeftSlideVC closeLeftView];//关闭左侧抽屉
    _conversationVC.hidesBottomBarWhenPushed = YES;
    [appDelegate.mainTabBarController.selectedViewController pushViewController:_conversationVC animated:YES];
}

- (void)addNotifications {
    [NC addObserver:self selector:@selector(refreshPortrait:) name:@"refreshPortrait" object:nil];
}

- (void)refreshPortrait:(NSNotification *)noti {
    NSString *portraitUrl = noti.object;
    [_headerBtn sd_setImageWithURL:[NSURL URLWithString:portraitUrl] forState:UIControlStateNormal placeholderImage:nil];
}

- (void)removeNotifications {
    [NC removeObserver:self];
}

- (void)dealloc {
    [self removeNotifications];
}

@end
