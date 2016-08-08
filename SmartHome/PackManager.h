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

#define PROTOCOL_OFF 0x00
#define PROTOCOL_ON 0x01

#define PROTOCOL_PLAY 0x02
#define PROTOCOL_PAUSE 0x03
#define PROTOCOL_STOP 0x04

#define PROTOCOL_LEFT 0x05
#define PROTOCOL_RIGHT 0x06
#define PROTOCOL_UP 0x07
#define PROTOCOL_DOWN 0x08

#define PROTOCOL_PREVIOUS 0x09
#define PROTOCOL_NEXT 0x0A
#define PROTOCOL_FORWARD 0x0B
#define PROTOCOL_BACKWARD 0x0C

#define PROTOCOL_VOLUME 0xAA

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

+(uint8_t)dataToUint:(NSData *)data;

@end
