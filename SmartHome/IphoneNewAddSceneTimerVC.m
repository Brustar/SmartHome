//
//  IphoneNewAddSceneTimerVC.m
//  SmartHome
//
//  Created by zhaona on 2017/4/10.
//  Copyright © 2017年 Brustar. All rights reserved.
//添加定时

#import "IphoneNewAddSceneTimerVC.h"
#import "SceneManager.h"
#import "Scene.h"
#import "Schedule.h"
#import "NSString+RegMatch.h"
#import "MBProgressHUD+NJ.h"
#import "WeekdaysVC.h"
#import "IphoneEditSceneController.h"
#import "Scene.h"
#import "IpadDeviceListViewController.h"
#import "IphoneSaveNewSceneController.h"
#import "HGCircularSlider-Swift.h"


@interface IphoneNewAddSceneTimerVC ()<WeekdaysVCDelegate>
@property (nonatomic,strong) Scene *scene;
@property (nonatomic,strong) Schedule *schedule;
@property (nonatomic,strong) NSMutableDictionary *weeks;
@property (nonatomic,strong) UIButton * naviRightBtn;
@property (nonatomic,strong)WeekdaysVC * weekDaysVC;
@property (weak, nonatomic) IBOutlet UIImageView *timingImage;
@property (nonatomic,strong) NSArray * viewControllerArrs;
@property (nonatomic,strong) NSDateFormatter  *dateFormatter;
@property (weak, nonatomic) IBOutlet RangeCircularSlider *rangClock;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *TimViewLeadingConstraint;//到父视图左边的距离
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *TimeViewTrailingConstraint;//到父视图右边的距离
@property (weak, nonatomic) IBOutlet UIView *SupView;

@end

@implementation IphoneNewAddSceneTimerVC

-(NSMutableDictionary *)weeks
{
    if(!_weeks)
    {
        _weeks = [NSMutableDictionary dictionary];
    }
    return _weeks;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (self.startTimeStr.length >0) {
        self.starTimeLabel.text = self.startTimeStr;
       
        NSArray *temp=[self.starTimeLabel.text componentsSeparatedByString:@":"];
        self.rangClock.startPointValue = [temp[0] intValue]* 60 * 60+ [temp[1] intValue]*60;
      
    }
    if (self.endTimeStr.length >0) {
        self.endTimeLabel.text = self.endTimeStr;
        NSArray *temp=[self.endTimeLabel.text componentsSeparatedByString:@":"];
        self.rangClock.endPointValue = [temp[0] intValue]* 60 * 60+ [temp[1] intValue]*60;

    }
    
    if (self.repeatitionStr.length >0) {
        self.RepetitionLable.text = self.repeatitionStr;
    }
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        
        self.TimViewLeadingConstraint.constant = 200;
        self.TimeViewTrailingConstraint.constant = 200;
        
        self.SupView.backgroundColor = [UIColor colorWithRed:25/255.0 green:25/255.0 blue:29/255.0 alpha:1];
    }
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    _weekArray = [NSMutableArray array];
    [self setupNaviBar];
    self.schedule = [[Schedule alloc]initWhithoutSchedule];
    self.schedule.startTime = self.starTimeLabel.text;
    self.schedule.endTime = self.endTimeLabel.text;
    self.RepetitionLable.text = @"永不";
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(iphoneSelectWeek:) name:@"SelectWeek" object:nil];

    CGFloat dayInSeconds = 24 * 60 * 60;
    self.rangClock.maximumValue = dayInSeconds;
    self.rangClock.startThumbImage = [UIImage imageNamed:@"ipad-sss"];
    self.rangClock.endThumbImage = [UIImage imageNamed:@"ipad-END"];
    self.rangClock.startPointValue = 3 * 60 * 60;
    self.rangClock.endPointValue = 8 * 60 * 60;
    self.rangClock.alpha = 0.8;
    
    [self updateTexts:self.rangClock];

}

