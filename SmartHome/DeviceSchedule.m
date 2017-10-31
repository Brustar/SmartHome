//
//  DeviceSchedule.m
//  SmartHome
//
//  Created by Brustar on 2017/8/10.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "DeviceSchedule.h"

@implementation DeviceSchedule

- (instancetype)initWithoutScheduleByDeviceID:(int)deviceid
{
    self = [super init];
    if (self) {
        [self setDeviceID:deviceid];
        [self setSchedules:@[]];
    }
    return self;
}

- (instancetype)initWithoutScheduleByENumber:(NSInteger)eNumber
{
    self = [super init];
    if (self) {
        [self setENumber:eNumber];
        [self setDeviceID:(int)eNumber];
        [self setSchedules:@[]];
    }
    return self;
}

@end
