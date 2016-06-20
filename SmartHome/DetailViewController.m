//
//  DetailViewController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/6/2.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "DetailViewController.h"
#import "Detail.h"
#import "DetailList.h"
@interface DetailViewController ()

@property (nonatomic,strong) NSArray *detailArray;
@property (nonatomic,strong) NSArray *titleArr;

@end

@implementation DetailViewController

//-(NSArray *)detailArray
//{
//    if(!_detailArray)
//    {
//        _detailArray = [DetailList getDetailListWithID:2];
//    }
//    return _detailArray;
//    
//}
-(void)setDeviceid:(NSString*)deviceID
{
    _deviceid = deviceID;
    self.detailArray = [DetailList getDetailListWithID:[deviceID intValue]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self detailArray];
    self.navigationItem.title = @"详细信息";
    self.titleArr = @[@"设备",@"序列号",@"生产日期",@"保修截止日期",@"型号",@"购买价格",@"购买日期",@"生产厂商",@"保修电话",@"功率",@"输入电流",@"输入电压",@"社区推荐"];
    
    //self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(40, 0, self.view.frame.size.width - 80, self.view.frame.size.height)];
    
    self.tableView.backgroundColor = [UIColor colorWithRed:170/255.0 green:170/255.0 blue:170/255.0 alpha:1];
    self.tableView.tableFooterView = [UIView new];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    self.view.backgroundColor = self.tableView.backgroundColor;
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0)
    {
        return 1;
    }
    
    return self.detailArray.count -1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        
    }
    if(indexPath.section == 0)
    {
        cell.textLabel.text= self.titleArr[0];
        cell.detailTextLabel.text = self.detailArray[0];
    }else{
        cell.textLabel.text= self.titleArr[indexPath.row +1];
        cell.detailTextLabel.text = self.detailArray[indexPath.row +1];
        if(indexPath.row == 7)
        {
            cell.detailTextLabel.textColor = [UIColor blueColor];
        }

    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 20;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footView = [[UIView alloc]init];
    footView.backgroundColor = self.tableView.backgroundColor;
    return footView;
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
