//
//  DeviceManager.m
//  SmartHome
//
//  Created by 逸云科技 on 16/8/5.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "SQLManager.h"
#import "Device.h"
#import "DeviceType.h"
#import "DeviceInfo.h"
#import "Room.h"

@implementation SQLManager

+(FMDatabase *)connetdb
{
    NSString *dbPath = [[IOManager sqlitePath] stringByAppendingPathComponent:[[DeviceInfo defaultManager] db]];
    
    return [FMDatabase databaseWithPath:dbPath];
}

//从数据中获取所有设备信息
+(NSArray *)getAllDevicesInfo{
    FMDatabase *db = [self connetdb];
    NSMutableArray *deviceModels = [NSMutableArray array];
    if([db open])
    {
        FMResultSet *resultSet = [db executeQuery:@"select * from Devices"];
        
        while ([resultSet next]){
            [deviceModels addObject:[self deviceMdoelByFMResultSet:resultSet]];
        }
    }
    [db closeOpenResultSets];
    [db close];
    return [deviceModels copy];
}

+(NSString *)deviceNameByDeviceID:(int)eId
{
    FMDatabase *db = [self connetdb];
    NSString *eName;
    if([db open])
    {
        NSString *sql = [NSString stringWithFormat:@"SELECT NAME FROM Devices where ID = %d",eId];
        FMResultSet *resultSet = [db executeQuery:sql];
        while ([resultSet next])
        {
            eName = [resultSet stringForColumn:@"NAME"];
        }
    }
    [db closeOpenResultSets];
    [db close];
    return eName;
}

+(NSString *)getUrlByDeviceId:(int)eId
{
    FMDatabase *db = [self connetdb];
    NSString *url;
    if([db open])
    {
        NSString *sql = [NSString stringWithFormat:@"SELECT url FROM Devices where ID = %d and hTypeId = 45",eId];
        FMResultSet *resultSet = [db executeQuery:sql];
        while ([resultSet next])
        {
            url = [resultSet stringForColumn:@"url"];
        }
    }
    [db closeOpenResultSets];
    [db close];
    return url;

}

