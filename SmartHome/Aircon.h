//
//  Aircon.h
//  SmartHome
//
//  Created by Brustar on 16/5/23.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "Device.h"
//空调
@interface Aircon : Device

//温度
@property (nonatomic) int temperature;
//风向
@property (nonatomic) int Windirection;
//风速
@property (nonatomic) int WindLevel;
//模式
@property (nonatomic) int mode;

@end
