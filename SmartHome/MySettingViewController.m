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
    self.titleArr = @[@"推送设置",@"权限控制",@"系统设置",@"系统信息",@"去评价",@"关于我们",@"退出"];
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
            break;
    }
    cell.textLabel.text = title;
    
    return cell;
}
-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 40)];
    return view;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
