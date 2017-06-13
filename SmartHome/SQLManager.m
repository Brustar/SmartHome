//
//  DeviceManager.m
//  SmartHome
//
//  Created by 逸云科技 on 16/8/5.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "SQLManager.h"

#import "DeviceInfo.h"
#import "Room.h"
#import "Scene.h"
#import "TVChannel.h"

@implementation SQLManager

+(FMDatabase *)connetdb
{
    NSString *dbPath = [[IOManager sqlitePath] stringByAppendingPathComponent:SMART_DB];
    
    return [FMDatabase databaseWithPath:dbPath];
}

//从数据中获取该房间的所有设备信息（按房间号）
+(NSArray *)getAllDevicesInfo:(int)roomID
{
    FMDatabase *db = [self connetdb];
    NSMutableArray *deviceModels = [NSMutableArray array];
    if([db open])
    {
        NSString *deviceSql =[NSString stringWithFormat:@"select * from Devices where masterID = '%ld' and rID = %d and subTypeId <> 4 and subTypeId <> 6", [[DeviceInfo defaultManager] masterID], roomID];
        
        FMResultSet *resultSet = [db executeQuery:deviceSql];
        
        while ([resultSet next]){
            [deviceModels addObject:[self deviceMdoelByFMResultSet:resultSet]];
        }
    }
    [db closeOpenResultSets];
    [db close];
    return [deviceModels copy];
}

//从数据中获取所有设备信息
+(NSArray *)getAllDevicesInfo
{
    FMDatabase *db = [self connetdb];
    NSMutableArray *deviceModels = [NSMutableArray array];
    if([db open])
    {
        NSString *deviceSql =[NSString stringWithFormat:@"select * from Devices where masterID = '%ld'", [[DeviceInfo defaultManager] masterID]];
        
        FMResultSet *resultSet = [db executeQuery:deviceSql];
        
        while ([resultSet next]){
            [deviceModels addObject:[self deviceMdoelByFMResultSet:resultSet]];
        }
    }
    [db closeOpenResultSets];
    [db close];
    return [deviceModels copy];
}
//从数据库中获取所有场景信息
+ (NSArray *)getAllScene
{
    FMDatabase *db = [self connetdb];
    NSMutableArray *deviceModels = [NSMutableArray array];
    if([db open])
    {
        NSString *sceneSql = [NSString stringWithFormat:@"select * from Scenes where masterID = '%ld'", [[DeviceInfo defaultManager] masterID]];
        FMResultSet *resultSet = [db executeQuery:sceneSql];
        
        while ([resultSet next]){
            Scene *scene = [Scene new];
            scene.sceneName = [resultSet stringForColumn:@"NAME"];
            scene.sceneID = [resultSet intForColumn:@"ID"];
            scene.picName = [resultSet stringForColumn:@"pic"];
            scene.roomID =     [resultSet intForColumn:@"rId"];
            scene.roomName = [resultSet stringForColumn:@"roomName"];
            [deviceModels addObject:scene];
        }
    }
    [db closeOpenResultSets];
    [db close];
    return [deviceModels copy];

}

//从数据库中获取所有场景信息(按房间排序)
+ (NSArray *)getAllSceneOrderByRoomID
{
    FMDatabase *db = [self connetdb];
    NSMutableArray *deviceModels = [NSMutableArray array];
    if([db open])
    {
        NSString *sceneSql = [NSString stringWithFormat:@"select * from Scenes where masterID = '%ld' order by rId", [[DeviceInfo defaultManager] masterID]];
        FMResultSet *resultSet = [db executeQuery:sceneSql];
        
        while ([resultSet next]){
            Scene *scene = [Scene new];
            scene.sceneName = [resultSet stringForColumn:@"NAME"];
            scene.sceneID = [resultSet intForColumn:@"ID"];
            scene.picName = [resultSet stringForColumn:@"pic"];
            scene.roomID =     [resultSet intForColumn:@"rId"];
            scene.roomName = [resultSet stringForColumn:@"roomName"];
            [deviceModels addObject:scene];
        }
    }
    [db closeOpenResultSets];
    [db close];
    return [deviceModels copy];
    
}

+(NSString *)deviceNameByDeviceID:(int)eId
{
    FMDatabase *db = [self connetdb];
    NSString *eName = @"";
    if([db open])
    {
        NSString *sql = nil;
        
        sql = [NSString stringWithFormat:@"SELECT NAME FROM Devices where ID = %d and masterID = '%ld'",eId,[[DeviceInfo defaultManager] masterID]];
       
        FMResultSet *resultSet = [db executeQuery:sql];
        if ([resultSet next])
        {
            eName = [resultSet stringForColumn:@"NAME"];
        }
    }
    [db closeOpenResultSets];
    [db close];
    return eName;
}

//根据设备ID获取设备htypeID
+(NSInteger)deviceHtypeIDByDeviceID:(int)eId
{
    FMDatabase *db = [self connetdb];
    NSInteger htypeID = 0;
    if([db open])
    {
        NSString *sql = nil;
        
        sql = [NSString stringWithFormat:@"SELECT HTYPEID FROM Devices where ID = %d and masterID = '%ld'",eId,[[DeviceInfo defaultManager] masterID]];

        FMResultSet *resultSet = [db executeQuery:sql];
        while ([resultSet next])
        {
            htypeID = [resultSet intForColumn:@"HTYPEID"];
        }
    }
    [db closeOpenResultSets];
    [db close];
    return htypeID;
    
}

+(NSInteger)deviceIDByDeviceName:(NSString *)deviceName
{
    FMDatabase *db = [self connetdb];
    NSInteger eId = 0;
    if([db open])
    {
        NSString *sql = [NSString stringWithFormat:@"SELECT ID FROM Devices where NAME = '%@' and masterID = '%ld'",deviceName,[[DeviceInfo defaultManager] masterID]];

        FMResultSet *resultSet = [db executeQuery:sql];
        while ([resultSet next])
        {
            eId = [resultSet intForColumn:@"ID"];
        }
    }
    [db closeOpenResultSets];
    [db close];
    return eId;

}
+(NSString *)deviceUrlByDeviceID:(int)deviceID
{
    FMDatabase *db = [self connetdb];
    NSString *url;
    if([db open])
    {
        NSString *sql = [NSString stringWithFormat:@"SELECT camera_url FROM Devices where ID = %d and masterID = '%ld'",deviceID,[[DeviceInfo defaultManager] masterID]];
        
        FMResultSet *resultSet = [db executeQuery:sql];
        while ([resultSet next])
        {
            url = [resultSet stringForColumn:@"camera_url"];
        }
    }
    [db closeOpenResultSets];
    [db close];
    return url;

}

+(NSString *)deviceTypeNameByDeviceID:(int)eId
{
    FMDatabase *db = [self connetdb];
    NSString *typeName=@"";
    if([db open])
    {
        long masterID =  [[DeviceInfo defaultManager] masterID];
        NSString *sql = [NSString stringWithFormat:@"SELECT typeName,subtypeid FROM Devices where ID = %d and masterID = '%ld'",eId,masterID];
        FMResultSet *resultSet = [db executeQuery:sql];
        if ([resultSet next])
        {
            typeName = [resultSet stringForColumn:@"typeName"];
            int typeID = [[resultSet stringForColumn:@"subtypeid"] intValue];
            if ([self transferSubType:typeID]) {
                typeName = [self transferSubType:typeID];
            }
        }
    }
    [db closeOpenResultSets];
    [db close];
    return typeName;
}

+ (NSString *)getSubTypeNameByDeviceID:(int)eId
{
    FMDatabase *db = [self connetdb];
    NSString *subTypeName = @"";
    if([db open])
    {
        NSString *sql = [NSString stringWithFormat:@"SELECT subTypeName FROM Devices where ID = %d and masterID = '%ld'",eId,[[DeviceInfo defaultManager] masterID]];
        FMResultSet *resultSet = [db executeQuery:sql];
        if ([resultSet next])
        {
            subTypeName = [resultSet stringForColumn:@"subTypeName"];
            
        }
    }
    [db closeOpenResultSets];
    [db close];
    return subTypeName;
}

+(NSString*)lightTypeNameByDeviceID:(int)eId
{
    FMDatabase *db = [self connetdb];
    NSString *typeName;
    if([db open])
    {
        long masterID =  [[DeviceInfo defaultManager] masterID];
        NSString *sql = [NSString stringWithFormat:@"SELECT typeName FROM Devices where ID = %d and masterID = '%ld'",eId,masterID];
        FMResultSet *resultSet = [db executeQuery:sql];
        while ([resultSet next])
        {
            typeName = [resultSet stringForColumn:@"typeName"];
                        
        }
    }
    [db closeOpenResultSets];
    [db close];
    return typeName;
}

//htypeid=14
+(NSString *) singleDeviceWithCatalogID:(int)catalogID byRoom:(int)roomID
{
    NSString *cata = catalogID<10?[NSString stringWithFormat:@"0%d",catalogID]:[NSString stringWithFormat:@"%d",catalogID];
    
    FMDatabase *db = [self connetdb];
    NSString *deviceID = @"";
    if([db open])
    {
        NSString *sql;
        if ([self isWholeHouse:roomID]) {
            sql = [NSString stringWithFormat:@"SELECT id FROM Devices where htypeid = '%@'",cata];
        }else{
            sql = [NSString stringWithFormat:@"SELECT id FROM Devices where htypeid = '%@' and rid = %d",cata,roomID];
        }
        FMResultSet *resultSet = [db executeQuery:sql];
        if ([resultSet next])
        {
            deviceID = [resultSet stringForColumn:@"id"];
        }
    }
    [db closeOpenResultSets];
    [db close];
    return deviceID;
}

+ (NSArray *)devicesWithCatalogID:(long)catalogID room:(int)roomID
{
    FMDatabase *db = [self connetdb];
    NSMutableArray *names = [NSMutableArray new];
    if([db open])
    {
        NSString *sql;
        if ([self isWholeHouse:roomID]) {
            sql = [NSString stringWithFormat:@"SELECT id,NAME FROM Devices where UITypeOfLight = '%ld'",catalogID];
        }else{
            sql = [NSString stringWithFormat:@"SELECT id,NAME FROM Devices where UITypeOfLight = '%ld' and rid = %d",catalogID,roomID];
        }
        FMResultSet *resultSet = [db executeQuery:sql];
        while ([resultSet next])
        {
            Device *device = [Device new];
            device.eID = [[resultSet stringForColumn:@"id"] intValue];
            device.name = [resultSet stringForColumn:@"NAME"];
            [names addObject:device];
        }
    }
    [db closeOpenResultSets];
    [db close];
    return names;
}

+(Device*)deviceMdoelByFMResultSet:(FMResultSet *)resultSet 
{
    Device *device = [Device new];
    device.eID = [resultSet intForColumn:@"ID"];
    device.name = [resultSet stringForColumn:@"NAME"];
    device.sn = [resultSet stringForColumn:@"sn"];
    device.birth = [resultSet stringForColumn:@"birth"];
    device.guarantee = [resultSet stringForColumn:@"guarantee"];
    device.price = [resultSet doubleForColumn:@"price"];
    device.purchase = [resultSet stringForColumn:@"purchase"];
    device.producer = [resultSet stringForColumn:@"producer"];
    device.gua_tel = [resultSet stringForColumn:@"gua_tel"];
    device.current = [resultSet doubleForColumn:@"current"];
    device.voltage = [resultSet intForColumn:@"voltage"];
    device.protocol = [resultSet stringForColumn:@"protocol"];
    device.rID = [resultSet intForColumn:@"rID"];
    device.eNumber = [resultSet intForColumn:@"eNumber"];
    device.hTypeId = [resultSet intForColumn:@"hTypeId"];
    device.subTypeId = [resultSet intForColumn:@"subTypeId"];
    device.typeName = [resultSet stringForColumn:@"typeName"];
    device.subTypeName = [resultSet stringForColumn:@"subTypeName"];
    
    device.power = [resultSet intForColumn:@"power"];
    device.bright = [resultSet intForColumn:@"bright"];
    device.color = [resultSet stringForColumn:@"color"];
    device.position = [resultSet intForColumn:@"position"];
    device.air_model = [resultSet intForColumn:@"model"];
    device.fanspeed = [resultSet intForColumn:@"fanspeed"];
    device.temperature = [resultSet intForColumn:@"temperature"];
    
    return device;
}

