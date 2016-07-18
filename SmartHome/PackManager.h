//
//  packManager.h
//  SmartHome
//
//  Created by Brustar on 16/5/31.
//  Copyright © 2016年 Brustar. All rights reserved.
//
struct Action
{
    uint8_t state; //设备动作
    uint8_t RValue;//红色或设备属性值
    uint8_t G;//绿色值
    uint8_t B;//蓝色值
};

struct Protocol
{
    uint8_t head; //帧头
    uint8_t cmd; //CMDID
    uint16_t masterID; //中控ID
    
    struct Action action; //设备动作
    
    uint16_t deviceID; // 设备序号
    uint8_t deviceType; // 设备类型
    uint8_t tail; //帧尾
};

typedef struct Protocol Proto;

#define PROTOCOL_HEAD 0xEC
#define PROTOCOL_TAIL 0xEA

@interface PackManager : NSObject

NSData *dataFromProtocol(Proto protcol);
Proto protocolFromData(NSData *data);
Proto createProto();

+ (NSData *) fireflyProtocol:(NSString *)cmd;
+ (long) NSDataToUInt:(NSData *)data;
+ (NSString *) NSDataToIP:(NSData *)ip;
+ (BOOL) checkSum:(NSData *)data;
+ (BOOL) checkProtocol:(NSData *)data cmd:(long)value;

+ (NSData*)dataFormHexString:(NSString*)hexString;
+ (NSString *)hexStringFromData:(NSData*)data;

@end
