//
//  AireTableViewCell.m
//  SmartHome
//
//  Created by zhaona on 2017/3/23.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "AireTableViewCell.h"
#import "SQLManager.h"
#import "Aircon.h"
#import "SocketManager.h"
#import "SceneManager.h"
#import "PackManager.h"

@implementation AireTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
  
//    [IOManager removeTempFile];
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
    if (ON_IPAD) {
        self.supImageViewHeight.constant = 85;
        self.AireNameLabel.font = [UIFont systemFontOfSize:17];
        [self.AddAireBtn setImage:[UIImage imageNamed:@"ipad-icon_add_nol"] forState:UIControlStateNormal];
    }
}
-(void) query:(NSString *)deviceid
{
    self.deviceid = deviceid;
    SocketManager *sock=[SocketManager defaultManager];
    //sock.delegate=self;
    //查询设备状态
    NSData *data = [[DeviceInfo defaultManager] query:deviceid];
    [sock.socket writeData:data withTimeout:1 tag:1];
}
- (IBAction)save:(id)sender {
     _scene=[[SceneManager defaultManager] readSceneByID:[self.sceneid intValue]];
      Aircon *device=[[Aircon alloc] init];
    if (sender == self.AireSwitchBtn) {
        if (ON_IPAD) {
            [self.AddAireBtn setImage:[UIImage imageNamed:@"ipad-icon_reduce_nol"] forState:UIControlStateNormal];
        }else{
            [self.AddAireBtn setImage:[UIImage imageNamed:@"icon_reduce_normal"] forState:UIControlStateNormal];
        }
        self.AddAireBtn.selected = YES;
        self.AireSwitchBtn.selected = !self.AireSwitchBtn.selected;
        if (self.AireSwitchBtn.selected) {
            [self.AireSwitchBtn setBackgroundImage:[UIImage imageNamed:@"dvd_btn_switch_on"] forState:UIControlStateSelected];
        }else{
            [self.AireSwitchBtn setBackgroundImage:[UIImage imageNamed:@"dvd_btn_switch_off"] forState:UIControlStateNormal];
        }
        
        Device *device = [SQLManager getDeviceWithDeviceHtypeID:air roomID:self.roomID];
        NSData * data = [[DeviceInfo defaultManager] toogleAirCon:self.AireSwitchBtn.selected deviceID:self.deviceid roomID:device.airID];
        SocketManager *sock=[SocketManager defaultManager];
        [sock.socket writeData:data withTimeout:1 tag:1];
        
        if (_delegate && [_delegate respondsToSelector:@selector(onAirSwitchBtnClicked:)]) {
            [_delegate onAirSwitchBtnClicked:sender];
        }
        
    }else if (sender == self.AddAireBtn){
        self.AddAireBtn.selected = !self.AddAireBtn.selected;
        if (self.AddAireBtn.selected) {
            
            if (ON_IPAD) {
                [self.AddAireBtn setImage:[UIImage imageNamed:@"ipad-icon_reduce_nol"] forState:UIControlStateNormal];
            }else{
                 [self.AddAireBtn setImage:[UIImage imageNamed:@"icon_reduce_normal"] forState:UIControlStateNormal];
            }
        }else{
            
            if (ON_IPAD) {
                [self.AddAireBtn setImage:[UIImage imageNamed:@"ipad-icon_add_nol"] forState:UIControlStateNormal];
            }else{
                [self.AddAireBtn setImage:[UIImage imageNamed:@"icon_add_normal"] forState:UIControlStateNormal];
            }
            //删除当前场景的当前硬件
            NSArray *devices = [[SceneManager defaultManager] subDeviceFromScene:_scene withDeivce:device.deviceID];
            [_scene setDevices:devices];
        }
       
    }else if (sender == self.AireSlider){
        if (ON_IPAD) {
            [self.AddAireBtn setImage:[UIImage imageNamed:@"ipad-icon_reduce_nol"] forState:UIControlStateNormal];
        }else{
            [self.AddAireBtn setImage:[UIImage imageNamed:@"icon_reduce_normal"] forState:UIControlStateNormal];
        }
        self.AddAireBtn.selected = YES;
        self.temperatureLabel.text = [NSString stringWithFormat:@"%ld°C", lroundf(self.AireSlider.value)];
        NSData *data=[[DeviceInfo defaultManager] changeTemperature:0x6A deviceID:self.deviceid value:lroundf(self.AireSlider.value)];
        SocketManager *sock=[SocketManager defaultManager];
        [sock.socket writeData:data withTimeout:1 tag:1];
        
        if (_delegate && [_delegate respondsToSelector:@selector(onAirSliderValueChanged:)]) {
            [_delegate onAirSliderValueChanged:sender];
        }
    }

    [device setDeviceID:[self.deviceid intValue]];
    [device setPoweron:self.AireSwitchBtn.selected];
    [_scene setSceneID:[self.sceneid intValue]];
    [_scene setRoomID:self.roomID];
    [_scene setMasterID:[[DeviceInfo defaultManager] masterID]];
    [_scene setReadonly:NO];
    //    [NSString stringWithFormat:@"%ld°C", lroundf(self.AireSlider.value)]
    [device setTemperature:(int)lroundf(self.AireSlider.value)];
    NSArray *devices=[[SceneManager defaultManager] addDevice2Scene:_scene withDeivce:device withId:device.deviceID];
    [_scene setDevices:devices];
   
    [[SceneManager defaultManager] addScene:_scene withName:nil withImage:[UIImage imageNamed:@""] withiSactive:0];
}

#pragma mark - TCP recv delegate
-(void)recv:(NSData *)data withTag:(long)tag
{
    Proto proto=protocolFromData(data);
    
    if (CFSwapInt16BigToHost(proto.masterID) != [[DeviceInfo defaultManager] masterID]) {
        return;
    }
    
    if (proto.cmd==0x01) {
        
        if (proto.action.state==0x6A) {
            self.temperatureLabel.text = [NSString stringWithFormat:@"Current:%d°C",proto.action.RValue];
        }
//        if (proto.action.state==0x8A) {
//            NSString *valueString = [NSString stringWithFormat:@"%d %%",proto.action.RValue];
//            self.wetLabel.text = valueString;
//            [self.humidity_hand rotate:30+proto.action.RValue*100/300];
//        }
//        if (proto.action.state==0x7F) {
//            NSString *valueString = [NSString stringWithFormat:@"%d",proto.action.RValue];
//            self.pmLabel.text = valueString;
//            
//            float value = 30+proto.action.RValue*200/100;
//            if (proto.action.RValue>100 && proto.action.RValue<200) {
//                value = 230+proto.action.RValue*40/100;
//            }
//            if (proto.action.RValue>200)
//            {
//                value = 240+proto.action.RValue*60/300;
//            }
//            [self.pm_clock_hand rotate:value];
//        }
        NSString *devID=[SQLManager getDeviceIDByENumber:CFSwapInt16BigToHost(proto.deviceID)];
        if ([devID intValue]==[self.deviceid intValue]) {
            if (proto.action.state == PROTOCOL_OFF || proto.action.state == PROTOCOL_ON) {
                self.AddAireBtn.selected = proto.action.state;
            }
        }
    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
