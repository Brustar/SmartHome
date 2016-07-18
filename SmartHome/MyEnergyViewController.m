//
//  MyEnergyViewController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/7/14.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "MyEnergyViewController.h"
#import "MyEnergyCell.h"
@interface MyEnergyViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation MyEnergyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView =[UIView new];
    // Do any additional setup after loading the view.
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MyEnergyCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyEnergyCell" forIndexPath:indexPath];
    
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
