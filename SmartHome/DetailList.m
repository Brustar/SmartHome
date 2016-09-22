//
//  DetailList.m
//  SmartHome
//
//  Created by 逸云科技 on 16/6/1.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "DetailList.h"
#import "FMDatabase.h"
#import "FMResultSet.h"
#import "SQLManager.h"

@implementation DetailList

+(NSArray *)getDetailListWithID:(NSInteger)ID
{
    FMDatabase *db = [SQLManager connetdb];
    if (![db open]) {
        NSLog(@"Could not open db.");
        return nil;
    }
    NSMutableArray *array = [NSMutableArray array];
    NSString *sql = [NSString stringWithFormat:@"select * from Devices where ID=%ld",(long)ID];
    FMResultSet *resultSet = [db executeQuery:sql];
    
    if([resultSet next])
    {
        [array addObject:[resultSet stringForColumn:@"NAME"]];
    }
    
    [db closeOpenResultSets];
    [db close];
    
    
    return array;
}

+(NSArray *)getDeviceForModel:(NSString *)str
{
    FMDatabase *db = [SQLManager connetdb];
    if (![db open]) {
        NSLog(@"Could not open db.");
        return nil;
    }
    NSMutableArray *array = [NSMutableArray array];
    
    NSString *strTemp = [NSString stringWithFormat:@"SELECT * FROM Devices where model='%@'", str];
    
    FMResultSet *resultSet = [db executeQuery:strTemp];
    
    while([resultSet next])
    {
        DetailList *list = [[DetailList alloc] init];
        list.ID = [resultSet intForColumn:@"ID"];
        list.name = [resultSet stringForColumn:@"NAME"];
        list.sn = [resultSet stringForColumn:@"sn"];
        
        [array addObject:list];
    }
    
    [db closeOpenResultSets];
    [db close];
    
    return array;
}

@end
