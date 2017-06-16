
//
//  OtherTableViewCell.m
//  SmartHome
//
//  Created by zhaona on 2017/3/23.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "OtherTableViewCell.h"
#import "SQLManager.h"
#import "Light.h"
#import "SocketManager.h"
#import "SceneManager.h"
#import "Amplifier.h"

@implementation OtherTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self.OtherSwitchBtn addTarget:self action:@selector(save:) forControlEvents:UIControlEventTouchUpInside];
    [self.AddOtherBtn addTarget:self action:@selector(save:) forControlEvents:UIControlEventTouchUpInside];
    [self.OtherSwitchBtn setBackgroundImage:[UIImage imageNamed:@"dvd_btn_switch_on"] forState:UIControlStateSelected];
    [self.OtherSwitchBtn setBackgroundImage:[UIImage imageNamed:@"dvd_btn_switch_off"] forState:UIControlStateNormal];
      if (ON_IPAD) {
          
          self.NameLabel.font = [UIFont systemFontOfSize:17];
          [self.AddOtherBtn setImage:[UIImage imageNamed:@"ipad-icon_add_nol"] forState:UIControlStateNormal];
      }
}

- (IBAction)save:(id)sender {
    
        Amplifier *device=[[Amplifier alloc] init];
        [device setDeviceID:[self.deviceid intValue]];
        [device setWaiting: device.waiting];
    if (sender == self.OtherSwitchBtn) {
        self.OtherSwitchBtn.selected = !self.OtherSwitchBtn.selected;
        if (self.OtherSwitchBtn.selected) {
            [self.OtherSwitchBtn setBackgroundImage:[UIImage imageNamed:@"dvd_btn_switch_on"] forState:UIControlStateSelected];
        }else{
            [self.OtherSwitchBtn setBackgroundImage:[UIImage imageNamed:@"dvd_btn_switch_off"] forState:UIControlStateNormal];
        }
        NSData *data=[[DeviceInfo defaultManager] toogle:self.OtherSwitchBtn.selected deviceID:self.deviceid];
        SocketManager *sock=[SocketManager defaultManager];
        [sock.socket writeData:data withTimeout:1 tag:1];
        
        if (_delegate && [_delegate respondsToSelector:@selector(onOtherSwitchBtnClicked:)]) {
            [_delegate onOtherSwitchBtnClicked:sender];
        }
        
    }else if (sender == self.AddOtherBtn){
        self.AddOtherBtn.selected = !self.AddOtherBtn.selected;
        if (self.AddOtherBtn.selected) {
             if (ON_IPAD) {
                 
                  [self.AddOtherBtn setImage:[UIImage imageNamed:@"ipad-icon_reduce_nol"] forState:UIControlStateNormal];
             }else{
                
                 [self.AddOtherBtn setImage:[UIImage imageNamed:@"icon_reduce_normal"] forState:UIControlStateNormal];
                 
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
                 
                  [self.AddOtherBtn setImage:[UIImage imageNamed:@"ipad-icon_add_nol"] forState:UIControlStateNormal];
             }else{
                [self.AddOtherBtn setImage:[UIImage imageNamed:@"icon_add_normal"] forState:UIControlStateNormal];
             }
            
            [_scene setSceneID:[self.sceneid intValue]];
            [_scene setRoomID:self.roomID];
            [_scene setMasterID:[[DeviceInfo defaultManager] masterID]];
            
            [_scene setReadonly:NO];

             NSMutableArray *devices = [NSMutableArray arrayWithObject:[NSString stringWithFormat:@"@%d",device.deviceID]];
        
            [devices removeObject:[NSString stringWithFormat:@"@%d",device.deviceID]];
            [_scene setDevices:devices];
            [[SceneManager defaultManager] addScene:_scene withName:nil withImage:[UIImage imageNamed:@""] withiSactive:0];
           
        }
       
    }
  
}

- (IBAction)AddOtherBtn:(id)sender {
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
