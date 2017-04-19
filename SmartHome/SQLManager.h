//
//  DeviceManager.h
//  SmartHome
//
//  Created by 逸云科技 on 16/8/5.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "Device.h"
#import "Aircon.h"

#define DIMMER @"调光灯"
#define CURTAINS @"开合帘"
#define LightDevice @"照明"
#define AirDevice @"空调"
#define ColourLight @"调色灯"
#define OffOrOnLight @"开关灯" 

@interface SQLManager : NSObject

+(FMDatabase *)connetdb;
//从数据中获取所有设备信息
+(NSArray *)getAllDevicesInfo;
//从数据中获取所有设备
+(NSArray *)getAllDevices;
//从数据库中获取所有场景信息
+(NSArray *)getAllScene;
//根据房间ID得到该房间的所有设备
+(NSArray *)devicesByRoomId:(NSInteger)roomId;

//根据roomID 从Devices 表 查询出 subTypeName字段(可能有重复数据，要去重)
+ (NSArray *)getDevicesSubTypeNamesWithRoomID:(int)roomID;

//根据subTypeName 从Devices表 查询typeName(要去重)
+ (NSArray *)getDeviceTypeNameWithSubTypeName:(NSString *)subTypeName;
//根据房间ID得到房间所有的调色灯
+ (NSArray *)getColourLightByRoom:(int) roomID;
//根据房间ID获取照明设备
+ (NSArray *)getLightDevicesByRoom:(int)roomID;

//根据设备ID获取设备名称
+(NSString *)deviceNameByDeviceID:(int)eId;
//根据设备名字查找设备ID
+(NSInteger)deviceIDByDeviceName:(NSString *)deviceName;
//根据设备ID查到摄像头的URl
+(NSString *)deviceUrlByDeviceID:(int)deviceID;
//根据设备ID获取设备类别
+(NSString *)deviceTypeNameByDeviceID:(int)eId;
+ (NSArray *)getSwitchLightByRoom:(int) roomID;//开关灯
+(NSString*)lightTypeNameByDeviceID:(int)eId;
+(NSString *)getNameWithID:(int)eId;

+(NSArray *)deviceSubTypeByRoomId:(NSInteger)roomID;
+(NSArray *)deviceIdsByRoomId:(int)roomID;

+ (NSArray *)getLightTypeNameWithRoomID:(NSInteger)roomID;
+ (NSArray *)getLightWithTypeName:(NSString *)typeName roomID:(NSInteger)roomID;

+ (NSArray *)getCurtainWithTypeName:(NSString *)typeName roomID:(NSInteger)roomID;

+ (NSString *)deviceIDWithRoomID:(NSInteger)roomID withType:(NSString *)type;
//根据房间ID 获取所有的设备大类
+(NSArray*)getSubTypeNameByRoomID:(int)rID;
//根据房间ID 和设备大类找到对应的设备小类
+(NSArray *)getDeviceTypeName:(int)rID subTypeName:(NSString *)subTypeName;

//根据设备类别和房间ID获取设备的所有ID
+(NSArray *)getDeviceByTypeName:(NSString  *)typeName andRoomID:(NSInteger)roomID;
+(NSArray *)getDeviceBysubTypeName:(NSString  *)subtypeName andRoomID:(NSInteger)roomID;
//根据设备类别获取设备的所有ID
+(NSArray *)getDeviceByTypeName:(NSString  *)typeName;
+ (NSArray *)getDeviceIDWithRoomID:(int)roomID sceneID:(int)sceneID;

//根据房间ID和场景ID获得设备
+ (NSArray *)getDeviceWithRoomID:(int)roomID sceneID:(int)sceneID;
//根据房间ID和场景ID获得设备父类和子类
+ (NSArray *)getDeviceSubTypeNameWithRoomID:(int)roomID sceneID:(int)sceneID;
+ (NSArray *)getDeviceTypeNameWithRoomID:(int)roomID sceneID:(int)sceneID subTypeName:(NSString *)subTypeName;