+(NSArray *)devicesByRoomId:(NSInteger)roomId
{
    NSArray *devices = [self getAllDevicesInfo];
    NSMutableArray *arr = [NSMutableArray array];
    for(Device *device in devices )
    {
        if(device.rID == roomId)
        {
            [arr addObject:device];
        }
    }
    
    return [arr copy];
}

+(NSArray *)deviceOfRoom:(int) roomID
{
    NSMutableArray *devices = [NSMutableArray array];
    FMDatabase *db = [self connetdb];
    if([db open])
    {
        long masterID =  [[DeviceInfo defaultManager] masterID];
        NSString *sql;
        if ([self isWholeHouse:roomID]) {
            sql= [NSString stringWithFormat:@"SELECT ID,name,subtypeid,htypeid,rid FROM Devices where subTypeId<>6 and subTypeId<>4 and masterID = '%ld'",masterID];
        }else{
            sql= [NSString stringWithFormat:@"SELECT ID,name,subtypeid,htypeid,rid FROM Devices where rID = %d and subTypeId<>6 and subTypeId<>4 and masterID = '%ld'",roomID, masterID];
        }
        FMResultSet *resultSet = [db executeQuery:sql];
        while ([resultSet next])
        {
            Device *device = [Device new];
            device.eID = [resultSet intForColumn:@"ID"];
            device.name = [resultSet stringForColumn:@"name"];
            device.subTypeId = [resultSet intForColumn:@"subtypeid"];
            device.hTypeId = [resultSet intForColumn:@"htypeid"];
            device.rID = [resultSet intForColumn:@"rid"];
            [devices addObject:device];
        }
    }
    [db closeOpenResultSets];
    [db close];
    return [devices copy];
}

+ (BOOL)isWholeHouse:(NSInteger)eId
{
    FMDatabase *db = [self connetdb];
    int ret = 0;
    if([db open])
    {
        long masterID =  [[DeviceInfo defaultManager] masterID];
        NSString *sql = [NSString stringWithFormat:@"select isAll from rooms where ID = %ld and masterID = '%ld'",eId,masterID];
        FMResultSet *resultSet = [db executeQuery:sql];
        if ([resultSet next])
        {
            ret = [resultSet boolForColumn:@"isAll"];
        }
    }
    [db closeOpenResultSets];
    [db close];
    return ret;
}

+(NSArray *)deviceTypeIDByRoom:(NSInteger)roomID
{
    NSMutableArray *subTypes = [NSMutableArray array];
    FMDatabase *db = [self connetdb];
    if([db open])
    {
        NSString *sql = nil;

        if ([self isWholeHouse:roomID]) {
            sql = [NSString stringWithFormat:@"SELECT distinct htypeid,subtypeid FROM Devices where masterID = '%ld' and subTypeId<>6 and htypeid<>45 order by subTypeId,htypeID ASC",[[DeviceInfo defaultManager] masterID]];
        }else{
            sql = [NSString stringWithFormat:@"SELECT distinct htypeid,subtypeid FROM Devices where rID = %ld and masterID = '%ld' and subTypeId<>6 and htypeid<>45 order by subTypeId,htypeID ASC",(long)roomID,[[DeviceInfo defaultManager] masterID]];
        }
        
        FMResultSet *resultSet = [db executeQuery:sql];
        
        while ([resultSet next])
        {
            NSString *deviceUItype = [resultSet stringForColumn:@"htypeid"];
            int typeID = [[resultSet stringForColumn:@"subtypeid"] intValue];
            
            if (typeID == 1 || typeID == 7) {
                deviceUItype = [NSString stringWithFormat:@"%d",typeID];
            }
            
            if (![deviceUItype isEqualToString:@""]) {
                [subTypes addObject:deviceUItype];
            }
            
        }
        
    }
    [db closeOpenResultSets];
    [db close];
    
    return [subTypes copy];
    
}

+(NSArray *)deviceSubTypeByRoomId:(NSInteger)roomID
{
    NSMutableArray *subTypes = [NSMutableArray array];
    FMDatabase *db = [self connetdb];
    if([db open])
    {
        NSString *sql = nil;

        if ([self isWholeHouse:roomID]) {
            sql = [NSString stringWithFormat:@"SELECT distinct typeName,subtypeid FROM Devices where masterID = '%ld' and subTypeId<>6 and htypeid<>45 order by subTypeId,htypeID ASC",[[DeviceInfo defaultManager] masterID]];
        }else{
            sql = [NSString stringWithFormat:@"SELECT distinct typeName,subtypeid FROM Devices where rID = %ld and masterID = '%ld' and subTypeId<>6 and htypeid<>45 order by subTypeId,htypeID ASC",(long)roomID,[[DeviceInfo defaultManager] masterID]];
        }

        
        FMResultSet *resultSet = [db executeQuery:sql];
      
        while ([resultSet next])
        {
         
            NSString *typeName = [resultSet stringForColumn:@"typeName"];
            int typeID = [[resultSet stringForColumn:@"subtypeid"] intValue];
            
            if (typeID == 1 || typeID == 7) {
                typeName = [self transferSubType:typeID];
            }

            if (![typeName isEqualToString:@""]) {
                [subTypes addObject:typeName];
            }

        }
        
    }
    [db closeOpenResultSets];
    [db close];
    
   
    return [subTypes copy];
   
}

+(NSArray *)getAllDevices
{
    NSMutableArray *subTypes = [NSMutableArray array];
    FMDatabase *db = [self connetdb];
    if([db open])
    {
        long masterID = [[DeviceInfo defaultManager] masterID];
        
        NSString *sql = [NSString stringWithFormat:@"SELECT distinct typeName,subtypeID FROM Devices where masterID = '%ld'",masterID];
        
        FMResultSet *resultSet = [db executeQuery:sql];
        
        while ([resultSet next])
        {
            
            NSString *typeName = [resultSet stringForColumn:@"typeName"];
            int typeID = [[resultSet stringForColumn:@"subtypeid"] intValue];
            if ([self transferSubType:typeID]) {
                typeName = [self transferSubType:typeID];
            }
            
            BOOL isEqual = false;
            for (NSString *tempTypeName in subTypes) {
                if ([tempTypeName isEqualToString:typeName]) {
                    isEqual = true;
                    break;
                }
            }
            if (!isEqual) {
                [subTypes addObject:typeName];
            }
        }
        
    }
    [db closeOpenResultSets];
    [db close];
    
    
    return [subTypes copy];
    
}

+ (NSMutableArray *)typeName:(int)typeID byRoom:(int) roomID
{
    NSMutableArray *subTypes = [NSMutableArray new];
    FMDatabase *db = [self connetdb];
    if([db open])
    {
        NSString *sql ;
        if ([self isWholeHouse:roomID]) {
            sql = [NSString stringWithFormat:@"SELECT distinct typeName,htypeid FROM Devices where subtypeid = %d order by htypeID",typeID];
        }else{
            sql = [NSString stringWithFormat:@"SELECT distinct typeName,htypeid FROM Devices where subtypeid = %d and rID = '%d order by htypeID'",typeID,roomID];
        }
        FMResultSet *resultSet = [db executeQuery:sql];
        int i=0;
        while ([resultSet next])
        {
            Device *device = [Device new];
            device.typeName = [resultSet stringForColumn:@"typeName"];
            device.hTypeId = [[resultSet stringForColumn:@"htypeid"] intValue];
            device.rID = ++i;
            [subTypes addObject:device];

        }
    }
    [db closeOpenResultSets];
    [db close];
    return subTypes;
}

//根据房间ID获取该房间的所有设备ID
+ (NSArray *)deviceIdsByRoomId:(int)roomID
{
    NSMutableArray *deviceDIs = [NSMutableArray array];
    FMDatabase *db = [self connetdb];
    if([db open])
    {
        long masterID =  [[DeviceInfo defaultManager] masterID];
        NSString *sql = [NSString stringWithFormat:@"SELECT ID FROM Devices where rID = %d and masterID = '%ld'",roomID, masterID];
        
        FMResultSet *resultSet = [db executeQuery:sql];
        while ([resultSet next])
        {
            int deviceID = [resultSet intForColumn:@"ID"];
            [deviceDIs addObject:[NSNumber numberWithInt:deviceID]];
            
        }
    }
    [db closeOpenResultSets];
    [db close];
    return [deviceDIs copy];
}


+ (NSArray *)getLightTypeNameWithRoomID:(NSInteger)roomID
{
    NSMutableArray *lightNames = [NSMutableArray array];
    
    FMDatabase *db = [self connetdb];
    if([db open])
    {
        long masterID = [[DeviceInfo defaultManager] masterID];
        
        NSString *sql = [NSString stringWithFormat:@"SELECT distinct typeName FROM Devices where rID = %ld and typeName in (\"开关\",\"调色\",\"调光\") and masterID = '%ld'",(long)roomID, masterID];
        FMResultSet *resultSet = [db executeQuery:sql];
        while ([resultSet next])
        {
            NSString *light = [resultSet stringForColumn:@"typeName"];
            [lightNames addObject:light];
        }
    }

    [db closeOpenResultSets];
    [db close];
    if (lightNames.count < 1) {
        return nil;
    }
    return [lightNames copy];
}

+ (NSArray *)getLightWithTypeName:(NSString *)typeName roomID:(NSInteger)roomID
{
    NSMutableArray *lights = [NSMutableArray array];
    
    FMDatabase *db = [self connetdb];
    if([db open])
    {
        long masterID =[[DeviceInfo defaultManager] masterID];
        
        NSString *sql = [NSString stringWithFormat:@"SELECT ID FROM Devices where rID = %ld and typeName = \"%@\" and masterID = '%ld'",(long)roomID, typeName, masterID];
        FMResultSet *resultSet = [db executeQuery:sql];
        while ([resultSet next])
        {
            int lightID = [resultSet intForColumn:@"ID"];
            [lights addObject:[NSNumber numberWithInt:lightID]];
        }
    }
    

    [db closeOpenResultSets];
    [db close];
    if (lights.count < 1) {
        return nil;
    }
    return [lights copy];
}

+ (NSArray *)getCurtainWithTypeName:(NSString *)typeName roomID:(NSInteger)roomID
{
    NSMutableArray *curtains = [NSMutableArray array];
    
    FMDatabase *db = [self connetdb];
    if([db open])
    {
        long masterID = [[DeviceInfo defaultManager] masterID];
        
        NSString *sql = [NSString stringWithFormat:@"SELECT ID FROM Devices where rID = %ld and typeName = \"%@\" and masterID = '%ld'",(long)roomID, typeName, masterID];
        FMResultSet *resultSet = [db executeQuery:sql];
        while ([resultSet next])
        {
            int lightID = [resultSet intForColumn:@"ID"];
            [curtains addObject:[NSNumber numberWithInt:lightID]];
        }
    }
    
    [db closeOpenResultSets];
    [db close];
    if (curtains.count < 1) {
        return nil;
    }
    return [curtains copy];
}

+ (NSString *)deviceIDWithRoomID:(NSInteger)roomID withType:(NSString *)type
{
    NSString *deviceID = nil;
    
    FMDatabase *db = [self connetdb];
    if([db open])
    {
        long masterID =  [[DeviceInfo defaultManager] masterID];
        
        NSString *sql = [NSString stringWithFormat:@"SELECT ID FROM Devices where rID = %ld and typeName = \'%@\' and masterID = '%ld'",(long)roomID,type, masterID];
        FMResultSet *resultSet = [db executeQuery:sql];
        while ([resultSet next])
        {
            int tvID = [resultSet intForColumn:@"ID"];
            deviceID = [NSString stringWithFormat:@"%d", tvID];
        }
    }
    [db closeOpenResultSets];
    [db close];
    return deviceID;
}

