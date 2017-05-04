//
//  IphoneNewAddSceneTimerVC.m
//  SmartHome
//
//  Created by zhaona on 2017/4/10.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "IphoneNewAddSceneTimerVC.h"
#import "EFCircularSlider.h"
#import "SceneManager.h"
#import "Scene.h"
#import "Schedule.h"
#import "NSString+RegMatch.h"
#import "MBProgressHUD+NJ.h"

@interface IphoneNewAddSceneTimerVC ()
@property (nonatomic,strong) Scene *scene;
@property (nonatomic,strong) Schedule *schedule;
@property (nonatomic,strong) NSMutableDictionary *weeks;
@end

@implementation IphoneNewAddSceneTimerVC
{
    EFCircularSlider* minuteSlider;
    EFCircularSlider* hourSlider;
}
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
    [self setSlider];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(iphoneSelectWeek:) name:@"SelectWeek" object:nil];
}
-(void)setSlider
{
    CGRect minuteSliderFrame = CGRectMake(90, 100, 220, 220);
    minuteSlider.center = self.DrawView.center;
    minuteSlider = [[EFCircularSlider alloc] initWithFrame:minuteSliderFrame];
    //    minuteSlider.unfilledColor = [UIColor colorWithRed:23/255.0f green:47/255.0f blue:70/255.0f alpha:1.0f];
    minuteSlider.unfilledColor = [UIColor clearColor];
    minuteSlider.filledColor = [UIColor colorWithRed:87/255.0f green:88/255.0f blue:89/255.0f alpha:0.6f];
//    [minuteSlider setInnerMarkingLabels:@[@"13",@"14",@"15",@"16",@"17",@"18",@"19",@"20",@"21",@"22",@"23",@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10",@"11",@"12"]];
    [minuteSlider setInnerMarkingLabels:nil];
    minuteSlider.labelFont = [UIFont systemFontOfSize:8.0f];

    minuteSlider.lineWidth = 20;
    minuteSlider.minimumValue = 0;
    minuteSlider.maximumValue = 24;
    //    minuteSlider.labelColor = [UIColor colorWithRed:76/255.0f green:111/255.0f blue:137/255.0f alpha:1.0f];
    minuteSlider.labelColor = [UIColor lightGrayColor];
    minuteSlider.handleType = semiTransparentWhiteCircle;
    minuteSlider.handleColor = [UIColor clearColor];
    
    [self.DrawView addSubview:minuteSlider];
    //    self.DrawView.backgroundColor = [UIColor redColor];
    //    [imageView addSubview:minuteSlider];
    [minuteSlider addTarget:self action:@selector(minuteDidChange:) forControlEvents:UIControlEventValueChanged];

}
-(void)minuteDidChange:(EFCircularSlider*)slider {
    //    int newVal = (int)slider.currentValue < 60 ? (int)slider.currentValue : 0;
    int newVal = (int)slider.currentValue;
    NSString* oldTime = _starTimeLabel.text;
    NSRange colonRange = [oldTime rangeOfString:@":"];
    //    _timeLabel.text = [NSString stringWithFormat:@"%@:%02d", [oldTime substringToIndex:colonRange.location], newVal];
    _starTimeLabel.text = [NSString stringWithFormat:@"%d:%@", newVal, [oldTime substringFromIndex:colonRange.location + 1]];
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
   // self.RepetitionLable.text = [display componentsSeparatedByString:@"、"];
    
    //    if (self.isSceneSetTime) { //设置了开始时间和结束时间才能设置重复选项
    
    NSMutableArray *weekValue = [NSMutableArray array];
    for (int i = 0; i < 7; i++) {
        if (week[i]) {
            NSNumber *temp = [NSNumber numberWithInt:i];
            [weekValue addObject:temp];
            
        }
    }
    
    self.schedule.weekDays = weekValue;
    
    [[SceneManager defaultManager] addScene:self.scene withName:nil withImage:[UIImage imageNamed:@""]];
    //    }
    //        else {
    //        [MBProgressHUD showError:@"请先设置时间"];
    //    }
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
