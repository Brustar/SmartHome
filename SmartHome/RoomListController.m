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
#import "Room.h"
#import <CoreLocation/CoreLocation.h>

#import "Scene.h"
#import "SceneManager.h"
#import "SQLManager.h"
#import "DeviceOfFixTimerViewController.h"
#import "Schedule.h"
#import "NSString+RegMatch.h"

@interface RoomListController ()<UITableViewDataSource,UITableViewDelegate,UIPickerViewDelegate,UIPickerViewDataSource,CLLocationManagerDelegate,deviceOfFixTimerViewControllerDelegate>
@property (nonatomic,strong) NSArray *rooms;
@property (weak, nonatomic) IBOutlet UIView *timeView;
@property (weak, nonatomic) IBOutlet UIButton *repeatBtn;//重复日期

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSArray *hours;
@property (nonatomic,strong) NSArray * days;//记录定时的天数
@property (nonatomic,strong) NSArray *minutes;
@property (nonatomic,assign) BOOL isForenoon;
@property (nonatomic,strong) NSArray *noon;
@property (nonatomic,strong) FixTimeRepeatController *fixTimeVC;
//@property (nonatomic,strong) NSMutableArray *weeks;
@property (nonatomic,strong) NSMutableDictionary *weeks;
@property (weak, nonatomic) IBOutlet UILabel *timeIntervalLabel;//持续时长
@property (weak, nonatomic) IBOutlet UISlider *timeIntervalSlider;//持续时长选择器
@property (strong, nonatomic) UIDatePicker *dataPicker;
@property (weak, nonatomic) IBOutlet UIButton *startTimeBtn;

@property (weak, nonatomic) IBOutlet UIButton *endTimeBtn;


@property (weak, nonatomic) IBOutlet UIPickerView *pickerTime;
//@property (weak, nonatomic) IBOutlet UIDatePicker *dataPicker;
@property (strong,nonatomic) CLLocationManager *lm;

@property (nonatomic,strong) NSArray *antronomicalTimes;
@property (nonatomic,strong) Scene *scene;

@property (nonatomic,assign) int selectedRoomId;
//定时的设备
@property (weak, nonatomic) IBOutlet UILabel *fixTimeDevice;//显示被定时的设备名字，默认为“场景”定时

@property (nonatomic,strong) DeviceOfFixTimerViewController *deviceOfTimeVC;
@property (nonatomic, weak) Schedule *schedule;
@property (nonatomic, assign) BOOL isSceneSetTime;//是否设置了时间
@property (nonatomic, assign) BOOL isSceneSetDate;//是否设置了日期
@property (weak, nonatomic) IBOutlet UIButton *starDataBtn;//设置日期的开始按钮
@property (weak, nonatomic) IBOutlet UIButton *endDataBtn;//设置日期的结束按钮
@property (weak, nonatomic) IBOutlet UIButton *clickFixTimeBtn;//设置定时按钮

