//
//  Light.h
//  SmartHome
//
//  Created by Brustar on 16/5/23.
//  Copyright © 2016年 Brustar. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface Light : NSObject

//设备id
@property (nonatomic) int deviceID;
//开关状态
@property (nonatomic) bool isPoweron;
//颜色
@property (nonatomic) NSArray *color;
//亮度
@property (nonatomic) int brightness;

@end