+ (NSInteger)getRoomIDByDeviceID:(int)deviceID {
    NSInteger roomID = 0;
    FMDatabase *db = [self connetdb];
    if([db open])
    {
        NSString *sql = [NSString stringWithFormat:@"SELECT rID FROM Devices where ID = '%d' and masterID = '%ld'",deviceID,[[DeviceInfo defaultManager] masterID]];
        
        FMResultSet *resultSet = [db executeQuery:sql];
        if ([resultSet next])
        {
            roomID = [resultSet intForColumn:@"rID"];
        }
    }
    [db closeOpenResultSets];
    [db close];
    
    return roomID;
}

+ (NSString *)getCameraUrlByDeviceID:(int)deviceID {
    NSString *cameraURL = nil;
    FMDatabase *db = [self connetdb];
    if([db open])
    {
        NSString *sql = [NSString stringWithFormat:@"SELECT camera_url FROM Devices where ID = '%d' and masterID = '%ld'",deviceID,[[DeviceInfo defaultManager] masterID]];
        
        FMResultSet *resultSet = [db executeQuery:sql];
        if ([resultSet next])
        {
            cameraURL = [resultSet stringForColumn:@"camera_url"];
        }
    }
    [db closeOpenResultSets];
    [db close];
    
    return cameraURL;
}

+ (NSArray *)getDeviceIDsByHtypeID:(NSString *)htypeid
{
    NSMutableArray *array = [NSMutableArray array];
    FMDatabase *db = [self connetdb];
    if([db open])
    {
        NSString *sql = [NSString stringWithFormat:@"SELECT ID FROM Devices where htypeid = \'%@\' and masterID = '%ld'",htypeid,[[DeviceInfo defaultManager] masterID]];
        
        FMResultSet *resultSet = [db executeQuery:sql];
        while ([resultSet next])
        {
            int eId = [resultSet intForColumn:@"ID"];
            [array addObject:[NSNumber numberWithInt:eId]];
        }
    }
    [db closeOpenResultSets];
    [db close];
    return [array copy];
}

+(NSArray *)getDeviceByTypeName:(NSString  *)typeid andRoomID:(NSInteger)roomID
{
    NSMutableArray *array = [NSMutableArray array];
    FMDatabase *db = [self connetdb];
    if([db open])
    {
        NSString *sql = [NSString stringWithFormat:@"SELECT ID FROM Devices where rID = %ld and htypeid = \'%@\' and masterID = '%ld'",(long)roomID,typeid,[[DeviceInfo defaultManager] masterID]];
        FMResultSet *resultSet = [db executeQuery:sql];
        while ([resultSet next])
        {
            int eId = [resultSet intForColumn:@"ID"];
            [array addObject:[NSNumber numberWithInt:eId]];
        }
    }
    [db closeOpenResultSets];
    [db close];
    return [array copy];
}

+(NSArray *)getDeviceBysubTypeid:(NSString  *)subtypeid andRoomID:(NSInteger)roomID
{
    NSMutableArray *array = [NSMutableArray array];
    FMDatabase *db = [self connetdb];
    if([db open])
    {
        NSString *sql = nil;
        DeviceInfo *device = [DeviceInfo defaultManager];
        if ([self isWholeHouse:roomID]) {
            sql = [NSString stringWithFormat:@"SELECT ID FROM Devices where subtypeid = \'%@\' and masterID = '%ld'",subtypeid,[device masterID]];
        }else{
        sql = [NSString stringWithFormat:@"SELECT ID FROM Devices where rID = %ld and subtypeid = \'%@\' and masterID = '%ld'",roomID,subtypeid,[device masterID]];
        }
        
        FMResultSet *resultSet = [db executeQuery:sql];
        while ([resultSet next])
        {
            int eId = [resultSet intForColumn:@"ID"];
            [array addObject:[NSNumber numberWithInt:eId]];
        }
    }
    [db closeOpenResultSets];
    [db close];
    return [array copy];
}

+(NSArray *)getDeviceByTypeName:(NSString  *)typeName
{
    NSMutableArray *array = [NSMutableArray array];
    FMDatabase *db = [self connetdb];
    if([db open])
    {
        NSString *sql = [NSString stringWithFormat:@"SELECT ID FROM Devices where subTypeName = \'%@\' and masterID = '%ld'",typeName,[[DeviceInfo defaultManager] masterID]];
        
        FMResultSet *resultSet = [db executeQuery:sql];
        while ([resultSet next])
        {
            int eId = [resultSet intForColumn:@"ID"];
            [array addObject:[NSNumber numberWithInt:eId]];
        }
    }
    [db closeOpenResultSets];
    [db close];
    return [array copy];
}

+(NSString *)getEType:(NSInteger)eID
{
    NSString * htypeID=nil;
    FMDatabase *db = [self connetdb];
    if([db open])
    {
        long masterID =[[DeviceInfo defaultManager] masterID];
        
        NSString *sql = [NSString stringWithFormat:@"SELECT htypeID FROM Devices where ID = %ld and masterID = '%ld'",(long)eID, masterID];
        FMResultSet *resultSet = [db executeQuery:sql];
        if ([resultSet next])
        {
            htypeID = [resultSet stringForColumn:@"htypeID"];
        }
    }
    [db closeOpenResultSets];
    [db close];
    return htypeID;
}

+(NSString *)getENumber:(NSInteger)eID
{
    NSString * enumber=nil;
    FMDatabase *db = [self connetdb];
    if([db open])
    {
        long masterID = [[DeviceInfo defaultManager] masterID];
        
        NSString *sql = [NSString stringWithFormat:@"SELECT enumber FROM Devices where ID = %ld and masterID = '%ld'",(long)eID, masterID];
        FMResultSet *resultSet = [db executeQuery:sql];
        if ([resultSet next])
        {
            enumber = [resultSet stringForColumn:@"enumber"];
        }
    }
    [db closeOpenResultSets];
    [db close];
    return enumber;
}

+(NSString *)getDeviceIDByENumber:(NSInteger)eID
{
    NSString *deviceID=nil;
    FMDatabase *db = [self connetdb];
    if([db open])
    {
        long masterID = [[DeviceInfo defaultManager] masterID];
        NSString *sql = [NSString stringWithFormat:@"SELECT ID FROM Devices where upper(enumber) = upper('%04lx') and masterID='%ld'",(long)eID, masterID];
        FMResultSet *resultSet = [db executeQuery:sql];
        if ([resultSet next])
        {
            deviceID = [resultSet stringForColumn:@"ID"];
        }
    }
    [db closeOpenResultSets];
    [db close];
    return deviceID;
}

+ (NSArray *) fetchScenes:(NSString *)name
{
    long masterID =  [[DeviceInfo defaultManager] masterID];
    
    NSString *sql=[NSString stringWithFormat:@"select id,roomName,name from Scenes where name like '%%%@%%' and masterID = '%ld'" , name , masterID];
    NSMutableArray *scenes= [NSMutableArray new];
    FMDatabase *db = [self connetdb];
    if([db open])
    {
        FMResultSet *resultSet = [db executeQuery:sql];
        
        while([resultSet next])
        {
            Scene *scene = [Scene new];
            scene.sceneID = [resultSet intForColumn:@"id"];
            scene.roomName = [resultSet stringForColumn:@"roomName"];
            scene.sceneName = [resultSet stringForColumn:@"name"];
            [scenes addObject:scene];
        }
    }
    [db closeOpenResultSets];
    [db close];
    return scenes;
}

+(int) getReadOnly:(int)sceneid
{
    long masterID =  [[DeviceInfo defaultManager] masterID];
    
    NSString *sql=[NSString stringWithFormat:@"select stype from Scenes where id=%d and masterID = '%ld'" ,sceneid, masterID];
    
    int readonly=0;
    FMDatabase *db = [self connetdb];
    if([db open])
    {
        FMResultSet *resultSet = [db executeQuery:sql];
        
        if([resultSet next])
        {
            readonly = [resultSet intForColumn:@"stype"];
        }
    }
    [db closeOpenResultSets];
    [db close];
    return readonly;
}

+(NSString *) getSnumber:(int)sceneid
{
    long masterID = [[DeviceInfo defaultManager] masterID];
    
    NSString *sql=[NSString stringWithFormat:@"select snumber from Scenes where id=%d and masterID = '%ld'" ,sceneid, masterID];
    
    NSString *snumber=nil;
    FMDatabase *db = [self connetdb];
    if([db open])
    {
        FMResultSet *resultSet = [db executeQuery:sql];
        
        if([resultSet next])
        {
            snumber = [resultSet stringForColumn:@"snumber"];
        }
    }
    [db closeOpenResultSets];
    [db close];
    return snumber;
}

+(int) getRoomIDByNumber:(NSString *)enumber
{
    long masterID = [[DeviceInfo defaultManager] masterID];
    
    NSString *sql=[NSString stringWithFormat:@"select rId from devices where enumber='%@' and masterID = '%ld'",enumber, masterID];
    
    int roomId=0;
    FMDatabase *db = [self connetdb];
    if([db open])
    {
        FMResultSet *resultSet = [db executeQuery:sql];
        
        if([resultSet next])
        {
            roomId = [resultSet intForColumn:@"rId"];
        }
    }
    [db closeOpenResultSets];
    [db close];
    return roomId;
    
}

+ (int)getRoomAuthority:(int)roomID {
    long masterID =  [[DeviceInfo defaultManager] masterID];
    
    NSString *sql = [NSString stringWithFormat:@"select openforcurrentuser from Rooms where masterID = '%ld' and ID = '%d'", masterID, roomID];
    
    int roomAuthority = 0;
    FMDatabase *db = [self connetdb];
    if([db open])
    {
        FMResultSet *resultSet = [db executeQuery:sql];
        
        if([resultSet next])
        {
            roomAuthority = [resultSet intForColumn:@"openforcurrentuser"];
        }
    }
    [db closeOpenResultSets];
    [db close];
    return roomAuthority;
}

+ (int)getRoomID:(int)sceneID
{
    long masterID =[[DeviceInfo defaultManager] masterID];
    
    NSString *sql=[NSString stringWithFormat:@"select rId from Scenes where ID=%d and masterID = '%ld'",sceneID, masterID];
    
    int roomId=0;
    FMDatabase *db = [self connetdb];
    if([db open])
    {
        FMResultSet *resultSet = [db executeQuery:sql];
        
        if([resultSet next])
        {
            roomId = [resultSet intForColumn:@"rId"];
        }
    }
    [db closeOpenResultSets];
    [db close];
    return roomId;

}

+(NSString*)getSceneName:(int)sceneID
{
    long masterID =  [[DeviceInfo defaultManager] masterID];
    
    NSString *sql=[NSString stringWithFormat:@"select NAME from Scenes where ID=%d and masterID = '%ld'",sceneID, masterID];
    
    NSString *sceneName;
    FMDatabase *db = [self connetdb];
    if([db open])
    {
        FMResultSet *resultSet = [db executeQuery:sql];
        
        if([resultSet next])
        {
            sceneName = [resultSet stringForColumn:@"NAME"];
        }
    }
    [db closeOpenResultSets];
    [db close];
    
    return sceneName;
   
}

+(int)saveMaxSceneId:(Scene *)scene name:(NSString *)name pic:(NSString *)img
{
    int sceneID=1;
    NSArray *devices = scene.devices;
    NSMutableString *eIdStr = [[NSMutableString alloc]init];
    for(NSDictionary *deviceDic in devices)
    {
        [eIdStr appendString:[NSString stringWithFormat:@"%@,",deviceDic[@"deviceID"]]];
    }
    FMDatabase *db = [self connetdb];
    if([db open])
    {
        long masterID =  [[DeviceInfo defaultManager] masterID];
        
        NSString *sql = [NSString stringWithFormat:@"select max(id) as id from scenes where masterID = '%ld'", masterID];
        FMResultSet *resultSet = [db executeQuery:sql];
        if ([resultSet next])
        {
            sceneID = [resultSet intForColumn:@"ID"]+1;
        }
        
        sql=[NSString stringWithFormat:@"insert into Scenes values(%d,'%@','','%@',%ld,%d,null,null,null,'%ld',%d)",sceneID,name,img,(long)scene.roomID,2, masterID,0];
        [db executeUpdate:sql];
    }
    [db closeOpenResultSets];
    [db close];

    return sceneID;
}

