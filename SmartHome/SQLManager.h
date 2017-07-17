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
#import "UserInfo.h"

#define SWITCHLIGHT_SUB_TYPE @"01"
#define DIMMER_SUB_TYPE @"02"
#define COLORLIGHT_SUB_TYPE @"03"

#define CURTAINS_SUB_TYPE @"21"
#define AIR_SUB_TYPE @"31"

#define LIGHT_DEVICE_TYPE @"1"
#define CURTAIN_DEVICE_TYPE @"7"

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
+(NSArray *)deviceOfRoom:(int) roomID;
//根据roomID 从Devices 表 查询出 subTypeName字段(可能有重复数据，要去重)
+ (NSArray *)getDevicesSubTypeNamesWithRoomID:(int)roomID;
+ (NSArray *)allTypeinRoom:(int)roomID;
//根据roomID和subTypeName字段 从Devices 表 查询出 htypeID字段(可能有重复数据，要去重)
+ (NSArray *)getDevicesIDWithRoomID:(int)roomID SubTypeName:(NSString *)subTypeName;

//根据subTypeName 从Devices表 查询typeName(要去重)
+ (NSArray *)getDeviceTypeNameWithSubTypeName:(NSString *)subTypeName;
//根据房间ID得到房间所有的调色灯
+ (NSArray *)getColourLightByRoom:(int) roomID;
//根据房间ID获取照明设备
+ (NSArray *)getLightDevicesByRoom:(int)roomID;
+ (Device *)singleLightByRoom:(int) roomID;
//根据设备ID获取设备名称
+(NSString *)deviceNameByDeviceID:(int)eId;
//根据设备ID获取设备htypeID
+(NSInteger)deviceHtypeIDByDeviceID:(int)eId;
//根据设备名字查找设备ID
+(NSInteger)deviceIDByDeviceName:(NSString *)deviceName;
//根据设备ID查到摄像头的URl
+(NSString *)deviceUrlByDeviceID:(int)deviceID;
//根据设备ID获取设备类别
+(NSString *)deviceTypeNameByDeviceID:(int)eId;
+ (NSArray *)getSwitchLightByRoom:(int) roomID;//开关灯
+(NSString *)lightTypeNameByDeviceID:(int)eId;
+(NSArray *)devicesWithCatalogID:(long)catalogID room:(int)roomID;
+(NSString *) singleDeviceWithCatalogID:(int)catalogID byRoom:(int)roomID;
+(NSArray *)deviceSubTypeByRoomId:(NSInteger)roomID;
+(NSArray *)deviceTypeIDByRoom:(NSInteger)roomID;
+(NSArray *)deviceIdsByRoomId:(int)roomID;
+ (NSString *)getRoomNameByDeviceID:(int) deviceId;

+(int) currentDevicesOfRoom:(int)roomID;
//多媒体UI菜单
+(NSArray *)mediaDeviceNamesByRoom:(int)roomID;
//智能单品菜单
+(NSArray *)singleProductByRoom:(int)roomID;

+ (NSArray *)getLightTypeNameWithRoomID:(NSInteger)roomID;
+ (NSArray *)getLightWithTypeName:(NSString *)typeName roomID:(NSInteger)roomID;

+ (NSArray *)getCurtainWithTypeName:(NSString *)typeName roomID:(NSInteger)roomID;

+ (NSString *)deviceIDWithRoomID:(NSInteger)roomID withType:(NSString *)type;
//根据房间ID 获取所有的设备大类
+(NSMutableArray*)typeName:(int)typeID byRoom:(int) roomID;
//根据房间ID 和设备大类找到对应的设备小类
+(NSArray *)getDeviceTypeName:(int)rID subTypeName:(NSString *)subTypeName;

//根据设备类别和房间ID获取设备的所有ID
+(NSArray *)getDeviceByTypeName:(NSString  *)typeName andRoomID:(NSInteger)roomID;
+(NSArray *)getDeviceBysubTypeid:(NSString  *)subtypeName andRoomID:(NSInteger)roomID;
//根据设备类别获取设备的所有ID
+(NSArray *)getDeviceByTypeName:(NSString  *)typeName;
+ (NSArray *)getDeviceIDWithRoomID:(int)roomID sceneID:(int)sceneID;

//根据房间ID和场景ID获得设备
+ (NSArray *)getDeviceWithRoomID:(int)roomID sceneID:(int)sceneID;
//根据房间ID和场景ID获得设备父类和子类
+ (NSArray *)getCatalogWithRoomID:(int)roomID;
+ (NSArray *)getDeviceTypeNameWithRoomID:(int)roomID sceneID:(int)sceneID subTypeName:(NSString *)subTypeName;

//修改场景的打开状态（status： 0表示关闭 1表示打开）
+ (BOOL)updateSceneStatus:(int)status sceneID:(int)sceneID;
+ (BOOL)updateScenePic:(NSString *)img sceneID:(int)sceneID;

//得到所有设备父类和具体的设备
+(NSArray *)getAllDeviceSubTypes;
+(NSArray *)getAllDeviceNameBysubType:(NSString *)subTypeName;

+(NSString *)getEType:(NSInteger)eID;
+(NSString *)getENumber:(NSInteger)eID;
+(NSString *)getDeviceIDByENumber:(NSInteger)eID;
+(int)saveMaxSceneId:(Scene *)scene name:name pic:(NSString *)img;

+(NSArray *) fetchScenes:(NSString *)name;

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

//根据房间ID找调光灯
+ (NSArray *)getDimmerByRoom:(int) roomID;
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
+ (Device *)getDeviceWithDeviceHtypeID:(int) htypeID ;

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
+ (NSArray *)queryAllChat;
+ (void) writeDevices:(NSArray *)rooms;
+(void) writeRooms:(NSArray *)roomList;
+(NSArray *) writeScenes:(NSArray *)rooms;
+(void) writeChannels:(NSArray *)channels parent:(NSString *)parent;
+(void) writeChats:(NSArray *)users;
+ (BOOL)isWholeHouse:(NSInteger)eId;

+ (NSInteger)numbersOfDeviceType;
+ (NSArray *)getDeviceIDsByHtypeID:(NSString *)htypeid;
+ (NSString *)getCameraUrlByDeviceID:(int)deviceID;
+ (NSInteger)getRoomIDByDeviceID:(int)deviceID;

+ (BOOL)updateUserPortraitUrlByID:(int)userID url:(NSString *)url;
+ (BOOL)insertOrReplaceUser:(UserInfo *)info;
+ (UserInfo *)getUserInfo:(int)userID;

+(NSArray *)getAllRoomsInfoWithoutIsAll;
+(NSArray *)getAllDevicesInfo:(int)roomID;
+ (NSArray *)getAllSceneOrderByRoomID;
+ (BOOL)updateDeviceStatus:(Device *)deviceInfo;
+ (NSString *)getSubTypeNameByDeviceID:(int)eId;//根据设备id查询设备大类的名字
+ (BOOL)updateChatsPortraitByID:(int)userID url:(NSString *)url;
+ (BOOL)updateSceneIsActive:(NSInteger)isActive sceneID:(int)sceneID;
+ (BOOL)updateChatsPortraitByID:(int)userID nickname:(NSString *)nickname;
+ (BOOL)updateUserNickNameByID:(int)userID nickName:(NSString *)nickName;
+ (NSArray *)getDeviceIDsBySubTypeId:(int)subTypeId;
+ (NSArray *)getDeviceIDsByRid:(NSInteger)rId;
@end
