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

@interface FloweringController ()
@property (weak, nonatomic) IBOutlet UILabel *HLabel;
@property (weak, nonatomic) IBOutlet UILabel *SLabel;
@property (weak, nonatomic) IBOutlet UIStackView *menuContainer;

@end

@implementation FloweringController

- (void)viewDidLoad {
    [super viewDidLoad];
    if(self.roomID == 0) self.roomID = (int)[DeviceInfo defaultManager].roomID;
    NSArray *menus = [SQLManager singleProductByRoom:self.roomID];
    [self initMenuContainer:self.menuContainer andArray:menus andID:self.deviceid];
    [self naviToDevice];
    NSString *roomName = [SQLManager getRoomNameByRoomID:self.roomID];
    [self setNaviBarTitle:[NSString stringWithFormat:@"%@ - 智能浇花",roomName]];
    [self initSlider];
}

-(void) initSlider
{
    int sliderSize = 90;
    CGRect frame = CGRectMake(self.view.center.x-sliderSize, self.view.center.y-sliderSize, sliderSize*2, sliderSize*2);//CGRectInset(self.view.bounds, 0, 0);
    
    HTCircularSlider *slider = [[HTCircularSlider alloc] initWithFrame:frame];
    [self.view addSubview:slider];
    [slider addTarget:self action:@selector(onValueChange:) forControlEvents:UIControlEventValueChanged];

    slider.handleImage = [UIImage imageNamed:@"schedule_pointer"];
    
    slider.handleSize = CGPointMake(15/2, 51/2);
    slider.maximumValue = 24;
    slider.value = -180;
    slider.tag = 0;
    slider.radius = sliderSize;
    
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
}


- (void)onValueChange:(HTCircularSlider *)slider {
    NSLog(@"%f", slider.value);
    
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
    Schedule *sch = [[Schedule alloc] initWhithoutSchedule];
    sch.deviceID = [self.deviceid intValue];
    sch.startTime = self.HLabel.text;
    sch.interval = [self.SLabel.text intValue];
    [IOManager writeScene:[NSString stringWithFormat:@"schedule_%@.plist",self.deviceid] scene:sch];
}

- (IBAction)start:(id)sender {
    UIButton *button = (UIButton *)sender;

    [button setSelected:!button.isSelected];
    if (button.isSelected) {
        //selected
        [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"device_on"]] forState:UIControlStateSelected];
    }else{
        //normal
        [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"device_off"]] forState:UIControlStateNormal];
    }
    
    NSData *data = [[DeviceInfo defaultManager] toogle:button.isSelected deviceID:self.deviceid];
    [[[SocketManager defaultManager] socket] writeData:data withTimeout:1 tag:1];
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