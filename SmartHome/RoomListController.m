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
#import "RoomManager.h"
#import "Room.h"
#import <CoreLocation/CoreLocation.h>
#import "SunCount.h"
#import "Scene.h"
#import "SceneManager.h"
#import "SQLManager.h"
#import "DeviceOfFixTimerViewController.h"
#import "Schedule.h"

@interface RoomListController ()<UITableViewDataSource,UITableViewDelegate,UIPickerViewDelegate,UIPickerViewDataSource,CLLocationManagerDelegate,deviceOfFixTimerViewControllerDelegate>
@property (nonatomic,strong) NSArray *rooms;
@property (weak, nonatomic) IBOutlet UIView *timeView;
@property (weak, nonatomic) IBOutlet UIButton *repeatBtn;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSArray *hours;
@property (nonatomic,strong) NSArray * days;//记录定时的天数
@property (nonatomic,strong) NSArray *minutes;
@property (nonatomic,assign) BOOL isForenoon;
@property (nonatomic,strong) NSArray *noon;
@property (nonatomic,strong) FixTimeRepeatController *fixTimeVC;
//@property (nonatomic,strong) NSMutableArray *weeks;
@property (nonatomic,strong) NSMutableDictionary *weeks;


@property (weak, nonatomic) IBOutlet UIButton *startTimeBtn;

@property (weak, nonatomic) IBOutlet UIButton *endTimeBtn;

@property (weak, nonatomic) IBOutlet UIView *dataPickerView;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerTime;
@property (weak, nonatomic) IBOutlet UIDatePicker *dataPicker;
@property (strong,nonatomic) CLLocationManager *lm;

@property (nonatomic,strong) NSArray *antronomicalTimes;
@property (nonatomic,strong) Scene *scene;

@property (nonatomic,assign) int selectedRoomId;
//定时的设备
@property (weak, nonatomic) IBOutlet UILabel *fixTimeDevice;

@property (nonatomic,strong) DeviceOfFixTimerViewController *deviceOfTimeVC;
@property (nonatomic, weak) Schedule *schedule;
@property (nonatomic, assign) BOOL isSceneSetTime;

- (IBAction)startDataBtn:(id)sender;//设置日期的开始按钮
- (IBAction)endDataBtn:(id)sender;//设置日期的结束按钮

@property (weak, nonatomic) IBOutlet UIView *ShowSettingDataView;

@end

@implementation RoomListController
-(NSArray *)days
{

    if (!_days) {
        _days = [[NSArray array] init];
    }

    return _days;
}
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

//显示周一到周日的TableView
-(FixTimeRepeatController *)fixTimeVC
{
    if(!_fixTimeVC)
    {
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        _fixTimeVC = [story instantiateViewControllerWithIdentifier:@"FixTimeRepeatController"];
    }
    return _fixTimeVC;
}

