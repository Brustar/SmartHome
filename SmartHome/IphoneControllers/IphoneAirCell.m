//
//  IphoneAirCell.m
//  SmartHome
//
//  Created by zhaona on 2017/1/23.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "IphoneAirCell.h"
#import "SocketManager.h"

@implementation IphoneAirCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    [self.IphoneSwitch addTarget:self action:@selector(Iphoneswitch:) forControlEvents:UIControlEventValueChanged];
}
-(void)Iphoneswitch:(UISwitch *)switc
{
    NSString *deviceid = self.deviceId;    
//    NSData * data = [[DeviceInfo defaultManager] toogleLight:switc.on deviceID:deviceid];
    NSData * data = [[DeviceInfo defaultManager] toogleAirCon:switc.on deviceID:deviceid];
    SocketManager *sock=[SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