- (IBAction)startDataBtn:(id)sender;//设置日期的开始按钮点击事件
- (IBAction)endDataBtn:(id)sender;//设置日期的结束按钮点击事件

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
   
    [self createDatePicker];
    
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
    
    self.timeIntervalSlider.minimumValue = 1;
    self.timeIntervalSlider.maximumValue = 13;
    self.timeIntervalSlider.value = 1;
    self.timeIntervalSlider.continuous = YES;
    [self.timeIntervalSlider addTarget:self action:@selector(timeIntervalSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    self.clickFixTimeBtn.hidden = YES;
}

- (void)timeIntervalSliderValueChanged:(UISlider *)sender {
    
    NSLog(@"sender: %f", sender.value);
    if (lroundf(sender.value) == 13) {
        self.timeIntervalLabel.text = @"永不";
    }else {
        self.timeIntervalLabel.text = [NSString stringWithFormat:@"%ld小时", lroundf(sender.value)];
    }
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
    
    BOOL compareResult = NO;//开始时间和结束时间的比较结果
    
    if (self.startTimeBtn.selected) { //设置开始时间
        [self.startTimeBtn setTitle:time forState:UIControlStateNormal];
        self.isSceneSetTime = YES;
    } else { //设置结束时间
        compareResult = [[time substringToIndex:(time.length-3)] laterTime:[self.startTimeBtn.titleLabel.text substringToIndex:(self.startTimeBtn.titleLabel.text.length-3)]];
        
        if (compareResult) { //YES: 结束时间大于开始时间 NO：结束时间小于等于开始时间
            [self.endTimeBtn setTitle:time forState:UIControlStateNormal];
            self.isSceneSetTime = YES;
        }else {
            [MBProgressHUD showError:@"结束时间要大于开始时间"];
            return;
        }
    }
    if (self.startTimeBtn.selected) {
        self.schedule.startTime = [time substringToIndex:5];
    }else {
        if (compareResult) {
            self.schedule.endTime = [time substringToIndex:5];
        }
    }
    NSMutableArray *sches = [self.scene.schedules mutableCopy];
    
    //遍历 schedules
    if (sches && sches.count >0) {
        
       __block BOOL shouldAdd = YES;
        [sches enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
            Schedule *schedule = obj;
            //根据deviceID 来判断是修改旧的定时，还是新增定时
            if (schedule.deviceID == self.schedule.deviceID) { //已存在的schedule，对它进行修改即可
                schedule.astronomicalStartID = self.schedule.astronomicalStartID;
                schedule.astronomicalEndID = self.schedule.astronomicalEndID;
                schedule.interval = self.schedule.interval;
                schedule.startDate = self.schedule.startDate;
                schedule.endDate = self.schedule.endDate;
                schedule.startTime = self.schedule.startTime;
                schedule.endTime = self.schedule.endTime;
                schedule.openToValue = self.schedule.openToValue;
                schedule.weekDays = self.schedule.weekDays;
                
                shouldAdd = NO;
                *stop = YES;
            }
            
        }];
        
        if (shouldAdd) {
            [sches addObject:self.schedule];
        }
    }else { //无定时，直接add
        [sches addObject:self.schedule];
    }
    
    
    self.scene.schedules = sches;
    self.clickFixTimeBtn.tintColor=[UIColor redColor];
    [[SceneManager defaultManager] addScene:self.scene withName:nil withImage:[UIImage imageNamed:@""]];
    
}


