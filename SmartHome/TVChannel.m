//
//  TVChannel.m
//  SmartHome
//
//  Created by 逸云科技 on 16/6/13.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "TVChannel.h"
#import "FMDatabase.h"
#import "FMResultSet.h"

@implementation TVChannel

+(instancetype)getChannelFromChannelID:(NSInteger)channel_ID
{
//    NSString *dbPath = [[IOManager sqlitePath] stringByAppendingPathComponent:@"smartDB"];
//    FMDatabase *db = [FMDatabase databaseWithPath:dbPath] ;
//    if (![db open]) {
//        NSLog(@"Could not open db.");
//    }
//    FMResultSet *resultSet = [db executeQueryWithFormat:@"select * from Channels where id=%ld", channel_ID];
    TVChannel *channel = [TVChannel new];
//    channel.channel_name = [resultSet stringForColumn:@"Channel_name"];
//    channel.channel_id = [resultSet intForColumn:@"Channel_id"];
//    channel.channel_pic = [resultSet stringForColumn:@"Channel_pic"];
//    channel.isFavorite = [resultSet boolForColumn:@"isFavorite"];
//    channel.parent =[resultSet stringForColumn:@"parent"];
//    channel.channelValue=[resultSet intForColumn:@"channelValue"];
//    [db closeOpenResultSets];
//    [db close];
    
    return channel;
}

+(NSMutableArray *)getAllChannelForFavoritedForType:(NSString *)type;
{
//    NSString *dbPath = [[IOManager sqlitePath] stringByAppendingPathComponent:@"smartDB"];
//    FMDatabase *db = [FMDatabase databaseWithPath:dbPath] ;
//    if (![db open]) {
//        NSLog(@"Could not open db.");
//        
//    }
//    
//    FMResultSet *resultSet = [db executeQueryWithFormat:@"select * from Channels where isFavorite = 1 and parent = %@",type];
    NSMutableArray *mutabelArr = [NSMutableArray array];
//    while([resultSet next])
//    {
//        TVChannel *channel = [TVChannel new];
//        channel.channel_name = [resultSet stringForColumn:@"Channel_name"];
//        channel.channel_id = [resultSet intForColumn:@"Channel_id"];
//        channel.channel_pic = [resultSet stringForColumn:@"Channel_pic"];
//        channel.isFavorite = [resultSet boolForColumn:@"isFavorite"];
//        channel.channelValue=[resultSet intForColumn:@"channelValue"];
//        //channel.parent =[resultSet stringForColumn:@"parent"];
//        [mutabelArr addObject:channel];
//    }
//    [db closeOpenResultSets];
//    [db close];

    return mutabelArr;
}

+(BOOL)deleteChannelForChannelID:(NSInteger)channel_id
{
    NSString *dbPath = [[IOManager sqlitePath] stringByAppendingPathComponent:@"smartDB"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath] ;
    BOOL isSuccess = false;
    if([db open])
    {
         isSuccess = [db executeQueryWithFormat:@"delete from Channels where Channel_id = %ld",channel_id];
        [db close];
    }
    return isSuccess;
}

+(BOOL)upDateChannelForChannelID:(NSInteger)channel_id andNewChannel_Name:(NSString *)newName
{
    
    NSString *dbPath = [[IOManager sqlitePath] stringByAppendingPathComponent:@"smartDB"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath] ;
    BOOL isSuccess = false;
    
    if([db open])
    {
        NSString *execute = [NSString stringWithFormat:@"update Channels set Channel_name = '%@' where Channel_id = %ld",newName,channel_id];
        
        isSuccess = [db executeUpdate:execute];
        [db close];
    }
  
    return isSuccess;
}

@end
