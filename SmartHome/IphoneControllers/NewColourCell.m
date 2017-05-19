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
    
    [self.colourSlider setThumbImage:[UIImage imageNamed:@"lv_btn_adjust_normal"] forState:UIControlStateNormal];
    self.colourSlider.maximumTrackTintColor = [UIColor colorWithRed:16/255.0 green:17/255.0 blue:21/255.0 alpha:1];
    self.colourSlider.minimumTrackTintColor = [UIColor colorWithRed:253/255.0 green:254/255.0 blue:254/255.0 alpha:1];
//    self.colourSlider.layer.borderWidth = 3;
    //设置结点左边背景
    UIImage *trackLeftImage = [[UIImage imageNamed:@"corSlider"]stretchableImageWithLeftCapWidth:14 topCapHeight:0];
    [self.colourSlider setMinimumTrackImage:trackLeftImage forState:UIControlStateNormal];
    //设置结点右边背景
    UIImage *trackRightImage = [[UIImage imageNamed:@"corSlider"]stretchableImageWithLeftCapWidth:14 topCapHeight:0];
    [self.colourSlider setMaximumTrackImage:trackRightImage forState:UIControlStateNormal];
    [self.AddColourLightBtn addTarget:self action:@selector(save:) forControlEvents:UIControlEventTouchUpInside];
    [self.colourBtn addTarget:self action:@selector(save:) forControlEvents:UIControlEventTouchUpInside];
    [self.colourSlider addTarget:self action:@selector(save:) forControlEvents:UIControlEventValueChanged];
    
    [self.colourBtn setImage:[UIImage imageNamed:@"lv_icon_light_on"] forState:UIControlStateSelected];
    [self.colourBtn setImage:[UIImage imageNamed:@"lv_icon_light_off"] forState:UIControlStateNormal];
}

- (IBAction)save:(id)sender {
    
        Light *device=[[Light alloc] init];
        [device setDeviceID:[self.deviceid intValue]];
        [device setIsPoweron:device.isPoweron];
        [device setColor:@[]];
    
    if (sender == self.colourBtn) {
        self.colourBtn.selected = !self.colourBtn.selected;
        if (self.colourBtn.selected) {
            [self.colourBtn setImage:[UIImage imageNamed:@"lv_icon_light_on"] forState:UIControlStateSelected];
        }else{
            
            [self.colourBtn setImage:[UIImage imageNamed:@"lv_icon_light_off"] forState:UIControlStateNormal];
        }
        NSData *data=[[DeviceInfo defaultManager] toogleLight:self.colourBtn.selected deviceID:self.deviceid];
        SocketManager *sock=[SocketManager defaultManager];
        [sock.socket writeData:data withTimeout:1 tag:1];
        
        if (_delegate && [_delegate respondsToSelector:@selector(onColourSwitchBtnClicked:)]) {
            [_delegate onColourSwitchBtnClicked:sender];
        }
        
    }else if (sender == self.AddColourLightBtn){
        self.AddColourLightBtn.selected = !self.AddColourLightBtn.selected;
        if (self.AddColourLightBtn.selected) {
            [self.AddColourLightBtn setImage:[UIImage imageNamed:@"icon_reduce_normal"] forState:UIControlStateNormal];
        }else{
            [self.AddColourLightBtn setImage:[UIImage imageNamed:@"icon_add_normal"] forState:UIControlStateNormal];
        }
        
        [_scene setSceneID:[self.sceneid intValue]];
        [_scene setRoomID:self.roomID];
        [_scene setMasterID:[[DeviceInfo defaultManager] masterID]];
        
        [_scene setReadonly:NO];
        
        NSArray *devices=[[SceneManager defaultManager] addDevice2Scene:_scene withDeivce:device withId:device.deviceID];
        [_scene setDevices:devices];
        [[SceneManager defaultManager] addScene:_scene withName:nil withImage:[UIImage imageNamed:@""]];
        
    }else if (sender == self.colourSlider){
        //调光灯
//        NSData *data=[[DeviceInfo defaultManager] changeBright:self.NewL.value*100 deviceID:self.deviceid];
//        NSData * data =[[DeviceInfo defaultManager] changeColor:<#(NSString *)#> R:<#(uint8_t)#> G:<#(uint8_t)#> B:<#(uint8_t)#>];
//        SocketManager *sock=[SocketManager defaultManager];
//        [sock.socket writeData:data withTimeout:1 tag:1];
    }
   
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
