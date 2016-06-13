//
//  packManager.m
//  SmartHome
//
//  Created by Brustar on 16/5/31.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "PackManager.h"

@implementation PackManager

+ (NSData *) fireflyProtocol:(NSString *)cmd
{
    NSData* bytes = [cmd dataUsingEncoding:NSUTF8StringEncoding];
    int len=[cmd length]+4;
    Byte array[]={0,0,0,0,0,0,0,0,0,0,0,0,len,0,0,0,2};
    NSData *data = [NSData dataWithBytes: array length: sizeof(array)];
    NSMutableData *ret=[[NSMutableData alloc] initWithData:data];
    [ret appendData:bytes];
    return ret;
}

@end
