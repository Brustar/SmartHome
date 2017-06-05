//
//  IpadDVDTableViewCell.m
//  SmartHome
//
//  Created by zhaona on 2017/6/5.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "IpadDVDTableViewCell.h"
#import "SQLManager.h"
#import "DVD.h"
#import "SocketManager.h"
#import "SceneManager.h"

@implementation IpadDVDTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self.PreviousBtn setImage:[UIImage imageNamed:@"ipad-icon_lt_prd"] forState:UIControlStateHighlighted];
    [self.nextBtn setImage:[UIImage imageNamed:@"ipad-icon_rt_prd"] forState:UIControlStateHighlighted];
    [self.DVDSlider setThumbImage:[UIImage imageNamed:@"lv_btn_adjust_normal"] forState:UIControlStateNormal];
    self.DVDSlider.maximumTrackTintColor = [UIColor colorWithRed:16/255.0 green:17/255.0 blue:21/255.0 alpha:1];
    self.DVDSlider.minimumTrackTintColor = [UIColor colorWithRed:253/255.0 green:254/255.0 blue:254/255.0 alpha:1];
    [self.AddDvdBtn addTarget:self action:@selector(save:) forControlEvents:UIControlEventTouchUpInside];
    [self.DVDSwitchBtn addTarget:self action:@selector(save:) forControlEvents:UIControlEventTouchUpInside];
    [self.DVDSlider addTarget:self action:@selector(save:) forControlEvents:UIControlEventValueChanged];
    [self.DVDSwitchBtn setBackgroundImage:[UIImage imageNamed:@"dvd_btn_switch_on"] forState:UIControlStateSelected];
    [self.DVDSwitchBtn setBackgroundImage:[UIImage imageNamed:@"dvd_btn_switch_off"] forState:UIControlStateNormal];
}
- (IBAction)save:(id)sender {
    
    DVD *device=[[DVD alloc] init];
    [device setDeviceID:[self.deviceid intValue]];
    [device setPoweron:device.poweron];
    
    if (sender == self.DVDSwitchBtn) {
        NSData *data=nil;
        self.DVDSwitchBtn.selected = !self.DVDSwitchBtn.selected;
        if (self.DVDSwitchBtn.selected) {
            [self.DVDSwitchBtn setBackgroundImage:[UIImage imageNamed:@"dvd_btn_switch_on"] forState:UIControlStateSelected];
            data=[[DeviceInfo defaultManager] pause:self.deviceid];
            SocketManager *sock=[SocketManager defaultManager];
            [sock.socket writeData:data withTimeout:1 tag:1];
            
        }else{
            
            [self.DVDSwitchBtn setBackgroundImage:[UIImage imageNamed:@"dvd_btn_switch_off"] forState:UIControlStateNormal];
            data=[[DeviceInfo defaultManager] play:self.deviceid];
            SocketManager *sock=[SocketManager defaultManager];
            [sock.socket writeData:data withTimeout:1 tag:1];
        }
        
        if (_delegate && [_delegate respondsToSelector:@selector(onDVDSwitchBtnClicked:)]) {
            [_delegate onDVDSwitchBtnClicked:sender];
        }
        
    }else if (sender == self.AddDvdBtn){
        self.AddDvdBtn.selected = !self.AddDvdBtn.selected;
        if (self.AddDvdBtn.selected) {
            [self.AddDvdBtn setImage:[UIImage imageNamed:@"ipad-icon_reduce_nol"] forState:UIControlStateNormal];
            
            [_scene setSceneID:[self.sceneid intValue]];
            [_scene setRoomID:self.roomID];
            [_scene setMasterID:[[DeviceInfo defaultManager] masterID]];
            
            [_scene setReadonly:NO];
            
            NSArray *devices=[[SceneManager defaultManager] addDevice2Scene:_scene withDeivce:device withId:device.deviceID];
            [_scene setDevices:devices];
            [[SceneManager defaultManager] addScene:_scene withName:nil withImage:[UIImage imageNamed:@""]];
            
        }else{
            [self.AddDvdBtn setImage:[UIImage imageNamed:@"ipad-icon_add_nol"] forState:UIControlStateNormal];
        }
        
    }else if (sender == self.DVDSlider){
        
        NSData *data=[[DeviceInfo defaultManager] changeVolume:self.DVDSlider.value*100 deviceID:self.deviceid];
        SocketManager *sock=[SocketManager defaultManager];
        [sock.socket writeData:data withTimeout:1 tag:1];
        
        if (_delegate && [_delegate respondsToSelector:@selector(onDVDSliderValueChanged:)]) {
            [_delegate onDVDSliderValueChanged:sender];
        }
    }
}
//上一曲
- (IBAction)Previous:(id)sender {
    NSData *data=nil;
    data=[[DeviceInfo defaultManager] previous:self.deviceid];
    SocketManager *sock=[SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
    
}
//下一曲
- (IBAction)nextBtn:(id)sender {
    NSData *data=nil;
    data=[[DeviceInfo defaultManager] next:self.deviceid];
    SocketManager *sock=[SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
}
//暂停
- (IBAction)stopBtn:(id)sender {
    NSData *data=nil;
    self.stopBtn.selected = !self.stopBtn.selected;
    if (self.stopBtn.selected) {
        [self.stopBtn setImage:[UIImage imageNamed:@"ipad-icon_st_prd"] forState:UIControlStateNormal];
        data=[[DeviceInfo defaultManager] pause:self.deviceid];
        SocketManager *sock=[SocketManager defaultManager];
        [sock.socket writeData:data withTimeout:1 tag:1];
    }else{
        [self.stopBtn setImage:[UIImage imageNamed:@"ipad-icon_st_nol"] forState:UIControlStateNormal];
        data=[[DeviceInfo defaultManager] play:self.deviceid];
        SocketManager *sock=[SocketManager defaultManager];
        [sock.socket writeData:data withTimeout:1 tag:1];
    }
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
