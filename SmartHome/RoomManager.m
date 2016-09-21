//
//  RoomManager.m
//  SmartHome
//
//  Created by 逸云科技 on 16/8/6.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "RoomManager.h"
#import "IOManager.h"
#import "Room.h"
#import "FMDatabase.h"
#import "DeviceManager.h"

@implementation RoomManager

//根据主机ID获取房间配置信息
+(NSArray *)getAllRoomsInfo
{
    FMDatabase *db = [DeviceManager connetdb];
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
    FMDatabase *db = [DeviceManager connetdb];
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

@end
