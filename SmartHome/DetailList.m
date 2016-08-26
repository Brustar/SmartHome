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
#import "Detail.h"

@implementation DetailList

+(NSArray *)getDetailListWithID:(NSInteger)ID
{
    NSString *dbPath = [[IOManager sqlitePath] stringByAppendingPathComponent:@"smartDB"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath] ;
    if (![db open]) {
        NSLog(@"Could not open db.");
        
    }
    NSMutableArray *array = [NSMutableArray array];
    NSString *sql = [NSString stringWithFormat:@"select * from Devices where ID=%ld",(long)ID];
    FMResultSet *resultSet = [db executeQuery:sql];
    
    if([resultSet next])
    {
        [array addObject:[resultSet stringForColumn:@"NAME"]];
        [array addObject:[resultSet stringForColumn:@"sn"]];
        
        
        NSString *birth = [resultSet stringForColumn:@"birth"];
        [array addObject:birth];

       
        NSString *guarantee = [resultSet stringForColumn:@"guarantee"];
        [array addObject:guarantee];

        [array addObject:[resultSet stringForColumn:@"model"]];
        [array addObject:[NSString stringWithFormat:@"%.2f",[resultSet doubleForColumn:@"price"]]];
        NSString *purchase = [resultSet stringForColumn:@"purchase"];
        [array addObject:purchase];
        
        [array addObject: [resultSet stringForColumn:@"producer"]];
        [array addObject: [resultSet stringForColumn:@"gua_tel"]];
        [array addObject: [NSString stringWithFormat:@"%d",[resultSet intForColumn:@"power"]]];
        [array addObject: [NSString stringWithFormat:@"%.2f",[resultSet doubleForColumn:@"current"]]];
        [array addObject: [NSString stringWithFormat:@"%d",[resultSet intForColumn:@"voltage"]]];
        [array addObject: [resultSet stringForColumn:@"protocol"]];
    }
    
   
    [db closeOpenResultSets];
    [db close];
    
    
    return array;

}
+(NSArray *)getDeviceForModel:(NSString *)str
{
    NSString *dbPath = [[IOManager sqlitePath] stringByAppendingPathComponent:@"smartDB"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath] ;
    if (![db open]) {
        NSLog(@"Could not open db.");
        
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
