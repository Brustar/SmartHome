//
//  ScreenCurtainCell.m
//  SmartHome
//
//  Created by zhaona on 2017/4/11.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "ScreenCurtainCell.h"
#import "SQLManager.h"
#import "Light.h"
#import "Amplifier.h"
#import "SocketManager.h"
#import "SceneManager.h"

@implementation ScreenCurtainCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self.AddScreenCurtainBtn addTarget:self action:@selector(save:) forControlEvents:UIControlEventTouchUpInside];
    [self.ScreenCurtainBtn addTarget:self action:@selector(save:) forControlEvents:UIControlEventTouchUpInside];
  
   
}
- (IBAction)save:(id)sender {
    if (sender == self.ScreenCurtainBtn) {
        self.ScreenCurtainBtn.selected = !self.ScreenCurtainBtn.selected;
        if (self.ScreenCurtainBtn.selected) {
            [self.ScreenCurtainBtn setBackgroundImage:[UIImage imageNamed:@"dvd_btn_switch_off"] forState:UIControlStateNormal];
        }else{
            
            [self.ScreenCurtainBtn setBackgroundImage:[UIImage imageNamed:@"dvd_btn_switch_on"] forState:UIControlStateSelected];
        }
    }else if (sender == self.AddScreenCurtainBtn){
        self.AddScreenCurtainBtn.selected = !self.AddScreenCurtainBtn.selected;
        if (self.AddScreenCurtainBtn.selected) {
            [self.AddScreenCurtainBtn setImage:[UIImage imageNamed:@"icon_reduce_normal"] forState:UIControlStateNormal];
        }else{
            [self.AddScreenCurtainBtn setImage:[UIImage imageNamed:@"icon_add_normal"] forState:UIControlStateNormal];
        }
    }
    
    Amplifier *device=[[Amplifier alloc] init];
    [device setDeviceID:[self.deviceid intValue]];
    [device setWaiting: device.waiting];
    
    
    [_scene setSceneID:[self.sceneid intValue]];
    [_scene setRoomID:self.roomID];
    [_scene setMasterID:[[DeviceInfo defaultManager] masterID]];
    
    [_scene setReadonly:NO];
    
    NSArray *devices=[[SceneManager defaultManager] addDevice2Scene:_scene withDeivce:device withId:device.deviceID];
    [_scene setDevices:devices];
    
    [[SceneManager defaultManager] addScene:_scene withName:nil withImage:[UIImage imageNamed:@""]];
}

- (IBAction)AddScreenCurtainBtn:(id)sender {
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
