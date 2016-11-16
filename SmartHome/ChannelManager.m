//
//  ChannelManager.m
//  SmartHome
//
//  Created by 逸云科技 on 16/8/16.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "ChannelManager.h"
#import "FMDatabase.h"
#import "FMResultSet.h"
#import "SQLManager.h"
#import "TVChannel.h"

@implementation ChannelManager
+(NSMutableArray *)getAllChannelForFavoritedForType:(NSString *)type deviceID:(int)deviceID
{
        FMDatabase *db = [SQLManager connetdb];
        if (![db open]) {
            NSLog(@"Could not open db");
            return nil;
        }
    
        FMResultSet *resultSet = [db executeQueryWithFormat:@"select * from Channels where isFavorite = 1 and eqId = %d and parent = %@",deviceID,type];
        NSMutableArray *mutabelArr = [NSMutableArray array];
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

+(BOOL)upDateChannelForChannelID:(NSInteger)channel_id andNewChannel_Name:(NSString *)newName
{
    FMDatabase *db = [SQLManager connetdb];
    BOOL isSuccess = false;
    
    if([db open])
    {
        NSString *execute = [NSString stringWithFormat:@"update Channels set Channel_name = '%@' where Channel_id = %ld",newName,channel_id];
        
        isSuccess = [db executeUpdate:execute];
    }
    [db close];
    return isSuccess;
}

@end
