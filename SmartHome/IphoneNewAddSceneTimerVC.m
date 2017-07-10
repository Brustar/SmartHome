//
//  IphoneNewAddSceneTimerVC.m
//  SmartHome
//
//  Created by zhaona on 2017/4/10.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "IphoneNewAddSceneTimerVC.h"
#import "SceneManager.h"
#import "Scene.h"
#import "Schedule.h"
#import "NSString+RegMatch.h"
#import "MBProgressHUD+NJ.h"
#import <math.h>
#import "WeekdaysVC.h"
#import "IphoneEditSceneController.h"
#import "SmartHome-Swift.h"
#import "Scene.h"
#import "IpadDeviceListViewController.h"

@interface IphoneNewAddSceneTimerVC ()<WeekdaysVCDelegate,TenClockDelegate>
@property (nonatomic,strong) Scene *scene;
@property (nonatomic,strong) Schedule *schedule;
@property (nonatomic,strong) NSMutableDictionary *weeks;
@property (nonatomic,strong) UIButton * naviRightBtn;
@property (nonatomic,strong)WeekdaysVC * weekDaysVC;
@property (weak, nonatomic) IBOutlet UIImageView *timingImage;
@property (nonatomic,strong) NSArray * viewControllerArrs;
@property (nonatomic,strong) NSDateFormatter  *dateFormatter;
@property (weak, nonatomic) IBOutlet TenClock *clock;
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
-(Scene *)scene
{
    if(!_scene)
    {
        NSString *sceneFile = [NSString stringWithFormat:@"%@_0.plist",SCENE_FILE_NAME];
        NSString *scenePath=[[IOManager scenesPath] stringByAppendingPathComponent:sceneFile];
        NSDictionary *plistDic = [NSDictionary dictionaryWithContentsOfFile:scenePath];
        _scene = [[Scene alloc] initWhithoutSchedule];
        if(plistDic)
        {
            [_scene setValuesForKeysWithDictionary:plistDic];
        }
    }
    return _scene;
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
    }
    
    if (self.endTimeStr.length >0) {
        self.endTimeLabel.text = self.endTimeStr;
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
    
    NSDate *date = [NSDate date];
    self.clock.startDate = date;
    NSTimeInterval interval = 60 * 60 * 8;
    self.clock.endDate = [NSDate dateWithTimeInterval:interval sinceDate:date];
    [self.clock update];
    self.clock.delegate = self;
    
    //self.starTimeLabel.text = [self.dateFormatter stringFromDate:self.clock.startDate];
    //self.endTimeLabel.text = [self.dateFormatter stringFromDate:self.clock.endDate];
}

#pragma mark -- CKCircleViewDelegate
-(void)startTextChange:(NSString *)startText{
    NSLog(@"startText:%@",startText);
    self.starTimeLabel.text = [NSString stringWithFormat:@"%@",startText];
}

-(void)endTextChange:(NSString *)endText{
    NSLog(@"endText:%@",endText);
    self.endTimeLabel.text = [NSString stringWithFormat:@"%@",endText];
}

- (void)setupNaviBar {
    [self setNaviBarTitle:_naviTitle]; //设置标题
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
        self.scene.schedules = @[self.schedule];
        [[SceneManager defaultManager] addScene:self.scene withName:nil withImage:[UIImage imageNamed:@""] withiSactive:0];
        
        NSDictionary *dic = @{
                              @"startDay":self.starTimeLabel.text,
                              @"endDay":self.endTimeLabel.text,
                              @"repeat":self.RepetitionLable.text,
                              @"weekArray":_weekArray
                              };
        [NC postNotificationName:@"AddSceneOrDeviceTimerNotification" object:nil userInfo:dic];
  
    [self.navigationController popViewControllerAnimated:YES];

}
- (IBAction)SelectWeek:(id)sender {
    
    UIStoryboard * HomeStoryBoard = [UIStoryboard storyboardWithName:@"Scene" bundle:nil];
    if (_weekDaysVC == nil) {
        self.timingImage.hidden = YES;
        self.TimerView.hidden = YES;
        self.clock.hidden = YES;
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
        self.clock.hidden = NO;
        [_weekDaysVC.view removeFromSuperview];
        _weekDaysVC = nil;
    }
}
-(void)onWeekButtonClicked:(UIButton *)button
{
    self.timingImage.hidden = NO;
    self.TimerView.hidden = NO;
    self.clock.hidden = NO;
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
    
    [[SceneManager defaultManager] addScene:self.scene withName:nil withImage:[UIImage imageNamed:@""] withiSactive:0];

}
#pragma mark -- TenClockDelegate
-(void)timesChanged:(TenClock *)clock startDate:(NSDate *)startDate endDate:(NSDate *)endDate{
    NSLog(@"startDate:%@--endDate:%@",startDate,endDate);
}

-(void)timesUpdated:(TenClock *)clock startDate:(NSDate *)startDate endDate:(NSDate *)endDate{
    self.starTimeLabel.text = [self.dateFormatter stringFromDate:startDate];
    self.endTimeLabel.text = [self.dateFormatter stringFromDate:endDate];
}

#pragma mark -- lazy load
-(NSDateFormatter  *)dateFormatter{
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        // hh:mm a
        [_dateFormatter setDateFormat:@"hh:mm a"];
    }
    return  _dateFormatter;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
