//
//  DeviceManager.m
//  SmartHome
//
//  Created by 逸云科技 on 16/8/5.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "DeviceManager.h"
#import "Device.h"
#import "FMDatabase.h"
#import "DeviceType.h"
@implementation DeviceManager

//从数据中获取所有设备信息
+(NSArray *)getAllDevicesInfo{
    
    
    NSString *dbPath = [[IOManager sqlitePath] stringByAppendingPathComponent:@"smartDB"];
    
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    NSMutableArray *deviceModels = [NSMutableArray array];
    if([db open])
    {
        FMResultSet *resultSet = [db executeQuery:@"select * from Devices"];
        
        while ([resultSet next]){
            
            
            [deviceModels addObject:[self deviceMdoelByFMResultSet:resultSet]];
            
        }
        
        
    }
    [db close];
    return [deviceModels copy];
}

+(NSString *)deviceNameByDeviceID:(int)eId
{
    NSString *dbPath = [[IOManager sqlitePath] stringByAppendingPathComponent:@"smartDB"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
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
    return eName;
}
+(NSString *)deviceTypeNameByDeviceID:(int)eId
{
    NSString *dbPath = [[IOManager sqlitePath] stringByAppendingPathComponent:@"smartDB"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
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
    NSString *dbPath = [[IOManager sqlitePath] stringByAppendingPathComponent:@"smartDB"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    if([db open])
    {
        NSString *sql = [NSString stringWithFormat:@"SELECT distinct typeName FROM Devices where rID = %ld",roomID];
        FMResultSet *resultSet = [db executeQuery:sql];
        while ([resultSet next])
        {
            NSString *typeName = [resultSet stringForColumn:@"typeName"];
            
            if ([typeName isEqualToString:@"开关"]||[typeName isEqualToString:@"调色"]||[typeName isEqualToString:@"调光"]) {
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
    
    return [subTypes copy];
}



+ (NSArray *)getLightTypeNameWithRoomID:(NSInteger)roomID
{
    NSMutableArray *lightNames = [NSMutableArray array];
    
    NSString *dbPath = [[IOManager sqlitePath] stringByAppendingPathComponent:@"smartDB"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
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
    
    return [lightNames copy];
}


+ (NSArray *)getLightWithTypeName:(NSString *)typeName roomID:(NSInteger)roomID
{
    NSMutableArray *lights = [NSMutableArray array];
    
    NSString *dbPath = [[IOManager sqlitePath] stringByAppendingPathComponent:@"smartDB"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
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
    
    return [lights copy];
}



+ (NSArray *)getCurtainTypeNameWithRoomID:(NSInteger)roomID
{
    NSMutableArray *curtainNames = [NSMutableArray array];
    
    NSString *dbPath = [[IOManager sqlitePath] stringByAppendingPathComponent:@"smartDB"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
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
    
    return [curtainNames copy];
}


+ (NSArray *)getCurtainWithTypeName:(NSString *)typeName roomID:(NSInteger)roomID
{
    NSMutableArray *curtains = [NSMutableArray array];
    
    NSString *dbPath = [[IOManager sqlitePath] stringByAppendingPathComponent:@"smartDB"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
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
    
    return [curtains copy];
}



+ (NSString *)deviceIDWithRoomID:(NSInteger)roomID withType:(NSString *)type
{
    NSString *deviceID = nil;
    
    NSString *dbPath = [[IOManager sqlitePath] stringByAppendingPathComponent:@"smartDB"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
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
    [db close];
    return deviceID;
}


+(NSArray *)getDeviceByTypeName:(NSString  *)typeName andRoomID:(NSInteger)roomID
{
    NSMutableArray *array = [NSMutableArray array];
    NSString *dbPath = [[IOManager sqlitePath] stringByAppendingPathComponent:@"smartDB"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
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
    [db close];
    return [array copy];
}

+(NSString *)getEType:(NSInteger)eID
{
    NSString * htypeID;
    NSString *dbPath = [[IOManager sqlitePath] stringByAppendingPathComponent:@"smartDB"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    if([db open])
    {
        NSString *sql = [NSString stringWithFormat:@"SELECT htypeID FROM Devices where ID = %ld",eID];
        FMResultSet *resultSet = [db executeQuery:sql];
        if ([resultSet next])
        {
            htypeID = [resultSet stringForColumn:@"htypeID"];
        }
    }
    [db close];
    return htypeID;
}


@end
