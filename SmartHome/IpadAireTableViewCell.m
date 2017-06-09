//
//  IpadAireTableViewCell.m
//  SmartHome
//
//  Created by zhaona on 2017/6/1.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "IpadAireTableViewCell.h"
#import "SQLManager.h"
#import "Aircon.h"
#import "SocketManager.h"
#import "SceneManager.h"

@implementation IpadAireTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.AireSlider.minimumValue = 16;
    self.AireSlider.maximumValue = 30;
    self.AireSlider.value = 1;
    [self.AireSlider setThumbImage:[UIImage imageNamed:@"lv_btn_adjust_normal"] forState:UIControlStateNormal];
    self.AireSlider.maximumTrackTintColor = [UIColor colorWithRed:16/255.0 green:17/255.0 blue:21/255.0 alpha:1];
    self.AireSlider.minimumTrackTintColor = [UIColor colorWithRed:253/255.0 green:254/255.0 blue:254/255.0 alpha:1];
    [self.AireSwitchBtn addTarget:self action:@selector(save:) forControlEvents:UIControlEventTouchUpInside];
    [self.AddAireBtn addTarget:self action:@selector(save:) forControlEvents:UIControlEventTouchUpInside];
    [self.AireSlider addTarget:self action:@selector(save:) forControlEvents:UIControlEventValueChanged];
    self.AireSlider.continuous = NO;
    
    [self.AireSwitchBtn setBackgroundImage:[UIImage imageNamed:@"dvd_btn_switch_on"] forState:UIControlStateSelected];
    [self.AireSwitchBtn setBackgroundImage:[UIImage imageNamed:@"dvd_btn_switch_off"] forState:UIControlStateNormal];
}

- (IBAction)save:(id)sender {
    
    Aircon *device=[[Aircon alloc] init];
    [device setDeviceID:[self.deviceid intValue]];
    [device setWaiting:device.waiting];
    //    [device setTemperature:[self.showTemLabel.text intValue]];
    
    if (sender == self.AireSwitchBtn) {
        self.AireSwitchBtn.selected = !self.AireSwitchBtn.selected;
        if (self.AireSwitchBtn.selected) {
            [self.AireSwitchBtn setBackgroundImage:[UIImage imageNamed:@"dvd_btn_switch_on"] forState:UIControlStateSelected];
        }else{
            [self.AireSwitchBtn setBackgroundImage:[UIImage imageNamed:@"dvd_btn_switch_off"] forState:UIControlStateNormal];
        }
        NSData * data = [[DeviceInfo defaultManager] toogleAirCon:self.AireSwitchBtn.selected deviceID:self.deviceid];
        SocketManager *sock=[SocketManager defaultManager];
        [sock.socket writeData:data withTimeout:1 tag:1];
        
        if (_delegate && [_delegate respondsToSelector:@selector(onAirSwitchBtnClicked:)]) {
            [_delegate onAirSwitchBtnClicked:sender];
        }
        
    }else if (sender == self.AddAireBtn){
        self.AddAireBtn.selected = !self.AddAireBtn.selected;
        if (self.AddAireBtn.selected) {
            [self.AddAireBtn setImage:[UIImage imageNamed:@"ipad-icon_reduce_nol"] forState:UIControlStateNormal];
            
            [_scene setSceneID:[self.sceneid intValue]];
            [_scene setRoomID:self.roomID];
            [_scene setMasterID:[[DeviceInfo defaultManager] masterID]];
            
            [_scene setReadonly:NO];
            
            NSArray *devices=[[SceneManager defaultManager] addDevice2Scene:_scene withDeivce:device withId:device.deviceID];
            [_scene setDevices:devices];
            [[SceneManager defaultManager] addScene:_scene withName:nil withImage:[UIImage imageNamed:@""]];
            
        }else{
            [self.AddAireBtn setImage:[UIImage imageNamed:@"ipad-icon_add_nol"] forState:UIControlStateNormal];
            
            [_scene setSceneID:[self.sceneid intValue]];
            [_scene setRoomID:self.roomID];
            [_scene setMasterID:[[DeviceInfo defaultManager] masterID]];
            
            [_scene setReadonly:NO];
            
            //删除当前场景的当前硬件
            NSMutableArray *devices = [NSMutableArray arrayWithObject:[NSString stringWithFormat:@"@%d",device.deviceID]];
            [devices removeObject:[NSString stringWithFormat:@"@%d",device.deviceID]];
            
            [_scene setDevices:devices];
            [[SceneManager defaultManager] addScene:_scene withName:nil withImage:[UIImage imageNamed:@""]];
            
        }
        
    }else if (sender == self.AireSlider){
        
        self.temperatureLabel.text = [NSString stringWithFormat:@"%ld°C", lroundf(self.AireSlider.value)];
        NSData *data=[[DeviceInfo defaultManager] changeTemperature:0x6A deviceID:self.deviceid value:lroundf(self.AireSlider.value)];
        SocketManager *sock=[SocketManager defaultManager];
        [sock.socket writeData:data withTimeout:1 tag:1];
        
        if (_delegate && [_delegate respondsToSelector:@selector(onAirSliderValueChanged:)]) {
            [_delegate onAirSliderValueChanged:sender];
        }
    }
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
