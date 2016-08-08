//
//  DeviceManager.h
//  SmartHome
//
//  Created by 逸云科技 on 16/8/5.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceManager : NSObject

+(NSArray *)parseDevicesResult:(id)result;
+(NSArray *)getAllDevicesInfo;
//得到所有设备的模型
+(NSArray *)getDeviceModel;
//获取所有设备种类
+(NSArray *)getTypeNameForDevice;
+ (NSArray *)getDeviceType;

@end
