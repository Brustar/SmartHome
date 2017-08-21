//
//  TVTableViewCell.m
//  SmartHome
//
//  Created by zhaona on 2017/3/23.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "TVTableViewCell.h"
#import "SQLManager.h"
#import "TV.h"
#import "SocketManager.h"
#import "SceneManager.h"
#import "PackManager.h"


@implementation TVTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
   
//   [IOManager removeTempFile];
    [self.TVSlider setThumbImage:[UIImage imageNamed:@"lv_btn_adjust_normal"] forState:UIControlStateNormal];
    self.TVSlider.maximumTrackTintColor = [UIColor colorWithRed:16/255.0 green:17/255.0 blue:21/255.0 alpha:1];
    self.TVSlider.minimumTrackTintColor = [UIColor colorWithRed:253/255.0 green:254/255.0 blue:254/255.0 alpha:1];
    [self.TVSwitchBtn addTarget:self action:@selector(save:) forControlEvents:UIControlEventTouchUpInside];
    [self.AddTvDeviceBtn addTarget:self action:@selector(save:) forControlEvents:UIControlEventTouchUpInside];
    [self.TVSlider addTarget:self action:@selector(save:) forControlEvents:UIControlEventValueChanged];
    self.TVSlider.continuous = NO;
    [self.TVSwitchBtn setBackgroundImage:[UIImage imageNamed:@"TV_on"] forState:UIControlStateHighlighted];
    [self.TVSwitchBtn setBackgroundImage:[UIImage imageNamed:@"TV_off"] forState:UIControlStateNormal];
}
-(void)initWithFrame
{
    if ([SQLManager isIR:[self.deviceid intValue]]) {
        self.IRContainerView.hidden = NO;
      
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
       TV *device=[[TV alloc] init];
    if (sender == self.TVSwitchBtn) {
        [self.AddTvDeviceBtn setImage:[UIImage imageNamed:@"icon_reduce_normal"] forState:UIControlStateNormal];
        self.AddTvDeviceBtn.selected = YES;
        self.TVSwitchBtn.selected = !self.TVSwitchBtn.selected;
        if (self.TVSwitchBtn.selected) {
            
            NSData *data=nil;
            DeviceInfo *device=[DeviceInfo defaultManager];
            data=[device toogle:self.TVSwitchBtn.selected deviceID:self.deviceid];
            SocketManager *sock=[SocketManager defaultManager];
            [sock.socket writeData:data withTimeout:1 tag:1];
        }else{
            
            
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
            
        }else{
            
            [self.AddTvDeviceBtn setImage:[UIImage imageNamed:@"icon_add_normal"] forState:UIControlStateNormal];
            //删除当前场景的当前硬件
            NSArray *devices = [[SceneManager defaultManager] subDeviceFromScene:_scene withDeivce:device.deviceID];
            [_scene setDevices:devices];
        }
  
    }else if (sender == self.TVSlider){
          [self.AddTvDeviceBtn setImage:[UIImage imageNamed:@"icon_add_normal"] forState:UIControlStateNormal];
        self.AddTvDeviceBtn.selected = YES;
        NSData *data=[[DeviceInfo defaultManager] changeVolume:self.TVSlider.value*100 deviceID:self.deviceid];
//        self.voiceValue.text = [NSString stringWithFormat:@"%d%%",(int)self.volume.value];
        SocketManager *sock=[SocketManager defaultManager];
        [sock.socket writeData:data withTimeout:1 tag:1];
        
        if (_delegate && [_delegate respondsToSelector:@selector(onTVSliderValueChanged:)]) {
            [_delegate onTVSliderValueChanged:sender];
        }
    }
    
    [device setDeviceID:[self.deviceid intValue]];
    [device setPoweron:self.TVSwitchBtn.selected];
    [device setVolume:self.TVSlider.value*100];
    [_scene setSceneID:[self.sceneid intValue]];
    [_scene setRoomID:self.roomID];
    [_scene setMasterID:[[DeviceInfo defaultManager] masterID]];
    [_scene setReadonly:NO];
    NSArray *devices=[[SceneManager defaultManager] addDevice2Scene:_scene withDeivce:device withId:device.deviceID];
    [_scene setDevices:devices];
    [[SceneManager defaultManager] addScene:_scene withName:nil withImage:[UIImage imageNamed:@""] withiSactive:0];

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
    
    /*if (proto.cmd==0x01) {
        NSString *devID=[SQLManager getDeviceIDByENumber:CFSwapInt16BigToHost(proto.deviceID)];
        if ([devID intValue]==[self.deviceid intValue]) {
            if (proto.action.state == PROTOCOL_VOLUME) {
                self.TVSlider.value=proto.action.RValue/100.0;
            }
            if (proto.action.state == PROTOCOL_OFF || proto.action.state == PROTOCOL_ON) {
                UIButton *btn = [self viewWithTag:8];
                btn.selected = proto.action.state;
            }
        }
    }*/
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
