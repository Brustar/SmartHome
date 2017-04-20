//
//  WeekdaysVC.m
//  SmartHome
//
//  Created by zhaona on 2017/1/11.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "WeekdaysVC.h"
#import "WeekDaysCell.h"

@interface WeekdaysVC ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (nonatomic,strong) NSMutableArray * dataArr;
@end

@implementation WeekdaysVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.dataArr = [NSMutableArray arrayWithObjects:@"每周日",@"每周一",@"每周二",@"每周三",@"每周四",@"每周五",@"每周六", nil];
     self.tableview.scrollEnabled = NO;
    UIView *view = [[UIView alloc] init];
    [view setBackgroundColor:[UIColor clearColor]];
    self.tableview.tableFooterView = view;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArr.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WeekDaysCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
   
    cell.weekDayLabel.text = self.dataArr[indexPath.row];
    [self sendNotification:indexPath.row select:0];
    return cell;

}
- (void)sendNotification:(NSInteger)week select:(NSInteger)select
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"week"] = [NSString stringWithFormat:@"%ld", (long)week];
    dict[@"select"] = [NSString stringWithFormat:@"%ld", (long)select];
    
    [center postNotificationName:@"SelectWeek" object:nil userInfo:dict];
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if(cell.accessoryType == UITableViewCellAccessoryNone)
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        [self sendNotification:indexPath.row select:1];
    }else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        [self sendNotification:indexPath.row select:0];
    }
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
