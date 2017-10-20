//
//  DeviceTimerInfo.m
//  SmartHome
//
//  Created by KobeBryant on 2017/2/27.
//  Copyright © 2017年 Brustar. All rights reserved.
//



#import "DeviceTimerInfo.h"

@implementation DeviceTimerInfo

- (instancetype)initWithoutSchedule 
{
    self = [super init];
    if (self) {
        [self setSchedules:@[]];
    }
    return self;
}

@end
