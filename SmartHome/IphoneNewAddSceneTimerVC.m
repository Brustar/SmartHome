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

@interface IphoneNewAddSceneTimerVC ()<CKCircleViewDelegate,WeekdaysVCDelegate>
@property (nonatomic,strong) Scene *scene;
@property (nonatomic,strong) Schedule *schedule;
@property (nonatomic,strong) NSMutableDictionary *weeks;
@property (nonatomic,strong) UIButton * naviRightBtn;
@property CKCircleView * dialView;
@property (nonatomic,strong)WeekdaysVC * weekDaysVC;

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
    [self setCustomerSlider];
}
-(void)setCustomerSlider
{
//    CGFloat width = self.view.frame.size.width;
    
    self.dialView = [[CKCircleView alloc] initWithFrame:CGRectMake(0, 0, 265, 265)];
    self.dialView.delegate = self;

    self.dialView.center = CGPointMake(self.DrawView.center.x, self.DrawView.center.y);
    //轨道路径颜色
    self.dialView.arcColor = [UIColor colorWithRed:82/255.0 green:83/255.0 blue:85/255.0 alpha:0.8];
    //圆盘背景色
    self.dialView.backColor = [UIColor clearColor];
    //开始拨号键颜色
    self.dialView.dialColor = [UIColor clearColor];
    self.dialView.dialColor2 = [UIColor clearColor];
    self.dialView.arcRadius = 80;
//    self.dialView.units = @"小时";
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
    self.scene.schedules = @[self.schedule];
    [[SceneManager defaultManager] addScene:self.scene withName:nil withImage:[UIImage imageNamed:@""]];
    
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
        self.DrawView.hidden = YES;
        self.dialView.hidden = YES;
        _weekDaysVC = [HomeStoryBoard instantiateViewControllerWithIdentifier:@"WeekdaysVC"];
        _weekDaysVC.delegate = self;
        [self.view addSubview:_weekDaysVC.view];
        [self.view bringSubviewToFront:_weekDaysVC.view];
        
    }else {
        self.DrawView.hidden = NO;
        self.dialView.hidden = NO;
        [_weekDaysVC.view removeFromSuperview];
        _weekDaysVC = nil;
    }
}
-(void)onWeekButtonClicked:(UIButton *)button
{
    self.DrawView.hidden = NO;
    self.dialView.hidden = NO;
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
