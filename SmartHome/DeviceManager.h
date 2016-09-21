//
//  DeviceManager.h
//  SmartHome
//
//  Created by 逸云科技 on 16/8/5.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

@interface DeviceManager : NSObject

+(FMDatabase *) connetdb;
//从数据中获取所有设备信息
+(NSArray *)getAllDevicesInfo;

//根据房间ID得到该房间的所有设备
+(NSArray *)devicesByRoomId:(NSInteger)roomId;

//根据设备ID获取设备名称
+(NSString *)deviceNameByDeviceID:(int)eId;
//根据设备名字查找设备ID
+(NSInteger)deviceIDByDeviceName:(NSString *)deviceName;
//根据设备ID获取设备类别
+(NSString *)deviceTypeNameByDeviceID:(int)eId;

+(NSString*)lightTypeNameByDeviceID:(int)eId;
+(NSString *)getNameWithID:(int)eId;

+(NSArray *)deviceSubTypeByRoomId:(NSInteger)roomID;
+(NSArray *)deviceIdsByRoomId:(int)roomID;

+ (NSArray *)getLightTypeNameWithRoomID:(NSInteger)roomID;
+ (NSArray *)getLightWithTypeName:(NSString *)typeName roomID:(NSInteger)roomID;


+ (NSArray *)getCurtainTypeNameWithRoomID:(NSInteger)roomID;
+ (NSArray *)getCurtainWithTypeName:(NSString *)typeName roomID:(NSInteger)roomID;

+ (NSString *)deviceIDWithRoomID:(NSInteger)roomID withType:(NSString *)type;
//根据房间ID 获取所有的设备大类
+(NSArray*)getSubTypeNameByRoomID:(int)rID;
//根据房间ID 和设备大类找到对应的设备小类
+(NSArray *)getDeviceTypeName:(int)rID subTypeName:(NSString *)subTypeName;

//根据设备类别和房间ID获取设备的所有ID
+(NSArray *)getDeviceByTypeName:(NSString  *)typeName andRoomID:(NSInteger)roomID;
+ (NSArray *)getDeviceIDWithRoomID:(int)roomID sceneID:(int)sceneID;

//根据房间ID和场景ID获得设备
+ (NSArray *)getDeviceWithRoomID:(int)roomID sceneID:(int)sceneID;
//根据房间ID和场景ID获得设备父类和子类
+ (NSArray *)getDeviceSubTypeNameWithRoomID:(int)roomID sceneID:(int)sceneID;
+ (NSArray *)getDeviceTypeNameWithRoomID:(int)roomID sceneID:(int)sceneID subTypeName:(NSString *)subTypeName;


//得到所有设备父类和具体的设备
+(NSArray *)getAllDeviceSubTypes;
+(NSArray *)getAllDeviceNameBysubType:(NSString *)subTypeName;

+(NSString *)getUrlByDeviceId:(int)eId;

+(NSString *)getEType:(NSInteger)eID;
+(NSString *)getENumber:(NSInteger)eID;
+(NSString *)getDeviceIDByENumber:(NSInteger)eID masterID:(NSInteger)mID;
+(int)saveMaxSceneId:(Scene *)scene name:name pic:(NSString *)img;
+(int) getSceneID:(NSString *)name;
+(int) getRoomID:(int)sceneID;
+(NSString *)getSceneName:(int)sceneID;

+(bool) getReadOnly:(int)sceneid;
+(NSString *) getSnumber:(int)sceneid;

+(NSArray *)getDeviceIDBySubName:(NSString *)subName;

//------------------------------------------------
//根据场景ID找到文件和设备ID
+(NSArray *)getDeviceIDsBySeneId:(int)SceneId;
+(NSArray *)getSubTydpeBySceneID:(int)sceneId;
+(NSArray *)getDeviceTypeNameWithScenID:(int)sceneId subTypeName:(NSString *)subTypeName;

+(void)initSQlite;
+(void)initDemoSQlite;
@end
