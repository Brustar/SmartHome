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
    self.deviceTypes =[[NSMutableDictionary alloc] init];
    self.deviceStates =[[NSMutableDictionary alloc] init];
    self.deviceHexIDs =[[NSMutableDictionary alloc] init];
    NSString *dbPath = [[IOManager sqlitePath] stringByAppendingPathComponent:@"smartDB"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath] ;
    if (![db open]) {
        NSLog(@"Could not open db.");
    }
    
    FMResultSet *resultSet = [db executeQueryWithFormat:@"select * from t_protocol_config"];
    while([resultSet next])
    {
        NSString *key=[NSString stringWithFormat:@"%@_%@",[resultSet stringForColumn:@"actKey"],[resultSet stringForColumn:@"eid"]];
        NSString *type =[NSString stringWithFormat:@"%@",[resultSet stringForColumn:@"etype"]];
        NSString *state = [resultSet stringForColumn:@"actcode"];
        NSString *hexID = [resultSet stringForColumn:@"enumber"];
        [self addDeviceTypes:type key:key];
        [self addDeviceStates:state Key:key];
        [self addDeviceHexIDs:hexID Key:key];
    }
    [db closeOpenResultSets];
    [db close];
}

-(NSString *) queryDeviceTypes:(NSString*)key
{
    return [self.deviceTypes objectForKey:key];
}

-(void) addDeviceTypes:(NSString*)protocol key:(NSString*) key
{
    [self.deviceTypes setObject:protocol forKey:key];
}

-(NSString *) queryDeviceStates:(NSString*)key
{
    NSString *ret = [self.deviceStates objectForKey:key];
    return ret;
}

-(void) addDeviceStates:(NSString*)state Key:(NSString*) key
{
    [self.deviceStates setObject:state forKey:key];
}

-(Byte) queryDeviceHexIDs:(NSString*)key
{
    NSData* data = [PackManager dataFormHexString:[NSString stringWithFormat:@"%@",[self.deviceHexIDs objectForKey:key]]];
    Byte* bytes = (Byte*)([data bytes]);
    
    return bytes[0];
}

-(void) addDeviceHexIDs:(NSString*)hex Key:(NSString*) key
{
    [self.deviceHexIDs setObject:hex forKey:key];
    /*
    NSData* data = [PackManager dataFormHexString:hex];
    if(data.length > 0)
    {
        Byte* bytes = (Byte*)([data bytes]);
        NSNumber* b1 = [NSNumber numberWithChar:bytes[0]];
        [self.deviceHexIDs setObject:b1 forKey:key];
    }
     */
}

-(void) trace
{
    for(NSString* key in self.deviceTypes)
    {
        NSLog(@"键值:%@ 对应设备类型:%@ hex:%@ state:%@",key,self.deviceTypes[key],self.deviceHexIDs[key],self.deviceStates[key]);
    }
}

@end
