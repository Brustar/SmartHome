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
    self.pm25Label.hidden = YES;
    NSString *pm25 = [NSString stringWithFormat:@"%@%@%@", @"PM2.5:", info.pm25, @"μg/m³"];
    
    CGFloat pm25X = -66.0f;
    CGFloat pm25Y = 80.0f;
    CGFloat radius = -80.0f;
    
    if (UI_SCREEN_WIDTH == 375) {
        pm25X = -75.0f;
        pm25Y = 60.0f;
        radius = -70.0f;
    }else if (UI_SCREEN_WIDTH == 320) {
        pm25X = -88.0f;
        pm25Y = 40.0f;
        radius = -60.0f;
    }
    
    
    UIFont *font = [UIFont systemFontOfSize:10.0];
    CGRect rect = CGRectMake(pm25X, pm25Y, 320, 120);
    UIColor * color = [UIColor whiteColor];
    CoreTextArcView * pm25Label = [[CoreTextArcView alloc] initWithFrame:rect
                                                                      font:font
                                                                      text:pm25
                                                                    radius:radius
                                                                   arcSize:radius
                                                                     color:color];
    
    [pm25Label showsLineMetrics];
    pm25Label.backgroundColor = [UIColor clearColor];
    [self addSubview:pm25Label];
    [self bringSubviewToFront:pm25Label];
    
    
    [self addRingForDevice:info];
    [self addRingForPM25:info];
}

- (void)addRingForDevice:(RoomStatus *)info {
    CGFloat ringR = 57;
    if (UI_SCREEN_WIDTH == 414) {
        ringR = 67;
    }else if (UI_SCREEN_WIDTH == 320) {
        ringR = 47;
    }
    NSMutableArray *deviceColorArray = [NSMutableArray array];
    if (info.lightStatus == 0 && info.airconditionerStatus == 0 && info.mediaStatus == 0) {
        [deviceColorArray addObjectsFromArray:@[Dev_OFF_COLOR,Dev_OFF_COLOR,Dev_OFF_COLOR]];
    }else if (info.lightStatus == 1 && info.airconditionerStatus == 0 && info.mediaStatus == 0) {
        [deviceColorArray addObjectsFromArray:@[Light_ON_COLOR,Dev_OFF_COLOR,Dev_OFF_COLOR]];
    }else if (info.lightStatus == 1 && info.airconditionerStatus == 1 && info.mediaStatus == 0) {
        [deviceColorArray addObjectsFromArray:@[Light_ON_COLOR,Air_ON_COLOR,Dev_OFF_COLOR]];
    }else if (info.lightStatus == 1 && info.airconditionerStatus == 1 && info.mediaStatus == 1) {
        [deviceColorArray addObjectsFromArray:@[Light_ON_COLOR,Air_ON_COLOR,AV_ON_COLOR]];
    }else if (info.lightStatus == 0 && info.airconditionerStatus == 1 && info.mediaStatus == 0) {
        [deviceColorArray addObjectsFromArray:@[Dev_OFF_COLOR,Air_ON_COLOR,Dev_OFF_COLOR]];
    }else if (info.lightStatus == 0 && info.airconditionerStatus == 1 && info.mediaStatus == 1) {
        [deviceColorArray addObjectsFromArray:@[Dev_OFF_COLOR,Air_ON_COLOR,AV_ON_COLOR]];
    }else if (info.lightStatus == 0 && info.airconditionerStatus == 0 && info.mediaStatus == 1) {
        [deviceColorArray addObjectsFromArray:@[Dev_OFF_COLOR,Dev_OFF_COLOR,AV_ON_COLOR]];
    }else if (info.lightStatus == 1 && info.airconditionerStatus == 0 && info.mediaStatus == 1) {
        [deviceColorArray addObjectsFromArray:@[Light_ON_COLOR,Dev_OFF_COLOR,AV_ON_COLOR]];
    }
    
    
    [LayerUtil createRing:ringR pos:CGPointMake(self.frame.size.width/2, self.frame.size.width/2) colors:deviceColorArray container:self];
}

- (void)addRingForPM25:(RoomStatus *)info {
    
    CGFloat ringR = 75;
    if (UI_SCREEN_WIDTH == 414) {
        ringR = 85;
    }else if (UI_SCREEN_WIDTH == 320) {
        ringR = 65;
    }
    
    [LayerUtil createRingForPM25:ringR pos:CGPointMake(self.frame.size.width/2, self.frame.size.width/2) colors:@[PM25_COLOR] pm25Value:[info.pm25 floatValue] container:self];
}

@end