//显示定时选择器边的场景的名字
-(DeviceOfFixTimerViewController *)deviceOfTimeVC
{
    if(!_deviceOfTimeVC)
    {
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        _deviceOfTimeVC = [story instantiateViewControllerWithIdentifier:@"DeviceOfFixTimerViewController"];
    }
    return _deviceOfTimeVC;
}
-(NSMutableDictionary *)weeks
{
    if(!_weeks)
    {
        _weeks = [NSMutableDictionary dictionary];
    }
    return _weeks;
}
-(NSArray *)rooms
{
    if(!_rooms)
    {
        _rooms = [SQLManager getAllRoomsInfo];
    }
    return _rooms;
}
-(Scene *)scene
{
    if(!_scene)
    {
        
        NSString *sceneFile = [NSString stringWithFormat:@"%@_0.plist",SCENE_FILE_NAME];
        NSString *scenePath=[[IOManager scenesPath] stringByAppendingPathComponent:sceneFile];
        NSDictionary *plistDic = [NSDictionary dictionaryWithContentsOfFile:scenePath];
        
        _scene = [[Scene alloc] initWhithoutSchedule];
        [_scene setValuesForKeysWithDictionary:plistDic];
        
    }
    return _scene;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.timeView.layer.cornerRadius = 10;
    self.timeView.layer.masksToBounds = YES;
    

    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView.tableFooterView = [UIView new];
   
 
    
    [self.tableView selectRowAtIndexPath:0 animated:YES scrollPosition:UITableViewScrollPositionTop];
    self.splitViewController.maximumPrimaryColumnWidth = 250;
    self.tableView.backgroundColor = backGroudColour;
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectWeek:) name:@"SelectWeek" object:nil];
    self.view.backgroundColor = backGroudColour;
    
    Schedule *schedule = nil;
    
    if (self.scene.schedules.count > 0) {
        for (Schedule *scheduleTemp in self.scene.schedules) {
            if (scheduleTemp.deviceID == 0) {
                schedule = scheduleTemp;
                break;
            }
        }
    }
    
    if (schedule == nil) {
        schedule = [[Schedule alloc] initWhithoutSchedule];
        schedule.deviceID = 0;
        
        NSMutableArray *schedules = [NSMutableArray arrayWithArray:self.scene.schedules];
        [schedules addObject:schedule];
        self.scene.schedules = [schedules copy];
    }
    
    self.schedule = schedule;
   }
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //默认选中第一行
    NSIndexPath *selectedIndexPath  = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView selectRowAtIndexPath:selectedIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    
    if([self.delegate respondsToSelector:@selector(RoomListControllerDelegate:SelectedRoom:)])
    {
        Room *room = self.rooms[0];
        [self.delegate RoomListControllerDelegate:self SelectedRoom:room.rId];
    }
}
#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.rooms.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AddSenseCell *cell = [tableView dequeueReusableCellWithIdentifier:@"roomListCell" forIndexPath:indexPath];
   

    Room *room = self.rooms[indexPath.row];
    cell.roomName.text = room.rName;
    
    
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
        Room *room = self.rooms[indexPath.row];
        [self.delegate RoomListControllerDelegate:self SelectedRoom:room.rId];
       // self.selectedRoomId = room.rId;
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
    
    NSString *hour = self.hours[[self.pickerTime selectedRowInComponent:0]];
    NSString *min = self.minutes[[self.pickerTime selectedRowInComponent:1]];
    NSString *noon = self.noon[[self.pickerTime selectedRowInComponent:2]];
    NSString *time = [NSString stringWithFormat:@"%@:%@ %@", hour, min, noon];
    
    
    if (self.startTimeBtn.selected) {
        [self.startTimeBtn setTitle:time forState:UIControlStateNormal];
    } else {
        [self.endTimeBtn setTitle:time forState:UIControlStateNormal];
    }
    
   
    
    if (self.startTimeBtn.selected) {
        self.schedule.startTime=time;
    } else {
        self.schedule.endTime = time;
    }
    
    [[SceneManager defaultManager] addScene:self.scene withName:nil withImage:[UIImage imageNamed:@""]];
    
}


