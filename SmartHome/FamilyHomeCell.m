//
//  FamilyHomeCell.m
//  SmartHome
//
//  Created by KobeBryant on 2017/4/9.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "FamilyHomeCell.h"

@implementation FamilyHomeCell

- (void)setRoomAndDeviceStatus:(RoomStatus *)info {
    self.roomNameLabel.text = info.roomName;
    self.temperatureLabel.text = [NSString stringWithFormat:@"%@℃", info.temperature];
    self.humidityLabel.text = [NSString stringWithFormat:@"%@%@", info.humidity, @"%"];
    self.pm25Label.text = info.pm25;
    
    [self addRingForDevice:info];
    [self addRingForPM25:info];
}

- (void)addRingForDevice:(RoomStatus *)info {
    CGFloat ringR = 57;
    if (UI_SCREEN_WIDTH == 414) {
        ringR = 67;
    }
    NSMutableArray *deviceColorArray = [NSMutableArray array];
    if (info.lightStatus == 0 && info.airconditionerStatus == 0 && info.tvStatus == 0) {
        [deviceColorArray addObjectsFromArray:@[Dev_OFF_COLOR,Dev_OFF_COLOR,Dev_OFF_COLOR]];
    }else if (info.lightStatus == 1 && info.airconditionerStatus == 0 && info.tvStatus == 0) {
        [deviceColorArray addObjectsFromArray:@[Light_ON_COLOR,Dev_OFF_COLOR,Dev_OFF_COLOR]];
    }else if (info.lightStatus == 1 && info.airconditionerStatus == 1 && info.tvStatus == 0) {
        [deviceColorArray addObjectsFromArray:@[Light_ON_COLOR,Air_ON_COLOR,Dev_OFF_COLOR]];
    }else if (info.lightStatus == 1 && info.airconditionerStatus == 1 && info.tvStatus == 1) {
        [deviceColorArray addObjectsFromArray:@[Light_ON_COLOR,Air_ON_COLOR,AV_ON_COLOR]];
    }else if (info.lightStatus == 0 && info.airconditionerStatus == 1 && info.tvStatus == 0) {
        [deviceColorArray addObjectsFromArray:@[Dev_OFF_COLOR,Air_ON_COLOR,Dev_OFF_COLOR]];
    }else if (info.lightStatus == 0 && info.airconditionerStatus == 1 && info.tvStatus == 1) {
        [deviceColorArray addObjectsFromArray:@[Dev_OFF_COLOR,Air_ON_COLOR,AV_ON_COLOR]];
    }else if (info.lightStatus == 0 && info.airconditionerStatus == 0 && info.tvStatus == 1) {
        [deviceColorArray addObjectsFromArray:@[Dev_OFF_COLOR,Dev_OFF_COLOR,AV_ON_COLOR]];
    }
    
    
    [LayerUtil createRing:ringR pos:CGPointMake(self.frame.size.width/2, self.frame.size.width/2) colors:deviceColorArray container:self];
}

- (void)addRingForPM25:(RoomStatus *)info {
    
    CGFloat ringR = 75;
    if (UI_SCREEN_WIDTH == 414) {
        ringR = 85;
    }
    
    [LayerUtil createRingForPM25:ringR pos:CGPointMake(self.frame.size.width/2, self.frame.size.width/2) colors:@[PM25_COLOR] pm25Value:200 container:self];
}

@end
