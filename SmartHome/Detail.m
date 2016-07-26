//
//  Detail.m
//  SmartHome
//
//  Created by 逸云科技 on 16/6/1.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "Detail.h"
#import "FMDatabase.h"
#import "FMResultSet.h"

@implementation Detail

+(NSArray *)getAllDetails
{
    
    NSString *dbPath = [[IOManager sqlitePath] stringByAppendingPathComponent:@"smartDB"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath] ;
    if (![db open]) {
        NSLog(@"Could not open db.");
        
    }
    NSMutableArray *array = [NSMutableArray array];
   
    FMResultSet *resultSet = [db executeQuery:@"select * from Devices"];
    while ([resultSet next])
    {
        Detail *detail = [Detail new];
        detail.ID = [resultSet intForColumn:@"ID"];
        [array addObject:detail];
        
    }
    [db closeOpenResultSets];
    [db close];

    
    return [array copy];
}


@end
