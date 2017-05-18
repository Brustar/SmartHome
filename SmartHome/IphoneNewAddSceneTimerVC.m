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
#import "CKCircleView.h"
#import "WeekdaysVC.h"
#import "HTCircularSlider.h"
#import "IphoneEditSceneController.h"

@interface IphoneNewAddSceneTimerVC ()<CKCircleViewDelegate,WeekdaysVCDelegate>
@property (nonatomic,strong) Scene *scene;
@property (nonatomic,strong) Schedule *schedule;
@property (nonatomic,strong) NSMutableDictionary *weeks;
@property (nonatomic,strong) UIButton * naviRightBtn;
@property CKCircleView * dialView;
@property  HTCircularSlider *slider;
@property (nonatomic,strong)WeekdaysVC * weekDaysVC;
@property (weak, nonatomic) IBOutlet UIImageView *timingImage;
@property (nonatomic,strong) NSArray * viewControllerArrs;

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
- (void)viewDidLoad{
    [super viewDidLoad];
    _weekArray = [NSMutableArray array];
    [self setupNaviBar];
    self.schedule = [[Schedule alloc]initWhithoutSchedule];
    self.schedule.startTime = self.starTimeLabel.text;
    self.schedule.endTime = self.endTimeLabel.text;
    self.RepetitionLable.text = @"永不";
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(iphoneSelectWeek:) name:@"SelectWeek" object:nil];
//    [self setCustomerSlider];
//     [self initSlider];
}
-(void) initSlider
{
    int sliderSize = 90;
    
    CGRect frame = CGRectMake(self.view.center.x-sliderSize, self.view.center.y-sliderSize, sliderSize*2, sliderSize*2);
    self.slider = [[HTCircularSlider alloc] initWithFrame:frame];
    [self.view addSubview:self.slider];
    [self.slider addTarget:self action:@selector(onValueChange:) forControlEvents:UIControlEventValueChanged];
    self.slider.handleImage = [UIImage imageNamed:@"schedule_pointer"];
    self.slider.handleSize = CGPointMake(15/2, 51/2);
    self.slider.maximumValue = 24;
    self.slider.value = 0;
    self.slider.trackAlpha = 0.6;
    self.slider.tag = 0;
    self.slider.radius = sliderSize;

}

- (void)onValueChange:(HTCircularSlider *)slider {
    NSLog(@"%f", slider.value);
    
        float dec = slider.value-(int)slider.value;
        int second = (int)(dec*60);
        NSString *pattern = second>9?@"%d:%d":@"%d:0%d";
        
        int hint = (int)slider.value;
        int hour = hint >= 12 ? hint - 12 : hint + 12;
        self.starTimeLabel.text = [NSString stringWithFormat:pattern,hour,second];
    
}
-(void)setCustomerSlider
{
    int sliderSize = 90;
    CGRect frame = CGRectMake(self.view.center.x-sliderSize, self.view.center.y-sliderSize-40, sliderSize*2, sliderSize*2);
    self.dialView = [[CKCircleView alloc] initWithFrame:frame];
    self.dialView.delegate = self;
    self.dialView.center = CGPointMake(40/2, 51/2);
    //轨道路径颜色
    self.dialView.arcColor = [UIColor colorWithRed:82/255.0 green:83/255.0 blue:85/255.0 alpha:0.8];
    //圆盘背景色
    self.dialView.backColor = [UIColor clearColor];
    //开始拨号键颜色
    self.dialView.dialColor = [UIColor clearColor];
    self.dialView.dialColor2 = [UIColor clearColor];
    self.dialView.arcRadius = 80;

    //最小值
    self.dialView.minNum = 0;
    //最大值
    self.dialView.maxNum = 23;
    //中间文字颜色
    self.dialView.labelColor = [UIColor redColor];
    self.dialView.labelFont = [UIFont systemFontOfSize:20.0];
    [self.view addSubview: self.dialView];

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
    _naviRightBtn = [CustomNaviBarView createNormalNaviBarBtnByTitle:@"保存" target:self action:@selector(rightBtnClicked:)];
    _naviRightBtn.tintColor = [UIColor whiteColor];
    //    [self setNaviBarLeftBtn:_naviLeftBtn];
    [self setNaviBarRightBtn:_naviRightBtn];
}
-(void)rightBtnClicked:(UIButton *)btn
{
    _viewControllerArrs =self.navigationController.viewControllers;
    NSInteger vcCount = _viewControllerArrs.count;
    UIViewController * lastVC = _viewControllerArrs[vcCount -2];
    UIStoryboard * iphoneStoryBoard = [UIStoryboard storyboardWithName:@"iPhone" bundle:nil];
    IphoneEditSceneController * iphoneEditSceneVC = [iphoneStoryBoard instantiateViewControllerWithIdentifier:@"IphoneEditSceneController"];
    if ([lastVC isKindOfClass:[iphoneEditSceneVC class]]) {
        
        [DeviceInfo defaultManager].isPhotoLibrary = NO;
        //场景ID不变
        NSString *sceneFile = [NSString stringWithFormat:@"%@_%d.plist",SCENE_FILE_NAME,self.sceneID];
        NSString *scenePath=[[IOManager scenesPath] stringByAppendingPathComponent:sceneFile];
        NSDictionary *plistDic = [NSDictionary dictionaryWithContentsOfFile:scenePath];
        Scene * scene = [[Scene alloc] init];
        if (plistDic) {
            [scene setValuesForKeysWithDictionary:plistDic];
            
            [[SceneManager defaultManager] editScene:scene];
        }
        
    }else{
        
        self.scene.schedules = @[self.schedule];
        [[SceneManager defaultManager] addScene:self.scene withName:nil withImage:[UIImage imageNamed:@""]];
        
        NSDictionary *dic = @{
                              @"startDay":self.starTimeLabel.text,
                              @"endDay":self.endTimeLabel.text,
                              @"repeat":self.RepetitionLable.text,
                              @"weekArray":_weekArray
                              };
        [NC postNotificationName:@"AddSceneOrDeviceTimerNotification" object:nil userInfo:dic];
    }
  
    [self.navigationController popViewControllerAnimated:YES];

}
- (IBAction)SelectWeek:(id)sender {
    
    UIStoryboard * HomeStoryBoard = [UIStoryboard storyboardWithName:@"Scene" bundle:nil];
    if (_weekDaysVC == nil) {
        self.timingImage.hidden = YES;
        self.dialView.hidden = YES;
        self.TimerView.hidden = YES;
        self.slider.hidden = YES;
        _weekDaysVC = [HomeStoryBoard instantiateViewControllerWithIdentifier:@"WeekdaysVC"];
        _weekDaysVC.delegate = self;
        [self.view addSubview:_weekDaysVC.view];
        [self.view bringSubviewToFront:_weekDaysVC.view];
        
    }else {
        self.TimerView.hidden = NO;
        self.dialView.hidden = NO;
        self.timingImage.hidden = NO;
        self.slider.hidden = NO;
        [_weekDaysVC.view removeFromSuperview];
        _weekDaysVC = nil;
    }
}
-(void)onWeekButtonClicked:(UIButton *)button
{
    
//    self.DrawView.hidden = NO;
    self.slider.hidden = NO;
    self.dialView.hidden = NO;
    self.timingImage.hidden = NO;
    self.TimerView.hidden = NO;
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
    
    [[SceneManager defaultManager] addScene:self.scene withName:nil withImage:[UIImage imageNamed:@""]];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