+ (NSArray *)getCatalogWithRoomID:(int)roomID
{
    NSMutableArray *catalogs = [NSMutableArray new];
    NSString *sql;
    if ([self isWholeHouse:roomID]) {
        sql = @"select subtypename,subtypeid from devices where subtypeid<>6 and subtypeid<>4 and subtypeid<>0  group by subtypeid";
    }else{
        sql = [NSString stringWithFormat:@"select subtypename,subtypeid from devices where subtypeid<>6 and subtypeid<>4 and subtypeid<>0 and rid = %d group by subtypeid" ,roomID];
    }
    
    FMDatabase *db = [self connetdb];
    if([db open])
    {
        FMResultSet *resultSet = [db executeQuery:sql];
        
        while ([resultSet next])
        {
            Device *cata = [Device new];
            cata.subTypeName = [resultSet stringForColumn:@"subtypename"];
            cata.subTypeId = [[resultSet stringForColumn:@"subtypeid"] intValue];
            [catalogs addObject:cata];
        }
    }
    [db closeOpenResultSets];
    [db close];
    
    return catalogs;
}

+(NSArray *)getAllDeviceSubTypes
{
    NSMutableArray *subTypeNames = [NSMutableArray array];
    NSMutableArray *deviceIDArr = [NSMutableArray array];
    
    FMDatabase *db = [self connetdb];
    
    if([db open])
    {
        long masterID =  [[DeviceInfo defaultManager] masterID];
        
        NSString *sql =[NSString stringWithFormat: @"SELECT ID FROM Devices where masterID = '%ld'", masterID];
        
        FMResultSet *resultSet = [db executeQuery:sql];
        while ([resultSet next])
        {
            int deviceID = [resultSet intForColumn:@"ID"];
            
            [deviceIDArr addObject:[NSNumber numberWithInt:deviceID]];
        }
    }
    [db closeOpenResultSets];
    [db close];
    if (deviceIDArr.count < 1) {
        return nil;
    }

    NSArray *deviceIDs = [deviceIDArr copy];
    for(NSString *deviceID in deviceIDs)
    {
        NSString *subTypeName = [self getDeviceSubTypeNameWithID:[deviceID intValue]];
        BOOL isSame = false;
        for (NSString *tempSubTypeName in subTypeNames) {
            if ([tempSubTypeName isEqualToString:subTypeName]) {
                isSame = true;
                break;
            }
        }
        if (isSame) {
            continue;
        }
        
        [subTypeNames addObject:subTypeName];
        
    }
    if(subTypeNames.count < 1)
    {
        return  nil;
    }
    
    return subTypeNames;
}

+(NSArray *)getAllDevicesIds
{
    NSMutableArray *deviceIDs = [NSMutableArray array];
    
    FMDatabase *db = [self connetdb];
    
    if([db open])
    {
        long masterID =  [[DeviceInfo defaultManager] masterID];
        
        NSString *sql = [NSString stringWithFormat:@"SELECT eId FROM Scenes where masterID = '%ld'", masterID];
        
        FMResultSet *resultSet = [db executeQuery:sql];
        while ([resultSet next])
        {
            NSString *deviceID = [resultSet stringForColumn:@"eId"];
            
            [deviceIDs addObject:deviceID];
        }
    }
    [db closeOpenResultSets];
    [db close];
    if (deviceIDs.count < 1) {
        return nil;
    }
    
    return [deviceIDs copy];
}

//根据roomID 从Devices 表 查询出 subTypeName字段(可能有重复数据，要去重)
+ (NSArray *)getDevicesSubTypeNamesWithRoomID:(int)roomID {
    NSMutableArray *subTypeNames = [NSMutableArray array];
    FMDatabase *db = [self connetdb];
    
    if([db open])
    {
        NSString *sql = nil;
        if ([self isWholeHouse:roomID]) {
            sql = [NSString stringWithFormat:@"SELECT DISTINCT subTypeName FROM Devices where masterID = '%ld' and subtypeid<>6",[[DeviceInfo defaultManager] masterID]];
        }else{
            sql = [NSString stringWithFormat:@"SELECT DISTINCT subTypeName FROM Devices where rID = %d and masterID = '%ld' and subtypeid<>6",roomID,[[DeviceInfo defaultManager] masterID]];
        }
        
        FMResultSet *resultSet = [db executeQuery:sql];
        while([resultSet next])
        {
            NSString *subTypeName = [resultSet stringForColumn:@"subTypeName"];
            if (subTypeName) {
                [subTypeNames addObject:subTypeName];
            }
            
        }
    }
    [db closeOpenResultSets];
    [db close];
    return subTypeNames;
}

+ (NSArray *)allTypeinRoom:(int)roomID
{
    NSMutableArray *subTypeNames = [NSMutableArray array];
    FMDatabase *db = [self connetdb];
    
    if([db open])
    {
        NSString *sql = nil;
        if ([self isWholeHouse:roomID]) {
            sql = [NSString stringWithFormat:@"SELECT DISTINCT subTypeName,subtypeid FROM Devices where masterID = '%ld' and subtypeid<>6 and subTypeId<>4",[[DeviceInfo defaultManager] masterID]];
        }else{
            sql = [NSString stringWithFormat:@"SELECT DISTINCT subTypeName,subtypeid FROM Devices where rID = %d and masterID = '%ld' and subtypeid<>6 and subTypeId<>4",roomID,[[DeviceInfo defaultManager] masterID]];
        }
        
        FMResultSet *resultSet = [db executeQuery:sql];
        while([resultSet next])
        {
            Device *device = [Device new];
            NSString *subTypeName = [resultSet stringForColumn:@"subTypeName"];
            if (subTypeName) {
                device.subTypeName = subTypeName;
                device.subTypeId = [resultSet intForColumn:@"subTypeid"];
                [subTypeNames addObject:device];
            }
            
        }
    }
    [db closeOpenResultSets];
    [db close];
    return subTypeNames;
}

+ (NSArray *)getDevicesIDWithRoomID:(int)roomID SubTypeName:(NSString *)subTypeName
{
    NSMutableArray *htypeIDs = [NSMutableArray array];
    FMDatabase *db = [self connetdb];
    
    if([db open])
    {
        NSString *sql = nil;
        if ([self isWholeHouse:roomID]) {
        sql = [NSString stringWithFormat:@"SELECT ID FROM Devices where subTypeName = '%@' and masterID = '%ld'",subTypeName,[[DeviceInfo defaultManager] masterID]];
        }else{
        sql = [NSString stringWithFormat:@"SELECT ID FROM Devices where rID = %d and subTypeName = '%@' and masterID = '%ld'",roomID,subTypeName,[[DeviceInfo defaultManager] masterID]];
        }
        
        FMResultSet *resultSet = [db executeQuery:sql];
        while([resultSet next])
        {
            int eId = [resultSet intForColumn:@"ID"];
            if (eId) {
                 [htypeIDs addObject:[NSNumber numberWithInt:eId]];
            }
            
        }
    }
    [db closeOpenResultSets];
    [db close];
    return [htypeIDs copy];

}
+ (NSString *)getDeviceSubTypeNameWithID:(int)ID
{
    NSString *subTypeName = nil;
    
    FMDatabase *db = [self connetdb];
    
    if([db open])
    {
        long masterID = [[DeviceInfo defaultManager] masterID];
        
        NSString *sql = [NSString stringWithFormat:@"SELECT subTypeName FROM Devices where ID = %d and masterID = '%ld'",ID, masterID];
        
        FMResultSet *resultSet = [db executeQuery:sql];
        if ([resultSet next])
        {
            subTypeName = [resultSet stringForColumn:@"subTypeName"];
        }
    }
    [db closeOpenResultSets];
    [db close];
    return subTypeName;
}

+(NSString *)getDevicePicByID:(int)sceneID
{
    NSString *subTypeName = nil;
    
    FMDatabase *db = [self connetdb];
    
    if([db open])
    {
        long masterID =  [[DeviceInfo defaultManager] masterID];
        
        NSString *sql = [NSString stringWithFormat:@"SELECT pic FROM Scenes where ID = %d and masterID = '%ld'",sceneID, masterID];
        
        FMResultSet *resultSet = [db executeQuery:sql];
        if ([resultSet next])
        {
            subTypeName = [resultSet stringForColumn:@"pic"];
        }
    }
    [db closeOpenResultSets];
    [db close];
    return subTypeName;
}

+ (NSArray *)getDeviceIDWithRoomID:(int)roomID sceneID:(int)sceneID
{
    NSArray *deviceIDs;
    
    FMDatabase *db = [self connetdb];
    
    if([db open])
    {
        long masterID =  [[DeviceInfo defaultManager] masterID];
        
        NSString *sql = [NSString stringWithFormat:@"SELECT eId FROM Scenes where rId = %d and ID = %d masterID = '%ld'",roomID, sceneID, masterID];
        
        FMResultSet *resultSet = [db executeQuery:sql];
        NSString *deviceIDStr;
        while ([resultSet next])
        {
            deviceIDStr = [resultSet stringForColumn:@"eId"];
        }
        
       deviceIDs = [deviceIDStr componentsSeparatedByString:@","];
    
    }
    [db closeOpenResultSets];
    [db close];
    if (deviceIDs.count < 1) {
        return nil;
    }
    
    return [deviceIDs copy];
}

+ (NSArray *)getDimmerByRoom:(int) roomID
{
    NSMutableArray *lights = [NSMutableArray new];
    
    FMDatabase *db = [self connetdb];
    if([db open])
    {
        long masterID =  [[DeviceInfo defaultManager] masterID];
        
        NSString *sql = [NSString stringWithFormat:@"SELECT id FROM devices where rid=%d and htypeid ='%@' and masterID = '%ld'",roomID,DIMMER_SUB_TYPE, masterID];
        FMResultSet *resultSet = [db executeQuery:sql];
        while ([resultSet next])
        {
            [lights addObject:[resultSet stringForColumn:@"id"]];
        }
    }
    [db closeOpenResultSets];
    [db close];
    return lights;
}

+ (NSArray *)getColourLightByRoom:(int) roomID
{
    NSMutableArray *lights = [NSMutableArray new];
    
    FMDatabase *db = [self connetdb];
    if([db open])
    {
        long masterID = [[DeviceInfo defaultManager] masterID];
        
        NSString *sql = [NSString stringWithFormat:@"SELECT id FROM devices where rid=%d and htypeid ='%@' and masterID = '%ld'",roomID,COLORLIGHT_SUB_TYPE, masterID];
        FMResultSet *resultSet = [db executeQuery:sql];
        while ([resultSet next])
        {
            [lights addObject:[resultSet stringForColumn:@"id"]];
        }
    }
    [db closeOpenResultSets];
    [db close];
    return lights;
}
+ (NSArray *)getSwitchLightByRoom:(int)roomID
{
    NSMutableArray *lights = [NSMutableArray new];
    
    FMDatabase *db = [self connetdb];
    if([db open])
    {
        long masterID = [[DeviceInfo defaultManager] masterID];
        
        NSString *sql = [NSString stringWithFormat:@"SELECT id FROM devices where rid=%d and htypeid ='%@' and masterID = '%ld'",roomID,SWITCHLIGHT_SUB_TYPE, masterID];
        FMResultSet *resultSet = [db executeQuery:sql];
        while ([resultSet next])
        {
            [lights addObject:[resultSet stringForColumn:@"id"]];
        }
    }
    [db closeOpenResultSets];
    [db close];
    return lights;
}

// 获取“照明”设备（灯，窗帘）
+ (NSArray *)getLightDevicesByRoom:(int)roomID
{
    NSMutableArray *lights = [NSMutableArray new];
    
    FMDatabase *db = [self connetdb];
    if([db open])
    {
        long masterID = [[DeviceInfo defaultManager] masterID];
        
        NSString *sql = [NSString stringWithFormat:@"SELECT id FROM devices where rid=%d and (subTypeid ='%@' or subTypeid ='%@') and masterID = '%ld'",roomID,LIGHT_DEVICE_TYPE,CURTAIN_DEVICE_TYPE, masterID];
        FMResultSet *resultSet = [db executeQuery:sql];
        while ([resultSet next])
        {
            [lights addObject:[resultSet stringForColumn:@"id"]];
        }
    }
    [db closeOpenResultSets];
    [db close];
    return lights;
}

