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
@implementation RoomManager

//从数据库中获取房间配置信息
+(NSArray *)getAllRoomsInfo
{
    NSString *dbPath = [[IOManager sqlitePath] stringByAppendingPathComponent:@"smartDB"];
    
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    NSMutableArray *roomList = [NSMutableArray array];
    if([db open])
    {
        FMResultSet *resultSet = [db executeQuery:@"select * from Rooms"];
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
            [roomList addObject:room];
            
        }
    }
    [db close];
    
    return [roomList copy];
}


@end
