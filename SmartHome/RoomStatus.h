//
//  RoomStatus.h
//  SmartHome
//
//  Created by KobeBryant on 2017/4/1.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RoomStatus : NSObject
@property(nonatomic, assign) NSInteger roomId;
@property(nonatomic, strong) NSString *roomName;
@property(nonatomic, strong) NSString *temperature;//温度
@property(nonatomic, strong) NSString *humidity;//湿度
@property(nonatomic, strong) NSString *pm25;//PM2.5
@property(nonatomic, assign) NSInteger lightStatus;//灯状态
@property(nonatomic, assign) NSInteger curtainStatus;//窗帘状态
@property(nonatomic, assign) NSInteger bgmusicStatus;//背景音乐状态
@property(nonatomic, assign) NSInteger airconditionerStatus;//空调状态
@property(nonatomic, assign) NSInteger dvdStatus;//DVD状态
@property(nonatomic, assign) NSInteger tvStatus;//TV状态

@end
