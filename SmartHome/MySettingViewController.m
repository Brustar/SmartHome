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
    return 6;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 2)
    {
        return 2;
    }
    return 1;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"settingCell" forIndexPath:indexPath];
    NSString *title;
    switch (indexPath.section) {
        case 0:
            title = @"推送设置";
            break;
        case 1:
            title = @"权限控制";
            break;
        case 2:
        {
            if(indexPath.row == 0)
            {
                title = @"系统设置";
            }else title = @"系统信息";
            
            break;
        }
        case 3:
            title = @"去评价";
            break;
        case 4:
            title = @"关于我们";
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
    
    if(indexPath.section == 0)
    {

        [self performSegueWithIdentifier:@"pushSegue" sender:self];
        
        
    }else if(indexPath.section == 1)
    {

        [self performSegueWithIdentifier:@"accessSegue" sender:self];
        
        
    }else if(indexPath.section == 2)
    {
        if(indexPath.row == 0)
        {

            [self performSegueWithIdentifier:@"systemSetSegue" sender:self];
        }else {
            [self performSegueWithIdentifier:@"systemInfoSegue" sender:self];
        }
    }else if(indexPath.section == 3)
    {
        [self gotoAppStoreToComment];
    
    }else if(indexPath.section == 4)
    {

         [self performSegueWithIdentifier:@"aboutSegue" sender:self];
    }else {
        //退出发送请求
        
        NSDictionary *dict = @{@"AuthorToken":[[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"]};
        
        NSString *url = [NSString stringWithFormat:@"%@UserLogOut.aspx",[IOManager httpAddr]];
        HttpManager *http=[HttpManager defaultManager];
        http.delegate=self;
        http.tag = 1;
        [http sendPost:url param:dict];
     
    }

}

-(void) httpHandler:(id) responseObject tag:(int)tag
{
    if([responseObject[@"Result"] intValue] == 0)
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"AuthorToken"];
        [[SocketManager defaultManager] cutOffSocket];
        self.splitViewController.preferredDisplayMode = UISplitViewControllerDisplayModePrimaryHidden;
        [self performSegueWithIdentifier:@"goLogin" sender:self];
        
    }else {
        [MBProgressHUD showSuccess:responseObject[@"Msg"]];
    }
    
}


-(void)gotoAppStoreToComment
{
    NSString *str = [NSString stringWithFormat:@"https://itunes.apple.com/cn/app/yi-yun-zhi-jia/id1034629669?mt=8"];
    NSURL * url = [NSURL URLWithString:str];
    
    if ([[UIApplication sharedApplication] canOpenURL:url])
    {
        [[UIApplication sharedApplication] openURL:url];
    }
    else
    {
        NSLog(@"can not open");
    }
}





@end
