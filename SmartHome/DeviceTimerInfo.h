//
//  DeviceTimerInfo.h
//  SmartHome
//
//  Created by KobeBryant on 2017/2/27.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceTimerInfo : NSObject

@property(nonatomic, strong) NSNumber *deviceValue;
@property(nonatomic, strong) NSString *repetition;
@property(nonatomic, strong) NSString *deviceName;
@property(nonatomic, strong) NSString *startTime;
@property(nonatomic, strong) NSString *endTime;
@property(nonatomic, strong) NSNumber *status;

@end
