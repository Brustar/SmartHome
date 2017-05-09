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
      cell.tintColor = [UIColor redColor];
     [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(cell.accessoryType == UITableViewCellAccessoryNone)
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        [self sendNotification:indexPath.row select:1];
    }else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        [self sendNotification:indexPath.row select:0];
    }
    
}
-(void)viewDidLayoutSubviews {
    
    if ([self.tableview respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableview setSeparatorInset:UIEdgeInsetsZero];
        
    }
    if ([self.tableview respondsToSelector:@selector(setLayoutMargins:)])  {
        [self.tableview setLayoutMargins:UIEdgeInsetsZero];
    }
    
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPat{
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]){
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView * view = [[UIView alloc] init];
    view.frame  = CGRectMake(0, 0, self.view.bounds.size.width, 50);
    UIView * line1 = [[UIView alloc] init];
    line1.frame = CGRectMake(0, 0, self.view.bounds.size.width, 1);
    line1.backgroundColor = [UIColor colorWithRed:115/255.0 green:116/255.0 blue:119/255.0 alpha:1];
    [view addSubview:line1];
    UIButton * button = [[UIButton alloc] init];
    button.frame = CGRectMake(0, 1, self.view.bounds.size.width, 49);
    [button setBackgroundImage:[UIImage imageNamed:@"tm_fm_high_normal"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"icon_pull_normal"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(weekButton:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button];
    
    return view;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section

{
    
    return 50;
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)weekButton:(id)sender {
    
    if (_delegate && [_delegate respondsToSelector:@selector(onWeekButtonClicked:)]) {
        [_delegate onWeekButtonClicked:sender];
    }
}

@end
