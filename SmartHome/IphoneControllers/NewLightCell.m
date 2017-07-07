//
//  NewLightCell.m
//  SmartHome
//
//  Created by zhaona on 2017/4/20.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "NewLightCell.h"
#import "SQLManager.h"
#import "Light.h"
#import "SocketManager.h"
#import "SceneManager.h"
#import "PackManager.h" 

@implementation NewLightCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
     [IOManager removeTempFile];
    _scene=[[SceneManager defaultManager] readSceneByID:[self.sceneid intValue]];
    [self.NewLightSlider setThumbImage:[UIImage imageNamed:@"lv_btn_adjust_normal"] forState:UIControlStateNormal];
//    self.NewLightSlider.layer.borderWidth = 10;
    self.NewLightSlider.maximumTrackTintColor = [UIColor colorWithRed:16/255.0 green:17/255.0 blue:21/255.0 alpha:1];
    self.NewLightSlider.minimumTrackTintColor = [UIColor colorWithRed:253/255.0 green:254/255.0 blue:254/255.0 alpha:1];
    [self.NewLightPowerBtn addTarget:self action:@selector(save:) forControlEvents:UIControlEventTouchUpInside];
    [self.AddLightBtn addTarget:self action:@selector(save:) forControlEvents:UIControlEventTouchUpInside];
    [self.NewLightSlider addTarget:self action:@selector(save:) forControlEvents:UIControlEventValueChanged];
    [self.NewLightPowerBtn setImage:[UIImage imageNamed:@"lv_icon_light_off"] forState:UIControlStateNormal];
    [self.NewLightPowerBtn setImage:[UIImage imageNamed:@"lv_icon_light_on"] forState:UIControlStateSelected];
    
    
    if (ON_IPAD) {
        self.supImageViewHeight.constant = 85;
        self.NewLightNameLabel.font = [UIFont systemFontOfSize:17];
         [self.AddLightBtn setImage:[UIImage imageNamed:@"ipad-icon_add_nol"] forState:UIControlStateNormal];
    }
    
}

-(void) query:(NSString *)deviceid delegate:(id)delegate
{
    self.deviceid = deviceid;
    SocketManager *sock=[SocketManager defaultManager];
    sock.delegate=delegate;
    //查询设备状态
    NSData *data = [[DeviceInfo defaultManager] query:deviceid];
    [sock.socket writeData:data withTimeout:1 tag:1];
}

- (IBAction)save:(id)sender {
    
    Light *device=[[Light alloc] init];
    [device setDeviceID:[self.deviceid intValue]];
    [device setIsPoweron:self.NewLightPowerBtn.selected];
    [device setBrightness:self.NewLightSlider.value * 100];
    [device setColor:@[]];
    
    if (sender == self.NewLightSlider){
        
        float value = self.NewLightSlider.value;
        if(0==value){
            //关闭switch
            self.NewLightPowerBtn.selected = NO;
        }else if(value > 0 ){
            //打开switch
            self.NewLightPowerBtn.selected = YES;
        }

        NSData *data=[[DeviceInfo defaultManager] changeBright:self.NewLightSlider.value*100 deviceID:self.deviceid];
        SocketManager *sock=[SocketManager defaultManager];
        [sock.socket writeData:data withTimeout:1 tag:1];
    }
    
     if (sender == self.NewLightPowerBtn) {
         
         BOOL isOn  = [self.NewLightPowerBtn isSelected];
         
         if(isOn){
             //让slider的值等于1
             
             self.NewLightSlider.value = 0;
             
         }else{
             //让slider的值为0
             
             self.NewLightSlider.value = 1;
             
         }
        self.NewLightPowerBtn.selected = !self.NewLightPowerBtn.selected;
        if (self.NewLightPowerBtn.selected) {
            [self.NewLightPowerBtn setImage:[UIImage imageNamed:@"lv_icon_light_on"] forState:UIControlStateSelected];
        }else{
            [self.NewLightPowerBtn setImage:[UIImage imageNamed:@"lv_icon_light_off"] forState:UIControlStateNormal];
           
       }
         
         NSData *data=[[DeviceInfo defaultManager] toogleLight:self.NewLightPowerBtn.selected deviceID:self.deviceid];
         SocketManager *sock=[SocketManager defaultManager];
         [sock.socket writeData:data withTimeout:1 tag:1];
         
         if (_delegate && [_delegate respondsToSelector:@selector(onLightPowerBtnClicked:)]) {
             [_delegate onLightPowerBtnClicked:self.NewLightPowerBtn];
         }
         
    }

    if (sender == self.AddLightBtn){
        
           self.AddLightBtn.selected = !self.AddLightBtn.selected;
       
        if (self.AddLightBtn.selected) {
            if (ON_IPAD) {
                 [self.AddLightBtn setImage:[UIImage imageNamed:@"ipad-icon_reduce_nol"] forState:UIControlStateNormal];
            }else{
                 [self.AddLightBtn setImage:[UIImage imageNamed:@"icon_reduce_normal"] forState:UIControlStateNormal];
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
                  [self.AddLightBtn setImage:[UIImage imageNamed:@"ipad-icon_add_nol"] forState:UIControlStateNormal];
             }else{
                  [self.AddLightBtn setImage:[UIImage imageNamed:@"icon_add_normal"] forState:UIControlStateNormal];
             }
           
             [_scene setSceneID:[self.sceneid intValue]];
             [_scene setRoomID:self.roomID];
             [_scene setMasterID:[[DeviceInfo defaultManager] masterID]];
             
             [_scene setReadonly:NO];

             //删除当前场景的当前硬件
             NSArray *devices = [[SceneManager defaultManager] subDeviceFromScene:_scene withDeivce:device.deviceID];
             [_scene setDevices:devices];
             [[SceneManager defaultManager] addScene:_scene withName:nil withImage:[UIImage imageNamed:@""] withiSactive:0];
          
         }
       
        
     }
    
    [_scene setSceneID:[self.sceneid intValue]];
    [_scene setRoomID:self.roomID];
    [_scene setMasterID:[[DeviceInfo defaultManager] masterID]];
    
    [_scene setReadonly:NO];
    
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
    //同步设备状态
    if(proto.cmd == 0x01){
        NSString *devID=[SQLManager getDeviceIDByENumber:CFSwapInt16BigToHost(proto.deviceID)];
        if ([devID intValue]==[self.deviceid intValue]) {
            if (proto.action.state == PROTOCOL_OFF || proto.action.state == PROTOCOL_ON) {
                self.NewLightPowerBtn.selected = proto.action.state;
            }else if(proto.action.state == 0x1A){
                float brightness_f = proto.action.RValue/100.0;
                self.NewLightSlider.value = brightness_f;
            }
        }
    }
    
}
@end