+(NSInteger)deviceIDByDeviceName:(NSString *)deviceName
{
    FMDatabase *db = [self connetdb];
    NSInteger eId;
    if([db open])
    {
        NSString *sql = [NSString stringWithFormat:@"SELECT ID FROM Devices where NAME = '%@'",deviceName];
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

+(NSString *)deviceTypeNameByDeviceID:(int)eId
{
    FMDatabase *db = [self connetdb];
    NSString *typeName;
    if([db open])
    {
        NSString *sql = [NSString stringWithFormat:@"SELECT typeName FROM Devices where ID = %d",eId];
        FMResultSet *resultSet = [db executeQuery:sql];
        while ([resultSet next])
        {
            typeName = [resultSet stringForColumn:@"typeName"];
            if ([typeName isEqualToString:@"开关灯"]||[typeName isEqualToString:@"调色灯"]||[typeName isEqualToString:@"调光灯"]) {
                typeName = @"灯光";
            }else if ([typeName isEqualToString:@"开合帘"] || [typeName isEqualToString:@"卷帘"]) {
                typeName = @"窗帘";
            }
        }
    }
    [db closeOpenResultSets];
    [db close];
    return typeName;
}

+(NSString*)lightTypeNameByDeviceID:(int)eId
{
    FMDatabase *db = [self connetdb];
    NSString *typeName;
    if([db open])
    {
        NSString *sql = [NSString stringWithFormat:@"SELECT typeName FROM Devices where ID = %d",eId];
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

+ (NSString *)getNameWithID:(int)eId
{
    FMDatabase *db = [self connetdb];
    NSString *typeName = nil;
    if([db open])
    {
        NSString *sql = [NSString stringWithFormat:@"SELECT NAME FROM Devices where ID = %d",eId];
        FMResultSet *resultSet = [db executeQuery:sql];
        if ([resultSet next])
        {
            typeName = [resultSet stringForColumn:@"NAME"];
        }
    }
    [db closeOpenResultSets];
    [db close];
    return typeName;
}

+(Device*)deviceMdoelByFMResultSet:(FMResultSet *)resultSet
{
    Device *device = [Device new];
    device.eID = [resultSet intForColumn:@"ID"];
    device.name = [resultSet stringForColumn:@"NAME"];
    device.sn = [resultSet stringForColumn:@"sn"];
    device.birth = [resultSet stringForColumn:@"birth"];
    device.guarantee = [resultSet stringForColumn:@"guarantee"];
    device.model = [resultSet stringForColumn:@""];
    device.price = [resultSet doubleForColumn:@"price"];
    device.purchase = [resultSet stringForColumn:@"purchase"];
    device.producer = [resultSet stringForColumn:@"producer"];
    device.gua_tel = [resultSet stringForColumn:@"gua_tel"];
    device.power = [resultSet intForColumn:@"power"];
    device.current = [resultSet doubleForColumn:@"current"];
    device.voltage = [resultSet intForColumn:@"voltage"];
    device.protocol = [resultSet stringForColumn:@"protocol"];
    device.rID = [resultSet intForColumn:@"rID"];
    device.eNumber = [resultSet intForColumn:@"eNumber"];
    device.hTypeId = [resultSet intForColumn:@"hTypeId"];
    device.subTypeId = [resultSet intForColumn:@"subTypeId"];
    device.typeName = [resultSet stringForColumn:@"typeName"];
    device.subTypeName = [resultSet stringForColumn:@"subTypeName"];
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


+(NSArray *)deviceSubTypeByRoomId:(NSInteger)roomID
{
    NSMutableArray *subTypes = [NSMutableArray array];
    FMDatabase *db = [self connetdb];
    if([db open])
    {
        NSString *sql = [NSString stringWithFormat:@"SELECT distinct typeName FROM Devices where rID = %ld",roomID];
        FMResultSet *resultSet = [db executeQuery:sql];
        while ([resultSet next])
        {
            NSString *typeName = [resultSet stringForColumn:@"typeName"];
            
            if ([typeName isEqualToString:@"开关灯"]||[typeName isEqualToString:@"调色灯"]||[typeName isEqualToString:@"调光灯"]) {
                typeName = @"灯光";
            }
            else if ([typeName isEqualToString:@"开合帘"] || [typeName isEqualToString:@"卷帘"]) {
                typeName = @"窗帘";
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
+(NSArray*)getSubTypeNameByRoomID:(int)rID
{
    NSMutableArray *subTypes = [NSMutableArray array];
    FMDatabase *db = [self connetdb];
    if([db open])
    {
        NSString *sql = [NSString stringWithFormat:@"SELECT distinct subTypeName FROM Devices where rID = %d",rID];
        FMResultSet *resultSet = [db executeQuery:sql];
        while ([resultSet next])
        {
            NSString *subTypeName = [resultSet stringForColumn:@"subTypeName"];
            [subTypes addObject:subTypeName];

        }
    }
    [db closeOpenResultSets];
    [db close];
    return [subTypes copy];

}
+(NSArray *)deviceIdsByRoomId:(int)roomID
{
    
    NSMutableArray *deviceDIs = [NSMutableArray array];
    FMDatabase *db = [self connetdb];
    if([db open])
    {
        NSString *sql = [NSString stringWithFormat:@"SELECT ID FROM Devices where rID = %d",roomID];
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
        NSString *sql = [NSString stringWithFormat:@"SELECT distinct typeName FROM Devices where rID = %ld and typeName in (\"开关\",\"调色\",\"调光\")",roomID];
        FMResultSet *resultSet = [db executeQuery:sql];
        while ([resultSet next])
        {
            NSString *light = [resultSet stringForColumn:@"typeName"];
            [lightNames addObject:light];
        }
    }
    
    if (lightNames.count < 1) {
        return nil;
    }
    [db closeOpenResultSets];
    [db close];
    return [lightNames copy];
}

+ (NSArray *)getLightWithTypeName:(NSString *)typeName roomID:(NSInteger)roomID
{
    NSMutableArray *lights = [NSMutableArray array];
    
    FMDatabase *db = [self connetdb];
    if([db open])
    {
        NSString *sql = [NSString stringWithFormat:@"SELECT ID FROM Devices where rID = %ld and typeName = \"%@\"",roomID, typeName];
        FMResultSet *resultSet = [db executeQuery:sql];
        while ([resultSet next])
        {
            int lightID = [resultSet intForColumn:@"ID"];
            [lights addObject:[NSNumber numberWithInt:lightID]];
        }
    }
    
    if (lights.count < 1) {
        return nil;
    }
    [db closeOpenResultSets];
    [db close];
    return [lights copy];
}



+ (NSArray *)getCurtainTypeNameWithRoomID:(NSInteger)roomID
{
    NSMutableArray *curtainNames = [NSMutableArray array];
    
    FMDatabase *db = [self connetdb];
    if([db open])
    {
        NSString *sql = [NSString stringWithFormat:@"SELECT distinct typeName FROM Devices where rID = %ld and typeName in (\"开合帘\",\"卷帘\")",roomID];
        FMResultSet *resultSet = [db executeQuery:sql];
        while ([resultSet next])
        {
            NSString *light = [resultSet stringForColumn:@"typeName"];
            [curtainNames addObject:light];
        }
    }
    
    if (curtainNames.count < 1) {
        return nil;
    }
    [db closeOpenResultSets];
    [db close];
    return [curtainNames copy];
}

+ (NSArray *)getCurtainWithTypeName:(NSString *)typeName roomID:(NSInteger)roomID
{
    NSMutableArray *curtains = [NSMutableArray array];
    
    FMDatabase *db = [self connetdb];
    if([db open])
    {
        NSString *sql = [NSString stringWithFormat:@"SELECT ID FROM Devices where rID = %ld and typeName = \"%@\"",roomID, typeName];
        FMResultSet *resultSet = [db executeQuery:sql];
        while ([resultSet next])
        {
            int lightID = [resultSet intForColumn:@"ID"];
            [curtains addObject:[NSNumber numberWithInt:lightID]];
        }
    }
    
    if (curtains.count < 1) {
        return nil;
    }
    [db closeOpenResultSets];
    [db close];
    return [curtains copy];
}

+ (NSString *)deviceIDWithRoomID:(NSInteger)roomID withType:(NSString *)type
{
    NSString *deviceID = nil;
    
    FMDatabase *db = [self connetdb];
    if([db open])
    {
        NSString *sql = [NSString stringWithFormat:@"SELECT ID FROM Devices where rID = %ld and typeName = \'%@\'",roomID,type];
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


+(NSArray *)getDeviceByTypeName:(NSString  *)typeName andRoomID:(NSInteger)roomID
{
    NSMutableArray *array = [NSMutableArray array];
    FMDatabase *db = [self connetdb];
    if([db open])
    {
        NSString *sql = [NSString stringWithFormat:@"SELECT ID FROM Devices where rID = %ld and typeName = \'%@\'",roomID,typeName];
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
        NSString *sql = [NSString stringWithFormat:@"SELECT htypeID FROM Devices where ID = %ld",eID];
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
        NSString *sql = [NSString stringWithFormat:@"SELECT enumber FROM Devices where ID = %ld",eID];
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

+(NSString *)getDeviceIDByENumber:(NSInteger)eID masterID:(NSInteger)mID
{
    NSString *deviceID=nil;
    FMDatabase *db = [self connetdb];
    if([db open])
    {
        NSString *sql = [NSString stringWithFormat:@"SELECT ID FROM Devices where upper(enumber) = upper('%04lx') and masterID='%04lx'",eID,mID];
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

+(int) getSceneID:(NSString *)name
{
    NSString *sql=[NSString stringWithFormat:@"select id from Scenes where name='%@'" ,name];
    int sceneid=0;
    FMDatabase *db = [self connetdb];
    if([db open])
    {
        FMResultSet *resultSet = [db executeQuery:sql];
        
        if([resultSet next])
        {
            sceneid = [resultSet intForColumn:@"id"];
        }
    }
    [db closeOpenResultSets];
    [db close];
    return sceneid;
}

+(bool) getReadOnly:(int)sceneid
{
    NSString *sql=[NSString stringWithFormat:@"select stype from Scenes where id=%d" ,sceneid];
    
    bool readonly=false;
    FMDatabase *db = [self connetdb];
    if([db open])
    {
        FMResultSet *resultSet = [db executeQuery:sql];
        
        if([resultSet next])
        {
            readonly = [resultSet boolForColumn:@"stype"];
        }
    }
    [db closeOpenResultSets];
    [db close];
    return readonly;
}

+(NSString *) getSnumber:(int)sceneid
{
    NSString *sql=[NSString stringWithFormat:@"select snumber from Scenes where id=%d" ,sceneid];
    
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

+(int) getRoomID:(int)sceneID
{
    NSString *sql=[NSString stringWithFormat:@"select rId from Scenes where ID=%d" ,sceneID];
    
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
    NSString *sql=[NSString stringWithFormat:@"select NAME from Scenes where ID=%d" ,sceneID];
    
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
    NSString *dbPath = [[IOManager sqlitePath] stringByAppendingPathComponent:@"smartDB"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    if([db open])
    {
        NSString *sql = [NSString stringWithFormat:@"select max(id) as id from scenes"];
        FMResultSet *resultSet = [db executeQuery:sql];
        if ([resultSet next])
        {
            sceneID = [resultSet intForColumn:@"ID"]+1;
        }
        
        sql=[NSString stringWithFormat:@"insert into Scenes values(%d,'%@','%@','%@',%d,%d,null,null)",sceneID,name,scene.roomName,img,scene.roomID,2];
        [db executeUpdate:sql];
    }
    [db close];

    return sceneID;
}

+ (NSArray *)getDeviceSubTypeNameWithRoomID:(int)roomID sceneID:(int)sceneID
{
    NSMutableArray *subTypeNames = [NSMutableArray array];
    
    NSArray *deviceIDs = [self getDeviceIDWithRoomID:roomID sceneID:sceneID];
    
    for (NSString *deviceID in deviceIDs) {
        if([deviceID isEqualToString:@""])
        {
            break;
        }
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
    
    if (subTypeNames.count < 1) {
        return nil;
    }
    
    return [subTypeNames copy];
}

+(NSArray *)getAllDeviceSubTypes
{
    NSMutableArray *subTypeNames = [NSMutableArray array];
    NSMutableArray *deviceIDArr = [NSMutableArray array];
    
    FMDatabase *db = [self connetdb];
    
    if([db open])
    {
        NSString *sql = @"SELECT ID FROM Devices";
        
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
        NSString *sql = @"SELECT eId FROM Scenes";
        
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
+ (NSString *)getDeviceSubTypeNameWithID:(int)ID
{
    NSString *subTypeName = nil;
    
    FMDatabase *db = [self connetdb];
    
    if([db open])
    {
        NSString *sql = [NSString stringWithFormat:@"SELECT subTypeName FROM Devices where ID = %d",ID];
        
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

+ (NSArray *)getDeviceIDWithRoomID:(int)roomID sceneID:(int)sceneID
{
    NSArray *deviceIDs;
    
    FMDatabase *db = [self connetdb];
    
    if([db open])
    {
        NSString *sql = [NSString stringWithFormat:@"SELECT eId FROM Scenes where rId = %d and ID = %d",roomID, sceneID];
        
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

+ (Device *)getDeviceWithDeviceID:(int) deviceID
{
    Device *device = nil;
    
    FMDatabase *db = [self connetdb];
    if([db open])
    {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM Devices where ID = %d",deviceID];
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


+ (NSArray *)getDeviceTypeNameWithRoomID:(int)roomID sceneID:(int)sceneID subTypeName:(NSString *)subTypeName
{
    NSMutableArray *typeNames = [NSMutableArray array];
    
    NSArray *deviceIDs = [self getDeviceIDWithRoomID:roomID sceneID:sceneID];
    
    for (NSString *deviceID in deviceIDs) {
        NSString *typeName = [self getDeviceTypeNameWithID:deviceID subTypeName:subTypeName];
        
        if ([typeName isEqualToString:@"开关灯"] || [typeName isEqualToString:@"调色灯"] || [typeName isEqualToString:@"调光灯"]) {
            typeName = @"灯光";
        } else if ([typeName isEqualToString:@"开合帘"] || [typeName isEqualToString:@"卷帘"]) {
            typeName = @"窗帘";
        }
        
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
        NSString *typeName = [self getDeviceTypeNameWithID:deviceID subTypeName:subTypeName];
        
        if ([typeName isEqualToString:@"开关灯"] || [typeName isEqualToString:@"调色灯"] || [typeName isEqualToString:@"调光灯"]) {
            typeName = @"灯光";
        } else if ([typeName isEqualToString:@"开合帘"] || [typeName isEqualToString:@"卷帘"]) {
            typeName = @"窗帘";
        }
        
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
        NSString *sql = [NSString stringWithFormat:@"SELECT typeName FROM Devices where ID = %@ and subTypeName = '%@'",ID, subTypeName];
        
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
        NSString *sql = [NSString stringWithFormat:@"SELECT ID FROM Devices where subTypeName = '%@'", subName];
        
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
+(NSArray *)getDeviceIDsBySeneId:(int)SceneId;
{
   
    
    NSString *sceneFile = [NSString stringWithFormat:@"%@_%d.plist",SCENE_FILE_NAME,SceneId];
    NSString *scenePath=[[IOManager scenesPath] stringByAppendingPathComponent:sceneFile];
    NSDictionary *dictionary = [[NSDictionary alloc] initWithContentsOfFile:scenePath];
    if(dictionary)
    {
        NSMutableArray *deviceIds=[[NSMutableArray alloc] init];
        for (NSDictionary *dic in [dictionary objectForKey:@"devices"])
        {
            int deviceID;
        
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

//根据场景ID，得到该场景下的设备子类
+(NSArray *)getDeviceTypeNameWithScenID:(int)sceneId subTypeName:(NSString *)subTypeName
{
    NSMutableArray *typeNames = [NSMutableArray array];
    NSArray *deviceIDs = [self getDeviceIDsBySeneId:sceneId];
    for(NSString *devcieID in deviceIDs)
    {
        if(devcieID)
        {
            NSString *typeName = [self getDeviceTypeNameWithID:devcieID subTypeName:subTypeName];
            if ([typeName isEqualToString:@"开关灯"] || [typeName isEqualToString:@"调色灯"] || [typeName isEqualToString:@"调光灯"]) {
                typeName = @"灯光";
            } else if ([typeName isEqualToString:@"开合帘"] || [typeName isEqualToString:@"卷帘"]) {
                typeName = @"窗帘";
            }
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
        
        NSString *sqlRoom=@"CREATE TABLE IF NOT EXISTS Rooms(ID INT PRIMARY KEY NOT NULL, NAME TEXT NOT NULL, \"PM25\" INTEGER, \"NOISE\" INTEGER, \"TEMPTURE\" INTEGER, \"CO2\" INTEGER, \"moisture\" INTEGER, \"imgUrl\" TEXT,\"ibeacon\" INTEGER)";
        NSString *sqlChannel=@"CREATE TABLE IF NOT EXISTS Channels (\"id\" INTEGER PRIMARY KEY  NOT NULL  UNIQUE ,\"eqId\" INTEGER,\"channelValue\" INTEGER,\"cNumber\" INTEGER, \"Channel_name\" TEXT,\"Channel_pic\" TEXT, \"parent\" CHAR(2) NOT NULL  DEFAULT TV, \"isFavorite\" BOOL DEFAULT 0, \"eqNumber\" TEXT)";
        NSString *sqlDevice=@"CREATE TABLE IF NOT EXISTS Devices(ID INT PRIMARY KEY NOT NULL, NAME TEXT NOT NULL, \"sn\" TEXT, \"birth\" DATETIME, \"guarantee\" DATETIME, \"model\" TEXT, \"price\" FLOAT, \"purchase\" DATETIME, \"producer\" TEXT, \"gua_tel\" TEXT, \"power\" INTEGER, \"current\" FLOAT, \"voltage\" INTEGER, \"protocol\" TEXT, \"rID\" INTEGER, \"eNumber\" TEXT, \"hTypeId\" TEXT, \"subTypeId\" INTEGER, \"typeName\" TEXT, \"subTypeName\" TEXT, \"masterID\" TEXT, \"url\" TEXT)";
        NSString *sqlScene=@"CREATE TABLE IF NOT EXISTS \"Scenes\" (\"ID\" INT PRIMARY KEY  NOT NULL ,\"NAME\" TEXT NOT NULL ,\"roomName\" TEXT,\"pic\" TEXT DEFAULT (null) ,\"rId\" INTEGER,\"sType\" INTEGER, \"snumber\" TEXT,\"isFavorite\" BOOL)";
        
        //NSString *sqlProtocol=@"CREATE TABLE IF NOT EXISTS [t_protocol_config]([rid] [int] IDENTITY(1,1) NOT NULL,[eid] [int] NULL,[enumber] [varchar](64) NULL,[ename] [varchar](64) NULL,[etype] [varchar](64) NULL,[actname] [varchar](256) NULL,[actcode] [varchar](256) NULL, \"actKey\" VARCHAR)";
        NSArray *sqls=@[sqlRoom,sqlChannel,sqlDevice,sqlScene];//,sqlProtocol];
        //4.创表
        for (NSString *sql in sqls) {
            BOOL result=[db executeUpdate:sql];
            if (result) {
                NSLog(@"创表成功");
            }else{
                NSLog(@"创表失败");
            }
        }
    }else{
        NSLog(@"Could not open db.");
    }
    
    [db close];
}

+(void)initDemoSQlite
{
    [self initSQlite];
    FMDatabase *db = [self connetdb];
    if ([db open]) {
        int count=0;
        NSString *sql = @"SELECT count(*) as count FROM Rooms";
        FMResultSet *resultSet = [db executeQuery:sql];
        if ([resultSet next])
        {
            count += [resultSet intForColumn:@"count"];
        }
        sql = @"SELECT count(*) as count FROM devices";
        resultSet = [db executeQuery:sql];
        if ([resultSet next])
        {
            count += [resultSet intForColumn:@"count"];
        }

        sql = @"SELECT count(*) as count FROM scenes";
        resultSet = [db executeQuery:sql];
        if ([resultSet next])
        {
            count += [resultSet intForColumn:@"count"];
        }
        [db closeOpenResultSets];
        if (count == 0) {
            
        //insert rooms
        NSArray *sqls=@[@"INSERT INTO \"Rooms\" VALUES(1,'主卧',NULL,NULL,NULL,NULL,NULL,'http://115.28.151.85:8088/DefaultFiles\\images\\room\\kitchen.jpg',0);",
        @"INSERT INTO \"Rooms\" VALUES(2,'影音室',NULL,NULL,NULL,NULL,NULL,'http://115.28.151.85:8088/DefaultFiles\\images\\room\\kitchen.jpg',0);",
        @"INSERT INTO \"Rooms\" VALUES(3,'小孩房',NULL,NULL,NULL,NULL,NULL,'http://115.28.151.85:8088/DefaultFiles\\images\\room\\kitchen.jpg',0);",
        @"INSERT INTO \"Rooms\" VALUES(4,'测试区',NULL,NULL,NULL,NULL,NULL,'http://115.28.151.85:8088/DefaultFiles\\images\\room\\kitchen.jpg',10002);",
        @"INSERT INTO \"Rooms\" VALUES(5,'车库',NULL,NULL,NULL,NULL,NULL,'http://115.28.151.85:8088/DefaultFiles\\images\\room\\kitchen.jpg',0);",
          @"INSERT INTO \"Rooms\" VALUES(6,'健身房',NULL,NULL,NULL,NULL,NULL,'http://115.28.151.85:8088/DefaultFiles\\images\\room\\kitchen.jpg',10001);"];
        for (NSString *sql in sqls) {
            BOOL result=[db executeUpdate:sql];
            if (result) {
                NSLog(@"写入表ROOMS成功");
            }else{
                NSLog(@"写入表ROOMS失败");
            }
        }
            
        
        //insert devices
        sqls=@[@"INSERT INTO \"Devices\" VALUES(51,'卧室开关灯',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'(null)',NULL,NULL,NULL,NULL,1,'0036','01',1,'开关灯','照明','00ff','');",
        @"INSERT INTO \"Devices\" VALUES(52,'卧室调光灯',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'(null)',NULL,NULL,NULL,NULL,1,'0015','02',1,'调光灯','照明','00ff','');",
        @"INSERT INTO \"Devices\" VALUES(53,'卧室调色灯',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'(null)',NULL,NULL,NULL,NULL,1,'0016','03',1,'调色灯','照明','00ff','');",
        @"INSERT INTO \"Devices\" VALUES(54,'卧室电视',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'(null)',NULL,NULL,NULL,NULL,1,'0017','12',3,'网络电视','影音','00ff','');",
        @"INSERT INTO \"Devices\" VALUES(55,'卧室空调',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'(null)',NULL,NULL,NULL,NULL,1,'0018','31',2,'空调','环境','00ff','');",
        @"INSERT INTO \"Devices\" VALUES(56,'卧室纱帘',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'(null)',NULL,NULL,NULL,NULL,1,'0019','21',1,'开合帘','照明','00ff','');",
        @"INSERT INTO \"Devices\" VALUES(57,'卧室遮光帘',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'(null)',NULL,NULL,NULL,NULL,1,'0020','21',1,'开合帘','照明','00ff','');",
        @"INSERT INTO \"Devices\" VALUES(58,'卧室卷帘',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'(null)',NULL,NULL,NULL,NULL,1,'0021','22',1,'卷帘','照明','00ff','');",
        @"INSERT INTO \"Devices\" VALUES(59,'影音室DVD',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'(null)',NULL,NULL,NULL,NULL,2,'0022','13',3,'DVD','影音','00ff','');",
        @"INSERT INTO \"Devices\" VALUES(60,'影音室FM',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'(null)',NULL,NULL,NULL,NULL,2,'0023','15',3,'FM','影音','00ff','');",
        @"INSERT INTO \"Devices\" VALUES(61,'影音室背景音乐',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'(null)',NULL,NULL,NULL,NULL,2,'0024','14',3,'背景音乐','影音','00ff','');",
        @"INSERT INTO \"Devices\" VALUES(62,'影音室投影',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'(null)',NULL,NULL,NULL,NULL,2,'0025','16',3,'投影','影音','00ff','');",
        @"INSERT INTO \"Devices\" VALUES(63,'影音室幕布',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'(null)',NULL,NULL,NULL,NULL,2,'0026','17',3,'幕布','影音','00ff','');",
        @"INSERT INTO \"Devices\" VALUES(38,'墙边调光灯',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'(null)',NULL,NULL,NULL,NULL,4,'0001','02',1,'调光灯','照明','00ff','');",
        @"INSERT INTO \"Devices\" VALUES(39,'投影上调光灯',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'(null)',NULL,NULL,NULL,NULL,4,'0002','02',1,'调光灯','照明','00ff','');",
        @"INSERT INTO \"Devices\" VALUES(40,'沙发上调光灯',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'(null)',NULL,NULL,NULL,NULL,4,'0003','02',1,'调光灯','照明','00ff','');",
        @"INSERT INTO \"Devices\" VALUES(41,'测试区电视',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'(null)',NULL,NULL,NULL,NULL,4,'0005','12',3,'网络电视','影音','00ff','');",
        @"INSERT INTO \"Devices\" VALUES(42,'测试区DVD',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'(null)',NULL,NULL,NULL,NULL,4,'0006','13',3,'DVD','影音','00ff','');",
        @"INSERT INTO \"Devices\" VALUES(43,'测试区背景音乐',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'(null)',NULL,NULL,NULL,NULL,4,'0007','14',3,'背景音乐','影音','00ff','');",
        @"INSERT INTO \"Devices\" VALUES(44,'测试区FM',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'(null)',NULL,NULL,NULL,NULL,4,'0008','15',3,'FM','影音','00ff','');",
        @"INSERT INTO \"Devices\" VALUES(45,'测试区机顶盒',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'(null)',NULL,NULL,NULL,NULL,4,'0009','11',3,'机顶盒','影音','00ff','');",
        @"INSERT INTO \"Devices\" VALUES(46,'测试区空调',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'(null)',NULL,NULL,NULL,NULL,4,'0010','31',2,'空调','环境','00ff','');",
        @"INSERT INTO \"Devices\" VALUES(47,'测试区投影',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'(null)',NULL,NULL,NULL,NULL,4,'0011','16',3,'投影','影音','00ff','');",
        @"INSERT INTO \"Devices\" VALUES(48,'测试区幕布',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'(null)',NULL,NULL,NULL,NULL,4,'0012','17',3,'幕布','影音','00ff','');",
        @"INSERT INTO \"Devices\" VALUES(49,'测试摄像头',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'(null)',NULL,NULL,NULL,NULL,4,'0013','45',4,'摄像头','安防','00ff','rtsp://admin:stone123@flysun158.6655.la:8184');",
        @"INSERT INTO \"Devices\" VALUES(50,'测试区纱帘',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'(null)',NULL,NULL,NULL,NULL,4,'02BA','21',1,'开合帘','照明','00ff','');",
        @"INSERT INTO \"Devices\" VALUES(70,'测试区智能门锁',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'(null)',NULL,NULL,NULL,NULL,4,'0033','40',4,'智能门锁','安防','00ff','');",
        @"INSERT INTO \"Devices\" VALUES(71,'测试区智能插座',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'(null)',NULL,NULL,NULL,NULL,4,'0034','41',5,'智能插座','智能单品','00ff','');",
        @"INSERT INTO \"Devices\" VALUES(73,'测试区功放',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'(null)',NULL,NULL,NULL,NULL,4,'0014','18',3,'功放','影音','00ff','');",
        @"INSERT INTO \"Devices\" VALUES(37,'测试区开关灯',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'(null)',NULL,NULL,NULL,NULL,5,'0101','01',1,'开关灯','照明','00ff','');",
        @"INSERT INTO \"Devices\" VALUES(64,'车库温湿度感应器',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'(null)',NULL,NULL,NULL,NULL,5,'0027','50',6,'温湿度感应器','感应器','00ff','');",
        @"INSERT INTO \"Devices\" VALUES(65,'车库动静感应器',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'(null)',NULL,NULL,NULL,NULL,5,'0028','51',6,'动静感应器','感应器','00ff','');",
        @"INSERT INTO \"Devices\" VALUES(66,'车库照度感应器',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'(null)',NULL,NULL,NULL,NULL,5,'0029','52',6,'照度感应器','感应器','00ff','');",
        @"INSERT INTO \"Devices\" VALUES(67,'车库燃气监测',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'(null)',NULL,NULL,NULL,NULL,5,'0030','56',6,'燃气监测','感应器','00ff','');",
        @"INSERT INTO \"Devices\" VALUES(68,'车库噪音感应器',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'(null)',NULL,NULL,NULL,NULL,5,'0031','54',6,'噪音感应器','感应器','00ff','');",
        @"INSERT INTO \"Devices\" VALUES(69,'车库烟雾感应器',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'(null)',NULL,NULL,NULL,NULL,5,'0032','57',6,'烟雾感应器','感应器','00ff','');",
        @"INSERT INTO \"Devices\" VALUES(72,'健身房PM2.5监测',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'(null)',NULL,NULL,NULL,NULL,6,'0035','55',6,'PM2.5监测','感应器','00ff','');"];
        for (NSString *sql in sqls) {
            BOOL result=[db executeUpdate:sql];
            if (result) {
                NSLog(@"写入表Devices成功");
            }else{
                NSLog(@"写入表Devices失败");
            }
        }
        //insert scenes
        
        sqls=@[@"INSERT INTO \"Scenes\" VALUES(10,'DVD','测试区','http://115.28.151.85:8088/DefaultFiles/images/scene/moving.jpg',4,1,'0003',0);",
        @"INSERT INTO \"Scenes\" VALUES(11,'工作','测试区','http://115.28.151.85:8088/DefaultFiles/images/scene/relax.jpg',4,1,'0004',0);",
        @"INSERT INTO \"Scenes\" VALUES(12,'午休','测试区','http://115.28.151.85:8088/DefaultFiles/images/scene/sleep.jpg',4,1,'0005',0);",
        @"INSERT INTO \"Scenes\" VALUES(13,'离开','测试区','http://115.28.151.85:8088/DefaultFiles/images/scene/away.jpg',4,1,'0006',0);",
        @"INSERT INTO \"Scenes\" VALUES(14,'欢迎','测试区','http://115.28.151.85:8088/DefaultFiles/images/scene/welcome.jpg',4,1,'0001',0);",
        @"INSERT INTO \"Scenes\" VALUES(15,'投影','测试区','http://115.28.151.85:8088/DefaultFiles/images/scene/welcome.jpg',4,1,'0002',0);",
        @"INSERT INTO \"Scenes\" VALUES(53,'离开','车库','http://115.28.151.85:8088/UploadFiles/images/scene/cctv1.png',5,2,'',0);"];
        
        for (NSString *sql in sqls) {
            BOOL result=[db executeUpdate:sql];
            if (result) {
                NSLog(@"写入表scenes成功");
            }else{
                NSLog(@"写入表scenes失败");
            }
        }
            
        }
    }else{
        NSLog(@"Could not open db.");
    }
    [db close];
}

+(NSArray *)allSceneModels
{
    FMDatabase *db = [SQLManager connetdb];
    NSMutableArray *sceneModles = [NSMutableArray array];
    if([db open])
    {
        FMResultSet *resultSet = [db executeQuery:@"select * from Scenes"];
        while([resultSet next])
        {
            Scene *scene = [Scene new];
            scene.sceneID = [resultSet intForColumn:@"ID"];
            scene.sceneName = [resultSet stringForColumn:@"NAME"];
            scene.roomID = [resultSet intForColumn:@"roomName"];
            
            scene.picName =[resultSet stringForColumn:@"pic"];
            scene.isFavorite = [resultSet boolForColumn:@"isFavorite"];
            
            scene.startTime = [resultSet stringForColumn:@"startTime"];
            scene.astronomicalTime = [resultSet stringForColumn:@"astronomicalTime"];
            scene.weekValue = [resultSet stringForColumn:@"weekValue"];
            scene.weekRepeat = [resultSet intForColumn:@"weekRepeat"];
            
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
        NSString *sql = [NSString stringWithFormat:@"select * from Scenes where rId=%d", roomID];
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
    scene.roomName = [resultSet stringForColumn:@"roomName"];
    
    scene.picName =[resultSet stringForColumn:@"pic"];
    scene.isFavorite = [resultSet boolForColumn:@"isFavorite"];
    scene.roomID = [resultSet intForColumn:@"rId"];
    int sType = [resultSet intForColumn:@"sType"];
    if(sType == 1)
    {
        scene.readonly = YES;
    }
    
    return scene;
    
}
+(Scene *)sceneBySceneID:(int)sId
{
    FMDatabase *db = [SQLManager connetdb];
    Scene *scene = [Scene new];
    if([db open])
    {
        NSString *sql = [NSString stringWithFormat:@"select * from Scenes where ID = %d",sId];
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
    NSString *dbPath = [[IOManager sqlitePath] stringByAppendingPathComponent:@"smartDB"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath] ;
    BOOL isSuccess = false;
    if([db open])
    {
        isSuccess = [db executeUpdateWithFormat:@"delete from Scenes where ID = %d",sceneId];
        [db close];
    }
    return isSuccess;
    
}
//根据房间ID获取该房间所有的场景
+(NSArray *)getScensByRoomId:(int)roomId
{
    NSMutableArray *scens = [NSMutableArray array];
    
    
    NSString *dbPath = [[IOManager sqlitePath] stringByAppendingPathComponent:@"smartDB"];
    
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    if([db open])
    {
        FMResultSet *resultSet = [db executeQueryWithFormat:@"select * from Scenes where rId = %d",roomId];
        while ([resultSet next]) {
            Scene *scene = [Scene new];
            scene.sceneName = [resultSet stringForColumn:@"NAME"];
            scene.sceneID = [resultSet intForColumn:@"ID"];
            scene.picName = [resultSet stringForColumn:@"pic"];
            scene.roomName = [resultSet stringForColumn:@"roomName"];
            [scens addObject:scene];
        }
    }
    
    
    return [scens copy];
    
    
    
}
//得到数据库中所有的场景ID
+(NSArray *)getAllSceneIdsFromSql
{
    NSMutableArray *sceneIds = [NSMutableArray array];
    NSString *dbPath = [[IOManager sqlitePath] stringByAppendingPathComponent:@"smartDB"];
    
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    if([db open])
    {
        NSString *sql = @"select ID from Scenes";
        FMResultSet *resultSet = [db executeQuery:sql];
        while ([resultSet next]) {
            int scendID = [resultSet intForColumn:@"ID"];
            [sceneIds addObject: [NSNumber numberWithInt:scendID]];
        }
        [db close];
    }
    return [sceneIds copy];
}

+(NSArray *)getFavorScene
{
    NSMutableArray *scens = [NSMutableArray array];
    
    
    NSString *dbPath = [[IOManager sqlitePath] stringByAppendingPathComponent:@"smartDB"];
    
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    if([db open])
    {
        FMResultSet *resultSet = [db executeQuery:@"select * from Scenes where isFavorite = 1"];
        while ([resultSet next]) {
            Scene *scene = [Scene new];
            scene.sceneName = [resultSet stringForColumn:@"NAME"];
            scene.sceneID = [resultSet intForColumn:@"ID"];
            scene.picName = [resultSet stringForColumn:@"pic"];
            scene.roomName = [resultSet stringForColumn:@"roomName"];
            [scens addObject:scene];
        }
    }
    
    
    return [scens copy];
    
    
}


+(NSArray *)getAllRoomsInfo
{
    FMDatabase *db = [SQLManager connetdb];
    NSMutableArray *roomList = [NSMutableArray array];
    if([db open])
    {
        NSString *sql = @"select * from Rooms";
        FMResultSet *resultSet = [db executeQuery:sql];
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


+(int)getRoomIDByRoomName:(NSString *)rName;
{
    FMDatabase *db = [SQLManager connetdb];
    int rID ;
    if([db open])
    {
        NSString *sql = [NSString stringWithFormat:@"SELECT ID FROM Rooms where Name = '%@'",rName];
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
+(NSString *)getRoomNameByRoomID:(int) rId
{
    FMDatabase *db = [SQLManager connetdb];
    NSString *rName ;
    if([db open])
    {
        NSString *sql = [NSString stringWithFormat:@"SELECT ID FROM Rooms where ID = %d",rId];
        FMResultSet *resultSet = [db executeQuery:sql];
        if ([resultSet next])
        {
            rName = [resultSet stringForColumn:@"roomName"];
        }
    }
    [db closeOpenResultSets];
    [db close];
    return rName;
    
}


@end
