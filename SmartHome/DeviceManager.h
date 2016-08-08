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
+ (NSArray *)getDeviceModel;
@end
