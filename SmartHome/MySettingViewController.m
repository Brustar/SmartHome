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
#import "systemInfomationController.h"
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

@interface MySettingViewController ()<UITableViewDelegate,UITableViewDataSource,UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSArray *titleArr;
@property (nonatomic,strong) AccessSettingController *accessVC;
@property (nonatomic,strong) SystemSettingViewController *sySetVC;
@property (nonatomic,strong) SystemInfomationController *inforVC;
@property (nonatomic,strong) AboutUsController *aboutVC;

@end

@implementation MySettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"设置";
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor =  [UIColor colorWithRed:241/255.0 green:240/255.0 blue:246/255.0 alpha:1];
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
            return 4;
        }
        return 5;//如果是主人，显示“权限控制”选项
    }else{
        return 6;
    }
    
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   
    if ([[IOManager getUserDefaultForKey:@"UserType"] integerValue] == 1) { //如果是普通用户，不显示“权限控制”选项
        if(section == 1)
        {
            return 1;
        }if (section == 2) {
            
            return 2;
        }
    
    }else {
        if(section == 1)
        {
            return 2;
        }if (section == 2) {
            return 1;
        }
    }
    
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"settingCell" forIndexPath:indexPath];
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
        case 3:
            if ([[IOManager getUserDefaultForKey:@"UserType"] integerValue] == 2) {
                title = @"关于我们";
            }else {
               
                title = @"去评价";
            }
            
            break;
        case 4:
            if ([[IOManager getUserDefaultForKey:@"UserType"] integerValue] == 2) {
                title = @"关于我们";
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
-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc]init];
    if(section == 1)
    {
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, 15, 400, 20)];
        label.font = [UIFont systemFontOfSize:15];
        label.text = @"请在“设置->通知中心”中更改";
        label.textColor = [UIColor grayColor];
        [view addSubview:label];
    }
    
    
    view.backgroundColor = [UIColor colorWithRed:241/255.0 green:240/255.0 blue:246/255.0 alpha:1];
    return view;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section == 4 || section == 5)
    {
        return 25;
    }
    return 50;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self goToViewController:indexPath];
}
-(void)goToViewController:(NSIndexPath *)indexPath
{
   UIStoryboard * MainBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];   
    if(indexPath.section == 0)
    {

//        [self performSegueWithIdentifier:@"pushSegue" sender:self];
        PushSettingController * pushVC = [MainBoard instantiateViewControllerWithIdentifier:@"PushSettingController"];
        [self.navigationController pushViewController:pushVC animated:YES];
        
        
    }else if(indexPath.section == 1)
    {
       if ([[IOManager getUserDefaultForKey:@"UserType"] integerValue] == 2) {
           if(indexPath.row == 0)
           {
//               [self performSegueWithIdentifier:@"systemSetSegue" sender:self];
               SystemSettingViewController * systemVC = [MainBoard instantiateViewControllerWithIdentifier:@"SystemSettingViewController"];
               [self.navigationController pushViewController:systemVC animated:YES];
           }else {
//               [self performSegueWithIdentifier:@"systemInfoSegue" sender:self];
               SystemInfomationController * systemInfoVC = [MainBoard instantiateViewControllerWithIdentifier:@"systemInfomationController"];
               [self.navigationController pushViewController:systemInfoVC animated:YES];
           }
       }else {
           AccessSettingController * accessVC = [MainBoard instantiateViewControllerWithIdentifier:@"AccessSettingController"];
           [self.navigationController pushViewController:accessVC animated:YES];
           
//            [self performSegueWithIdentifier:@"accessSegue" sender:self];
       }
        
    }else if(indexPath.section == 2)
    {
        if ([[IOManager getUserDefaultForKey:@"UserType"] integerValue] == 2) {
                [self gotoAppStoreToComment];
        }else {
            if(indexPath.row == 0)
            {
//                [self performSegueWithIdentifier:@"systemSetSegue" sender:self];
            SystemSettingViewController * systemVC = [MainBoard instantiateViewControllerWithIdentifier:@"SystemSettingViewController"];
                [self.navigationController pushViewController:systemVC animated:YES];
            }else {
//                [self performSegueWithIdentifier:@"systemInfoSegue" sender:self];
         SystemInfomationController * systemInfoVC = [MainBoard instantiateViewControllerWithIdentifier:@"systemInfomationController"];
                [self.navigationController pushViewController:systemInfoVC animated:YES];
            }
        }
        
        
    }else if(indexPath.section == 3)
    {
        if ([[IOManager getUserDefaultForKey:@"UserType"] integerValue] == 2) {
           AboutUsController * aboutVC = [MainBoard instantiateViewControllerWithIdentifier:@"AboutUsController"];
            [self.navigationController pushViewController:aboutVC animated:YES];
//            [self performSegueWithIdentifier:@"aboutSegue" sender:self];
        }else {
            [self gotoAppStoreToComment];
        }
    
    }else if(indexPath.section == 4)
    {
        if ([[IOManager getUserDefaultForKey:@"UserType"] integerValue] == 2) {
//            [self performSegueWithIdentifier:@"aboutSegue" sender:self];
            AboutUsController * aboutVC = [MainBoard instantiateViewControllerWithIdentifier:@"AboutUsController"];
            [self.navigationController pushViewController:aboutVC animated:YES];
        }else{
//             [self performSegueWithIdentifier:@"aboutSegue" sender:self];
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
            self.splitViewController.preferredDisplayMode = UISplitViewControllerDisplayModePrimaryHidden;
            [self performSegueWithIdentifier:@"goWelcomeSegue" sender:self];
        }
    }

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
            self.splitViewController.preferredDisplayMode = UISplitViewControllerDisplayModePrimaryHidden;
            [self performSegueWithIdentifier:@"goLogin" sender:self];
            
            
        }else {
            [MBProgressHUD showSuccess:responseObject[@"Msg"]];
        }

    }
    
}
-(void)gotoAppStoreToComment
{
    NSString *str = [NSString stringWithFormat:@"https://itunes.apple.com/cn/app/yi-yun-zhi-jia/id1034629669?mt=8"];
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