+(Device *)singleLightByRoom:(int) roomID
{
    Device *light = [Device new];
    
    FMDatabase *db = [self connetdb];
    if([db open])
    {
        NSString *sql;
        if ([self isWholeHouse:roomID]) {
            sql = [NSString stringWithFormat:@"SELECT id,name FROM devices where subTypeid ='%@'",LIGHT_DEVICE_TYPE];
        }else{
            sql = [NSString stringWithFormat:@"SELECT id,name FROM devices where rid=%d and subTypeid ='%@'",roomID,LIGHT_DEVICE_TYPE];
        }
        FMResultSet *resultSet = [db executeQuery:sql];
        if ([resultSet next])
        {
            light.eID = [[resultSet stringForColumn:@"id"] intValue];
            light.name = [resultSet stringForColumn:@"name"];
        }
    }
    [db closeOpenResultSets];
    [db close];
    return light;
}

//多媒体UI菜单
+(NSArray *)mediaDeviceNamesByRoom:(int)roomID
{
    NSMutableArray *devices = [NSMutableArray new];
    
    FMDatabase *db = [self connetdb];
    if([db open])
    {
        NSString *sql;
        if ([self isWholeHouse:roomID]) {
            sql = [NSString stringWithFormat:@"select id,typename,htypeid from devices where subtypeid = 3 order by htypeID"];
        }else{
            sql = [NSString stringWithFormat:@"select id,typename,htypeid from devices where subtypeid = 3 and rid=%d order by htypeID",roomID];
        }
        FMResultSet *resultSet = [db executeQuery:sql];
        while ([resultSet next])
        {
            Device *device = [Device new];
            device.typeName =[resultSet stringForColumn:@"typename"];
            device.hTypeId = [[resultSet stringForColumn:@"hTypeId"] intValue];
            device.eID = [[resultSet stringForColumn:@"Id"] intValue];
            [devices addObject:device];
        }
    }
    [db closeOpenResultSets];
    [db close];
    return devices;
}

//智能单品菜单
+(NSArray *)singleProductByRoom:(int)roomID
{
    NSMutableArray *devices = [NSMutableArray new];
    
    FMDatabase *db = [self connetdb];
    if([db open])
    {
        NSString *sql;
        if ([self isWholeHouse:roomID]) {
            sql = [NSString stringWithFormat:@"select id,name,htypeid from devices where subtypeid = 5"];
        }else{
            sql = [NSString stringWithFormat:@"select id,name,htypeid from devices where subtypeid = 5 and rid=%d",roomID];
        }
        FMResultSet *resultSet = [db executeQuery:sql];
        while ([resultSet next])
        {
            Device *device = [Device new];
            device.typeName =[resultSet stringForColumn:@"name"];
            device.hTypeId = [[resultSet stringForColumn:@"hTypeId"] intValue];
            device.eID = [[resultSet stringForColumn:@"Id"] intValue];
            [devices addObject:device];
        }
    }
    [db closeOpenResultSets];
    [db close];
    return devices;
}

+ (NSArray *)getCurtainByRoom:(int) roomID
{
    NSMutableArray *curtains = [NSMutableArray new];
    
    FMDatabase *db = [self connetdb];
    if([db open])
    {
        long masterID = [[DeviceInfo defaultManager] masterID];
        
        NSString *sql = [NSString stringWithFormat:@"SELECT id FROM devices where rid=%d and htypeid ='%@' and masterID = '%ld'",roomID,CURTAINS_SUB_TYPE, masterID];
        FMResultSet *resultSet = [db executeQuery:sql];
        while ([resultSet next])
        {
            [curtains addObject:[resultSet stringForColumn:@"id"]];
        }
    }
    [db closeOpenResultSets];
    [db close];
    return curtains;
}

+ (NSArray *)getAirDeviceByRoom:(int) roomID
{
    NSMutableArray *curtains = [NSMutableArray new];
    
    FMDatabase *db = [self connetdb];
    if([db open])
    {
        long masterID =  [[DeviceInfo defaultManager] masterID];
        
        NSString *sql = [NSString stringWithFormat:@"SELECT id FROM devices where rid=%d and htypeid ='%@' and masterID = '%ld'",roomID,AIR_SUB_TYPE, masterID];
        FMResultSet *resultSet = [db executeQuery:sql];
        while ([resultSet next])
        {
            [curtains addObject:[resultSet stringForColumn:@"id"]];
        }
    }
    [db closeOpenResultSets];
    [db close];
    return curtains;

}

+ (Device *)getDeviceWithDeviceID:(int) deviceID
{
    Device *device = nil;
    
    FMDatabase *db = [self connetdb];
    if([db open])
    {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM Devices where ID = %d and masterID = '%ld'",deviceID, [[DeviceInfo defaultManager] masterID]];
        FMResultSet *resultSet = [db executeQuery:sql];
        if ([resultSet next])
        {
            device = [self deviceMdoelByFMResultSet:resultSet];
        }
    }
    [db closeOpenResultSets];
    [db close];
    return device;
}
+ (Device *)getDeviceWithDeviceHtypeID:(int) htypeID
{
    Device *device = nil;
    
    FMDatabase *db = [self connetdb];
    if([db open])
    {
        long masterID =[[DeviceInfo defaultManager] masterID];
        
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM Devices where ID = %d and masterID = '%ld'",htypeID, masterID];
        FMResultSet *resultSet = [db executeQuery:sql];
        if ([resultSet next])
        {
            device = [self deviceMdoelByFMResultSet:resultSet];
        }
    }
    [db closeOpenResultSets];
    [db close];
    return device;

}

+ (NSArray *)queryChat:(NSString *) userid
{
    NSMutableArray *temp = [NSMutableArray new];
    
    FMDatabase *db = [self connetdb];
    if([db open])
    {     
        NSString *sql = [NSString stringWithFormat:@"SELECT nickname,portrait FROM chats where user_id = '%@'",userid];
        FMResultSet *resultSet = [db executeQuery:sql];
        if ([resultSet next])
        {
            [temp addObject: [resultSet stringForColumn:@"nickname"]];
            [temp addObject: [resultSet stringForColumn:@"portrait"]];
        }
    }
    [db closeOpenResultSets];
    [db close];
    return temp;
}

+ (NSArray *)queryAllChat
{
    NSMutableArray *temp = [NSMutableArray new];
    
    FMDatabase *db = [self connetdb];
    if([db open])
    {
        NSString *sql = [NSString stringWithFormat:@"SELECT nickname,portrait FROM chats"];
        FMResultSet *resultSet = [db executeQuery:sql];
        while ([resultSet next])
        {
            [temp addObject: @{@"nickname":[resultSet stringForColumn:@"nickname"],@"portrait":[resultSet stringForColumn:@"portrait"]}];
        }
    }
    [db closeOpenResultSets];
    [db close];
    return temp;
}

+ (NSArray *)getDeviceWithRoomID:(int)roomID sceneID:(int)sceneID
{
    NSMutableArray *devices = [NSMutableArray array];
    
    NSArray *deviceIDs = [self getDeviceIDWithRoomID:roomID sceneID:sceneID];
    if(deviceIDs.count == 0 || deviceIDs == nil)
    {
        return 0;
    }
    for (NSString *deviceID in deviceIDs) {
        Device *device = [self getDeviceWithDeviceID:[deviceID intValue]];
        if([deviceID isEqualToString:@""]|| deviceID == nil)
        {
            break;
        }
        [devices addObject:device];
    }
    
    if (devices.count < 1) {
        return 0;
    }
    
    return [devices copy];
}

+(NSString *) getDeviceType:(NSString *)deviceID subTypeName:(NSString *)subTypeName
{
    NSString *typeName = [self getDeviceTypeNameWithID:deviceID subTypeName:subTypeName];
    int typeID = 0;
    FMDatabase *db = [SQLManager connetdb];
    if([db open])
    {
        NSString *sql = [NSString stringWithFormat:@"select subtypeid from devices where id = %@",deviceID];
        FMResultSet *resultSet = [db executeQuery:sql];
        if([resultSet next]){
            typeID =  [[resultSet stringForColumn:@"subtypeid"] intValue];
        }
    }
    
    [db closeOpenResultSets];
    [db close];
    
    if (typeID == 1 || typeID == 7) {
        return [self transferSubType:typeID];
    }
    
    return typeName;
}

+(NSString *) transferSubType:(int)typeID{
    FMDatabase *db = [SQLManager connetdb];
    if([db open])
    {
        NSString *sql = [NSString stringWithFormat:@"select catalogName from catalog where id = %d",typeID];
        FMResultSet *resultSet = [db executeQuery:sql];
        if([resultSet next]){
            return [resultSet stringForColumn:@"catalogName"];
        }
    }
    
    [db closeOpenResultSets];
    [db close];
    return @"";
}

+ (NSArray *)getDeviceTypeNameWithRoomID:(int)roomID sceneID:(int)sceneID subTypeName:(NSString *)subTypeName
{
    NSMutableArray *typeNames = [NSMutableArray array];
    
    NSArray *deviceIDs = [self getDeviceIDWithRoomID:roomID sceneID:sceneID];
    
    for (NSString *deviceID in deviceIDs) {
        NSString *typeName = [self getDeviceType:deviceID subTypeName:subTypeName];
        
        BOOL isSame = false;
        for (NSString *tempTypeName in typeNames) {
            if ([tempTypeName isEqualToString:typeName]) {
                isSame = true;
                break;
            }
        }
        if (isSame) {
            continue;
        }
        if([typeName isEqualToString:@""] || typeName == nil)
        {
            continue;
        }
         [typeNames addObject:typeName];
        
    }
    
    if (typeNames.count < 1) {
        return nil;
    }
    
    return [typeNames copy];
}


+(NSArray *)getDeviceTypeName:(int)rID subTypeName:(NSString *)subTypeName
{
    NSMutableArray *typeNames = [NSMutableArray array];
    
    NSArray *deviceIDs = [SQLManager deviceIdsByRoomId:rID];
    
    for (NSString *deviceID in deviceIDs) {
        NSString *typeName = [self getDeviceType:deviceID subTypeName:subTypeName];
        
        BOOL isSame = false;
        for (NSString *tempTypeName in typeNames) {
            if ([tempTypeName isEqualToString:typeName]) {
                isSame = true;
                break;
            }
        }
        if (isSame) {
            continue;
        }
        if([typeName isEqualToString:@""] || typeName == nil)
        {
            continue;
        }
        [typeNames addObject:typeName];
        
    }
    
    if (typeNames.count < 1) {
        return nil;
    }
    
    return [typeNames copy];

}

+(NSArray *)getAllDeviceNameBysubType:(NSString *)subTypeName
{
    NSMutableArray *typeNames = [NSMutableArray array];
    NSArray *deviceIDs = [self getAllDevicesIds];
    for (NSString *deviceID in deviceIDs) {
        NSString *typeName = [self getDeviceTypeNameWithID:deviceID subTypeName:subTypeName];
        BOOL isSame = false;
        for (NSString *tempTypeName in typeNames) {
            if ([tempTypeName isEqualToString:typeName]) {
                isSame = true;
                break;
            }
        }
        if (isSame) {
            continue;
        }
        
        [typeNames addObject:typeName];
    }
    
    if (typeNames.count < 1) {
        return nil;
    }
    
    return [typeNames copy];
}
+ (NSString *)getDeviceTypeNameWithID:(NSString *)ID subTypeName:(NSString *)subTypeName
{
    NSString *typeName = nil;
    
    FMDatabase *db = [self connetdb];
    
    if([db open])
    {
        NSString *sql = [NSString stringWithFormat:@"SELECT typeName FROM Devices where ID = %@ and subTypeName = '%@' and masterID = '%ld'",ID, subTypeName,[[DeviceInfo defaultManager] masterID]];
        
        FMResultSet *resultSet = [db executeQuery:sql];
        while ([resultSet next])
        {
            typeName = [resultSet stringForColumn:@"typeName"];
        }
    }
    [db closeOpenResultSets];
    [db close];
    return typeName;
}

