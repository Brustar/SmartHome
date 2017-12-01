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
#import "PackManager.h"


#define BLUETOOTH_MUSIC false

@implementation BjMusicTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
   
//   [IOManager removeTempFile];
    [self.BjSlider setThumbImage:[UIImage imageNamed:@"lv_btn_adjust_normal"] forState:UIControlStateNormal];
    self.BjSlider.maximumTrackTintColor = [UIColor colorWithRed:16/255.0 green:17/255.0 blue:21/255.0 alpha:1];
    self.BjSlider.minimumTrackTintColor = [UIColor colorWithRed:253/255.0 green:254/255.0 blue:254/255.0 alpha:1];
    [self.AddBjmusicBtn addTarget:self action:@selector(save:) forControlEvents:UIControlEventTouchUpInside];
    [self.BjPowerButton addTarget:self action:@selector(save:) forControlEvents:UIControlEventTouchUpInside];
    [self.BjSlider addTarget:self action:@selector(save:) forControlEvents:UIControlEventValueChanged];
    self.BjSlider.continuous = NO;
    [self.BjPowerButton setImage:[UIImage imageNamed:@"music-red"] forState:UIControlStateSelected];
    [self.BjPowerButton setImage:[UIImage imageNamed:@"music_white"] forState:UIControlStateNormal];
    
    if (ON_IPAD) {
        self.BjmusicHeightConstraint.constant = 85;
        self.bdIconLeadingConstraint.constant = 33;
        self.IRContainerHeight.constant = 85;
        self.IRContainerSubViewHeight.constant = 85;
        self.bgIconTadilingConst.constant = 33;
        self.BjMusicNameLb.font = [UIFont systemFontOfSize:17];
           [self.AddBjmusicBtn setImage:[UIImage imageNamed:@"ipad-icon_add_nol"] forState:UIControlStateNormal];
    }
}
-(void)initWithFrame
{
    if ([SQLManager isIR:[self.deviceid intValue]]) {
        self.IRContainerView.hidden = NO;
        self.BjSlider.hidden = YES;
        self.bgmusicBackgView.hidden = YES;
        self.bgSliderView.hidden = YES;
        self.YLDimageview.hidden  = YES;
        self.YLXimageview.hidden = YES;
       
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
        BgMusic *device=[[BgMusic alloc] init];
    
    if (sender == self.BjPowerButton) {
        [[DeviceInfo defaultManager] playVibrate];
        if (ON_IPAD) {
            [self.AddBjmusicBtn setImage:[UIImage imageNamed:@"ipad-icon_reduce_nol"] forState:UIControlStateNormal];
        }else{
            [self.AddBjmusicBtn setImage:[UIImage imageNamed:@"icon_reduce_normal"] forState:UIControlStateNormal];
        }
        self.AddBjmusicBtn.selected = YES;
        self.BjPowerButton.selected = !self.BjPowerButton.selected;
        if (self.BjPowerButton.selected) {
            //[self.BjPowerButton setImage:[UIImage imageNamed:@"music-red"] forState:UIControlStateSelected];
            //发送播放指令
             NSData * data = [[DeviceInfo defaultManager] ON:self.deviceid];
            SocketManager *sock=[SocketManager defaultManager];
            [sock.socket writeData:data withTimeout:1 tag:1];
            if (BLUETOOTH_MUSIC) {
                AudioManager *audio= [AudioManager defaultManager];
                [[audio musicPlayer] pause];
            }
            
        }else{
            
            //[self.BjPowerButton setImage:[UIImage imageNamed:@"music_white"] forState:UIControlStateNormal];
            //发送停止指令
              NSData * data = [[DeviceInfo defaultManager] OFF:self.deviceid];
            SocketManager *sock=[SocketManager defaultManager];
            [sock.socket writeData:data withTimeout:1 tag:1];
            
            if (BLUETOOTH_MUSIC) {
                AudioManager *audio= [AudioManager defaultManager];
                [[audio musicPlayer] play];
            }
        
        }
        
        if (_delegate && [_delegate respondsToSelector:@selector(onBjPowerButtonClicked:deviceID:)]) {
            [_delegate onBjPowerButtonClicked:self.BjPowerButton deviceID:self.deviceid.intValue];
        }
        
    }else if (sender == self.AddBjmusicBtn){
        self.AddBjmusicBtn.selected = !self.AddBjmusicBtn.selected;
        if (self.AddBjmusicBtn.selected) {
            if (ON_IPAD) {
                [self.AddBjmusicBtn setImage:[UIImage imageNamed:@"ipad-icon_reduce_nol"] forState:UIControlStateNormal];
            }else{
                [self.AddBjmusicBtn setImage:[UIImage imageNamed:@"icon_reduce_normal"] forState:UIControlStateNormal];
            }
          
        }else{
            
            if (ON_IPAD) {
                 [self.AddBjmusicBtn setImage:[UIImage imageNamed:@"ipad-icon_add_nol"] forState:UIControlStateNormal];
            }else{
                 [self.AddBjmusicBtn setImage:[UIImage imageNamed:@"icon_add_normal"] forState:UIControlStateNormal];
            }
            //删除当前场景的当前硬件
            NSArray *devices = [[SceneManager defaultManager] subDeviceFromScene:_scene withDeivce:device.deviceID];
            [_scene setDevices:devices];
        }
      
    }else if (sender == self.BjSlider){
        if (ON_IPAD) {
            [self.AddBjmusicBtn setImage:[UIImage imageNamed:@"ipad-icon_reduce_nol"] forState:UIControlStateNormal];
        }else{
            [self.AddBjmusicBtn setImage:[UIImage imageNamed:@"icon_reduce_normal"] forState:UIControlStateNormal];
        }
        self.AddBjmusicBtn.selected = YES;
        NSData *data=[[DeviceInfo defaultManager] changeVolume:self.BjSlider.value*100 deviceID:self.deviceid];
        SocketManager *sock=[SocketManager defaultManager];
        [sock.socket writeData:data withTimeout:1 tag:1];
        
        if (_delegate && [_delegate respondsToSelector:@selector(onBjSliderValueChanged:)]) {
            [_delegate onBjSliderValueChanged:sender];
        }
    }
    
    [device setDeviceID:[self.deviceid intValue]];
    [device setBgvolume:self.BjSlider.value * 100.0f];
    [device setPoweron:self.BjPowerButton.selected];
    [_scene setSceneID:[self.sceneid intValue]];
    [_scene setRoomID:self.roomID];
    [_scene setMasterID:[[DeviceInfo defaultManager] masterID]];
    [_scene setReadonly:NO];
    NSArray *devices=[[SceneManager defaultManager] addDevice2Scene:_scene withDeivce:device withId:device.deviceID];
    [_scene setDevices:devices];
    [[SceneManager defaultManager] addScene:_scene withName:nil withImage:[UIImage imageNamed:@""] withiSactive:0];
    
}
//音量减
- (IBAction)voice_downBtn:(id)sender {
    [[DeviceInfo defaultManager] playVibrate];
    NSData *data=nil;
    DeviceInfo *device=[DeviceInfo defaultManager];
    data=[device volumeDown:self.deviceid];
    SocketManager *sock=[SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
}

//音量加
- (IBAction)voice_upBtn:(id)sender {
    [[DeviceInfo defaultManager] playVibrate];
    NSData *data=nil;
    DeviceInfo *device=[DeviceInfo defaultManager];
    data=[device volumeUp:self.deviceid];
    SocketManager *sock=[SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
}
#pragma mark - TCP recv delegate
-(void)recv:(NSData *)data withTag:(long)tag
{
    Proto proto=protocolFromData(data);
    
    if (CFSwapInt16BigToHost(proto.masterID) != [[DeviceInfo defaultManager] masterID]) {
        return;
    }
    
    if (proto.cmd==0x01) {
        NSString *devID=[SQLManager getDeviceIDByENumber:CFSwapInt16BigToHost(proto.deviceID)];
        if ([devID intValue]==[self.deviceid intValue]) {
            if (proto.action.state == PROTOCOL_VOLUME) {
                self.BjSlider.value=proto.action.RValue/100.0;
            }
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
