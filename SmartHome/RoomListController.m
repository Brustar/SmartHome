//
//  RoomListController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/7/30.
//  Copyright © 2016年 Brustar. All rights reserved.
//
#define backGroudColour [UIColor colorWithRed:55/255.0 green:73/255.0 blue:91/255.0 alpha:1]

#import "RoomListController.h"
#import "AddSenseCell.h"
@interface RoomListController ()<UITableViewDataSource,UITableViewDelegate,UIPickerViewDelegate,UIPickerViewDataSource>
@property (nonatomic,strong) NSArray *rooms;
@property (weak, nonatomic) IBOutlet UIView *timeView;
@property (weak, nonatomic) IBOutlet UIButton *repeatBtn;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation RoomListController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView.tableFooterView = [UIView new];
    self.rooms = @[@"客厅",@"主卧",@"书房"];
    
    [self.tableView selectRowAtIndexPath:0 animated:YES scrollPosition:UITableViewScrollPositionTop];
    self.splitViewController.maximumPrimaryColumnWidth = 250;
    self.tableView.backgroundColor = backGroudColour;
  
}
#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.rooms.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AddSenseCell *cell = [tableView dequeueReusableCellWithIdentifier:@"roomListCell" forIndexPath:indexPath];
    cell.roomName.text = self.rooms[indexPath.row];
    
    
    return cell;
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    cell.backgroundColor = backGroudColour;

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //当点击某一行时，通过房间ID获得所有的设备
    if([self.delegate respondsToSelector:@selector(RoomListControllerDelegate:SelectedRoom:)])
    {
        [self.delegate RoomListControllerDelegate:self SelectedRoom:indexPath.row];
    }
}
- (IBAction)clickFixTimeBtn:(id)sender {
}

#pragma  mark - UIPickerViewDelegate
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 3;
}
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if(component == 0)
    {
        return 24;
    }else if(component == 1)
    {
        return 60;
    }else {
        return 2;
    }
}
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if(component == 0 || component== 1)
    {
        return [NSString stringWithFormat:@"0%ld",row];
    }else {
        if(row == 0)
        {
            return @"上午";
        }else return @"下午";
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