+ (NSArray *)getDeviceIDBySubName:(NSString *)subName
{
    NSMutableArray *subNames = [NSMutableArray array];
    
    FMDatabase *db = [self connetdb];
    
    if([db open])
    {
        long masterID = [[DeviceInfo defaultManager] masterID];
        
        NSString *sql = [NSString stringWithFormat:@"SELECT ID FROM Devices where subTypeName = '%@' and masterID = '%ld'", subName, masterID];
        
        FMResultSet *resultSet = [db executeQuery:sql];
        while ([resultSet next])
        {
            NSString *ID = [resultSet stringForColumn:@"ID"];
            [subNames addObject:ID];
        }
    }
    [db closeOpenResultSets];
    [db close];
    if (subNames.count < 1) {
        return nil;
    }
    
    return [subNames copy];
}

//根据场景ID得到改场景下的所有的设备ID
+(NSArray *)getDeviceIDsBySeneId:(int)SceneId
{
    //NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"255_216" ofType:@"plist"]];
    
    NSString *hostID = SCENE_FILE_NAME;
    
    //读取场景文件
    NSString *sceneFile = [NSString stringWithFormat:@"%@_%d.plist",hostID,SceneId];
    NSString *scenePath=[[IOManager scenesPath] stringByAppendingPathComponent:sceneFile];
    NSDictionary *dictionary = [[NSDictionary alloc] initWithContentsOfFile:scenePath];
  
    if(dictionary)
    {
        
        NSMutableArray *deviceIds=[[NSMutableArray alloc] init];
        for (NSDictionary *dic in [dictionary objectForKey:@"devices"])
        {
            int deviceID = 0;
        
            if([dic objectForKey:@"deviceID"])
            {
                deviceID = [dic[@"deviceID"] intValue];
               
            }
            [deviceIds addObject:[NSNumber numberWithInt:deviceID]];
            
        }
        return [deviceIds copy];
    }else{
    
        return nil;
    }
    
}

//根据场景ID，得到该场景下的所有设备SubTypeName
+(NSArray *)getSubTydpeBySceneID:(int)sceneId
{
    NSMutableArray *subTypeNames = [NSMutableArray array];

    NSArray *deviceIDs = [self getDeviceIDsBySeneId:sceneId];
    for(NSNumber *deviceID in deviceIDs)
    {
        if(deviceID)
        {
            NSString *subTypeName = [self getDeviceSubTypeNameWithID:[deviceID intValue]];
            if(subTypeName)
            {
                BOOL isSame = false;
                for(NSString *tempSubTypeName in subTypeNames) {
                    if ([tempSubTypeName isEqualToString:subTypeName]) {
                        isSame = true;
                        break;
                    }
                }
                if (isSame) {
                    continue;
                }
                
                [subTypeNames addObject:subTypeName];

            }
        }
    }
    if(subTypeNames.count < 1)
    {
        return nil;
    }
    return [subTypeNames copy];
}

//根据subTypeName 从Devices表 查询typeName(要去重)
+ (NSArray *)getDeviceTypeNameWithSubTypeName:(NSString *)subTypeName {
    NSMutableArray *typeNames = [NSMutableArray array];
    
    FMDatabase *db = [self connetdb];
    
    if([db open])
    {
        long masterID = [[DeviceInfo defaultManager] masterID];
        
        NSString *sql = [NSString stringWithFormat:@"SELECT DISTINCT typeName,subtypeid FROM Devices where subTypeName = '%@' and masterID = '%ld'", subTypeName,  masterID];
        
        FMResultSet *resultSet = [db executeQuery:sql];
        while ([resultSet next])
        {
           NSString *typeName = [resultSet stringForColumn:@"typeName"];
            int typeID = [[resultSet stringForColumn:@"subtypeid"] intValue];
            if ([self transferSubType:typeID]) {
                [typeNames addObject:[self transferSubType:typeID]];
            }else {
                [typeNames addObject:typeName];
            }
            
        }
    }
    [db closeOpenResultSets];
    [db close];
    return typeNames;
}

//根据场景ID，得到该场景下的设备子类
+ (NSArray *)getDeviceTypeNameWithScenID:(int)sceneId subTypeName:(NSString *)subTypeName
{
    NSMutableArray *typeNames = [NSMutableArray array];
    NSArray *deviceIDs = [self getDeviceIDsBySeneId:sceneId];
    for(NSString *devcieID in deviceIDs)
    {
        if(devcieID)
        {
            NSString *typeName = [self getDeviceType:devcieID subTypeName:subTypeName];

            BOOL isSame = false;
            for (NSString *tempTypeName in typeNames) {
                if ([tempTypeName isEqualToString:typeName]) {
                    isSame = true;
                    break;
                }
            }
            if (isSame) {
                continue;
            }
            if([typeName isEqualToString:@""] || typeName == nil)
            {
                continue;
            }
            [typeNames addObject:typeName];
        }
        
    }
    if (typeNames.count < 1) {
        return nil;
    }
    
    return [typeNames copy];
}

+(void)initSQlite
{
    FMDatabase *db = [self connetdb];
    if ([db open]) {
        
        NSString *sqlRoom=@"CREATE TABLE IF NOT EXISTS Rooms(ID INT PRIMARY KEY NOT NULL, NAME TEXT NOT NULL, \"PM25\" INTEGER, \"NOISE\" INTEGER, \"TEMPTURE\" INTEGER, \"CO2\" INTEGER, \"moisture\" INTEGER, \"imgUrl\" TEXT,\"ibeacon\" INTEGER,\"totalVisited\" INTEGER,\"masterID\" TEXT,\"openforcurrentuser\" INTEGER,\"isAll\" INTEGER)";
        NSString *sqlChannel=@"CREATE TABLE IF NOT EXISTS Channels (\"id\" INTEGER PRIMARY KEY  NOT NULL  UNIQUE ,\"eqId\" INTEGER,\"channelValue\" INTEGER,\"cNumber\" INTEGER, \"Channel_name\" TEXT,\"Channel_pic\" TEXT, \"parent\" CHAR(2) NOT NULL  DEFAULT TV, \"isFavorite\" BOOL DEFAULT 0, \"eqNumber\" TEXT,\"masterID\" TEXT)";
        NSString *sqlDevice=@"CREATE TABLE IF NOT EXISTS Devices(ID INT PRIMARY KEY NOT NULL, NAME TEXT NOT NULL, \"sn\" TEXT, \"birth\" DATETIME, \"guarantee\" DATETIME, \"model\" INTEGER, \"temperature\" INTEGER, \"fanspeed\" INTEGER, \"price\" FLOAT, \"purchase\" DATETIME, \"producer\" TEXT, \"gua_tel\" TEXT, \"power\" INTEGER, \"bright\" INTEGER, \"color\" TEXT, \"position\" INTEGER,  \"current\" FLOAT, \"voltage\" INTEGER, \"protocol\" TEXT, \"rID\" INTEGER, \"eNumber\" TEXT, \"htypeID\" TEXT, \"subTypeId\" INTEGER, \"typeName\" TEXT, \"subTypeName\" TEXT, \"masterID\" TEXT, \"icon_url\" TEXT, \"camera_url\" TEXT, \"UITypeOfLight\" INTEGER)";
        NSString *sqlScene=@"CREATE TABLE IF NOT EXISTS \"Scenes\" (\"ID\" INT PRIMARY KEY  NOT NULL ,\"NAME\" TEXT NOT NULL ,\"roomName\" TEXT,\"pic\" TEXT DEFAULT (null) ,\"rId\" INTEGER,\"sType\" INTEGER, \"snumber\" TEXT,\"isFavorite\" BOOL,\"totalVisited\" INTEGER,\"masterID\" TEXT ,\"status\" INTEGER DEFAULT (0))";
        NSString *sqlChat = @"CREATE TABLE IF NOT EXISTS chats(\"ID\" INTEGER PRIMARY KEY  NOT NULL ,nickname varchar(20),portrait varchar(100),username varchar(20),user_id integer)";
        NSString *sqlCatalog = @"CREATE TABLE IF NOT EXISTS catalog(\"ID\" INTEGER PRIMARY KEY  NOT NULL ,catalogName varchar(20))";
        NSString *sqlUser = @"CREATE TABLE IF NOT EXISTS Users(ID INT PRIMARY KEY NOT NULL, userType INTEGER, userName TEXT, nickName TEXT, vip TEXT, age INTEGER, sex INTEGER, portraitUrl TEXT, phoneNum TEXT, signature TEXT, extra1 TEXT, extra2 TEXT, extra3 TEXT, extra4 TEXT)";
        
        NSArray *sqls=@[sqlRoom,sqlChannel,sqlDevice,sqlScene,sqlChat,sqlCatalog,sqlUser];
        //4.创表
        for (NSString *sql in sqls) {
            BOOL result=[db executeUpdate:sql];
            if (result) {
                NSLog(@"创表成功---%@", sql);
            }else{
                NSLog(@"创表失败---%@", sql);
            }
        }
    }else{
        NSLog(@"Could not open db.");
    }
    
    [db close];
}

+ (NSInteger)numbersOfDeviceType {
    NSInteger count = 0;
    FMDatabase *db = [self connetdb];
    if ([db open]) {
        
        NSString *sql =[NSString stringWithFormat: @"SELECT count(*) as count FROM catalog"];
        FMResultSet *resultSet = [db executeQuery:sql];
        if ([resultSet next])
        {
            count += [resultSet intForColumn:@"count"];
        }
        
        return count;
    }
    
    return count;
}

+(NSArray *)allSceneModels
{
    FMDatabase *db = [SQLManager connetdb];
    NSMutableArray *sceneModles = [NSMutableArray array];
    if([db open])
    {
        FMResultSet *resultSet = [db executeQuery:[NSString stringWithFormat:@"select * from Scenes"]];
        while([resultSet next])
        {
            Scene *scene = [Scene new];
            scene.sceneID = [resultSet intForColumn:@"ID"];
            scene.sceneName = [resultSet stringForColumn:@"NAME"];
            scene.roomID = [resultSet intForColumn:@"roomName"];
            
            scene.picName =[resultSet stringForColumn:@"pic"];
            scene.isFavorite = [resultSet boolForColumn:@"isFavorite"];
            
            scene.roomID = [resultSet intForColumn:@"rId"];
            
            [sceneModles addObject:scene];
            
        }
    }
    [db closeOpenResultSets];
    [db close];
    return [sceneModles copy];
}
//根据场景中的设备ID获得该场景中的所有设备
+(NSArray *)devicesBySceneID:(int)sId
{
    NSArray *devices = [NSArray array];
    NSArray *arrs = [self allSceneModels];
    for(Scene *scene in arrs)
    {
        if(scene.sceneID == sId)
        {
            devices = [SQLManager devicesByRoomId:scene.roomID];
        }
    }
    return devices;
}

