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

@interface MySettingViewController ()<UITableViewDelegate,UITableViewDataSource,UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSArray *titleArr;
@property (nonatomic,strong) AccessSettingController *accessVC;
@property (nonatomic,strong) SystemSettingViewController *sySetVC;
@property (nonatomic,strong) systemInfomationController *inforVC;
@property (nonatomic,strong) AboutUsController *aboutVC;
@end

@implementation MySettingViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor =  [UIColor colorWithRed:241/255.0 green:240/255.0 blue:246/255.0 alpha:1];

    // Do any additional setup after loading the view.
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
    UIStoryboard *sy = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    if(indexPath.section == 0)
    {
        self.pushVC = [sy instantiateViewControllerWithIdentifier:@"PushSettingController"];
        self.pushVC.view.frame = self.view.bounds;
        [self.view addSubview:self.pushVC.view];
        
        
    }else if(indexPath.section == 1)
    {
        
            self.accessVC = [sy instantiateViewControllerWithIdentifier:@"AccessSettingController"];
            self.accessVC.view.frame = self.view.bounds;
            [self.view addSubview:self.accessVC.view];
        
        
        
    }else if(indexPath.section == 2)
    {
        if(indexPath.row == 0)
        {
            self.sySetVC = [sy instantiateViewControllerWithIdentifier:@"SystemSettingViewController"];
            self.sySetVC.view.frame = self.view.bounds;
            [self.view addSubview:self.sySetVC.view];
        }else {
            self.inforVC = [sy instantiateViewControllerWithIdentifier:@"systemInfomationController"];
            self.inforVC.view.frame = self.view.bounds;
            [self.view addSubview:self.inforVC.view];
        }
    }else if(indexPath.section == 3)
    {
        [self gotoAppStoreToComment];
    
    }else if(indexPath.section == 4)
    {
        self.aboutVC = [sy instantiateViewControllerWithIdentifier:@"AboutUsController"];
        self.aboutVC.view.frame = self.view.bounds;
        [self.view addSubview:self.aboutVC.view];
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


-(void)removeAllSubViewFromMySettingController
{
    [self.accessVC.view removeFromSuperview];
    [self.pushVC.view removeFromSuperview];
    [self.sySetVC.view removeFromSuperview];
    [self.inforVC.view removeFromSuperview];
    [self.aboutVC.view removeFromSuperview];
}


@end
