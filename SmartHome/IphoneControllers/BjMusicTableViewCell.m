//
//  BjMusicTableViewCell.m
//  SmartHome
//
//  Created by zhaona on 2017/4/12.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "BjMusicTableViewCell.h"
#import "SQLManager.h"
#import "SocketManager.h"
#import "SceneManager.h"
#import "BgMusic.h"
#import "AudioManager.h"


#define BLUETOOTH_MUSIC false

@implementation BjMusicTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    [self.BjSlider setThumbImage:[UIImage imageNamed:@"lv_btn_adjust_normal"] forState:UIControlStateNormal];
    self.BjSlider.maximumTrackTintColor = [UIColor colorWithRed:16/255.0 green:17/255.0 blue:21/255.0 alpha:1];
    self.BjSlider.minimumTrackTintColor = [UIColor colorWithRed:253/255.0 green:254/255.0 blue:254/255.0 alpha:1];
    [self.AddBjmusicBtn addTarget:self action:@selector(save:) forControlEvents:UIControlEventTouchUpInside];
    [self.BjPowerButton addTarget:self action:@selector(save:) forControlEvents:UIControlEventTouchUpInside];
    [self.BjSlider addTarget:self action:@selector(save:) forControlEvents:UIControlEventValueChanged];
    self.BjSlider.continuous = NO;
    
}

- (IBAction)save:(id)sender {
    
        BgMusic *device=[[BgMusic alloc] init];
        [device setDeviceID:[self.deviceid intValue]];
        [device setBgvolume:device.bgvolume];
    
    if (sender == self.BjPowerButton) {
        self.BjPowerButton.selected = !self.BjPowerButton.selected;
        if (self.BjPowerButton.selected) {
            [self.BjPowerButton setImage:[UIImage imageNamed:@"music-red"] forState:UIControlStateSelected];
            //发送停止指令
            NSData *data=[[DeviceInfo defaultManager] pause:self.deviceid];
            SocketManager *sock=[SocketManager defaultManager];
            [sock.socket writeData:data withTimeout:1 tag:1];
            if (BLUETOOTH_MUSIC) {
                AudioManager *audio= [AudioManager defaultManager];
                [[audio musicPlayer] pause];
            }
            
        }else{
            
            [self.BjPowerButton setImage:[UIImage imageNamed:@"music_white"] forState:UIControlStateNormal];
            //发送播放指令
            NSData *data=[[DeviceInfo defaultManager] play:self.deviceid];
            SocketManager *sock=[SocketManager defaultManager];
            [sock.socket writeData:data withTimeout:1 tag:1];
            
            if (BLUETOOTH_MUSIC) {
                AudioManager *audio= [AudioManager defaultManager];
                [[audio musicPlayer] play];
            }
        
        }
        
        if (_delegate && [_delegate respondsToSelector:@selector(onBjPowerButtonClicked:)]) {
            [_delegate onBjPowerButtonClicked:sender];
        }
        
    }else if (sender == self.AddBjmusicBtn){
        self.AddBjmusicBtn.selected = !self.AddBjmusicBtn.selected;
        if (self.AddBjmusicBtn.selected) {
            [self.AddBjmusicBtn setImage:[UIImage imageNamed:@"icon_add_normal"] forState:UIControlStateNormal];
            [_scene setSceneID:[self.sceneid intValue]];
            [_scene setRoomID:self.roomID];
            [_scene setMasterID:[[DeviceInfo defaultManager] masterID]];
            [_scene setReadonly:NO];
            
            NSArray *devices=[[SceneManager defaultManager] addDevice2Scene:_scene withDeivce:device withId:device.deviceID];
            [_scene setDevices:devices];
            
            [[SceneManager defaultManager] addScene:_scene withName:nil withImage:[UIImage imageNamed:@""]];
            
        }else{
            [self.AddBjmusicBtn setImage:[UIImage imageNamed:@"icon_reduce_normal"] forState:UIControlStateNormal];
        }
      
    }else if (sender == self.BjSlider){
        NSData *data=[[DeviceInfo defaultManager] changeVolume:self.BjSlider.value deviceID:self.deviceid];
        SocketManager *sock=[SocketManager defaultManager];
        [sock.socket writeData:data withTimeout:1 tag:1];
//        self.voiceValue.text = [NSString stringWithFormat:@"%d%%",(int)self.BjSlider.value];
        if (BLUETOOTH_MUSIC) {
            AudioManager *audio=[AudioManager defaultManager];
            [audio.musicPlayer setVolume:self.BjSlider.value/100.0];
        }
        
        
        if (_delegate && [_delegate respondsToSelector:@selector(onBjSliderValueChanged:)]) {
            [_delegate onBjSliderValueChanged:sender];
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
