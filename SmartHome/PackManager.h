//
//  packManager.h
//  SmartHome
//
//  Created by Brustar on 16/5/31.
//  Copyright © 2016年 Brustar. All rights reserved.
//
@interface PackManager : NSObject

+ (NSData *) fireflyProtocol:(NSString *)cmd;
+ (long) NSDataToUInt:(NSData *)data;
+ (NSString *) NSDataToIP:(NSData *)ip;
+ (BOOL) checkSum:(NSData *)data;
+ (BOOL) checkProtocol:(NSData *)data cmd:(long)value;

+ (void) handleUDP:(NSData *)data;

+ (NSData*)dataFormHexString:(NSString*)hexString;
+ (NSString *)hexStringFromData:(NSData*)data;

@end
