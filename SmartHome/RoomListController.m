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
#import "FixTimeRepeatController.h"
@interface RoomListController ()<UITableViewDataSource,UITableViewDelegate,UIPickerViewDelegate,UIPickerViewDataSource>
@property (nonatomic,strong) NSArray *rooms;
@property (weak, nonatomic) IBOutlet UIView *timeView;
@property (weak, nonatomic) IBOutlet UIButton *repeatBtn;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSArray *hours;
@property (nonatomic,strong) NSArray *minutes;
@property (nonatomic,assign) BOOL isForenoon;
@property (nonatomic,strong) NSArray *noon;
@property (nonatomic,strong) FixTimeRepeatController *fixTimeVC;
@property (nonatomic,strong) NSMutableArray *weeks;
@end

@implementation RoomListController

-(NSArray *)hours
{
    if(!_hours)
    {
        NSMutableArray *arr = [NSMutableArray array];
        for(int i = 0; i< 24; i++)
        {
            if(i < 10){
                [arr addObject:[NSString stringWithFormat:@"0%d",i]];
            }else{
                [arr addObject:[NSString stringWithFormat:@"%d",i]];
            }
            
        }
        _hours = [arr copy];
    }
    return _hours;
}
-(NSArray *)minutes
{
    if(!_minutes)
    {
        NSMutableArray *arr = [NSMutableArray array];
        for(int i = 0; i< 60; i++)
        {
            if(i < 10){
                [arr addObject:[NSString stringWithFormat:@"0%d",i]];
            }else{
                [arr addObject:[NSString stringWithFormat:@"%d",i]];
            }

        }
        _minutes = [arr copy];

    }
    return _minutes;
}
-(NSArray *)noon{
    if(!_noon)
    {
        _noon = @[@"AM",@"PM"];
    }
    return _noon;
}
-(FixTimeRepeatController *)fixTimeVC
{
    if(!_fixTimeVC)
    {
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        _fixTimeVC = [story instantiateViewControllerWithIdentifier:@"FixTimeRepeatController"];
    }
    return _fixTimeVC;
}
-(NSMutableArray *)weeks
{
    if(!_weeks)
    {
        _weeks = [NSMutableArray array];
    }
    return _weeks;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.timeView.layer.cornerRadius = 10;
    self.timeView.layer.masksToBounds = YES;

    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView.tableFooterView = [UIView new];
    self.rooms = @[@"客厅",@"主卧",@"书房"];
    
    [self.tableView selectRowAtIndexPath:0 animated:YES scrollPosition:UITableViewScrollPositionTop];
    self.splitViewController.maximumPrimaryColumnWidth = 250;
    self.tableView.backgroundColor = backGroudColour;
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectWeek:) name:@"SelectWeek" object:nil];
  
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
    UIButton *btn = (UIButton *)sender;
    btn.selected = !btn.selected;
    if(btn.selected)
    {
        self.timeView.hidden = YES;
    }else {
        self.timeView.hidden =  NO;
    }
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
        return self.hours.count;
    }else if(component == 1)
    {
        return self.minutes.count;
    }else {
        return 2;
    }
}
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if(component == 0 )
    {
        return self.hours[row];
    }else if(component == 1){
        return self.minutes[row];
    }else {
        return self.noon[row];
    }
}
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if(component == 0)
    {
        int hour = [self.hours[row] intValue];
        if(hour <12 || hour == 12)
        {
            [pickerView selectRow:0 inComponent:2 animated:YES];
        }else {
            [pickerView selectRow:1 inComponent:2 animated:YES];

        }
        
    }
}
- (IBAction)settingRepeatTime:(UIButton *)sender {
    self.fixTimeVC.modalPresentationStyle = UIModalPresentationPopover;
    self.fixTimeVC.popoverPresentationController.sourceView = sender;
    self.fixTimeVC.popoverPresentationController.sourceRect = sender.bounds;
   
    self.fixTimeVC.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionLeft;
    [self presentViewController:self.fixTimeVC animated:YES completion:nil];
}
- (void)selectWeek:(NSNotification *)noti
{
    NSDictionary *dict = noti.userInfo;
    NSString *strWeek = dict[@"week"];
    NSString *strSelect = dict[@"select"];
    

    if([strSelect isEqualToString:@"1"])
    {
        [self.weeks addObject:strWeek];
    }
    
    
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (IBAction)gotoLastViewController:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