+ (NSArray *)getAllSceneWithRoomID:(int)roomID
{
    FMDatabase *db = [SQLManager connetdb];
    NSMutableArray *sceneModles = [NSMutableArray array];
    
    if([db open])
    {
        long masterID =  [[DeviceInfo defaultManager] masterID];
        
        NSString *sql = [NSString stringWithFormat:@"select * from Scenes where rId=%d and masterID = '%ld'", roomID, masterID];
        FMResultSet *resultSet = [db executeQuery:sql];
        while([resultSet next])
        {
            
            Scene *scene = [SQLManager parseScene:resultSet];
            [sceneModles addObject:scene];
        }
    }
    [db closeOpenResultSets];
    [db close];
    return [sceneModles copy];
}
+(Scene*)parseScene:(FMResultSet *)resultSet
{
    
    Scene *scene = [Scene new];
    scene.sceneID = [resultSet intForColumn:@"ID"];
    scene.sceneName = [resultSet stringForColumn:@"NAME"];
    
    scene.picName =[resultSet stringForColumn:@"pic"];
    scene.isFavorite = [resultSet boolForColumn:@"isFavorite"];
    scene.roomID = [resultSet intForColumn:@"rId"];
    int sType = [resultSet intForColumn:@"sType"];
    if(sType == 1)
    {
        scene.readonly = YES;//系统场景
    }else {
        scene.readonly = NO;//自定义场景
    }
    
    return scene;
    
}
+(Scene *)sceneBySceneID:(int)sId
{
    FMDatabase *db = [SQLManager connetdb];
    Scene *scene = [Scene new];
    if([db open])
    {
        long masterID = [[DeviceInfo defaultManager] masterID];
        
        NSString *sql = [NSString stringWithFormat:@"select * from Scenes where ID = %d and masterID = '%ld'",sId, masterID];
        FMResultSet *resultSet = [db executeQuery:sql];
        
        while([resultSet next])
        {
            scene = [SQLManager parseScene:resultSet];
        }
        
    }
    [db closeOpenResultSets];
    [db close];
    return scene;
}
+(BOOL)deleteScene:(int)sceneId
{
    FMDatabase *db = [self connetdb];
    BOOL isSuccess = false;
    if([db open])
    {
        isSuccess = [db executeUpdateWithFormat:@"delete from Scenes where ID = %d",sceneId];
    }
    [db close];
    return isSuccess;
}
//根据房间ID获取该房间所有的场景
+(NSArray *)getScensByRoomId:(int)roomId
{
    NSMutableArray *scens = [NSMutableArray array];
    
    
    FMDatabase *db = [self connetdb];
    if([db open])
    {
        FMResultSet *resultSet = [db executeQueryWithFormat:@"select * from Scenes where rId = %d",roomId];
        while ([resultSet next]) {
            Scene *scene = [Scene new];
            scene.sceneName = [resultSet stringForColumn:@"NAME"];
            scene.sceneID = [resultSet intForColumn:@"ID"];
            scene.picName = [resultSet stringForColumn:@"pic"];
            scene.status = [resultSet intForColumn:@"status"];
            
            [scens addObject:scene];
        }
    }
    [db closeOpenResultSets];
    [db close];
    return [scens copy];
    
    
    
}
//得到数据库中所有的场景ID
+(NSArray *)getAllSceneIdsFromSql
{
    NSMutableArray *sceneIds = [NSMutableArray array];
    FMDatabase *db = [self connetdb];
    if([db open])
    {
        long masterID =  [[DeviceInfo defaultManager] masterID];
        
        NSString *sql = [NSString stringWithFormat:@"select ID from Scenes where masterID = '%ld'", masterID];
        FMResultSet *resultSet = [db executeQuery:sql];
        while ([resultSet next]) {
            int scendID = [resultSet intForColumn:@"ID"];
            [sceneIds addObject: [NSNumber numberWithInt:scendID]];
        }
        
    }
    [db closeOpenResultSets];
    [db close];
    return [sceneIds copy];
}

+(NSArray *)getFavorScene
{
    NSMutableArray *scens = [NSMutableArray array];
    FMDatabase *db = [self connetdb];
    
    if([db open])
    {
        FMResultSet *resultSet = [db executeQuery:[NSString stringWithFormat:@"select * from Scenes where isFavorite = 2"]];
        while ([resultSet next]) {
            Scene *scene = [Scene new];
            scene.sceneName = [resultSet stringForColumn:@"NAME"];
            scene.sceneID = [resultSet intForColumn:@"ID"];
            scene.picName = [resultSet stringForColumn:@"pic"];
            [scens addObject:scene];
        }
    }
    [db closeOpenResultSets];
    [db close];
    return [scens copy];
}

+(NSArray *)getAllRoomsInfoByName:(NSString *)name
{
    NSMutableArray *roomList = [NSMutableArray array];
    FMDatabase *db = [SQLManager connetdb];
    if([db open])
    {
        if (name) {
            long masterID =[[DeviceInfo defaultManager] masterID];
            
            NSString * roomSql =[NSString stringWithFormat:@"select * from Rooms where NAME like '%%%@%%' and masterID = '%ld'",name, masterID];
            //房间
            FMResultSet * roomResultSet = [db executeQuery:roomSql];
            while ([roomResultSet next]) {
                NSString * roomName = [roomResultSet stringForColumn:@"NAME"];
                NSString * roomID = [roomResultSet stringForColumn:@"ID"];
                NSDictionary *room = @{@"roomid":roomID,@"roomName":roomName};
                [roomList addObject:room];
            }
        }
    }
    [db closeOpenResultSets];
    [db close];
    return roomList;
}

+(NSArray *)getAllRoomsInfo
{
    FMDatabase *db = [SQLManager connetdb];
    NSMutableArray *roomList = [NSMutableArray array];
    if([db open])
    {
        NSString * roomSql =[NSString stringWithFormat:@"select * from Rooms where openforcurrentuser = 1 and masterID = '%ld'", [[DeviceInfo defaultManager] masterID]];
        FMResultSet *resultSet = [db executeQuery:roomSql];
        while ([resultSet next]) {
            Room *room = [Room new];
            room.rId = [resultSet intForColumn:@"ID"];
            room.rName = [resultSet stringForColumn:@"NAME"];
            room.pm25 = [resultSet intForColumn:@"PM25"];
            room.noise = [resultSet intForColumn:@"NOISE"];
            room.tempture = [resultSet intForColumn:@"TEMPTURE"];
            room.co2 = [resultSet intForColumn:@"CO2"];
            room.moisture = [resultSet intForColumn:@"moisture"];
            room.imgUrl = [resultSet stringForColumn:@"imgUrl"];
            room.ibeacon = [resultSet intForColumn:@"ibeacon"];
            [roomList addObject:room];
        }
    }
    [db closeOpenResultSets];
    [db close];
    return [roomList copy];
}

//获取所有房间除了全屋
+(NSArray *)getAllRoomsInfoWithoutIsAll
{
    FMDatabase *db = [SQLManager connetdb];
    NSMutableArray *roomList = [NSMutableArray array];
    if([db open])
    {
        
        NSString * roomSql =[NSString stringWithFormat:@"select * from Rooms where openforcurrentuser = 1 and isAll = 0 and masterID = '%ld'", [[DeviceInfo defaultManager] masterID]];
        FMResultSet *resultSet = [db executeQuery:roomSql];
        while ([resultSet next]) {
            Room *room = [Room new];
            room.rId = [resultSet intForColumn:@"ID"];
            room.rName = [resultSet stringForColumn:@"NAME"];
            room.pm25 = [resultSet intForColumn:@"PM25"];
            room.noise = [resultSet intForColumn:@"NOISE"];
            room.tempture = [resultSet intForColumn:@"TEMPTURE"];
            room.co2 = [resultSet intForColumn:@"CO2"];
            room.moisture = [resultSet intForColumn:@"moisture"];
            room.imgUrl = [resultSet stringForColumn:@"imgUrl"];
            room.ibeacon = [resultSet intForColumn:@"ibeacon"];
            [roomList addObject:room];
        }
    }
    [db closeOpenResultSets];
    [db close];
    return [roomList copy];
}


+(int)getRoomIDByBeacon:(int)beacon
{
    FMDatabase *db = [SQLManager connetdb];
    int rID = 0;
    if([db open])
    {
        long masterID = [[DeviceInfo defaultManager] masterID];
        
        NSString *sql = [NSString stringWithFormat:@"SELECT ID FROM Rooms where ibeacon = %d and masterID = '%ld'",beacon, masterID];
        FMResultSet *resultSet = [db executeQuery:sql];
        if ([resultSet next])
        {
            rID = [resultSet intForColumn:@"ID"];
        }
    }
    [db closeOpenResultSets];
    [db close];
    return rID;
}

+ (NSString *)getRoomNameByRoomID:(int) rId
{
    FMDatabase *db = [SQLManager connetdb];
    NSString *rName ;
    if([db open])
    {
        NSString *sql = [NSString stringWithFormat:@"SELECT NAME FROM Rooms where ID = %d and masterID = '%ld'",rId, [[DeviceInfo defaultManager] masterID]];
        FMResultSet *resultSet = [db executeQuery:sql];
        if ([resultSet next])
        {
            rName = [resultSet stringForColumn:@"name"];
        }
    }
    [db closeOpenResultSets];
    [db close];
    return rName;
}

+ (NSString *)getRoomNameByDeviceID:(int) deviceId
{
    FMDatabase *db = [SQLManager connetdb];
    NSString *rName ;
    if([db open])
    {
        NSString *sql = [NSString stringWithFormat:@"SELECT NAME FROM Rooms where ID = (select rid from devices where id = %d) and masterID = '%ld'",deviceId, [[DeviceInfo defaultManager] masterID]];
        FMResultSet *resultSet = [db executeQuery:sql];
        if ([resultSet next])
        {
            rName = [resultSet stringForColumn:@"name"];
        }
    }
    [db closeOpenResultSets];
    [db close];
    return rName;
}

+ (BOOL)updateScenePic:(NSString *)img sceneID:(int)sceneID
{
    FMDatabase *db = [SQLManager connetdb];
    
    BOOL ret = NO;
    if([db open])
    {
        long masterID =  [[DeviceInfo defaultManager] masterID];
        
        NSString *sql = [NSString stringWithFormat:@"update Scenes set pic = '%@' where ID = %d and masterID = '%ld'",img,sceneID, masterID];
        
        ret = [db executeUpdate:sql];
        
    }
    [db closeOpenResultSets];
    [db close];
    return ret;
}

+ (BOOL)updateSceneStatus:(int)status sceneID:(int)sceneID {
    FMDatabase *db = [SQLManager connetdb];
    
    BOOL ret = NO;
    if([db open])
    {
        long masterID =  [[DeviceInfo defaultManager] masterID];
        
        NSString *sql = [NSString stringWithFormat:@"update Scenes set status = %d where ID = %d and masterID = '%ld'",status,sceneID, masterID];
        
        ret = [db executeUpdate:sql];
        
    }
    [db closeOpenResultSets];
    [db close];
    return ret;
}

+(BOOL)updateTotalVisited:(int)roomID
{
    FMDatabase *db = [SQLManager connetdb];
    int oldTotalVisite = 0;
    BOOL ret = false;
    if([db open])
    {
        long masterID = [[DeviceInfo defaultManager] masterID];
        
        NSString *sql = [NSString stringWithFormat:@"SELECT totalVisited FROM Rooms where ID = %d and masterID = '%ld'",roomID, masterID];
        FMResultSet *resultSet = [db executeQuery:sql];
        if ([resultSet next])
        {
            oldTotalVisite = [resultSet intForColumn:@"totalVisited"];
        }
        sql = [NSString stringWithFormat:@"update Rooms set totalVisited  = %d where ID = %d ",oldTotalVisite + 1,roomID];
       ret = [db executeUpdate:sql];
        
    }
    [db closeOpenResultSets];
    [db close];
    return ret;
}

#pragma mark - chats
+ (BOOL)updateChatsPortraitByID:(int)userID url:(NSString *)url {
    FMDatabase *db = [SQLManager connetdb];
    if (![db open]) {
        NSLog(@"Could not open db");
        return NO;
    }
    BOOL result = [db executeUpdate:[NSString stringWithFormat:@"UPDATE chats SET portrait = '%@' where user_id = %d", url, userID]];
    
    [db close];
    return result;
}

#pragma mark - User
+ (BOOL)updateUserPortraitUrlByID:(int)userID url:(NSString *)url {
    FMDatabase *db = [SQLManager connetdb];
    if (![db open]) {
        NSLog(@"Could not open db");
        return NO;
    }
    BOOL result = [db executeUpdate:[NSString stringWithFormat:@"UPDATE Users SET portraitUrl = '%@' where ID = %d", url, userID]];
    
    [db close];
    return result;
}

+ (BOOL)insertOrReplaceUser:(UserInfo *)info {
    FMDatabase *db = [SQLManager connetdb];
    if (![db open]) {
        NSLog(@"Could not open db");
        return NO;
    }
    BOOL result = [db executeUpdate:[NSString stringWithFormat:@"insert or replace into Users values(%ld, %ld, '%@', '%@', '%@',  %ld, %ld, '%@', '%@', '%@', null, null, null, null);", info.userID, info.userType, info.userName, info.nickName, info.vip, info.age, info.sex, info.headImgURL, info.phoneNum, info.signature]];
    
    [db close];
    return result;
}

