//
//  DeviceSchedule.h
//  SmartHome
//
//  Created by Brustar on 2017/8/10.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceSchedule : NSObject

@property (nonatomic,assign) int deviceID;

//定时列表
@property (strong,nonatomic) NSArray *schedules;

- (instancetype)initWithoutScheduleByDeviceID:(int)deviceid;

@end
