//
//  systemInfomationController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/7/18.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "systemInfomationController.h"

@interface systemInfomationController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSArray *titles;
@end

@implementation systemInfomationController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titles = @[@"家庭名称",@"主机编号",@"主机品牌",@"主机型号"];
    self.tableView.tableFooterView = [UIView new];
    // Do any additional setup after loading the view.
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.titles.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = self.titles[indexPath.row];
    cell.detailTextLabel.text = @"逸云智家";
    return  cell;
}
- (IBAction)retunToSetting:(id)sender {
    [self.view removeFromSuperview];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


@end
