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

@implementation NewLightCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
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
            [self.AddLightBtn setImage:[UIImage imageNamed:@"icon_reduce_normal"] forState:UIControlStateNormal];
            [_scene setSceneID:[self.sceneid intValue]];
            [_scene setRoomID:self.roomID];
            [_scene setMasterID:[[DeviceInfo defaultManager] masterID]];
            
            [_scene setReadonly:NO];
            
            NSArray *devices=[[SceneManager defaultManager] addDevice2Scene:_scene withDeivce:device withId:device.deviceID];
            [_scene setDevices:devices];
            [[SceneManager defaultManager] addScene:_scene withName:nil withImage:[UIImage imageNamed:@""]];
            
         }else{
            [self.AddLightBtn setImage:[UIImage imageNamed:@"icon_add_normal"] forState:UIControlStateNormal];
             
             [_scene setSceneID:[self.sceneid intValue]];
             [_scene setRoomID:self.roomID];
             [_scene setMasterID:[[DeviceInfo defaultManager] masterID]];
             
             [_scene setReadonly:NO];

             //删除当前场景的当前硬件
             NSMutableArray *devices = [NSMutableArray arrayWithObject:[NSString stringWithFormat:@"@%d",device.deviceID]];
             [devices removeObject:[NSString stringWithFormat:@"@%d",device.deviceID]];
             
             [_scene setDevices:devices];
             [[SceneManager defaultManager] addScene:_scene withName:nil withImage:[UIImage imageNamed:@""]];
          
         }
       
        
     }

}

@end
