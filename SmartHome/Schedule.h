//
//  Schedule.h
//  SmartHome
//
//  Created by Brustar on 16/9/27.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Schedule : NSObject

//设备id 0表示控制场景的定时，大于0表示控制设备的定时
//@property (nonatomic) int deviceID;
//天文时钟 1 黎明 2 日出 3 日落 4 黄昏
//@property (nonatomic,assign) int astronomicalStartID;
//@property (nonatomic,assign) int astronomicalEndID;
//定时某设备的值，比如定时到12：00空调升一度
//@property(nonatomic) int openToValue;
//@property(nonatomic, strong) NSString* startDate;
//@property(nonatomic, strong) NSString* endDate;

//持续时间S
@property (nonatomic,assign) int interval;
@property(nonatomic, strong) NSString* startTime;
@property(nonatomic, strong) NSString* endTime;

//每周几重复，为空@[]只表示当天运行一次（永不）0 日 1 一 ...
@property(nonatomic,strong) NSArray *weekDays;

- (instancetype)initWhithoutSchedule;
@end
