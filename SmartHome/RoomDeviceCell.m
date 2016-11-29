//
//  RoomDeviceCell.m
//  SmartHome
//
//  Created by 逸云科技 on 2016/11/28.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "RoomDeviceCell.h"
#import "SocketManager.h"

@implementation RoomDeviceCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.deviceSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.deviceSwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)sliderValueChanged:(UISlider *)slider {
    NSString *deviceid = self.deviceid;
    NSData *data=[[DeviceInfo defaultManager] changeBright:slider.value*100 deviceID:deviceid];
    SocketManager *sock=[SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
    
    float value =  slider.value;
    if(0 == value){
        //关闭switch
        self.deviceSwitch.on = NO;
    }else if(value > 0 ){
        //打开switch
        self.deviceSwitch.on = YES;
    }
}

- (void)switchValueChanged:(UISwitch *)aSswitch {
    NSString *deviceid = self.deviceid;
    
    BOOL isOn  = [aSswitch isOn];
    
    if(isOn){
        
        self.deviceSlider.value = 1;
        
    }else{
        
        self.deviceSlider.value = 0;
        
    }
    
    NSData * data = [[DeviceInfo defaultManager] toogleLight:aSswitch.on deviceID:deviceid];
    SocketManager *sock=[SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
