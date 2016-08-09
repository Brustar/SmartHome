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
//根据房间ID的到该房间的所有设备
+(NSArray *)devicesByRoomId:(NSInteger)roomId;

@end
