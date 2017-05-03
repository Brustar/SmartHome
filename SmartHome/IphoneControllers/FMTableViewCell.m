//
//  FMTableViewCell.m
//  SmartHome
//
//  Created by zhaona on 2017/4/17.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "FMTableViewCell.h"
#import "SQLManager.h"
#import "Light.h"
#import "SocketManager.h"
#import "SceneManager.h"
#import "Radio.h"


@implementation FMTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self.AddFmBtn addTarget:self action:@selector(save:) forControlEvents:UIControlEventTouchUpInside];
    [self.FMSlider addTarget:self action:@selector(save:) forControlEvents:UIControlEventValueChanged];//音量
    [self.FMChannelSlider addTarget:self action:@selector(save:) forControlEvents:UIControlEventValueChanged];//频道
}
- (IBAction)save:(id)sender {
    if (sender == self.AddFmBtn) {
        self.AddFmBtn.selected = !self.AddFmBtn.selected;
        if (self.AddFmBtn.selected) {
            [self.AddFmBtn setImage:[UIImage imageNamed:@"icon_reduce_normal"] forState:UIControlStateNormal];
        }else{
            [self.AddFmBtn setImage:[UIImage imageNamed:@"icon_add_normal"] forState:UIControlStateNormal];
        }
    }else if (sender == self.FMSlider){
        //音量
        NSData *data=[[DeviceInfo defaultManager] changeVolume:self.FMSlider.value*100 deviceID:self.deviceid];
        SocketManager *sock=[SocketManager defaultManager];
        [sock.socket writeData:data withTimeout:1 tag:1];
        
//        self.voiceValue.text = [NSString stringWithFormat:@"%d%%",(int)self.FMSlider.value];
        
    }else if (sender == self.FMChannelSlider){
        //频道
        
    }
    
    Radio *device=[[Radio alloc] init];
    [device setDeviceID:6];
    [device setRvolume:device.rvolume];
    [device setChannel:device.channel];
    
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
