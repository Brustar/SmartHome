//
//  PowerLightCell.m
//  SmartHome
//
//  Created by zhaona on 2017/6/14.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "PowerLightCell.h"
#import "SQLManager.h"
#import "Light.h"
#import "SocketManager.h"
#import "SceneManager.h"
#import "PackManager.h"

@implementation PowerLightCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    [self.addPowerLightBtn addTarget:self action:@selector(save:) forControlEvents:UIControlEventTouchUpInside];
    [self.powerLightBtn addTarget:self action:@selector(save:) forControlEvents:UIControlEventTouchUpInside];
   
    
    [self.powerLightBtn setImage:[UIImage imageNamed:@"lv_icon_light_on"] forState:UIControlStateSelected];
    [self.powerLightBtn setImage:[UIImage imageNamed:@"lv_icon_light_off"] forState:UIControlStateNormal];
    if (ON_IPAD) {
        
        self.powerLightNameLabel.font = [UIFont systemFontOfSize:17];
        [self.addPowerLightBtn setImage:[UIImage imageNamed:@"ipad-icon_add_nol"] forState:UIControlStateNormal];
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
    [device setIsPoweron:device.isPoweron];
    [device setColor:@[]];
    
    if (sender == self.powerLightBtn) {
        self.powerLightBtn.selected = !self.powerLightBtn.selected;
        if (self.powerLightBtn.selected) {
            [self.powerLightBtn setImage:[UIImage imageNamed:@"lv_icon_light_on"] forState:UIControlStateSelected];
        }else{
            
            [self.powerLightBtn setImage:[UIImage imageNamed:@"lv_icon_light_off"] forState:UIControlStateNormal];
        }
        NSData *data=[[DeviceInfo defaultManager] toogleLight:self.powerLightBtn.selected deviceID:self.deviceid];
        SocketManager *sock=[SocketManager defaultManager];
        [sock.socket writeData:data withTimeout:1 tag:1];
        
       
        
    }else if (sender == self.addPowerLightBtn){
        self.addPowerLightBtn.selected = !self.addPowerLightBtn.selected;
        if (self.addPowerLightBtn.selected) {
            
            if (ON_IPAD) {
                [self.addPowerLightBtn setImage:[UIImage imageNamed:@"ipad-icon_reduce_nol"] forState:UIControlStateNormal];
            }else{
                [self.addPowerLightBtn setImage:[UIImage imageNamed:@"icon_reduce_normal"] forState:UIControlStateNormal];
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
                [self.addPowerLightBtn setImage:[UIImage imageNamed:@"ipad-icon_add_nol"] forState:UIControlStateNormal];
            }else{
                [self.addPowerLightBtn setImage:[UIImage imageNamed:@"icon_add_normal"] forState:UIControlStateNormal];
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
                self.powerLightBtn.selected = proto.action.state;
            }
            //            else if(proto.action.state == 0x1A){
            //                int brightness_f = proto.action.RValue;
            //                float degree = M_PI*brightness_f/100;
            //                self.tranformView.transform = CGAffineTransformMakeRotation(degree);
            //            }else if(proto.action.state == 0x1B){
            //                self.base.backgroundColor=[UIColor colorWithRed:proto.action.RValue/255.0 green:proto.action.G/255.0  blue:proto.action.B/255.0  alpha:1];
            //            }
            
        }
    }
    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
