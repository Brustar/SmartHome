//
//  MySettingViewController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/7/12.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "MySettingViewController.h"
#import "AccessSettingController.h"
#import "SystemSettingViewController.h"
#import "SystemInfomationController.h"
#import "AboutUsController.h"
#import "HttpManager.h"
#import "MBProgressHUD+NJ.h"
#import "AppDelegate.h"
#import "SocketManager.h"
#import "WelcomeController.h"
#import "PushSettingController.h"
#import "SystemSettingViewController.h"
#import "SystemInfomationController.h"
#import "AccessSettingController.h"
#import "AboutUsController.h"
#import "DeviceListTimeVC.h"
#import "IphoneSceneController.h"

@interface MySettingViewController ()<UITableViewDelegate,UITableViewDataSource,UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSArray *titleArr;
@property (nonatomic,strong) AccessSettingController *accessVC;
@property (nonatomic,strong) SystemSettingViewController *sySetVC;
@property (nonatomic,strong) SystemInfomationController *inforVC;
@property (nonatomic,strong) AboutUsController *aboutVC;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewTopConstraint;//顶部的距离
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewLeadingConstraint;//左边的距离
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewTainlingConstraint;//右边的距离

@end

@implementation MySettingViewController

-(void)viewWillAppear:(BOOL)animated
{
    if (ON_IPAD) {
        
        self.tableViewTopConstraint.constant = 60;
        self.tableViewLeadingConstraint.constant = 20;
        self.tableViewTainlingConstraint.constant = 20;
    }

}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView.tableFooterView = [UIView new];
//    self.tableView.backgroundColor =  [UIColor colorWithRed:241/255.0 green:240/255.0 blue:246/255.0 alpha:1];
    [self setupNaviBar];
}
- (void)setupNaviBar {
    
    [self setNaviBarTitle:@"设置"]; //设置标题
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        if ([[IOManager getUserDefaultForKey:@"UserType"] integerValue] == 2) { //如果是普通用户，不显示“权限控制”选项
            return 5;
        }
            return 6;//如果是主人，显示“权限控制”选项
    }else{
        if([[IOManager getUserDefaultForKey:@"UserType"] integerValue] == 2) { //2代表普通用户，如果是普通用户，不显示“权限控制”选项
            return 5;
        }else {
            return 6;//如果是主人，显示“权限控制”选项
        }
    }
    
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   
    if ([[IOManager getUserDefaultForKey:@"UserType"] integerValue] == 2) { //如果是普通用户，不显示“权限控制”选项
        if(section == 1)
        {
            return 2;
        }
    
    }else {
        if (section == 3) { // 场景快捷键，定时器，地址管理
            return 2;
        }
    }
    if (section ==2) {  //场景快捷键，定时器，地址管理
        return 3;
    }
    return 1;
}
-(void)viewDidLayoutSubviews {
    
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
        
    }
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)])  {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPat{
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]){
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"settingCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor colorWithRed:29/255.0 green:30/255.0 blue:34/255.0 alpha:1];
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    view.backgroundColor = [UIColor clearColor];
    cell.selectedBackgroundView = view;
    NSString *title;
    switch (indexPath.section) {
        case 0:
            title = @"推送设置";
            break;
        case 1:
            
            if ([[IOManager getUserDefaultForKey:@"UserType"] integerValue] == 2) {
                if(indexPath.row == 0)
                {
                    title = @"系统设置";
                }else {
                    title = @"系统信息";
                }
            }else {
                    title = @"权限控制";
            }
            
            break;
        case 2:
                if(indexPath.row == 0)
                {
                    title = @"场景快捷键";
                }else if(indexPath.row == 1){
                    title = @"定时器";
                }else {
                    title = @"地址管理";
                }
            break;
        case 3:
        {
           if ([[IOManager getUserDefaultForKey:@"UserType"] integerValue] == 2) {
                    title = @"去评价";
           }else {
               if(indexPath.row == 0)
               {
                    title = @"系统设置";
               }else {
                    title = @"系统信息";
               }
           }
            
            break;
        }
        case 4:
            if ([[IOManager getUserDefaultForKey:@"UserType"] integerValue] == 2) {
                title = @"关于我们";
            }else {
               
                title = @"去评价";
            }
            
            break;
        case 5:
            if ([[IOManager getUserDefaultForKey:@"UserType"] integerValue] == 2) {
                title = @"退出";
            }else{
                title = @"关于我们";
            }
            
            break;
        default:
            title = @"退出";
            cell.textLabel.textColor = [UIColor redColor];
            break;
    }
    cell.textLabel.text = title;
    
    return cell;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView * view = [UIView new];
    view.frame = CGRectMake(0, 0, self.view.bounds.size.width, 0.3);
    view.backgroundColor = [UIColor whiteColor];
    return view;
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.3;
    
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * view = [UIView new];
    view.frame = CGRectMake(0, 0, self.view.bounds.size.width, 20);
    UILabel * la = [[UILabel alloc] initWithFrame:CGRectMake(0, 19.5, self.view.bounds.size.width,0.5)];
    la.backgroundColor = [UIColor whiteColor];
    
    [view addSubview:la];
    
    return view;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{

    return 20;
}
-(void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section

{
    view.backgroundColor = [UIColor blackColor];
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self goToViewController:indexPath];
}
-(void)goToViewController:(NSIndexPath *)indexPath
{
   UIStoryboard * MainBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIStoryboard * iphoneBoard = [UIStoryboard storyboardWithName:@"iPhone" bundle:nil];
    UIStoryboard *myInfoStoryBoard  = [UIStoryboard storyboardWithName:@"MyInfo" bundle:nil];
    if(indexPath.section == 0)
    {
        PushSettingController * pushVC = [MainBoard instantiateViewControllerWithIdentifier:@"PushSettingController"];
        [self.navigationController pushViewController:pushVC animated:YES];
    }else if(indexPath.section == 1)
    {
       if ([[IOManager getUserDefaultForKey:@"UserType"] integerValue] == 2) {
           if(indexPath.row == 0)
           {
               SystemSettingViewController * systemVC = [MainBoard instantiateViewControllerWithIdentifier:@"SystemSettingViewController"];
               [self.navigationController pushViewController:systemVC animated:YES];
           }else {
               SystemInfomationController * systemInfoVC = [MainBoard instantiateViewControllerWithIdentifier:@"systemInfomationController"];
               [self.navigationController pushViewController:systemInfoVC animated:YES];
           }
       }else {
           AccessSettingController * accessVC = [MainBoard instantiateViewControllerWithIdentifier:@"AccessSettingController"];
           [self.navigationController pushViewController:accessVC animated:YES];
        }
        
      }else if (indexPath.section == 2){
          if (indexPath.row == 0) {
              //场景快捷键
              SceneShortcutsViewController *vc = [myInfoStoryBoard instantiateViewControllerWithIdentifier:@"SceneShortcutsVC"];
              [self.navigationController pushViewController:vc animated:YES];
          }else if(indexPath.row == 1){
              //定时器
              DeviceListTimeVC * deviceList = [iphoneBoard instantiateViewControllerWithIdentifier:@"iPhoneDeviceListTimeVC"];
              [self.navigationController pushViewController:deviceList animated:YES];
          }else { // 地址管理
              DeliveryAddressViewController *vc = [myInfoStoryBoard instantiateViewControllerWithIdentifier:@"DeliveryAddressVC"];
              vc.hidesBottomBarWhenPushed = YES;
              [self.navigationController pushViewController:vc animated:YES];
          }
        
     }else if(indexPath.section == 3)
     {
        if ([[IOManager getUserDefaultForKey:@"UserType"] integerValue] == 2) {
                [self gotoAppStoreToComment];
        }else {
            if(indexPath.row == 0)
            {
            SystemSettingViewController * systemVC = [MainBoard instantiateViewControllerWithIdentifier:@"SystemSettingViewController"];
                [self.navigationController pushViewController:systemVC animated:YES];
            }else {
         SystemInfomationController * systemInfoVC = [MainBoard instantiateViewControllerWithIdentifier:@"systemInfomationController"];
                [self.navigationController pushViewController:systemInfoVC animated:YES];
            }
        }
        
        
    }else if(indexPath.section == 4)
    {
        if ([[IOManager getUserDefaultForKey:@"UserType"] integerValue] == 2) {
           AboutUsController * aboutVC = [MainBoard instantiateViewControllerWithIdentifier:@"AboutUsController"];
            [self.navigationController pushViewController:aboutVC animated:YES];
        }else {
            [self gotoAppStoreToComment];
        }
    
    }else if(indexPath.section == 5)
    {
        if ([[IOManager getUserDefaultForKey:@"UserType"] integerValue] == 2) {
            AboutUsController * aboutVC = [MainBoard instantiateViewControllerWithIdentifier:@"AboutUsController"];
            [self.navigationController pushViewController:aboutVC animated:YES];
            //退出发送请求
            NSString *authorToken =[[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"];
            if (authorToken) {
                NSDictionary *dict = @{@"token":authorToken};
                
                NSString *url = [NSString stringWithFormat:@"%@login/logout.aspx",[IOManager httpAddr]];
                HttpManager *http=[HttpManager defaultManager];
                http.delegate=self;
                http.tag = 1;
                [http sendPost:url param:dict];
            }else{
                //跳转到欢迎页
                //self.splitViewController.preferredDisplayMode = UISplitViewControllerDisplayModePrimaryHidden;
                //[self performSegueWithIdentifier:@"goWelcomeSegue" sender:self];
                [self gotoLoginViewController];
            }

        }else{
            AboutUsController * aboutVC = [MainBoard instantiateViewControllerWithIdentifier:@"AboutUsController"];
            [self.navigationController pushViewController:aboutVC animated:YES];
        }
        
    }else {
        //退出发送请求
        NSString *authorToken =[[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"];
        if (authorToken) {
            NSDictionary *dict = @{@"token":authorToken};
        
            NSString *url = [NSString stringWithFormat:@"%@login/logout.aspx",[IOManager httpAddr]];
            HttpManager *http=[HttpManager defaultManager];
            http.delegate=self;
            http.tag = 1;
            [http sendPost:url param:dict];
        }else{
            //跳转到欢迎页
            //self.splitViewController.preferredDisplayMode = UISplitViewControllerDisplayModePrimaryHidden;
            //[self performSegueWithIdentifier:@"goWelcomeSegue" sender:self];
            [self gotoLoginViewController];
        }
    }

}
//退出登录
- (IBAction)QuitBtn:(id)sender {
    //退出发送请求
    NSString *authorToken =[[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"];
    if (authorToken) {
        NSDictionary *dict = @{@"token":authorToken};
        
        NSString *url = [NSString stringWithFormat:@"%@login/logout.aspx",[IOManager httpAddr]];
        HttpManager *http=[HttpManager defaultManager];
        http.delegate=self;
        http.tag = 1;
        [http sendPost:url param:dict];
    }else{
        //跳转到欢迎页
        //self.splitViewController.preferredDisplayMode = UISplitViewControllerDisplayModePrimaryHidden;
        //[self performSegueWithIdentifier:@"goWelcomeSegue" sender:self];
        [self gotoLoginViewController];
    }
    
    [[RCIM sharedRCIM] logout];
}

- (void)gotoLoginViewController {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    UIViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"loginNavController"];//进入登录页面
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.window.rootViewController = vc;
    [appDelegate.window makeKeyAndVisible];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"goWelcomeSegue"])
    {
        WelcomeController *welcomeVC = segue.destinationViewController;
        welcomeVC.coverView.hidden = YES;
    }
}
-(void) httpHandler:(id) responseObject tag:(int)tag
{
    if(tag == 1)
    {
        if([responseObject[@"Result"] intValue] == 0)
        {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"AuthorToken"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [[SocketManager defaultManager] cutOffSocket];
            
            
            //self.splitViewController.preferredDisplayMode = UISplitViewControllerDisplayModePrimaryHidden;
            //[self performSegueWithIdentifier:@"goLogin" sender:self];
            
            [self gotoLoginViewController];
            
            
        }else {
            [MBProgressHUD showSuccess:responseObject[@"Msg"]];
        }

    }
    
}
-(void)gotoAppStoreToComment
{
    NSString *str = [NSString stringWithFormat:@"https://itunes.apple.com/cn/app/yi-yun-zhi-neng-jia-ju/id1173335171?l=zh&ls=1&mt=8"];
    NSURL * url = [NSURL URLWithString:str];
    
    if ([[UIApplication sharedApplication] canOpenURL:url])
    {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    }
    else
    {
        NSLog(@"can not open");
    }
}

@end
