//
//  FMTableViewCell.m
//  SmartHome
//
//  Created by zhaona on 2017/4/17.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "FMTableViewCell.h"
#import "SQLManager.h"
#import "Light.h"
#import "SocketManager.h"
#import "SceneManager.h"
#import "Radio.h"


@implementation FMTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    [self.FMSlider setThumbImage:[UIImage imageNamed:@"lv_btn_adjust_normal"] forState:UIControlStateNormal];
    self.FMSlider.maximumTrackTintColor = [UIColor colorWithRed:16/255.0 green:17/255.0 blue:21/255.0 alpha:1];
    self.FMSlider.minimumTrackTintColor = [UIColor colorWithRed:253/255.0 green:254/255.0 blue:254/255.0 alpha:1];
    //设置结点左边背景
    UIImage *trackLeftImage;
    if (ON_IPAD) {
        trackLeftImage = [[UIImage imageNamed:@"Ipad-fm_adjustt"]stretchableImageWithLeftCapWidth:14 topCapHeight:0];
    }else{
        trackLeftImage = [[UIImage imageNamed:@"ss"]stretchableImageWithLeftCapWidth:14 topCapHeight:0];
    }
  
    [self.FMChannelSlider setMinimumTrackImage:trackLeftImage forState:UIControlStateNormal];
    self.FMChannelSlider.continuous = NO;
    self.FMSlider.continuous = NO;
    //设置结点右边背景
    UIImage *trackRightImage;
    if (ON_IPAD) {
          trackRightImage = [[UIImage imageNamed:@"Ipad-fm_adjustt"]stretchableImageWithLeftCapWidth:14 topCapHeight:0];
        self.IpadHomePageBgHeight.constant = 85;
        self.FMchoiceHeight.constant = 85;
        self.FMNameLabel.font = [UIFont systemFontOfSize:17];
        self.fmchannelSliderTopConstraint.constant = -10;
         [self.AddFmBtn setImage:[UIImage imageNamed:@"ipad-icon_add_nol"] forState:UIControlStateNormal];
        
    }else{
         trackRightImage = [[UIImage imageNamed:@"ss"]stretchableImageWithLeftCapWidth:14 topCapHeight:0];
    }
    
    [self.FMChannelSlider setMaximumTrackImage:trackRightImage forState:UIControlStateNormal];
    [self.AddFmBtn addTarget:self action:@selector(save:) forControlEvents:UIControlEventTouchUpInside];
    [self.FMSlider addTarget:self action:@selector(save:) forControlEvents:UIControlEventValueChanged];//音量
    [self.FMChannelSlider addTarget:self action:@selector(save:) forControlEvents:UIControlEventValueChanged];//频道
    [self.FMSwitchBtn addTarget:self action:@selector(save:) forControlEvents:UIControlEventTouchUpInside];
    [self.FMSwitchBtn setBackgroundImage:[UIImage imageNamed:@"dvd_btn_switch_on"] forState:UIControlStateSelected];
    [self.FMSwitchBtn setBackgroundImage:[UIImage imageNamed:@"dvd_btn_switch_off"] forState:UIControlStateNormal];
}
- (IBAction)save:(id)sender {
    
        Radio *device=[[Radio alloc] init];
        [device setDeviceID:[self.deviceid intValue]];
        [device setRvolume:device.rvolume];
        [device setChannel:device.channel];
    
    if (sender == self.FMSwitchBtn) {
         NSData *data=nil;
        self.FMSwitchBtn.selected = !self.FMSwitchBtn.selected;
        if (self.FMSwitchBtn.selected) {
            [self.FMSwitchBtn setBackgroundImage:[UIImage imageNamed:@"dvd_btn_switch_on"] forState:UIControlStateSelected];
            data = [[DeviceInfo defaultManager] open:self.deviceid];
            SocketManager *sock=[SocketManager defaultManager];
            [sock.socket writeData:data withTimeout:1 tag:1];
        }else{
            
            [self.FMSwitchBtn setBackgroundImage:[UIImage imageNamed:@"dvd_btn_switch_off"] forState:UIControlStateNormal];
             data = [[DeviceInfo defaultManager] close:self.deviceid];
            SocketManager *sock=[SocketManager defaultManager];
            [sock.socket writeData:data withTimeout:1 tag:1];
        }
        
        if (_delegate && [_delegate respondsToSelector:@selector(onFMSwitchBtnClicked:)]) {
            [_delegate onFMSwitchBtnClicked:sender];
        }
    
    }else if (sender == self.AddFmBtn) {
        self.AddFmBtn.selected = !self.AddFmBtn.selected;
        if (self.AddFmBtn.selected) {
            if (ON_IPAD) {
                [self.AddFmBtn setImage:[UIImage imageNamed:@"ipad-icon_reduce_nol"] forState:UIControlStateNormal];
            }else{
                [self.AddFmBtn setImage:[UIImage imageNamed:@"icon_reduce_normal"] forState:UIControlStateNormal];
            }
            
            [_scene setSceneID:[self.sceneid intValue]];
            [_scene setRoomID:self.roomID];
            [_scene setMasterID:[[DeviceInfo defaultManager] masterID]];
            
            [_scene setReadonly:NO];
            
            NSArray *devices=[[SceneManager defaultManager] addDevice2Scene:_scene withDeivce:device withId:device.deviceID];
            [_scene setDevices:devices];
            
            [[SceneManager defaultManager] addScene:_scene withName:nil withImage:[UIImage imageNamed:@""] withiSactive:0];
            
        }else{
            if (ON_IPAD) {
                 [self.AddFmBtn setImage:[UIImage imageNamed:@"ipad-icon_add_nol"] forState:UIControlStateNormal];
            }else{
                 [self.AddFmBtn setImage:[UIImage imageNamed:@"icon_add_normal"] forState:UIControlStateNormal];
            }
           
            [_scene setSceneID:[self.sceneid intValue]];
            [_scene setRoomID:self.roomID];
            [_scene setMasterID:[[DeviceInfo defaultManager] masterID]];
            
            [_scene setReadonly:NO];

            NSMutableArray *devices = [NSMutableArray arrayWithObject:[NSString stringWithFormat:@"@%d",device.deviceID]];
             [devices removeObject:[NSString stringWithFormat:@"@%d",device.deviceID]];
            [_scene setDevices:devices];
            [[SceneManager defaultManager] addScene:_scene withName:nil withImage:[UIImage imageNamed:@""] withiSactive:0];
        }
        
    }else if (sender == self.FMSlider){
        //音量
        NSData *data=[[DeviceInfo defaultManager] changeVolume:self.FMSlider.value*100 deviceID:self.deviceid];
        SocketManager *sock=[SocketManager defaultManager];
        [sock.socket writeData:data withTimeout:1 tag:1];
        
        if (_delegate && [_delegate respondsToSelector:@selector(onFMSliderValueChanged:)]) {
            [_delegate onFMSliderValueChanged:sender];
        }
        
    }else if (sender == self.FMChannelSlider){
        //频道
        self.FMChannelLabel.text = [NSString stringWithFormat:@"%.1fFM",80+self.FMChannelSlider.value*40];
        float frequence = 80+self.FMChannelSlider.value*40;// frequence取整后，作为高字节
        int dec = (int)((frequence - (int)frequence)*10);// 小数部分 作为低字节
        NSData *data=[[DeviceInfo defaultManager] switchFMProgram:(int)frequence dec:dec deviceID:self.deviceid];
        SocketManager *sock=[SocketManager defaultManager];
        [sock.socket writeData:data withTimeout:1 tag:1];
        
        if (_delegate && [_delegate respondsToSelector:@selector(onFMChannelSliderValueChanged:)]) {
            [_delegate onFMChannelSliderValueChanged:sender];
        }
    }
  
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
