//
//  CurtainC4TableViewCell.m
//  SmartHome
//
//  Created by KobeBryant on 2017/9/29.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "CurtainC4TableViewCell.h"

@implementation CurtainC4TableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.switchBtn addTarget:self action:@selector(save:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.addBtn addTarget:self action:@selector(save:) forControlEvents:UIControlEventTouchUpInside];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)query:(NSString *)deviceid delegate:(id)delegate
{
    self.deviceid = deviceid;
    SocketManager *sock=[SocketManager defaultManager];
    sock.delegate= delegate;
    //查询设备状态
    NSData *data = [[DeviceInfo defaultManager] query:deviceid];
    [sock.socket writeData:data withTimeout:1 tag:1];
}

- (void)save:(id)sender
{
    _scene = [[SceneManager defaultManager] readSceneByID:[self.sceneid intValue]];
    Curtain *device = [[Curtain alloc] init];
    
    
    if ([sender isEqual:self.switchBtn]) {
        [[DeviceInfo defaultManager] playVibrate];
        if (ON_IPAD) {
            [self.addBtn setImage:[UIImage imageNamed:@"ipad-icon_reduce_nol"] forState:UIControlStateNormal];
        }else{
            [self.addBtn setImage:[UIImage imageNamed:@"icon_reduce_normal"] forState:UIControlStateNormal];
        }
        self.addBtn.selected = YES;
        self.switchBtn.selected = !self.switchBtn.selected;
        if (self.switchBtn.selected) {
            
            [self.switchBtn setImage:[UIImage imageNamed:@"bd_icon_wd_on"] forState:UIControlStateSelected];
        }else{
            
            [self.switchBtn setImage:[UIImage imageNamed:@"bd_icon_wd_off"] forState:UIControlStateNormal];
        }
        
        NSData *data = [[DeviceInfo defaultManager] toogle:self.switchBtn.selected deviceID:self.deviceid];
        
        SocketManager *sock = [SocketManager defaultManager];
        [sock.socket writeData:data withTimeout:1 tag:2];
        
        if (_delegate && [_delegate respondsToSelector:@selector(onCurtainSwitchBtnClicked:deviceID:)]) {
            [_delegate onCurtainSwitchBtnClicked:self.switchBtn deviceID:self.deviceid.intValue];
        }
    }
    
    
    if ([sender isEqual:self.addBtn]) {
        
        self.addBtn.selected = !self.addBtn.selected;
        
        if (self.addBtn.selected) {
            if (ON_IPAD) {
                [self.addBtn setImage:[UIImage imageNamed:@"ipad-icon_reduce_nol"] forState:UIControlStateNormal];
            }else{
                [self.addBtn setImage:[UIImage imageNamed:@"icon_reduce_normal"] forState:UIControlStateNormal];
            }
            
        }else{
            
            if (ON_IPAD) {
                [self.addBtn setImage:[UIImage imageNamed:@"ipad-icon_add_nol"] forState:UIControlStateNormal];
            }else{
                [self.addBtn setImage:[UIImage imageNamed:@"icon_add_normal"] forState:UIControlStateNormal];
            }
            
            //删除当前场景的当前硬件
            NSArray *devices = [[SceneManager defaultManager] subDeviceFromScene:_scene withDeivce:device.deviceID];
            [_scene setDevices:devices];
            
        }
        
    }
    
    [device setDeviceID:[self.deviceid intValue]];
    [_scene setSceneID:[self.sceneid intValue]];
    [_scene setRoomID:self.roomID];
    [_scene setMasterID:[[DeviceInfo defaultManager] masterID]];
    [_scene setReadonly:NO];
    NSArray *devices = [[SceneManager defaultManager] addDevice2Scene:_scene withDeivce:device withId:device.deviceID];
    [_scene setDevices:devices];
    [[SceneManager defaultManager] addScene:_scene withName:nil withImage:[UIImage imageNamed:@""] withiSactive:0];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)closeBtnClicked:(id)sender {
    [[DeviceInfo defaultManager] playVibrate];
    NSData *data = [[DeviceInfo defaultManager] close:self.deviceid];
    SocketManager *sock = [SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
}

- (IBAction)stopBtnClicked:(id)sender {
    [[DeviceInfo defaultManager] playVibrate];
    NSData *data = [[DeviceInfo defaultManager] stopCurtainByDeviceID:self.deviceid];
    SocketManager *sock = [SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
}

- (IBAction)openBtnClicked:(id)sender {
    [[DeviceInfo defaultManager] playVibrate];
    NSData *data = [[DeviceInfo defaultManager] open:self.deviceid];
    SocketManager *sock = [SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
}
@end
