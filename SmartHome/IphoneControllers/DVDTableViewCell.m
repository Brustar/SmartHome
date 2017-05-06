//
//  DVDTableViewCell.m
//  SmartHome
//
//  Created by zhaona on 2017/3/23.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "DVDTableViewCell.h"
#import "SQLManager.h"
#import "DVD.h"
#import "SocketManager.h"
#import "SceneManager.h"

@implementation DVDTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
  
    [self.DVDSlider setThumbImage:[UIImage imageNamed:@"lv_btn_adjust_normal"] forState:UIControlStateNormal];
    self.DVDSlider.maximumTrackTintColor = [UIColor colorWithRed:16/255.0 green:17/255.0 blue:21/255.0 alpha:1];
    self.DVDSlider.minimumTrackTintColor = [UIColor colorWithRed:253/255.0 green:254/255.0 blue:254/255.0 alpha:1];
    [self.AddDvdBtn addTarget:self action:@selector(save:) forControlEvents:UIControlEventTouchUpInside];
    [self.DVDSwitchBtn addTarget:self action:@selector(save:) forControlEvents:UIControlEventTouchUpInside];
    [self.DVDSlider addTarget:self action:@selector(save:) forControlEvents:UIControlEventValueChanged];
}
- (IBAction)save:(id)sender {
    if (sender == self.DVDSwitchBtn) {
        self.DVDSwitchBtn.selected = !self.DVDSwitchBtn.selected;
        if (self.DVDSwitchBtn.selected) {
            [self.DVDSwitchBtn setBackgroundImage:[UIImage imageNamed:@"dvd_btn_switch_off"] forState:UIControlStateNormal];
        }else{
            
            [self.DVDSwitchBtn setBackgroundImage:[UIImage imageNamed:@"dvd_btn_switch_on"] forState:UIControlStateSelected];
        }
    }else if (sender == self.AddDvdBtn){
        self.AddDvdBtn.selected = !self.AddDvdBtn.selected;
        if (self.AddDvdBtn.selected) {
            [self.AddDvdBtn setImage:[UIImage imageNamed:@"icon_reduce_normal"] forState:UIControlStateNormal];
        }else{
            [self.AddDvdBtn setImage:[UIImage imageNamed:@"icon_add_normal"] forState:UIControlStateNormal];
        }
    }else if (sender == self.DVDSlider){
        
    }
    
    DVD *device=[[DVD alloc] init];
    [device setDeviceID:[self.deviceid intValue]];
    [device setPoweron:device.poweron];
    
    [_scene setSceneID:[self.sceneid intValue]];
    [_scene setRoomID:self.roomID];
    [_scene setMasterID:[[DeviceInfo defaultManager] masterID]];
    
    [_scene setReadonly:NO];
    
    NSArray *devices=[[SceneManager defaultManager] addDevice2Scene:_scene withDeivce:device withId:device.deviceID];
    [_scene setDevices:devices];
    [[SceneManager defaultManager] addScene:_scene withName:nil withImage:[UIImage imageNamed:@""]];
}
//上一曲
- (IBAction)Previous:(id)sender {
    
}
//下一曲
- (IBAction)nextBtn:(id)sender {
    
}
//暂停
- (IBAction)stopBtn:(id)sender {
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
