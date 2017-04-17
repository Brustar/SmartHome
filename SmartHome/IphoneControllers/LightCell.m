//
//  LightCell.m
//  SmartHome
//
//  Created by zhaona on 2016/11/21.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "LightCell.h"
#import "SocketManager.h"
#import "SceneManager.h"

@implementation LightCell

- (void)awakeFromNib {
    [super awakeFromNib];

     [self.slider setThumbImage:[UIImage imageNamed:@"lv_btn_adjust_normal"] forState:UIControlStateNormal];
    self.slider.maximumTrackTintColor = [UIColor colorWithRed:16/255.0 green:17/255.0 blue:21/255.0 alpha:1];
    self.slider.minimumTrackTintColor = [UIColor colorWithRed:253/255.0 green:254/255.0 blue:254/255.0 alpha:1];
    [self.slider addTarget:self action:@selector(dimming:) forControlEvents:UIControlEventValueChanged];
    [self.Iphoneswitch addTarget:self action:@selector(Iphoneswitch:) forControlEvents:UIControlEventValueChanged];
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void)dimming:(UISlider *)slider
{

    float value =  slider.value;
    if(0==value){
        //关闭switch
        self.Iphoneswitch.on = NO;
    }else if(value > 0 ){
        //打开switch
        self.Iphoneswitch.on = YES;
    }
    NSString *deviceid = self.deviceid;
    NSData *data=[[DeviceInfo defaultManager] changeBright:slider.value*100 deviceID:deviceid];
    SocketManager *sock=[SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
    Light *device=[[Light alloc] init];
    [device setDeviceID:[self.deviceid intValue]];
    [device setIsPoweron: self.Iphoneswitch.isOn];
    [_scene setSceneID:[self.sceneID intValue]];
    [_scene setRoomID:self.roomID];
    [_scene setMasterID:[[DeviceInfo defaultManager] masterID]];
    
    [_scene setReadonly:NO];
    
    NSArray *devices=[[SceneManager defaultManager] addDevice2Scene:_scene withDeivce:device withId:device.deviceID];
    [_scene setDevices:devices];
//    [[SceneManager defaultManager] addScene:_scene withName:nil withImage:[UIImage imageNamed:@""]];
    [[SceneManager defaultManager] addScene:_scene withName:nil withImage:[UIImage imageNamed:@""]];
 
}
-(void)Iphoneswitch:(UISwitch *)switc
{
    NSString *deviceid = self.deviceid;
    
    BOOL isOn  = [switc isOn];
    
    if(isOn){
        //让slider的值等于1
        
        self.slider.value = 1;
        
    }else{
        //让slider的值为0
        
        self.slider.value = 0;
        
    }
    
    NSData * data = [[DeviceInfo defaultManager] toogleLight:switc.on deviceID:deviceid];
    NSLog(@"light switch data:%@", data);
    SocketManager *sock=[SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
    [[SceneManager defaultManager] addScene:_scene withName:nil withImage:[UIImage imageNamed:@""]];
}


@end