+ (UserInfo *)getUserInfo:(int)userID {
    FMDatabase *db = [SQLManager connetdb];
    UserInfo *info = [[UserInfo alloc] init];
    if (![db open]) {
        NSLog(@"Could not open db");
        return nil;
    }
    
    FMResultSet *resultSet = [db executeQuery:[NSString stringWithFormat:@"select * from Users where ID = %d",userID]];
    if([resultSet next])
    {
        info.userID = [resultSet intForColumn:@"ID"];
        info.userType = [resultSet intForColumn:@"userType"];
        info.userName = [resultSet stringForColumn:@"userName"];
        info.nickName = [resultSet stringForColumn:@"nickName"];
        info.vip = [resultSet stringForColumn:@"vip"];
        info.age = [resultSet intForColumn:@"age"];
        info.sex = [resultSet intForColumn:@"sex"];
        info.headImgURL = [resultSet stringForColumn:@"portraitUrl"];
        info.phoneNum = [resultSet stringForColumn:@"phoneNum"];
        info.signature = [resultSet stringForColumn:@"signature"];
        
    }
    [db closeOpenResultSets];
    [db close];
    
    return info;
}

#pragma mark - channel favor
+(NSMutableArray *)getAllChannelForFavoritedForType:(NSString *)type deviceID:(int)deviceID
{
    FMDatabase *db = [SQLManager connetdb];
    NSMutableArray *mutabelArr = [NSMutableArray array];
    if (![db open]) {
        NSLog(@"Could not open db");
        return mutabelArr;
    }
    
    FMResultSet *resultSet = [db executeQuery:[NSString stringWithFormat:@"select * from Channels where isFavorite = 1 and eqId = %d and parent = '%@'",deviceID,type]];
    while([resultSet next])
    {
        TVChannel *channel = [TVChannel new];
        channel.channel_name = [resultSet stringForColumn:@"Channel_name"];
        channel.channel_id = [resultSet intForColumn:@"id"];
        channel.channel_pic = [resultSet stringForColumn:@"Channel_pic"];
        channel.isFavorite = [resultSet boolForColumn:@"isFavorite"];
        channel.channelValue=[resultSet intForColumn:@"channelValue"];
        channel.parent =[resultSet stringForColumn:@"parent"];
        channel.eqNumber = [resultSet intForColumn:@"eqNumber"];
        channel.eID = [resultSet intForColumn:@"eqId"];
        channel.channel_number = [resultSet intForColumn:@"cNumber"];
        [mutabelArr addObject:channel];
    }
    [db closeOpenResultSets];
    [db close];
    
    return mutabelArr;
}

//编辑fm
+(BOOL)getAllChangeChannelForFavoritedNewName:(NSString *)newName FmId:(NSInteger)fmId
{
    // 写sqlite更新场景表的isFavorite字段
    FMDatabase *db = [SQLManager connetdb];
    if (![db open]) {
        NSLog(@"Could not open db.");
        return NO;
    }
    BOOL result = [db executeUpdate:[NSString stringWithFormat:@"UPDATE Channels SET Channel_name ='%@' where isFavorite = 1 and id = %ld",newName,(long)fmId]];
    
    [db close];
    return result;
}

+(BOOL)deleteChannelForChannelID:(NSInteger)channel_id
{
    FMDatabase *db = [SQLManager connetdb];
    BOOL isSuccess = false;
    if([db open])
    {
        isSuccess = [db executeUpdateWithFormat:@"delete from Channels where id = %ld",(long)channel_id];
    }
    [db close];
    return isSuccess;
}

+(NSArray *)getDetailListWithID:(NSInteger)ID
{
    FMDatabase *db = [SQLManager connetdb];
    if (![db open]) {
        NSLog(@"Could not open db.");
        return nil;
    }
    NSMutableArray *array = [NSMutableArray array];
    long masterID = [[DeviceInfo defaultManager] masterID];
    
    NSString *sql = [NSString stringWithFormat:@"select * from Devices where ID=%ld and masterID = '%ld'",(long)ID, masterID];
    FMResultSet *resultSet = [db executeQuery:sql];
    
    if([resultSet next])
    {
        [array addObject:[resultSet stringForColumn:@"NAME"]];
    }
    
    [db closeOpenResultSets];
    [db close];
    
    
    return array;
}

+(NSArray *) writeScenes:(NSArray *)rooms
{
    FMDatabase *db = [SQLManager connetdb];
    NSMutableArray *plists = [NSMutableArray new];
    if([db open])
    {
        NSString *delsql=@"delete from Scenes";
        [db executeUpdate:delsql];
        for (NSDictionary *room in rooms) {
            NSString *rName = room[@"room_name"];
            int room_id = [room[@"room_id"] intValue];
            NSArray *sceneList = room[@"scene_list"];
            
            for(NSDictionary *sceneInfoDic in sceneList)
            {
                int sId = [sceneInfoDic[@"scence_id"] intValue];
                NSString *sName = sceneInfoDic[@"name"];
                int isFavorite = [sceneInfoDic[@"isstore"] intValue];//是否收藏，1:已收藏 2: 未收藏
                int sType = [sceneInfoDic[@"type"] intValue];
                NSString *sNumber = sceneInfoDic[@"snumber"];
                NSString *urlImage = sceneInfoDic[@"image_url"];
                if(sceneInfoDic[@"plist_url"])
                {
                    NSString *urlPlist = sceneInfoDic[@"plist_url"];
                    [plists addObject:urlPlist];
                }
                NSString *sql = [NSString stringWithFormat:@"insert into Scenes values(%d,'%@','%@','%@',%d,%d,'%@',%d,null,'%ld', %d)",sId,sName,rName,urlImage,room_id,sType,sNumber,isFavorite,[DeviceInfo defaultManager].masterID, 0];
                BOOL result = [db executeUpdate:sql];
                if(result)
                {
                    NSLog(@"insert 场景信息 成功");
                }else{
                    NSLog(@"insert 场景信息 失败");
                }
            }
        }
    }
    
    [db close];
    return plists;
}

+(void) writeCatalog:(int)cid name:(NSString*) cname db:(FMDatabase *)db
{
    if([db open])
    {
        NSString *sql = [NSString stringWithFormat:@"select * from catalog where id = %d",cid];
        FMResultSet *resultSet = [db executeQuery:sql];
        if([resultSet next]){
            return;
        }
        NSString *catasql = [NSString stringWithFormat:@"insert into catalog values(%d,'%@')",cid,cname];
        BOOL result = [db executeUpdate:catasql];
        
        if(result)
        {
            NSLog(@"insert 成功");
        }else{
            NSLog(@"insert 失败");
        }
    }
}

+ (void) writeDevices:(NSArray *)rooms
{
    if(rooms.count ==0 || rooms == nil)
    {
        return;
    }
    
    FMDatabase *db = [SQLManager connetdb];
    if([db open])
    {
        NSString *delsql=@"delete from Devices";
        [db executeUpdate:delsql];
        for(NSDictionary *room in rooms)
        {
            NSInteger rId = [room[@"room_id"] integerValue];
            NSArray *equipmentList = room[@"equipment_list"];
            if(equipmentList.count ==0 || equipmentList == nil)
            {
                continue;
            }
            for(NSDictionary *equip in equipmentList)
            {
                NSString *masterID = [NSString stringWithFormat:@"%ld", [[DeviceInfo defaultManager] masterID]];
                int subtypeID = [equip[@"subtype_id"] intValue];
                
                NSString *sql = [NSString stringWithFormat:@"insert into Devices values(%d, '%@', '%@', '%@', '%@', %d, %d, %d, %f, '%@', '%@', '%@', %d, %d, '%@', %d, %f, %d, '%@', '%ld', '%@', '%@', '%d', '%@', '%@', '%@', '%@', '%@',%d)",[equip[@"equipment_id"] intValue], equip[@"name"], NULL, NULL, NULL,0,25, 0, 1005.5, NULL, NULL, NULL, 0, 0, @"FFFF", 0, 0.1, 220, @"none",(long)rId, equip[@"number"], equip[@"htype_id"], subtypeID, equip[@"type_name"], equip[@"subtype_name"], masterID, equip[@"imgurl"], equip[@"cameraurl"],[equip[@"display_type"] intValue]];
                
                BOOL result = [db executeUpdate:sql];
                if(result)
                {
                    NSLog(@"insert 成功");
                }else{
                    NSLog(@"insert 失败");
                }
                
            }
            
        }
        
    }
    [db close];
}

+(void) writeRooms:(NSArray *)roomList
{
    FMDatabase *db = [SQLManager connetdb];
    if([db open])
    {
        NSString *delsql=@"delete from Rooms";
        [db executeUpdate:delsql];
        for(NSDictionary *roomDic in roomList)
        {
            if(roomDic)
            {
                NSString *sql = [NSString stringWithFormat:@"insert into Rooms values(%d,'%@',null,null,null,null,null,'%@',%d,null,'%ld',%d,%d)",[roomDic[@"room_id"] intValue],roomDic[@"room_name"],roomDic[@"room_image_url"],[roomDic[@"ibeacon"] intValue],[DeviceInfo defaultManager].masterID,[roomDic[@"isaccess"] intValue],[roomDic[@"ishouse"] intValue]];
                BOOL result = [db executeUpdate:sql];
                if(result)
                {
                    NSLog(@"insert 成功");
                }else{
                    NSLog(@"insert 失败");
                }
                
            }
        }
    }
    [db close];
}

+(void) writeChannels:(NSArray *)responseObject parent:(NSString *)parent
{
    FMDatabase *db = [SQLManager connetdb];
    if([db open])
    {
        for(NSDictionary *dicInfo in responseObject)
        {
            int eqId = [dicInfo[@"eqid"] intValue];
            NSString *eqNumber = dicInfo[@"eqnumber"];
            NSString *key = [NSString stringWithFormat:@"store_%@_list",parent];
            NSArray *channelList = dicInfo[key];
            if(channelList == nil || channelList .count == 0 )
            {
                return;
            }
            
            for(NSDictionary *channel in channelList)
            {
                NSString *sql = [NSString stringWithFormat:@"insert into Channels values(%d,%d,%d,%d,'%@','%@','%@',%d,'%@','%ld')",[channel[@"channel_id"] intValue],eqId,0,[channel[@"channel_number"] intValue],channel[@"channel_name"],channel[@"image_url"],parent,1,eqNumber,[DeviceInfo defaultManager].masterID];
                BOOL result = [db executeUpdate:sql];
                if(result)
                {
                    NSLog(@"insert 成功");
                }else{
                    NSLog(@"insert 失败");
                }
                
            }
            
        }
    }
    [db close];
}

+(void) writeChats:(NSArray *)users
{
    FMDatabase *db = [SQLManager connetdb];
    if([db open])
    {
        NSString *delsql=@"delete from chats";
        [db executeUpdate:delsql];
        int i=0;
        for (NSDictionary *user in users) {
            
            NSString *nickname = user[@"nickname"];
            NSString *portrait = user[@"portrait"];
            NSString *username = user[@"username"];
            int user_id = [user[@"user_id"] intValue];
            
            NSString *sql = [NSString stringWithFormat:@"insert into chats values(%d,'%@','%@','%@',%d)",i++,nickname,portrait,username,user_id];
            BOOL result = [db executeUpdate:sql];
            if(result)
            {
                NSLog(@"insert 聊天信息 成功");
            }else{
                NSLog(@"insert 聊天信息 失败");
            }
            
        }
        [IOManager writeUserdefault:@(i) forKey:@"familyNum"];
    }
    
    [db close];
}

//更新设备状态
+ (BOOL)updateDeviceStatus:(Device *)deviceInfo {
    FMDatabase *db = [SQLManager connetdb];
    
    BOOL ret = NO;
    if([db open])
    {
        
        NSString *sql = [NSString stringWithFormat:@"update Devices set power = %ld,  bright = %ld,  color = '%@',  position = %ld,  temperature = %ld,  fanspeed = %ld,  model = %ld  where ID = %d and masterID = '%ld'",(long)deviceInfo.power, (long)deviceInfo.bright, deviceInfo.color, (long)deviceInfo.position, (long)deviceInfo.temperature, (long)deviceInfo.fanspeed, (long)deviceInfo.air_model, deviceInfo.eID, [[DeviceInfo defaultManager] masterID]];
        
        ret = [db executeUpdate:sql];
        
    }
    [db closeOpenResultSets];
    [db close];
    return ret;
}

@end
