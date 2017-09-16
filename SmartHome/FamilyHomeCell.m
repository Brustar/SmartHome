//
//  FamilyHomeCell.m
//  SmartHome
//
//  Created by KobeBryant on 2017/4/9.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "FamilyHomeCell.h"

@implementation FamilyHomeCell

- (void)setRoomAndDeviceStatus:(Room *)info {
    self.roomNameLabel.text = info.rName;
    
    if (info.tempture >0) {
        self.temperatureLabel.text = [NSString stringWithFormat:@"%ld℃", info.tempture];
    }else {
        self.temperatureLabel.text = [NSString stringWithFormat:@"%@℃", @"--"];
    }
    
    if (info.humidity >0) {
        self.humidityLabel.text = [NSString stringWithFormat:@"%ld%@", info.humidity, @"%"];
    }else {
        self.humidityLabel.text = [NSString stringWithFormat:@"%@%@", @"--", @"%"];
    }
    
    self.pm25Label.hidden = YES;
    NSString *pm25 = [NSString stringWithFormat:@"%@%ld%@", @"PM2.5:", info.pm25, @"μg/m³"];
    
    CGFloat pm25X = -66.0f;
    CGFloat pm25Y = 80.0f;
    CGFloat radius = -80.0f;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        if (UI_SCREEN_WIDTH == 375) {
            pm25X = -75.0f;
            pm25Y = 60.0f;
            radius = -70.0f;
        }else if (UI_SCREEN_WIDTH == 320) {
            pm25X = -88.0f;
            pm25Y = 40.0f;
            radius = -60.0f;
        }
    }else {
        pm25X = -80.0f;
        pm25Y = 56.0f;
        radius = -66.0f;
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
    pm25Label.tag = 10777;
    UIView *view = [self viewWithTag:10777];
    [view removeFromSuperview];
    [self addSubview:pm25Label];
    [self bringSubviewToFront:pm25Label];
    
    [self addRingForDevice:info];// 设备颜色圈
    
    [self addRingForPM25:info];//PM2.5圈
}

- (void)addRingForDevice:(Room *)info {
    CGFloat ringR = 57;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        if (UI_SCREEN_WIDTH == 414) {
            ringR = 67;
        }else if (UI_SCREEN_WIDTH == 320) {
            ringR = 47;
        }
    }else {
        ringR = 57;
    }
    
    
    NSMutableArray *deviceColorArray = [NSMutableArray array];
    if (info.lightStatus == 0 && info.airStatus == 0 && info.avStatus == 0) {
        [deviceColorArray addObjectsFromArray:@[Dev_OFF_COLOR,Dev_OFF_COLOR,Dev_OFF_COLOR]];
    }else if (info.lightStatus == 1 && info.airStatus == 0 && info.avStatus == 0) {
        [deviceColorArray addObjectsFromArray:@[Light_ON_COLOR,Dev_OFF_COLOR,Dev_OFF_COLOR]];
    }else if (info.lightStatus == 1 && info.airStatus == 1 && info.avStatus == 0) {
        [deviceColorArray addObjectsFromArray:@[Light_ON_COLOR,Air_ON_COLOR,Dev_OFF_COLOR]];
    }else if (info.lightStatus == 1 && info.airStatus == 1 && info.avStatus == 1) {
        [deviceColorArray addObjectsFromArray:@[Light_ON_COLOR,Air_ON_COLOR,AV_ON_COLOR]];
    }else if (info.lightStatus == 0 && info.airStatus == 1 && info.avStatus == 0) {
        [deviceColorArray addObjectsFromArray:@[Dev_OFF_COLOR,Air_ON_COLOR,Dev_OFF_COLOR]];
    }else if (info.lightStatus == 0 && info.airStatus == 1 && info.avStatus == 1) {
        [deviceColorArray addObjectsFromArray:@[Dev_OFF_COLOR,Air_ON_COLOR,AV_ON_COLOR]];
    }else if (info.lightStatus == 0 && info.airStatus == 0 && info.avStatus == 1) {
        [deviceColorArray addObjectsFromArray:@[Dev_OFF_COLOR,Dev_OFF_COLOR,AV_ON_COLOR]];
    }else if (info.lightStatus == 1 && info.airStatus == 0 && info.avStatus == 1) {
        [deviceColorArray addObjectsFromArray:@[Light_ON_COLOR,Dev_OFF_COLOR,AV_ON_COLOR]];
    }
    
    
    [LayerUtil createRing:ringR pos:CGPointMake(self.frame.size.width/2, self.frame.size.width/2) colors:deviceColorArray container:self];
}

- (void)addRingForPM25:(Room *)info {
    
    CGFloat ringR = 75;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        if (UI_SCREEN_WIDTH == 414) {
            ringR = 85;
        }else if (UI_SCREEN_WIDTH == 320) {
            ringR = 65;
        }
    }else {
        ringR = 75;
    }
    
    
    [LayerUtil createRingForPM25:ringR pos:CGPointMake(self.frame.size.width/2, self.frame.size.width/2) colors:@[PM25_COLOR] pm25Value:info.pm25 container:self];
}

@end
