//
//  ProtocolManager.h
//  SmartHome
//
//  Created by Brustar on 16/7/13.
//  Copyright © 2016年 Brustar. All rights reserved.
//

@interface ProtocolManager : NSObject

@property (strong, nonatomic) NSMutableDictionary* Protocols;
@property (strong, nonatomic) NSMutableDictionary* actions;

+ (id) defaultManager;

- (void) fetchAll;

-(NSString*) queryProtocol:(NSString*)Key;
-(void) addProtocol:(NSString*)device key:(NSString*) key;
-(Byte) queryAction:(NSString*)Key;
-(void) addAction:(NSString*)action Key:(NSString*) Key;
-(void) trace;

@end
