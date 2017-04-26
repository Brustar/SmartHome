//
//  NewColourCell.m
//  SmartHome
//
//  Created by zhaona on 2017/4/19.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "NewColourCell.h"
#import "SQLManager.h"
#import "Light.h"
#import "SocketManager.h"
#import "SceneManager.h"

@implementation NewColourCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self.AddColourLightBtn addTarget:self action:@selector(save:) forControlEvents:UIControlEventTouchUpInside];
    [self.colourBtn addTarget:self action:@selector(save:) forControlEvents:UIControlEventTouchUpInside];
    [self.colourSlider addTarget:self action:@selector(save:) forControlEvents:UIControlEventValueChanged];
}

- (IBAction)save:(id)sender {
    if (sender == self.colourBtn) {
        self.colourBtn.selected = !self.colourBtn.selected;
        if (self.colourBtn.selected) {
            [self.colourBtn setBackgroundImage:[UIImage imageNamed:@"dvd_btn_switch_off"] forState:UIControlStateNormal];
        }else{
            
            [self.colourBtn setBackgroundImage:[UIImage imageNamed:@"dvd_btn_switch_on"] forState:UIControlStateSelected];
        }
    }else if (sender == self.AddColourLightBtn){
        self.AddColourLightBtn.selected = !self.AddColourLightBtn.selected;
        if (self.AddColourLightBtn.selected) {
            [self.AddColourLightBtn setImage:[UIImage imageNamed:@"icon_reduce_normal"] forState:UIControlStateNormal];
        }else{
            [self.AddColourLightBtn setImage:[UIImage imageNamed:@"icon_add_normal"] forState:UIControlStateNormal];
        }
    }else if (sender == self.colourSlider){
        //调光灯
    }
    
    Light *device=[[Light alloc] init];
    [device setDeviceID:[self.deviceid intValue]];
    [device setIsPoweron:device.isPoweron];
    
    [_scene setSceneID:[self.sceneid intValue]];
    [_scene setRoomID:self.roomID];
    [_scene setMasterID:[[DeviceInfo defaultManager] masterID]];
    
    [_scene setReadonly:NO];
    
    NSArray *devices=[[SceneManager defaultManager] addDevice2Scene:_scene withDeivce:device withId:device.deviceID];
    [_scene setDevices:devices];
    [[SceneManager defaultManager] addScene:_scene withName:nil withImage:[UIImage imageNamed:@""]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
