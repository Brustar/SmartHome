//
//  Schedule.h
//  SmartHome
//
//  Created by Brustar on 16/9/27.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Schedule : NSObject

//设备id
@property (nonatomic) int deviceID;
@property(nonatomic, strong) NSString* startTime;
@property(nonatomic, strong) NSString* endTime;

//定时某设备的值，比如定时到12：00空调升一度
@property(nonatomic) int openTovalue;

- (instancetype)initWhithoutSchedule;
@end