- (void)setupNaviBar {
    [self setNaviBarTitle:@"添加定时"]; //设置标题
    _naviRightBtn = [CustomNaviBarView createNormalNaviBarBtnByTitle:@"确定" target:self action:@selector(rightBtnClicked:)];
    _naviRightBtn.tintColor = [UIColor whiteColor];
    [self setNaviBarRightBtn:_naviRightBtn];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad && _isShowInSplitView) {
        [self adjustNaviBarFrameForSplitView];
        [self adjustTitleFrameForSplitView];
        [self setNaviBarRightBtnForSplitView:_naviRightBtn];
    }
}
-(void)rightBtnClicked:(UIButton *)btn
{
    
    if (self.isDeviceTimer && _timer) {
        
        NSString *timerFile = [NSString stringWithFormat:@"%@_%ld_%d.plist",DEVICE_TIMER_FILE_NAME, [[DeviceInfo defaultManager] masterID], _timer.deviceID];
        NSString *timerPath = [[IOManager deviceTimerPath] stringByAppendingPathComponent:timerFile];
        NSDictionary *plistDic = [NSDictionary dictionaryWithContentsOfFile:timerPath];
        
        if(plistDic)
        {
            [_timer setValuesForKeysWithDictionary:plistDic];
        }
        
        self.schedule.startTime = self.starTimeLabel.text;
        self.schedule.endTime = self.endTimeLabel.text;
        _timer.schedules = @[self.schedule];
        
        
        [[SceneManager defaultManager] addDeviceTimer:_timer isEdited:YES isActive:1 block:nil];
        
        NSDictionary *dic = @{
                              @"startDay":self.starTimeLabel.text,
                              @"endDay":self.endTimeLabel.text,
                              @"repeat":self.RepetitionLable.text,
                              @"weekArray":_weekArray
                              };
        [NC postNotificationName:@"AddSceneOrDeviceTimerNotification" object:nil userInfo:dic];
        
        [self.navigationController popViewControllerAnimated:YES];
        
    }else {
    
        NSString *sceneFile = [NSString stringWithFormat:@"%@_0.plist",SCENE_FILE_NAME];
        NSString *scenePath = [[IOManager scenesPath] stringByAppendingPathComponent:sceneFile];
        NSDictionary *plistDic = [NSDictionary dictionaryWithContentsOfFile:scenePath];
        
        _scene = [[Scene alloc] initWhithoutSchedule];
        
        if(plistDic)
        {
            [_scene setValuesForKeysWithDictionary:plistDic];
        }
    
    _viewControllerArrs =self.navigationController.viewControllers;
    NSInteger vcCount = _viewControllerArrs.count;
    UIViewController * lastVC = _viewControllerArrs[vcCount -2];
    UIStoryboard * iphoneStoryBoard = [UIStoryboard storyboardWithName:@"iPhone" bundle:nil];
    IphoneSaveNewSceneController * iphoneSaveNewSceneVC = [iphoneStoryBoard instantiateViewControllerWithIdentifier:@"IphoneSaveNewSceneController"];
   
    if ([lastVC isKindOfClass:[iphoneSaveNewSceneVC class]]) {  //新增定时
        self.schedule.startTime = self.starTimeLabel.text;
        self.schedule.endTime = self.endTimeLabel.text;
        _scene.schedules = @[self.schedule];
        _scene.isplan = 1;
        _scene.isactive = 1;
        
        [[SceneManager defaultManager] addScene:self.scene withName:nil withImage:[UIImage imageNamed:@""] withiSactive:0];
        
        NSDictionary *dic = @{
                              @"startDay":self.starTimeLabel.text,
                              @"endDay":self.endTimeLabel.text,
                              @"repeat":self.RepetitionLable.text,
                              @"weekArray":_weekArray
                              };
        [NC postNotificationName:@"AddSceneOrDeviceTimerNotification" object:nil userInfo:dic];
        
    }else{  //编辑定时
        _scene = [[SceneManager defaultManager] readSceneByID:self.sceneID];
        Schedule *sch = [[Schedule alloc] init];
        sch.startTime = self.starTimeLabel.text;
        sch.endTime = self.endTimeLabel.text;
        sch.weekDays = self.schedule.weekDays;
        _scene.schedules = @[sch];
        [[SceneManager defaultManager] editSceneTimer:_scene];

    }

    [self.navigationController popViewControllerAnimated:YES];
   }
}
- (IBAction)SelectWeek:(id)sender {
    
    UIStoryboard * HomeStoryBoard = [UIStoryboard storyboardWithName:@"Scene" bundle:nil];
    if (_weekDaysVC == nil) {
        self.timingImage.hidden = YES;
        self.TimerView.hidden = YES;
        self.rangClock.hidden = YES;
        _weekDaysVC = [HomeStoryBoard instantiateViewControllerWithIdentifier:@"WeekdaysVC"];
        _weekDaysVC.delegate = self;
        [self.view addSubview:_weekDaysVC.view];
        
        if (ON_IPAD && _isShowInSplitView) {
            CGRect tempFrame = _weekDaysVC.view.frame;
            tempFrame.origin.x = -120;
            _weekDaysVC.view.frame = tempFrame;
        }
        
        [self.view bringSubviewToFront:_weekDaysVC.view];
        
    }else {
        self.TimerView.hidden = NO;
        self.timingImage.hidden = NO;
        self.rangClock.hidden = NO;
        [_weekDaysVC.view removeFromSuperview];
        _weekDaysVC = nil;
    }
}
-(void)onWeekButtonClicked:(UIButton *)button
{
    self.timingImage.hidden = NO;
    self.TimerView.hidden = NO;
    self.rangClock.hidden = NO;
    if (_weekDaysVC) {
        [_weekDaysVC.view removeFromSuperview];
        _weekDaysVC = nil;
    }
}
- (void)iphoneSelectWeek:(NSNotification *)noti
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
                        [display appendString:@"周一、"];
                        break;
                        
                    case 2:
                        [display appendString:@"周二、"];
                        break;
                        
                    case 3:
                        [display appendString:@"周三、"];
                        break;
                        
                    case 4:
                        [display appendString:@"周四、"];
                        break;
                        
                    case 5:
                        [display appendString:@"周五、"];
                        break;
                        
                    case 6:
                        [display appendString:@"周六、"];
                        break;
                        
                    default:
                        break;
                }
            }
        }
        if (week[0] == 1) {
            [display appendString:@"周日、"];
        }
    }
    self.RepetitionLable.text = [NSString stringWithFormat:@"%@",display];
    
    NSMutableArray *weekValue = [NSMutableArray array];
    [_weekArray removeAllObjects];
    
    for (int i = 0; i < 7; i++) {
        
        [_weekArray addObject:@(week[i])];
        
        if (week[i]) {
            NSNumber *temp = [NSNumber numberWithInt:i];
            [weekValue addObject:temp];
            
        }
    }
    
    self.schedule.weekDays = weekValue;
    NSString *sceneFile = [NSString stringWithFormat:@"%@_0.plist",SCENE_FILE_NAME];
    NSString *scenePath=[[IOManager scenesPath] stringByAppendingPathComponent:sceneFile];
    NSDictionary *plistDic = [NSDictionary dictionaryWithContentsOfFile:scenePath];
    
    _scene = [[Scene alloc] initWhithoutSchedule];
    if(plistDic)
    {
        [_scene setValuesForKeysWithDictionary:plistDic];
    }
    [[SceneManager defaultManager] addScene:self.scene withName:nil withImage:[UIImage imageNamed:@""] withiSactive:0];

}

- (IBAction)updateTexts:(id)sender {
    
    _dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone* localzone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    [_dateFormatter setTimeZone:localzone];
    [_dateFormatter setDateFormat:@"HH:mm"];
    
    self.rangClock.startPointValue = [self adjustValue:self.rangClock.startPointValue];
    self.rangClock.endPointValue = [self adjustValue:self.rangClock.endPointValue];
    NSDate *bedtimeDate = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:self.rangClock.startPointValue];
    self.starTimeLabel.text = [_dateFormatter stringFromDate:bedtimeDate];
    
    NSDate *wakeDate = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:self.rangClock.endPointValue];
    self.endTimeLabel.text = [_dateFormatter stringFromDate:wakeDate];
}

-(CGFloat)adjustValue:(CGFloat)value
{
    
    CGFloat minutes = value / 60;
    CGFloat adjustedMinutes =  ceil(minutes / 5.0) * 5;
    return adjustedMinutes * 60;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