- (IBAction)settingRepeatTime:(UIButton *)sender {
   
    if (!self.isSceneSetTime) {
        [MBProgressHUD showError:@"请先设置时间"];
        return;
    }
    
    if (self.isSceneSetDate) {
        [MBProgressHUD showError:@"无法设置此项，已经设置了日期"];
        return;
    }
   
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
 
    if (self.isSceneSetTime) { //设置了开始时间和结束时间才能设置重复选项
        
        NSMutableArray *weekValue = [NSMutableArray array];
        for (int i = 0; i < 7; i++) {
            if (week[i]) {
                NSNumber *temp = [NSNumber numberWithInt:i];
                [weekValue addObject:temp];
                
            }
        }
       
        self.schedule.weekDays = weekValue;
        
        [[SceneManager defaultManager] addScene:self.scene withName:nil withImage:[UIImage imageNamed:@""]];
    }else {
        [MBProgressHUD showError:@"请先设置时间"];
    }
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

//判断是否已经选择了设备
- (BOOL)hasSelectedDevice {
    BOOL selected = NO;
    NSString *sceneFile = [NSString stringWithFormat:@"%@_0.plist",SCENE_FILE_NAME];
    NSString *scenePath = [[IOManager scenesPath] stringByAppendingPathComponent:sceneFile];
    NSDictionary *plistDic = [NSDictionary dictionaryWithContentsOfFile:scenePath];
    NSArray *array = plistDic[@"devices"];
    if (array.count >0) {
        selected = YES;
    }
    
    return selected;
}

//右下角的定时按钮
- (IBAction)clickFixTimeBtn:(id)sender {
    UIButton *btn = (UIButton *)sender;
    
    if (![self hasSelectedDevice]) {
        [MBProgressHUD showError:@"先选择设备，再设置定时"];
        return;
    }
    
    if(btn.selected)
    {
        self.timeView.hidden = YES;
        self.dataPicker.hidden = YES;
        self.ShowSettingDataView.hidden = YES;
    }else {
        
        self.timeView.hidden =  NO;
        //_timeView.backgroundColor = [UIColor redColor];
        self.ShowSettingDataView.hidden = NO;
        //_ShowSettingDataView.backgroundColor = [UIColor greenColor];
        //        self.dataPicker.hidden = NO;
        
        NSString  *astronomicealTime = @"1";
        NSDictionary *dic;
        int isPlane;
        int playType;
        if([self.startTimeBtn.titleLabel.text isEqualToString:@"设置"])
        {
            isPlane = 2;
        }else {
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
        }
      
        dic = @{
                @"astronomicealTime":astronomicealTime,
                @"playType":[NSNumber numberWithInt:playType],
                @"startTime":self.startTimeBtn.titleLabel.text,
                @"endTime":self.endTimeBtn.titleLabel.text,
                @"isPane":[NSNumber numberWithInt:isPlane]
                };
        
    }
    
    btn.selected = !btn.selected;
}

//设置开始时间，结束时间
- (IBAction)setTimeOnClick:(UIButton *)sender {
    
    //判断有没有选择定时类型
    if ([self.fixTimeDevice.text isEqualToString:@"无"]) {
        [MBProgressHUD showError:@"请先选择定时类型"];
        return;
    }
    
    self.dataPicker.hidden = YES;
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
    NSString *scenePath = [[IOManager scenesPath] stringByAppendingPathComponent:sceneFile];
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

-(void) createDatePicker
{
    self.dataPicker = [[UIDatePicker alloc] init];
    self.dataPicker.frame = CGRectMake(22+8-40, 136, 280, 204);
    self.dataPicker.backgroundColor = [UIColor whiteColor];
    self.dataPicker.datePickerMode = UIDatePickerModeDateAndTime;
    self.dataPicker.hidden = YES;
    [self.view addSubview:self.dataPicker];
}


//开始日期的设置
- (IBAction)startDataBtn:(id)sender {
    
    //判断有没有选择定时类型
    /*if ([self.fixTimeDevice.text isEqualToString:@"无"]) {
        [MBProgressHUD showError:@"请先选择定时类型"];
        return;
    }*/
    
    self.pickTimeView.hidden = YES;
    
    self.starDataBtn.selected =! self.starDataBtn.selected;
    self.dataPicker.hidden = !self.starDataBtn.selected;
    if (!self.starDataBtn.selected) { //设置开始日期并关闭日期选择器
        NSDate *myDate = self.dataPicker.date;//选择的日期
        NSDate *currentDate = [NSDate date];//当前日期
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd"];
        
        NSString *prettyDate = [dateFormat stringFromDate:myDate];
        NSString *currentDateStr = [dateFormat stringFromDate:currentDate];
        
        BOOL compareResult = [prettyDate laterDate:currentDateStr];
        if(compareResult) { //YES:选择的时间大于等于当前时间
            
            //和结束日期比较
            if (![self.endDataBtn.titleLabel.text isEqualToString:@"设置"]) {
                BOOL result = [self.endDataBtn.titleLabel.text laterDate:prettyDate];
                if (result) {
                    
                    //格式化日期 yy/MM/dd EEEE HH:mm   13/10/08 星期二 21:01
                    NSDateFormatter *dateF = [[NSDateFormatter alloc] init];
                    [dateF setDateFormat:@"yy/MM/dd EEEE HH:mm"];
                    NSString *prettyD = [dateF stringFromDate:myDate];
                    [self.starDataBtn setTitle:prettyD forState:UIControlStateNormal];
                    self.schedule.startDate = prettyDate;
                    self.clickFixTimeBtn.tintColor = [UIColor redColor];
                    self.isSceneSetDate = YES;
                }else {
                    [MBProgressHUD showError:@"开始日期不能大于结束日期"];
                    return;
                }
            }else {
                
                //格式化日期 yy/MM/dd EEEE HH:mm   13/10/08 星期二 21:01
                NSDateFormatter *dateF = [[NSDateFormatter alloc] init];
                [dateF setDateFormat:@"yy/MM/dd EEEE HH:mm"];
                NSString *prettyD = [dateF stringFromDate:myDate];
                [self.starDataBtn setTitle:prettyD forState:UIControlStateNormal];
                
                self.schedule.startDate = prettyDate;
                self.clickFixTimeBtn.tintColor = [UIColor redColor];
                self.isSceneSetDate = YES;
            }
            
        }else { //NO:选择的时间小于当前时间
            [MBProgressHUD showError:@"开始日期不能小于今天"];
            return;
        }
        
        
        //修改场景的plist文件，把定时信息写进去(开始日期)
        NSMutableArray *sches = [self.scene.schedules mutableCopy];
        
        
        //遍历 schedules
        if (sches && sches.count >0) {
            
            __block BOOL shouldAdd = YES;
            [sches enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
                Schedule *schedule = obj;
                //根据deviceID 来判断是修改旧的定时，还是新增定时
                if (schedule.deviceID == self.schedule.deviceID) { //已存在的schedule，对它进行修改即可
                    schedule.astronomicalStartID = self.schedule.astronomicalStartID;
                    schedule.astronomicalEndID = self.schedule.astronomicalEndID;
                    schedule.interval = self.schedule.interval;
                    schedule.startDate = self.schedule.startDate;
                    schedule.endDate = self.schedule.endDate;
                    schedule.startTime = self.schedule.startTime;
                    schedule.endTime = self.schedule.endTime;
                    schedule.openToValue = self.schedule.openToValue;
                    schedule.weekDays = self.schedule.weekDays;
                    
                    shouldAdd = NO;
                    *stop = YES;
                }
                
            }];
            
            if (shouldAdd) {
                [sches addObject:self.schedule];
            }
        }else { //无定时，直接add
            [sches addObject:self.schedule];
        }
        
        
        self.scene.schedules = sches;
        [[SceneManager defaultManager] addScene:self.scene withName:nil withImage:[UIImage imageNamed:@""]];
    }
    
}

//结束日期的时间设置
- (IBAction)endDataBtn:(id)sender {
    
    //判断有没有选择定时类型
    if ([self.fixTimeDevice.text isEqualToString:@"无"]) {
        [MBProgressHUD showError:@"请先选择定时类型"];
        return;
    }
    
    self.pickTimeView.hidden = YES;
    self.endDataBtn.selected =! self.endDataBtn.selected;
    self.dataPicker.hidden = !self.endDataBtn.selected;
    
    if (!self.endDataBtn.selected) { //设置结束日期并关闭日期选择器
        NSDate *myDate = self.dataPicker.date;
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd"];
        NSString *prettyDate = [dateFormat stringFromDate:myDate];
        
        if ([self.starDataBtn.titleLabel.text isEqualToString:@"设置"]) {
            [MBProgressHUD showError:@"先设置开始日期"];
            return;
        }else {
            BOOL compareResult = [prettyDate laterDate:self.starDataBtn.titleLabel.text];
        if (compareResult) {
            [self.endDataBtn setTitle:prettyDate forState:UIControlStateNormal];
            self.schedule.endDate = prettyDate;
            self.clickFixTimeBtn.tintColor = [UIColor redColor];
            self.isSceneSetDate = YES;
        }else {
            [MBProgressHUD showError:@"结束日期不能小于开始日期"];
            return;
        }
        
      }
        
      //修改场景的plist文件，把定时信息写进去（结束日期）
        NSMutableArray *sches=[self.scene.schedules mutableCopy];
        
        
        //遍历 schedules
        if (sches && sches.count >0) {
            
            __block BOOL shouldAdd = YES;
            [sches enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
                Schedule *schedule = obj;
                //根据deviceID 来判断是修改旧的定时，还是新增定时
                if (schedule.deviceID == self.schedule.deviceID) { //已存在的schedule，对它进行修改即可
                    schedule.astronomicalStartID = self.schedule.astronomicalStartID;
                    schedule.astronomicalEndID = self.schedule.astronomicalEndID;
                    schedule.interval = self.schedule.interval;
                    schedule.startDate = self.schedule.startDate;
                    schedule.endDate = self.schedule.endDate;
                    schedule.startTime = self.schedule.startTime;
                    schedule.endTime = self.schedule.endTime;
                    schedule.openToValue = self.schedule.openToValue;
                    schedule.weekDays = self.schedule.weekDays;
                    
                    shouldAdd = NO;
                    *stop = YES;
                }
                
            }];
            
            if (shouldAdd) {
                [sches addObject:self.schedule];
            }
        }else { //无定时，直接add
            [sches addObject:self.schedule];
        }
        
        self.scene.schedules = sches;
        
        [[SceneManager defaultManager] addScene:self.scene withName:nil withImage:[UIImage imageNamed:@""]];
    }
}
@end
