//
//  IphoneFixSubTimeVC.m
//  SmartHome
//
//  Created by zhaona on 2017/1/11.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "IphoneFixSubTimeVC.h"
#import "SceneManager.h"
#import "Scene.h"
#import "Schedule.h"
#import "NSString+RegMatch.h"
#import "MBProgressHUD+NJ.h"

@interface IphoneFixSubTimeVC ()
@property (weak, nonatomic) IBOutlet UIButton *showTimeBtn;//展示和修改定时的Btn
@property (weak, nonatomic) IBOutlet UISwitch *PowerSwitch;//是否启动按钮
@property (weak, nonatomic) IBOutlet UILabel *showTimeLabel;//显示几个小时的label
@property (weak, nonatomic) IBOutlet UISlider *changeSlider;
@property (nonatomic,strong) Scene *scene;
@property (nonatomic,strong) Schedule *schedule;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (nonatomic,strong) NSMutableString *repeatTime;
@property (nonatomic,strong) NSMutableDictionary *dic;
@property (nonatomic,strong) NSArray *hours;
@property (nonatomic,strong) NSArray *minutes;
@property (nonatomic,strong) NSMutableDictionary *weeks;
@property (weak, nonatomic) IBOutlet UILabel *repeatLabel;

@end

@implementation IphoneFixSubTimeVC
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
-(NSMutableString *)repeatTime
{
    if(!_repeatTime)
    {
        _repeatTime = [NSMutableString string];
    }
    return _repeatTime;
}
-(NSMutableDictionary *)dic
{
    if(!_dic)
    {
        _dic =[NSMutableDictionary dictionary];
    }
    return _dic;
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
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.schedule = [[Schedule alloc]initWhithoutSchedule];
    [self createDatePicker];
    self.datePicker.hidden = YES;
    self.view.backgroundColor = [UIColor colorWithRed:255.0/247 green:255.0/247 blue:255.0/249 alpha:1];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(iphoneSelectWeek:) name:@"SelectWeek" object:nil];
    self.changeSlider.minimumValue = 1;
    self.changeSlider.maximumValue = 13;
    self.changeSlider.value = 1;
    self.changeSlider.continuous = YES;
    [self.changeSlider addTarget:self action:@selector(SliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        UIBarButtonItem *returnItem = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(clickRetunBtn:)];
        self.navigationItem.leftBarButtonItem = returnItem;
}

- (void)SliderValueChanged:(UISlider *)sender {
    
    NSLog(@"sender: %f", sender.value);
    if (lroundf(sender.value) == 13) {
        self.showTimeLabel.text = @"永不";
    }else {
        self.showTimeLabel.text = [NSString stringWithFormat:@"%ld小时", lroundf(sender.value)];
    }
}
-(void)createDatePicker
{
    self.datePicker.backgroundColor = [UIColor whiteColor];
    self.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"YYYY-MM-dd HH:mm"];

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
    
//    [self.repaBtn setTitle:display forState:UIControlStateNormal];
    self.repeatLabel.text = [NSString stringWithFormat:@"%@",display];
    
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
- (IBAction)showTimeBtn:(id)sender {
    
//    self.pickerTime.hidden = YES;
    
    self.showTimeBtn.selected = !self.showTimeBtn.selected;
    self.datePicker.hidden = !self.showTimeBtn.selected;
    if (!self.showTimeBtn.selected) {
        NSDate *myDate = self.datePicker.date;
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"MM-dd HH:mm"];
        NSString *prettyDate = [dateFormat stringFromDate:myDate];
        [self.showTimeBtn setTitle:prettyDate forState:UIControlStateNormal];
        self.schedule.startDate=prettyDate;
        //        self.clickFixTimeBtn.tintColor=[UIColor redColor];
    }
    
    NSMutableArray *sches=[self.scene.schedules mutableCopy];
    if ([sches count]==0) {
        [sches addObject:self.schedule];
    }else{
        sches[0]=self.schedule;
    }
    self.scene.schedules = sches;
    [[SceneManager defaultManager] addScene:self.scene withName:nil withImage:[UIImage imageNamed:@""]];
}
//保存按钮
- (IBAction)saveFixTime:(id)sender {
    
    self.scene.schedules = @[self.schedule];
    [[SceneManager defaultManager] addScene:self.scene withName:nil withImage:[UIImage imageNamed:@""]];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
     NSString * startDay;
    if ([self.showTimeBtn.titleLabel.text isEqualToString:@"设置"]) {
        startDay = @"无";
    }else{
        
        startDay = self.showTimeBtn.titleLabel.text;
    }
    
    NSDictionary *dic = @{@"startDay":startDay,@"repeat":self.repeatLabel.text};
    [center postNotificationName:@"time" object:nil userInfo:dic];
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)clickRetunBtn:(id)sender {
    [self.navigationController popViewControllerAnimated:NO];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
