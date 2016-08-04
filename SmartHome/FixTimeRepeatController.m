//
//  FixTimeRepeatController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/8/1.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "FixTimeRepeatController.h"

@interface FixTimeRepeatController ()<UITableViewDelegate ,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSArray *weekDays;
@end

@implementation FixTimeRepeatController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.weekDays = @[@"每周日",@"每周一",@"每周二",@"每周三",@"每周四",@"每周五",@"每周六"];
    self.tableView.tableFooterView = [UIView new];
    self.tableView.scrollEnabled = NO;
}

-(CGSize)preferredContentSize
{
    if(self.presentingViewController && self.tableView != nil)
    {
        CGSize tempSize = self.presentingViewController.view.bounds.size;
        tempSize.width = 200;
        CGSize size = [self.tableView sizeThatFits:tempSize];
        return size;
    }else {
        return [super preferredContentSize];
    }
}
-(void)setPreferredContentSize:(CGSize)preferredContentSize
{
    super.preferredContentSize = preferredContentSize;
}

#pragma mark - UITableViewDelegate


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.weekDays.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(!cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
          [self sendNotification:indexPath.row select:1];
        
    }
         cell.textLabel.text = self.weekDays[indexPath.row];
    
   
   
   
    
    return cell;
}
- (void)sendNotification:(NSInteger)week select:(NSInteger)select
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"week"] = [NSString stringWithFormat:@"%ld", week];
    dict[@"select"] = [NSString stringWithFormat:@"%ld", select];
    
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



@end
