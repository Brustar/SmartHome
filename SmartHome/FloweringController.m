//
//  FloweringController.m
//  SmartHome
//
//  Created by Brustar on 2017/5/4.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "FloweringController.h"
#import "HTCircularSlider.h"
#import "DeviceInfo.h"
#import "SocketManager.h"
#import "Schedule.h"
#import "IOManager.h"
#import "SQLManager.h"
#import "UIViewController+Navigator.h"
#import "UIView+Popup.h"
#import "SceneManager.h"
#import "SocketManager.h"
#import "DeviceSchedule.h"

@interface FloweringController ()

@property (weak, nonatomic) IBOutlet UILabel *HLabel;
@property (weak, nonatomic) IBOutlet UILabel *SLabel;
@property (weak, nonatomic) IBOutlet UIStackView *menuContainer;
@property (weak, nonatomic) IBOutlet UIImageView *start;
@property (weak, nonatomic) IBOutlet UIImageView *timer;
@property (weak, nonatomic) IBOutlet UIImageView *line;
@property (weak, nonatomic) IBOutlet UIImageView *base;
@property (weak, nonatomic) IBOutlet UILabel *second;
@property (nonatomic,assign) NSTimer *scheduler;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *menuTop;
@property (weak, nonatomic) IBOutlet UIButton *btnCmd;

@property (weak, nonatomic) IBOutlet UILabel *schduleLbl;
@property (weak, nonatomic) IBOutlet UILabel *immediateLbl;
@property (weak, nonatomic) IBOutlet UIButton *schduleBtn;
@property (weak, nonatomic) IBOutlet UIButton *immediateBtn;
@property (weak, nonatomic) IBOutlet UIImageView *timeBase;
@property (weak, nonatomic) IBOutlet UILabel *timeLbl;
@property (weak, nonatomic) IBOutlet UIView *schLine;
@property (weak, nonatomic) IBOutlet UIView *immedLine;

@property(nonatomic) int interval;
@end

@implementation FloweringController

- (void)viewDidLoad {
    [super viewDidLoad];
    if(self.roomID == 0) self.roomID = (int)[DeviceInfo defaultManager].roomID;
    NSArray *menus = [SQLManager singleProductByRoom:self.roomID];
    self.deviceid = [SQLManager singleDeviceWithCatalogID:flowering byRoom:self.roomID];
    [self initMenuContainer:self.menuContainer andArray:menus andID:self.deviceid];
    [self naviToDevice];
    NSString *roomName = [SQLManager getRoomNameByRoomID:self.roomID];
    self.title = [NSString stringWithFormat:@"%@ - 智能浇花",roomName];
    [self setNaviBarTitle:self.title];
    [self initSlider];
    if (ON_IPAD) {
        self.menuTop.constant = 0;
        self.btnCmd.hidden = self.second.hidden = YES;
        
        self.schLine.hidden = self.schduleBtn.hidden = self.schduleLbl.hidden = self.immedLine.hidden = self.immediateBtn.hidden = self.immediateLbl.hidden = self.timeLbl.hidden = self.timeBase.hidden = NO;
        [(CustomViewController *)self.splitViewController.parentViewController setNaviBarTitle:self.title];
    }
}

-(void) initSlider
{
    int sliderSize = 90;
    CGRect frame = CGRectMake(self.view.center.x-sliderSize, self.view.center.y-sliderSize, sliderSize*2, sliderSize*2);
    
    HTCircularSlider *slider = [[HTCircularSlider alloc] initWithFrame:frame];
    [self.view addSubview:slider];
    [slider addTarget:self action:@selector(onValueChange:) forControlEvents:UIControlEventValueChanged];

    slider.handleImage = [UIImage imageNamed:@"schedule_pointer"];
    
    slider.handleSize = CGPointMake(15/2, 51/2);
    slider.maximumValue = 24;
    slider.value = -180;
    slider.tag = 0;
    slider.radius = sliderSize;
    [slider constraintToCenter:sliderSize*2];
    sliderSize = 65;
    frame = CGRectMake(self.view.center.x-sliderSize, self.view.center.y-sliderSize, sliderSize*2, sliderSize*2);
    HTCircularSlider *second = [[HTCircularSlider alloc] initWithFrame:frame];
    [self.view addSubview:second];
    [second addTarget:self action:@selector(onValueChange:) forControlEvents:UIControlEventValueChanged];
    
    second.handleImage = [UIImage imageNamed:@"schedule_thumb"];
    second.handleSize = CGPointMake(28/2, 27/2);
    
    second.maximumValue = 16;
    second.value = 0;
    second.trackAlpha = 0.6;
    second.tag = 1;
    second.radius = sliderSize;
    [second constraintToCenter:sliderSize*2];
}


