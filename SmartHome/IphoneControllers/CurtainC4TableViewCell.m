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
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)closeBtnClicked:(id)sender {
    NSData *data = [[DeviceInfo defaultManager] close:self.deviceid];
    SocketManager *sock = [SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
}

- (IBAction)stopBtnClicked:(id)sender {
    NSData *data = [[DeviceInfo defaultManager] stopCurtainByDeviceID:self.deviceid];
    SocketManager *sock = [SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
}

- (IBAction)openBtnClicked:(id)sender {
    NSData *data = [[DeviceInfo defaultManager] open:self.deviceid];
    SocketManager *sock = [SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
}
@end
