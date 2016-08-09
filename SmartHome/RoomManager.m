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
@implementation RoomManager

//从缓存中获取房间配置信息
+(NSDictionary *)getAllRoomsInfo
{
    NSString *roomPath = [[IOManager configPath:@"rooms"] stringByAppendingPathComponent:@"roomConfig.plist"];
    return [NSDictionary dictionaryWithContentsOfFile:roomPath];
}

+(NSArray *)getRoomModels
{
    NSMutableArray *arrayReturn = [NSMutableArray array];
    NSDictionary *roomDic = [self getAllRoomsInfo];
    NSArray *roomInfo = roomDic[@"roomList"];
    for(NSDictionary *dict in roomInfo)
    {
        Room *room = [Room roomWithDict:dict];
        [arrayReturn addObject:room];
    }
    if(arrayReturn.count == 0){
        return  nil;

    }
    return [arrayReturn copy];
}
@end
