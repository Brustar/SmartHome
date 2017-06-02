//
//  IpadTVCell.m
//  SmartHome
//
//  Created by zhaona on 2017/6/1.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "IpadTVCell.h"
#import "SQLManager.h"
#import "TV.h"
#import "SocketManager.h"
#import "SceneManager.h"

@implementation IpadTVCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    [self.TVSlider setThumbImage:[UIImage imageNamed:@"lv_btn_adjust_normal"] forState:UIControlStateNormal];
    self.TVSlider.maximumTrackTintColor = [UIColor colorWithRed:16/255.0 green:17/255.0 blue:21/255.0 alpha:1];
    self.TVSlider.minimumTrackTintColor = [UIColor colorWithRed:253/255.0 green:254/255.0 blue:254/255.0 alpha:1];
    [self.TVSwitchBtn addTarget:self action:@selector(save:) forControlEvents:UIControlEventTouchUpInside];
    [self.AddTvDeviceBtn addTarget:self action:@selector(save:) forControlEvents:UIControlEventTouchUpInside];
    [self.TVSlider addTarget:self action:@selector(save:) forControlEvents:UIControlEventValueChanged];
    self.TVSlider.continuous = NO;
    [self.TVSwitchBtn setBackgroundImage:[UIImage imageNamed:@"dvd_btn_switch_on"] forState:UIControlStateSelected];
    [self.TVSwitchBtn setBackgroundImage:[UIImage imageNamed:@"dvd_btn_switch_off"] forState:UIControlStateNormal];
}
- (IBAction)save:(id)sender {
    
    TV *device=[[TV alloc] init];
    [device setDeviceID:[self.deviceid intValue]];
    //    [device setIsPoweron:device.poweron];
    [device setPoweron:device.poweron];
    [device setVolume:self.TVSlider.value*100];
    
    if (sender == self.TVSwitchBtn) {
        
        self.TVSwitchBtn.selected = !self.TVSwitchBtn.selected;
        if (self.TVSwitchBtn.selected) {
            [self.TVSwitchBtn setBackgroundImage:[UIImage imageNamed:@"dvd_btn_switch_on"] forState:UIControlStateSelected];
            NSData *data=nil;
            DeviceInfo *device=[DeviceInfo defaultManager];
            data=[device toogle:self.TVSwitchBtn.selected deviceID:self.deviceid];
            SocketManager *sock=[SocketManager defaultManager];
            [sock.socket writeData:data withTimeout:1 tag:1];
        }else{
            [self.TVSwitchBtn setBackgroundImage:[UIImage imageNamed:@"dvd_btn_switch_off"] forState:UIControlStateNormal];
            NSData *data=nil;
            DeviceInfo *device=[DeviceInfo defaultManager];
            data=[device toogle:self.TVSwitchBtn.selected deviceID:self.deviceid];
            SocketManager *sock=[SocketManager defaultManager];
            [sock.socket writeData:data withTimeout:1 tag:1];
        }
        
        if (_delegate && [_delegate respondsToSelector:@selector(onTVSwitchBtnClicked:)]) {
            [_delegate onTVSwitchBtnClicked:sender];
        }
        
    }else if (sender == self.AddTvDeviceBtn){
        self.AddTvDeviceBtn.selected = !self.AddTvDeviceBtn.selected;
        if (self.AddTvDeviceBtn.selected) {
            [self.AddTvDeviceBtn setImage:[UIImage imageNamed:@"icon_reduce_normal"] forState:UIControlStateNormal];
            
            [_scene setSceneID:[self.sceneid intValue]];
            [_scene setRoomID:self.roomID];
            [_scene setMasterID:[[DeviceInfo defaultManager] masterID]];
            
            [_scene setReadonly:NO];
            
            NSArray *devices=[[SceneManager defaultManager] addDevice2Scene:_scene withDeivce:device withId:device.deviceID];
            [_scene setDevices:devices];
            [[SceneManager defaultManager] addScene:_scene withName:nil withImage:[UIImage imageNamed:@""]];
            
        }else{
            [self.AddTvDeviceBtn setImage:[UIImage imageNamed:@"icon_add_normal"] forState:UIControlStateNormal];
        }
        
    }else if (sender == self.TVSlider){
        NSData *data=[[DeviceInfo defaultManager] changeVolume:self.TVSlider.value*100 deviceID:self.deviceid];
        //        self.voiceValue.text = [NSString stringWithFormat:@"%d%%",(int)self.volume.value];
        SocketManager *sock=[SocketManager defaultManager];
        [sock.socket writeData:data withTimeout:1 tag:1];
        
        if (_delegate && [_delegate respondsToSelector:@selector(onTVSliderValueChanged:)]) {
            [_delegate onTVSliderValueChanged:sender];
        }
    }
    
}
//频道减
- (IBAction)channelReduce:(id)sender {
    NSData *data=nil;
    DeviceInfo *device=[DeviceInfo defaultManager];
    data=[device previous:self.deviceid];
    SocketManager *sock=[SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
}
//频道加
- (IBAction)channelAdd:(id)sender {
    NSData *data=nil;
    DeviceInfo *device=[DeviceInfo defaultManager];
    data = [device next:self.deviceid];
    SocketManager *sock=[SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
