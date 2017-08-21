//
//  DVDTableViewCell.m
//  SmartHome
//
//  Created by zhaona on 2017/3/23.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "DVDTableViewCell.h"
#import "SQLManager.h"
#import "DVD.h"
#import "SocketManager.h"
#import "SceneManager.h"
#import "PackManager.h"

@implementation DVDTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
//      [IOManager removeTempFile];
   
     [self.PreviousBtn setImage:[UIImage imageNamed:@"DVD_previous_red"] forState:UIControlStateHighlighted];
     [self.nextBtn setImage:[UIImage imageNamed:@"DVD_next_red"] forState:UIControlStateHighlighted];
     [self.DVDSlider setThumbImage:[UIImage imageNamed:@"lv_btn_adjust_normal"] forState:UIControlStateNormal];
    self.DVDSlider.maximumTrackTintColor = [UIColor colorWithRed:16/255.0 green:17/255.0 blue:21/255.0 alpha:1];
    self.DVDSlider.minimumTrackTintColor = [UIColor colorWithRed:253/255.0 green:254/255.0 blue:254/255.0 alpha:1];
    [self.AddDvdBtn addTarget:self action:@selector(save:) forControlEvents:UIControlEventTouchUpInside];
    [self.DVDSwitchBtn addTarget:self action:@selector(save:) forControlEvents:UIControlEventTouchUpInside];
    [self.DVDSlider addTarget:self action:@selector(save:) forControlEvents:UIControlEventValueChanged];
    [self.DVDSwitchBtn setBackgroundImage:[UIImage imageNamed:@"TV_on"] forState:UIControlStateHighlighted];
    [self.DVDSwitchBtn setBackgroundImage:[UIImage imageNamed:@"TV_off"] forState:UIControlStateNormal];
     [self.stopBtn setImage:[UIImage imageNamed:@"DVD_toogle_red"] forState:UIControlStateHighlighted];
  
}

-(void)initWithFrame
{
    if ([SQLManager isIR:[self.deviceid intValue]]) {
        self.IRContainerView.hidden = NO;
        self.LYSimageview.hidden = YES;
        self.DVDsliderImageview.hidden = YES;
        self.YLImageView.hidden = YES;
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
        DVD *device=[[DVD alloc] init];
    
    if (sender == self.DVDSwitchBtn) {
        [self.AddDvdBtn setImage:[UIImage imageNamed:@"icon_reduce_normal"] forState:UIControlStateNormal];
        self.AddDvdBtn.selected = YES;
        NSData *data=nil;
        self.DVDSwitchBtn.selected = !self.DVDSwitchBtn.selected;
        if (self.DVDSwitchBtn.selected) {
            
            data=[[DeviceInfo defaultManager] ON:self.deviceid];
            SocketManager *sock=[SocketManager defaultManager];
            [sock.socket writeData:data withTimeout:1 tag:1];
            
        }else{
            
            data=[[DeviceInfo defaultManager] OFF:self.deviceid];
            SocketManager *sock=[SocketManager defaultManager];
            [sock.socket writeData:data withTimeout:1 tag:1];
        }
        
        if (_delegate && [_delegate respondsToSelector:@selector(onDVDSwitchBtnClicked:)]) {
            [_delegate onDVDSwitchBtnClicked:sender];
        }
        
    }else if (sender == self.AddDvdBtn){
        self.AddDvdBtn.selected = !self.AddDvdBtn.selected;
        if (self.AddDvdBtn.selected) {
            [self.AddDvdBtn setImage:[UIImage imageNamed:@"icon_reduce_normal"] forState:UIControlStateNormal];
            
        }else{
            
            [self.AddDvdBtn setImage:[UIImage imageNamed:@"icon_add_normal"] forState:UIControlStateNormal];
            //删除当前场景的当前硬件
            NSArray *devices = [[SceneManager defaultManager] subDeviceFromScene:_scene withDeivce:device.deviceID];
            [_scene setDevices:devices];
        }
        
    }else if (sender == self.DVDSlider){
          [self.AddDvdBtn setImage:[UIImage imageNamed:@"icon_reduce_normal"] forState:UIControlStateNormal];
        self.AddDvdBtn.selected = YES;
        NSData *data=[[DeviceInfo defaultManager] changeVolume:self.DVDSlider.value*100 deviceID:self.deviceid];
        SocketManager *sock=[SocketManager defaultManager];
        [sock.socket writeData:data withTimeout:1 tag:1];
        
        if (_delegate && [_delegate respondsToSelector:@selector(onDVDSliderValueChanged:)]) {
            [_delegate onDVDSliderValueChanged:sender];
        }
    }
    
    [device setDeviceID:[self.deviceid intValue]];
    [device setPoweron:self.DVDSwitchBtn.selected];
    [device setDvolume:self.DVDSlider.value * 100];
    [_scene setSceneID:[self.sceneid intValue]];
    [_scene setRoomID:self.roomID];
    [_scene setMasterID:[[DeviceInfo defaultManager] masterID]];
    [_scene setReadonly:NO];
    NSArray *devices=[[SceneManager defaultManager] addDevice2Scene:_scene withDeivce:device withId:device.deviceID];
    [_scene setDevices:devices];
    [[SceneManager defaultManager] addScene:_scene withName:nil withImage:[UIImage imageNamed:@""] withiSactive:0];
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
//        [self.stopBtn setImage:[UIImage imageNamed:@"DVD_pause"] forState:UIControlStateNormal];
        data=[[DeviceInfo defaultManager] pause:self.deviceid];
        SocketManager *sock=[SocketManager defaultManager];
        [sock.socket writeData:data withTimeout:1 tag:1];
    }else{
//        [self.stopBtn setImage:[UIImage imageNamed:@"DVD_play"] forState:UIControlStateNormal];
        data=[[DeviceInfo defaultManager] play:self.deviceid];
        SocketManager *sock=[SocketManager defaultManager];
        [sock.socket writeData:data withTimeout:1 tag:1];
    }
  
}
//音量减
- (IBAction)voice_downBtn:(id)sender {
    NSData *data=nil;
    DeviceInfo *device=[DeviceInfo defaultManager];
    data=[device volumeDown:self.deviceid];
    SocketManager *sock=[SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
}

//音量加
- (IBAction)voice_upBtn:(id)sender {
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
                self.DVDSlider.value=proto.action.RValue/100.0;
            }
        }
    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
