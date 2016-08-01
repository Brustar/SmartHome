//
//  ProtocolManager.h
//  SmartHome
//
//  Created by Brustar on 16/7/13.
//  Copyright © 2016年 Brustar. All rights reserved.
//

@interface ProtocolManager : NSObject

@property (strong, nonatomic) NSMutableDictionary* deviceTypes;
@property (strong, nonatomic) NSMutableDictionary* deviceStates;
@property (strong, nonatomic) NSMutableDictionary* deviceHexIDs;

+ (id) defaultManager;

- (void) fetchAll;

-(NSString*) queryDeviceTypes:(NSString*)Key;
-(void) addDeviceTypes:(NSString*)device key:(NSString*) key;
-(NSString *) queryDeviceStates:(NSString*)Key;
-(void) addDeviceStates:(NSString*)action Key:(NSString*) Key;
-(Byte) queryDeviceHexIDs:(NSString*)Key;
-(void) addDeviceHexIDs:(NSString*)action Key:(NSString*) Key;
-(void) trace;

@end
