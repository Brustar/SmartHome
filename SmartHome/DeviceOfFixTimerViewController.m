//
//  DeviceOfFixTimerViewController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/9/27.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "DeviceOfFixTimerViewController.h"

@interface DeviceOfFixTimerViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSArray *devices;
@end

@implementation DeviceOfFixTimerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.devices.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(!cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = self.devices[indexPath.row];
    return cell;
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}



@end
