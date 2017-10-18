//
//  CustomSliderViewController.m
//  SmartHome
//
//  Created by KobeBryant on 2017/10/17.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "CustomSliderViewController.h"

@interface CustomSliderViewController ()

@end

@implementation CustomSliderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
}

- (void)initUI {
    self.view.backgroundColor = [UIColor blackColor];
    [self.lightSlider setThumbImage:[UIImage imageNamed:@"lv_btn_adjust_normal"] forState:UIControlStateNormal];
    self.lightSlider.maximumTrackTintColor = [UIColor colorWithRed:16/255.0 green:17/255.0 blue:21/255.0 alpha:1];
    self.lightSlider.minimumTrackTintColor = [UIColor colorWithRed:253/255.0 green:254/255.0 blue:254/255.0 alpha:1];
    [self.lightSlider addTarget:self action:@selector(onSliderTouchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
    self.lightSlider.continuous = NO;
}

- (void)onSliderTouchUpOutside:(UISlider *)slider {
    NSData *data = [[DeviceInfo defaultManager] changeBright:slider.value*100 deviceID:self.deviceid];
    SocketManager *sock = [SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
    
    [SQLManager updateDeviceBrightStatus:[self.deviceid intValue] value:slider.value];
    [NC postNotificationName:@"AirControllerStatusChangedNotifications" object:nil];
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

- (IBAction)onSliderValueChange:(id)sender {
    UISlider *slider = (UISlider *)sender;
    NSData *data = [[DeviceInfo defaultManager] changeBright:slider.value*100 deviceID:self.deviceid];
    SocketManager *sock = [SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
    
    [SQLManager updateDeviceBrightStatus:[self.deviceid intValue] value:slider.value];
    [NC postNotificationName:@"AirControllerStatusChangedNotifications" object:nil];
}
@end
