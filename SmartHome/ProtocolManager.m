//
//  ProtocolManager.m
//  SmartHome
//
//  Created by Brustar on 16/7/13.
//  Copyright © 2016年 Brustar. All rights reserved.
//
#import "ProtocolManager.h"
#import "PackManager.h"
#import "FMDatabase.h"

@implementation ProtocolManager

+ (id)defaultManager
{
    static ProtocolManager *sharedInstance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (void) fetchAll
{
    self.Protocols =[[NSMutableDictionary alloc] init];
    self.actions =[[NSMutableDictionary alloc] init];
    NSString *dbPath = [[IOManager sqlitePath] stringByAppendingPathComponent:@"smartDB"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath] ;
    if (![db open]) {
        NSLog(@"Could not open db.");
    }
    
    FMResultSet *resultSet = [db executeQueryWithFormat:@"select * from Protocol"];
    while([resultSet next])
    {
        NSString *key=[NSString stringWithFormat:@"%@",[resultSet stringForColumn:@"deviceName"]];
        NSString *protocol =[NSString stringWithFormat:@"%@",[resultSet stringForColumn:@"device"]];
        NSString *action =[resultSet stringForColumn:@"action"];
        [self addProtocol:protocol key:key];
        [self addAction:action Key:key];
    }
    [db closeOpenResultSets];
    [db close];
}

-(NSString*) queryProtocol:(NSString*)key
{
    return [self.Protocols objectForKey:key];
}

-(void) addProtocol:(NSString*)protocol key:(NSString*) key
{
    [self.Protocols setObject:protocol forKey:key];
}

-(Byte) queryAction:(NSString*)key
{
    NSNumber* ret = [self.actions objectForKey:key];
    return [ret charValue];
}

-(void) addAction:(NSString*)action Key:(NSString*) key
{
    NSData* data = [PackManager dataFormHexString:action];
    if(data.length > 0)
    {
        Byte* bytes = (Byte*)([data bytes]);
        NSNumber* b1 = [NSNumber numberWithChar:bytes[0]];
        [self.actions setObject:b1 forKey:key];
    }
}

-(void) trace
{
    for(NSString* key in self.Protocols)
    {
        NSLog(@"键值:%@ 对应协议:%@",key,self.Protocols[key]);
    }
}

@end
