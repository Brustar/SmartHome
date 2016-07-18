//
//  SystemSettingViewController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/7/18.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "SystemSettingViewController.h"
#import "SystemCell.h"
@interface SystemSettingViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong)NSArray *titles;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation SystemSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titles = @[@"开启向导",@"开启每日提示",@"开启智能过滤",@"全部场景静音"];
    self.tableView.tableFooterView = [UIView new];
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.titles.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SystemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SystemCell" forIndexPath:indexPath];
    cell.title.text = self.titles[indexPath.row];
   
    return cell;
    
}
- (IBAction)returnToSetting:(id)sender {
    [self.view removeFromSuperview];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
