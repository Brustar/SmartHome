//
//  packManager.m
//  SmartHome
//
//  Created by Brustar on 16/5/31.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "PackManager.h"

@implementation PackManager

+ (NSData *)convertHexStrToData:(NSString *)str {
    if (!str || [str length] == 0) {
        return nil;
    }
    
    NSMutableData *hexData = [[NSMutableData alloc] initWithCapacity:8];
    NSRange range;
    if ([str length] % 2 == 0) {
        range = NSMakeRange(0, 2);
    } else {
        range = NSMakeRange(0, 1);
    }
    for (NSInteger i = range.location; i < [str length]; i += 2) {
        unsigned int anInt;
        NSString *hexCharStr = [str substringWithRange:range];
        NSScanner *scanner = [[NSScanner alloc] initWithString:hexCharStr];
        
        [scanner scanHexInt:&anInt];
        NSData *entity = [[NSData alloc] initWithBytes:&anInt length:1];
        [hexData appendData:entity];
        
        range.location += range.length;
        range.length = 2;
    }
    
    NSLog(@"hexdata: %@", hexData);
    return hexData;
}

+ (NSString *)convertDataToHexStr:(NSData *)data {
    if (!data || [data length] == 0) {
        return @"";
    }
    NSMutableString *string = [[NSMutableString alloc] initWithCapacity:[data length]];
    
    [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
        unsigned char *dataBytes = (unsigned char*)bytes;
        for (NSInteger i = 0; i < byteRange.length; i++) {
            NSString *hexStr = [NSString stringWithFormat:@"%x", (dataBytes[i]) & 0xff];
            if ([hexStr length] == 2) {
                [string appendString:hexStr];
            } else {
                [string appendFormat:@"0%@", hexStr];
            }
        }
    }];
    
    return string;
}

+(NSData *)convertStrToHex:(NSString *)str
{
    // NSString --> hex
    //NSString *string = @"1a1b1c1d";
    const char *buf = [str UTF8String];
    NSMutableData *data = [NSMutableData data];
    if (buf)
    {
        uint32_t len = strlen(buf);
        
        char singleNumberString[3] = {'\0', '\0', '\0'};
        uint32_t singleNumber = 0;
        for(uint32_t i = 0 ; i < len; i+=2)
        {
            if ( ((i+1) < len) && isxdigit(buf[i]) && (isxdigit(buf[i+1])) )
            {
                singleNumberString[0] = buf[i];
                singleNumberString[1] = buf[i + 1];
                sscanf(singleNumberString, "%x", &singleNumber);
                uint8_t tmp = (uint8_t)(singleNumber & 0x000000FF);
                [data appendBytes:(void *)(&tmp)length:1];
            }
            else
            {
                break;
            }
        }
    }
    return data;
}

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