//修改场景的打开状态（status： 0表示关闭 1表示打开）
+ (BOOL)updateSceneStatus:(int)status sceneID:(int)sceneID;

//得到所有设备父类和具体的设备
+(NSArray *)getAllDeviceSubTypes;
+(NSArray *)getAllDeviceNameBysubType:(NSString *)subTypeName;

+(NSString *)getEType:(NSInteger)eID;
+(NSString *)getENumber:(NSInteger)eID;
+(NSString *)getDeviceIDByENumber:(NSInteger)eID;
+(int)saveMaxSceneId:(Scene *)scene name:name pic:(NSString *)img;
+(int) getSceneID:(NSString *)name;
+(int) getRoomID:(int)sceneID;
+(int) getRoomIDByNumber:(NSString *)enumber;
//根据roomID从rooms表查出房间访问权限（openforcurrentuser）
+ (int)getRoomAuthority:(int)roomID;
+(NSString *)getSceneName:(int)sceneID;

+(int) getReadOnly:(int)sceneid;
+(NSString *) getSnumber:(int)sceneid;

+(NSArray *)getDeviceIDBySubName:(NSString *)subName;

//------------------------------------------------
//根据场景ID找到文件和设备ID
+(NSArray *)getDeviceIDsBySeneId:(int)SceneId;
+(NSArray *)getSubTydpeBySceneID:(int)sceneId;
+(NSArray *)getDeviceTypeNameWithScenID:(int)sceneId subTypeName:(NSString *)subTypeName;

+(void)initSQlite;
+(void)initDemoSQlite;
//根据房间ID找调光灯
+ (NSArray *)getDeviceByRoom:(int) roomID;
//根据房间ID找开合帘
+ (NSArray *)getCurtainByRoom:(int) roomID;
//根据房间ID找开合帘
+ (NSArray *)getAirDeviceByRoom:(int) roomID;
//得到所有场景
+(NSArray *)allSceneModels;
+(NSArray *)devicesBySceneID:(int)sId;
+(Scene *)sceneBySceneID:(int)sId;
//根据房间ID的到所有的场景
+ (NSArray *)getAllSceneWithRoomID:(int)roomID;
//得到数据库中所有的场景ID
+(NSArray *)getAllSceneIdsFromSql;
//从数据库中删除场景
+(BOOL)deleteScene:(int)sceneId;
+(NSArray *)getScensByRoomId:(int)roomId;
+(NSArray *)getFavorScene;

+(NSArray *)getAllRoomsInfoByName:(NSString *)name;
+(NSArray *)getAllRoomsInfo;

+(int)getRoomIDByBeacon:(int)beacon;
+(NSString *)getRoomNameByRoomID:(int) rId;

+ (Device *)getDeviceWithDeviceID:(int) deviceID ;

+(BOOL)updateTotalVisited:(int)roomID;

+(NSMutableArray *)getAllChannelForFavoritedForType:(NSString *)type deviceID:(int)deviceID;
+(BOOL)deleteChannelForChannelID:(NSInteger)channel_id;
+(NSString *)getDeviceType:(NSString *)deviceID subTypeName:(NSString *)subTypeName;
+ (NSString *)getDeviceTypeNameWithID:(NSString *)ID subTypeName:(NSString *)subTypeName;
+ (NSString *)getDeviceSubTypeNameWithID:(int)ID;
+(NSArray *)getDetailListWithID:(NSInteger)ID;
+(NSArray *)getAllDevicesIds;
//编辑fm
+(BOOL)getAllChangeChannelForFavoritedNewName:(NSString *)newName FmId:(NSInteger)fmId;
+(NSString *)getDevicePicByID:(int)sceneID;

+(NSArray *)queryChat:(NSString *)userid;
+ (void) writeDevices:(NSArray *)rooms;
+(void) writeRooms:(NSArray *)roomList;
+(NSArray *) writeScenes:(NSArray *)rooms;
+(void) writeChannels:(NSArray *)channels parent:(NSString *)parent;
+(void) writeChats:(NSArray *)users;
+ (BOOL)isWholeHouse:(NSInteger)eId;
@end
