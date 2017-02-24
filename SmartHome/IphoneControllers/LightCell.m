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
    [[SceneManager defaultManager] addScene:_scene withName:nil withImage:[UIImage imageNamed:@""]];
 
}
-(void)Iphoneswitch:(UISwitch *)switc
{
    NSString *deviceid = self.deviceid;
    
    BOOL isOn  = [switc isOn];
    
    if(isOn){
        //让slider的值大于0，小于1
        
        self.slider.value = 0.2;
        
    }else{
        //让slider的值为0
        
        self.slider.value = 0;
        
    }
    
    NSData * data = [[DeviceInfo defaultManager] toogleLight:switc.on deviceID:deviceid];
    SocketManager *sock=[SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
    [[SceneManager defaultManager] addScene:_scene withName:nil withImage:[UIImage imageNamed:@""]];
}


@end
