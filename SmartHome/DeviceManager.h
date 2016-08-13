//
//  DeviceManager.h
//  SmartHome
//
//  Created by 逸云科技 on 16/8/5.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceManager : NSObject


//从数据中获取所有设备信息
+(NSArray *)getAllDevicesInfo;

//根据房间ID的到该房间的所有设备
+(NSArray *)devicesByRoomId:(NSInteger)roomId;

+(NSString *)deviceNameByDeviceID:(int)eId;

+(NSArray *)deviceSubTypeByRoomId:(NSInteger)roomID;


+ (NSArray *)getLightTypeNameWithRoomID:(NSInteger)roomID;
+ (NSArray *)getLightWithTypeName:(NSString *)typeName roomID:(NSInteger)roomID;


+ (NSArray *)getCurtainTypeNameWithRoomID:(NSInteger)roomID;
+ (NSArray *)getCurtainWithTypeName:(NSString *)typeName roomID:(NSInteger)roomID;

+ (NSString *)getTVDeviceIDWithRoomID:(NSInteger)roomID;

+(NSArray *)getDeviceByTypeName:(NSString  *)typeName andRoomID:(NSInteger)roomID;

@end
