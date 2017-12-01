//
//  DeviceTimerInfo.h
//  SmartHome
//
//  Created by KobeBryant on 2017/2/27.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#define DEVICE_TIMER_FILE_NAME @"schedule"

#import <Foundation/Foundation.h>

@interface DeviceTimerInfo : NSObject

@property(nonatomic, assign) NSInteger timerID;
@property(nonatomic, assign) int eID;//设备ID
@property (nonatomic) long masterID;//主机ID

@property(nonatomic, strong) NSNumber *deviceValue;
@property(nonatomic, strong) NSString *repetition;
@property(nonatomic, strong) NSString *deviceName;
@property(nonatomic, strong) NSString *startTime;
@property(nonatomic, strong) NSString *endTime;
@property(nonatomic, strong) NSNumber *status;
@property(nonatomic, assign) NSInteger isActive;//1:启动 0:暂停
@property(nonatomic, strong) NSString *htype;

//定时列表
@property (strong,nonatomic) NSArray *schedules;

//设备状态：
@property(nonatomic, assign) int power;// 开关状态：1:开 0:关
@property(nonatomic, assign) int bright;//灯的亮度 (0~100)
@property(nonatomic, assign) int position;//窗帘的位置(0~100)
@property(nonatomic, strong) NSString *color;//灯的颜色 RGB
@property(nonatomic, assign) int temperature;//空调温度
@property(nonatomic, assign) int volume;//音量 (0~100)

- (instancetype)initWithoutSchedule;

@end
