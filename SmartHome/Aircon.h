//
//  Aircon.h
//  SmartHome
//
//  Created by Brustar on 16/5/23.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <Foundation/Foundation.h>
//空调
@interface Aircon : NSObject

//设备id
@property (nonatomic) int deviceID;
//温度
@property (nonatomic) int temperature;
//风向
@property (nonatomic) int Windirection;
//风速
@property (nonatomic) int WindLevel;
//模式
@property (nonatomic) int mode;
//定时
@property (nonatomic) int timing;

@end