- (void)onValueChange:(HTCircularSlider *)slider {
    NSLog(@"%f", slider.value);

    self.HLabel.hidden = self.SLabel.hidden = self.start.hidden = self.line.hidden = self.timer.hidden = slider.value==0;
    [self.base setImage:[UIImage imageNamed:slider.value>0?@"flower_schedule":@"sp_base"]];

    
    if (slider.tag == 0) {
        float dec = slider.value-(int)slider.value;
        int second = (int)(dec*60);
        NSString *pattern = second>9?@"%d:%d":@"%d:0%d";
        
        int hint = (int)slider.value;
        int hour = hint >= 12 ? hint - 12 : hint + 12;
        self.HLabel.text = [NSString stringWithFormat:pattern,hour,second];
    }else{
        self.SLabel.text = [NSString stringWithFormat:@"%dS",(int)slider.value];
    }
}

- (IBAction)save:(id)sender {
    UIButton *button = (UIButton *)sender;
    
    [button setSelected:!button.isSelected];
    if (button.isSelected) {
        Schedule *sch = [[Schedule alloc] initWhithoutSchedule];
        sch.startTime = self.HLabel.text;
        sch.interval = [self.SLabel.text intValue];
        
        NSString *plistFile = [NSString stringWithFormat:@"schedule_%ld_%@.plist",[[DeviceInfo defaultManager] masterID],self.deviceid];
        
        DeviceSchedule *ds = [DeviceSchedule new];
        ds.deviceID = [self.deviceid intValue];
        ds.schedules = @[sch];
        [IOManager writeScene:plistFile scene:ds];
        
        //upload
        [[SceneManager defaultManager] saveDeviceSchedule:plistFile];
    }
    NSData *data = [[DeviceInfo defaultManager] scheduleDevice:button.isSelected deviceID:self.deviceid];
    [[[SocketManager defaultManager] socket] writeData:data withTimeout:1 tag:1];
}

-(IBAction)startNow:(id)sender
{
    self.interval ++;
    int min = self.interval/60;
    int second = self.interval%60;
    NSString *matter =@"%d:%d";
    if (second<10) {
        matter =@"%d:0%d";
    }
    self.timeLbl.text = [NSString stringWithFormat:matter,min,second];
}

- (IBAction)start:(id)sender {
    UIButton *button = (UIButton *)sender;

    [button setSelected:!button.isSelected];
    
    if (ON_IPAD) {
        if (button.isSelected) {
            //selected
            [button setBackgroundImage:[UIImage imageNamed:@"dvd_btn_switch_on"] forState:UIControlStateSelected];
            self.scheduler = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(startNow:) userInfo:nil repeats:YES];
        }else{
            //normal
            [button setBackgroundImage:[UIImage imageNamed:@"dvd_btn_switch_off"] forState:UIControlStateNormal];
            self.timeLbl.text = @"00:00";
            self.interval = 0;
            [self.scheduler invalidate];
        }
    }else{
        if (button.isSelected) {
            //selected
            [button setBackgroundImage:[UIImage imageNamed:@"sp_on"] forState:UIControlStateSelected];
            self.interval = [self.SLabel.text intValue];
            self.scheduler = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timing:) userInfo:nil repeats:YES];
        }else{
            //normal
            [button setBackgroundImage:[UIImage imageNamed:@"sp_off"] forState:UIControlStateNormal];
            [button setTitle:@"" forState:UIControlStateNormal];
            [self.scheduler invalidate];
        }
        self.second.hidden = !button.isSelected;
    }
    
    NSData *data = [[DeviceInfo defaultManager] toogle:button.isSelected deviceID:self.deviceid];
    [[[SocketManager defaultManager] socket] writeData:data withTimeout:1 tag:1];
}

-(IBAction)timing:(id)sender
{
    NSTimer *timer  = (NSTimer*)sender;
    UIButton *button = [self.view viewWithTag:99];
    
    int t = [self.SLabel.text intValue];
    [button setTitle:[NSString stringWithFormat:@"%d",self.interval] forState:UIControlStateNormal];
    if(t > 0){
        if (self.interval==0) {
            button.selected = NO;
            self.second.hidden = YES;
            [button setTitle:@"" forState:UIControlStateNormal];
            NSData *data = [[DeviceInfo defaultManager] toogle:NO deviceID:self.deviceid];
            [[[SocketManager defaultManager] socket] writeData:data withTimeout:1 tag:1];
            [timer invalidate];
        }
        self.interval--;
    }else{
        self.interval++;
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