- (IBAction)settingRepeatTime:(UIButton *)sender {
   
    
//    if ([self.delegate respondsToSelector:@selector(showDataPicker)]) {
//        
//        self.pickTimeView.hidden = YES;
//        [self.delegate showDataPicker];
//    }
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
    
    self.weeks[strWeek] = strSelect;
    
    int week[7] = {0};
    
    for (NSString *key in [self.weeks allKeys]) {
        int index = [key intValue];
        int select = [self.weeks[key] intValue];
        
        week[index] = select;
    }
    
    NSMutableString *display = [NSMutableString string];
    //Schedule *schedule=[[Schedule alloc] initWhithoutSchedule];
    
    if (week[1] == 0 && week[2] == 0 && week[3] == 0 && week[4] == 0 && week[5] == 0 && week[0] == 0 && week[6] == 0) {
        [display appendString:@"永不"];
    }
    else if (week[1] == 1 && week[2] == 1 && week[3] == 1 && week[4] == 1 && week[5] == 1 && week[0] == 1 && week[6] == 1) {
        [display appendString:@"每天"];
    }
    else if (week[1] == 1 && week[2] == 1 && week[3] == 1 && week[4] == 1 && week[5] == 1 && week[0] == 0 && week[6] == 0) {
        [display appendString:@"工作日"];
    }
    else if ( week[1] == 0 && week[2] == 0 && week[3] == 0 && week[4] == 0 && week[5] == 0 && week[0] == 1 && week[6] == 1 ) {
        [display appendString:@"周末"];
    }
    else {
        for (int i = 1; i < 7; i++) {
            if (week[i] == 1) {
                switch (i) {
                    case 1:
                        [display appendString:@"周一"];
                        break;
                        
                    case 2:
                        [display appendString:@"周二"];
                        break;
                        
                    case 3:
                        [display appendString:@"周三"];
                        break;
                        
                    case 4:
                        [display appendString:@"周四"];
                        break;
                        
                    case 5:
                        [display appendString:@"周五"];
                        break;
                        
                    case 6:
                        [display appendString:@"周六"];
                        break;
                        
                    default:
                        break;
                }
            }
        }
        if (week[0] == 1) {
            [display appendString:@"周日"];
        }
    }
    
    [self.repeatBtn setTitle:display forState:UIControlStateNormal];
 
    if (self.isSceneSetTime) {
        //BOOL isRepeat = false;
        NSMutableArray *weekValue = [NSMutableArray array];
        for (int i = 0; i < 7; i++) {
            if (week[i]) {
                NSNumber *temp = [NSNumber numberWithInt:i];
                [weekValue addObject:temp];
                //isRepeat = true;
            }
        }
       
        self.schedule.weekDays = weekValue;
    }
     [[SceneManager defaultManager] addScene:self.scene withName:nil withImage:[UIImage imageNamed:@""]];

    
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (IBAction)clickFixTimeBtn:(id)sender {
    UIButton *btn = (UIButton *)sender;
    
    
    if(btn.selected)
    {
        self.timeView.hidden = YES;
        self.ShowSettingDataView.hidden = YES;
    }else {
        
        self.timeView.hidden =  NO;
        self.ShowSettingDataView.hidden = NO;
        NSString  *astronomicealTime;
        NSDictionary *dic;
        int isPlane;
        int playType;
        if([self.startTimeBtn.titleLabel.text isEqualToString:@"设置"])
        {
            isPlane = 2;
            
        }else{
            if([self.startTimeBtn.titleLabel.text isEqualToString:@"黎明"]){
                astronomicealTime = @"1";
            }else if([self.startTimeBtn.titleLabel.text isEqualToString:@"日出"]){
                astronomicealTime = @"2";
            }else if([self.startTimeBtn.titleLabel.text isEqualToString:@"日落"]){
                astronomicealTime = @"3";
            }else {
                astronomicealTime = @"4";
            }
            
            if(astronomicealTime)
            {
                playType = 2;
            }else{
                playType = 1;
            }
            isPlane = 1;
            dic = @{@"astronomicealTime":astronomicealTime,@"playType":[NSNumber numberWithInt:playType],@"startTIme":self.startTimeBtn.titleLabel.text,@"endTime":self.endTimeBtn.titleLabel.text,@"isPane":[NSNumber numberWithInt:isPlane]};
            
        }
      
       
        
    }
    btn.selected = !btn.selected;
}

- (IBAction)setTimeOnClick:(UIButton *)sender {
    
    if (sender == self.startTimeBtn)
    {
        if (self.startTimeBtn.selected)
        {
            self.startTimeBtn.selected = NO;
        }
        else {
            self.startTimeBtn.selected = YES;
            self.endTimeBtn.selected = NO;
        }
    }
    else {
        if (self.endTimeBtn.selected) {
            self.endTimeBtn.selected = NO;
        }
        else {
            self.startTimeBtn.selected = NO;
            self.endTimeBtn.selected = YES;
            
            
        }
    }
    
    if (self.startTimeBtn.selected || self.endTimeBtn.selected) {
        self.pickTimeView.hidden = NO;
        
    } else {
        self.pickTimeView.hidden = YES;
    }

}


- (IBAction)setAstromomicalTime:(id)sender {
    

    UIButton *btn = (UIButton *)sender;
    if(btn.tag == 0){
        [self.startTimeBtn setTitle:@"黎明" forState:UIControlStateNormal];
    }else if(btn.tag == 1){
        [self.startTimeBtn setTitle:@"日出" forState:UIControlStateNormal];
    }else if(btn.tag == 2){
        [self.startTimeBtn setTitle:@"日落" forState:UIControlStateNormal];
    }else{
        [self.startTimeBtn setTitle:@"黄昏" forState:UIControlStateNormal];
    }
    
    self.schedule.astronomicalStartID=(int)btn.tag + 1;
    
    [[SceneManager defaultManager] addScene:self.scene withName:nil withImage:[UIImage imageNamed:@""]];

}


- (IBAction)gotoLastViewController:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


//选择已经添加的设备
- (IBAction)selectedDevice:(id)sender {
    self.timeView.hidden = YES;
    self.deviceOfTimeVC.modalPresentationStyle = UIModalPresentationPopover;
    self.deviceOfTimeVC.popoverPresentationController.sourceView = self.fixTimeDevice;
    self.deviceOfTimeVC.popoverPresentationController.sourceRect = self.fixTimeDevice.bounds;
    
    self.deviceOfTimeVC.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUp;
    self.deviceOfTimeVC.delegate = self;
    [self presentViewController:self.deviceOfTimeVC animated:YES completion:nil];
}

-(void)DeviceOfFixTimerViewController:(DeviceOfFixTimerViewController *)vc andName:(NSString *)deviceName
{
    self.fixTimeDevice.text = deviceName;
    self.timeView.hidden = NO;
    
    NSString *sceneFile = [NSString stringWithFormat:@"%@_0.plist",SCENE_FILE_NAME];
    NSString *scenePath=[[IOManager scenesPath] stringByAppendingPathComponent:sceneFile];
    NSDictionary *plistDic = [NSDictionary dictionaryWithContentsOfFile:scenePath];
    
    _scene = [[Scene alloc] initWhithoutSchedule];
    [_scene setValuesForKeysWithDictionary:plistDic];
    
    NSMutableArray *schedulesTemp = [NSMutableArray array];
    
    for (NSDictionary *dict in self.scene.schedules) {
        Schedule *schedule = [[Schedule alloc] initWhithoutSchedule];
        
        [schedule setValuesForKeysWithDictionary:dict];
        
        [schedulesTemp addObject:schedule];
    }
    
    self.scene.schedules = [schedulesTemp copy];
    
    NSInteger deviceID = 0;
    
    if (![deviceName isEqualToString:@"场景"]) {
        deviceID = [SQLManager deviceIDByDeviceName:deviceName];
    }
    
    for (int i = 0; i < self.scene.schedules.count; i++) {
        Schedule *schedule = self.scene.schedules[i];
        
        if (deviceID == schedule.deviceID) {
            self.schedule = schedule;
            return;
        }
    }
    
    Schedule *schedule = [[Schedule alloc] initWhithoutSchedule];
    schedule.deviceID = (int)deviceID;
    NSMutableArray *schedules = [NSMutableArray arrayWithArray:self.scene.schedules];
    [schedules addObject:schedule];
    self.scene.schedules = [schedules copy];
    self.schedule = schedule;
   
}

- (IBAction)startDataBtn:(id)sender {
}
- (IBAction)endDataBtn:(id)sender {
}
@end
