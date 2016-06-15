//
//  TVChannel.m
//  SmartHome
//
//  Created by 逸云科技 on 16/6/13.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "TVChannel.h"
#import "IOManager.h"
#import "FMDatabase.h"
#import "FMResultSet.h"
@implementation TVChannel

+(instancetype)getChannelFromChannelID:(NSInteger)channel_ID
{
    NSString *dbPath = [[IOManager sqlitePath] stringByAppendingPathComponent:@"smartDB"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath] ;
    if (![db open]) {
        NSLog(@"Could not open db.");
        
    }
    FMResultSet *resultSet = [db executeQueryWithFormat:@"select * from Channels where id=%ld", channel_ID];
    TVChannel *channel = [TVChannel new];
    channel.channel_name = [resultSet stringForColumn:@"Channel_name"];
    channel.channel_id = [resultSet intForColumn:@"Channel_id"];
    channel.channel_pic = [resultSet stringForColumn:@"Channel_pic"];
    channel.isFavorite = [resultSet boolForColumn:@"isFavorite"];
    channel.parent =[resultSet stringForColumn:@"parent"];
    [db closeOpenResultSets];
    [db close];
    
    return channel;
}

+(NSArray *)getAllChannelForFavoritedForType:(NSString *)type;
{
    NSString *dbPath = [[IOManager sqlitePath] stringByAppendingPathComponent:@"smartDB"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath] ;
    if (![db open]) {
        NSLog(@"Could not open db.");
        
    }
    
    FMResultSet *resultSet = [db executeQueryWithFormat:@"select * from Channels where isFavorite = 1 and parent = %@",type];
    NSMutableArray *mutabelArr = [NSMutableArray array];
    while([resultSet next])
    {
        TVChannel *channel = [TVChannel new];
        channel.channel_name = [resultSet stringForColumn:@"Channel_name"];
        channel.channel_id = [resultSet intForColumn:@"Channel_id"];
        channel.channel_pic = [resultSet stringForColumn:@"Channel_pic"];
        channel.isFavorite = [resultSet boolForColumn:@"isFavorite"];
        //channel.parent =[resultSet stringForColumn:@"parent"];
        [mutabelArr addObject:channel];
    }
    NSLog(@"------------%ld",mutabelArr.count);
    [db closeOpenResultSets];
    [db close];
    
    return mutabelArr;
    
}


@end
