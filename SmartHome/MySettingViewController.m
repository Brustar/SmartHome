//
//  MySettingViewController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/7/12.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "MySettingViewController.h"

@interface MySettingViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSArray *titleArr;

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
    if(indexPath.row == 0)
    {
        self.pushVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"PushSettingController"];
        self.pushVC.view.frame = self.view.bounds;
        [self.view addSubview:self.pushVC.view];
        
    }
}


//-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    self.pushVC = segue.destinationViewController;
//    
//    self.pushVC.view.frame = CGRectMake(100, 100, 200, 400);
//    [self.view addSubview:self.pushVC.view];
//    
//    
//}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
