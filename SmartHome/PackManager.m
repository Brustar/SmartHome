//
//  packManager.m
//  SmartHome
//
//  Created by Brustar on 16/5/31.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "PackManager.h"

@implementation PackManager

NSData *dataFromProtocol(Proto protcol)
{
    // make a NSData object
    return [NSData dataWithBytes:&protcol length:sizeof(protcol)];
}

Proto protocolFromData(NSData *data)
{
    // make a new Protocol
    Proto proto;
    [data getBytes:&proto length:sizeof(proto)];
    return proto;
}

Proto createProto()
{
    Proto proto;
    proto.head=PROTOCOL_HEAD;
    proto.tail=PROTOCOL_TAIL;
    DeviceInfo *info=[DeviceInfo defaultManager];
    
    proto.masterID=info.masterID;
    return proto;
}

+ (NSData *) fireflyProtocol:(NSString *)cmd
{
    NSData* bytes = [cmd dataUsingEncoding:NSUTF8StringEncoding];
    long len=[cmd length]+4;
    Byte array[]={0,0,0,0,0,0,0,0,0,0,0,0,len,0,0,0,2};
    NSData *data = [NSData dataWithBytes: array length: sizeof(array)];
    NSMutableData *ret=[[NSMutableData alloc] initWithData:data];
    [ret appendData:bytes];
    return ret;
}

+ (BOOL) checkSum:(NSData *)data
{
    NSData *sum = [data subdataWithRange:NSMakeRange([data length]-2, 1)];
    long ret=0x00;
    for (int i=1; i<[data length]-2; i++) {
        ret = ret ^ [self NSDataToUInt:[data subdataWithRange:NSMakeRange(i, 1)]];
    }
    return [self NSDataToUInt:sum]==ret;
}

+ (BOOL) checkProtocol:(NSData *)data cmd:(long)value
{
    NSData *head = [data subdataWithRange:NSMakeRange(0, 1)];
    NSData *cmd = [data subdataWithRange:NSMakeRange(1, 1)];
    NSData *tail = [data subdataWithRange:NSMakeRange([data length]-1, 1)];
    return [self NSDataToUInt:head]==0xEC && [self NSDataToUInt:cmd]==value && [self NSDataToUInt:tail]==0xEA;
}

+ (long) NSDataToUInt:(NSData *)data
{
    NSString *result = [NSString stringWithFormat:@"0x%@",[[data description] substringWithRange:NSMakeRange(1, [[data description] length]-2)]];
    unsigned long ret = strtoul([result UTF8String],0,16);
    return ret;
}

+ (NSString *) NSDataToIP:(NSData *)ip
{
    NSData *ip1=[ip subdataWithRange:NSMakeRange(0, 1)];
    NSData *ip2=[ip subdataWithRange:NSMakeRange(1, 1)];
    NSData *ip3=[ip subdataWithRange:NSMakeRange(2, 1)];
    NSData *ip4=[ip subdataWithRange:NSMakeRange(3, 1)];
    
    return [NSString stringWithFormat:@"%ld.%ld.%ld.%ld",[self NSDataToUInt:ip1],[self NSDataToUInt:ip2],[self NSDataToUInt:ip3],[self NSDataToUInt:ip4]];
}

+ (NSData*)dataFormHexString:(NSString*)hexString
{
    hexString=[[hexString uppercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (!(hexString && [hexString length] > 0 && [hexString length]%2 == 0)) {
        return nil;
    }
    Byte tempbyte[1]={0};
    NSMutableData* bytes=[NSMutableData data];
    for(int i=0;i<[hexString length];i++)
    {
        unichar hex_char1 = [hexString characterAtIndex:i]; ////两位16进制数中的第一位(高位*16)
        int int_ch1;
        if(hex_char1 >= '0' && hex_char1 <='9')
            int_ch1 = (hex_char1-48)*16;   //// 0 的Ascll - 48
        else if(hex_char1 >= 'A' && hex_char1 <='F')
            int_ch1 = (hex_char1-55)*16; //// A 的Ascll - 65
        else
            return nil;
        i++;
        
        unichar hex_char2 = [hexString characterAtIndex:i]; ///两位16进制数中的第二位(低位)
        int int_ch2;
        if(hex_char2 >= '0' && hex_char2 <='9')
            int_ch2 = (hex_char2-48); //// 0 的Ascll - 48
        else if(hex_char2 >= 'A' && hex_char2 <='F')
            int_ch2 = hex_char2-55; //// A 的Ascll - 65
        else
            return nil;
        
        tempbyte[0] = int_ch1+int_ch2;  ///将转化后的数放入Byte数组里
        [bytes appendBytes:tempbyte length:1];
    }
    return bytes;
}

+ (NSString *)hexStringFromData:(NSData*)data
{
    return [[[[NSString stringWithFormat:@"%@",data]
              stringByReplacingOccurrencesOfString: @"<" withString: @""]
             stringByReplacingOccurrencesOfString: @">" withString: @""]
            stringByReplacingOccurrencesOfString: @" " withString: @""];
}

@end
