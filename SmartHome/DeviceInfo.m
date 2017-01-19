//
//  IBeacon.m
//  SmartHome
//
//  Created by Brustar on 16/5/10.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "DeviceInfo.h"
#import "sys/utsname.h"
#import "PackManager.h"
#import "MBProgressHUD+NJ.h"
#import "FMDatabase.h"
#import "SQLManager.h"
//#import <AdSupport/ASIdentifierManager.h>

@implementation DeviceInfo

+ (instancetype)defaultManager
{
    static DeviceInfo *sharedInstance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

-(void)initConfig
{
    //创建sqlite数据库及结构
    [SQLManager initSQlite];
}

- (NSString *) imei
{
    return @"";
    //return [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
}

//取设备机型
- (void) deviceGenaration
{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    if ([deviceString isEqualToString:@"iPhone1,1"])    self.genaration = iPhone;
    if ([deviceString isEqualToString:@"iPhone1,2"])    self.genaration = iPhone3G;
    if ([deviceString isEqualToString:@"iPhone2,1"])    self.genaration = iPhone3GS;
    if ([deviceString isEqualToString:@"iPhone3,1"])    self.genaration = iPhone4;
    if ([deviceString isEqualToString:@"iPhone4,1"])    self.genaration = iPhone4S;
    if ([deviceString isEqualToString:@"iPhone5,2"] || [deviceString isEqualToString:@"iPhone5,2"])    self.genaration = iPhone5;
    if ([deviceString isEqualToString:@"iPhone5,3"] || [deviceString isEqualToString:@"iPhone5,4"])   self.genaration = iPhone5C;
    if ([deviceString isEqualToString:@"iPhone6,1"] || [deviceString isEqualToString:@"iPhone6,2"])   self.genaration = iPhone5S;
    if ([deviceString isEqualToString:@"iPhone7,1"])   self.genaration = iPhone6Plus;
    if ([deviceString isEqualToString:@"iPhone7,2"])    self.genaration = iPhone6;
    if ([deviceString isEqualToString:@"iPhone8,1"])    self.genaration = iPhone6S;
    if ([deviceString isEqualToString:@"iPhone8,2"])    self.genaration = iPhone6SPlus;
    
    if ([deviceString isEqualToString:@"iPod1,1"])      self.genaration = iPod;
    if ([deviceString isEqualToString:@"iPod2,1"])      self.genaration = iPod2;
    if ([deviceString isEqualToString:@"iPod3,1"])      self.genaration = iPod3;
    if ([deviceString isEqualToString:@"iPod4,1"])      self.genaration = iPod4;
    if ([deviceString isEqualToString:@"iPod5,1"])      self.genaration = iPod5;
    
    if ([deviceString isEqualToString:@"iPad1,1"])      self.genaration = iPad;
    if ([deviceString isEqualToString:@"iPad2,1"] || [deviceString isEqualToString:@"iPad2,2"] || [deviceString isEqualToString:@"iPad2,3"] || [deviceString isEqualToString:@"iPad2,4"])      self.genaration = iPad2;
    if ([deviceString isEqualToString:@"iPad2,5"] || [deviceString isEqualToString:@"iPad2,6"] || [deviceString isEqualToString:@"iPad2,7"] )      self.genaration = iPadMini;
    if ([deviceString isEqualToString:@"iPad3,1"] || [deviceString isEqualToString:@"iPad3,2"] || [deviceString isEqualToString:@"iPad3,3"])
        self.genaration = iPad3;
    if( [deviceString isEqualToString:@"iPad3,4"] || [deviceString isEqualToString:@"iPad3,5"] || [deviceString isEqualToString:@"iPad3,6"])      self.genaration = iPad4;
    if ([deviceString isEqualToString:@"iPad4,1"] || [deviceString isEqualToString:@"iPad4,2"] || [deviceString isEqualToString:@"iPad4,3"])    self.genaration = iPadAir;
    if ([deviceString isEqualToString:@"iPad5,3"] || [deviceString isEqualToString:@"iPad5,4"])      self.genaration = iPadAir2;
    if ([deviceString isEqualToString:@"iPad4,4"]
        ||[deviceString isEqualToString:@"iPad4,5"]
        ||[deviceString isEqualToString:@"iPad4,6"])      self.genaration = iPadMini2;
    if ([deviceString isEqualToString:@"iPad4,7"]
        ||[deviceString isEqualToString:@"iPad4,8"]
        ||[deviceString isEqualToString:@"iPad4,9"])      self.genaration = iPadMini3;
    
    if ([deviceString isEqualToString:@"iPad6,3"] || [deviceString isEqualToString:@"iPad6,4"] || [deviceString isEqualToString:@"iPad6,7"] || [deviceString isEqualToString:@"iPad6,8"]) self.genaration = iPadPro;

    NSLog(@"NOTE: device type: %@", deviceString);
}

-(NSData *)startScenenAtMaster:(int)sceneid
{
    NSString *snumber=[SQLManager getSnumber:sceneid];
    uint16_t sid=[PackManager NSDataToUint16:snumber];
    
    uint8_t cmd=0x89;
    Proto proto=createProto();
    proto.cmd=cmd;
    proto.deviceID=CFSwapInt16BigToHost(sid);
    proto.deviceType=cmd;
    proto.action.state=0x00;
    proto.action.RValue=0x00;
    proto.action.G=0x00;
    proto.action.B=0x00;
    return dataFromProtocol(proto);
}

-(NSData *) action:(uint8_t)action
{
    Proto proto=createProto();
    if (self.connectState == atHome) {
        proto.cmd=0x04;
    }else if (self.connectState == outDoor){
        proto.cmd=0x03;
    }
    proto.action.state=action;

    proto.deviceType=BGMUSIC_DEVICE_TYPE;
    return dataFromProtocol(proto);
}

-(NSData *) action:(uint8_t)action deviceID:(NSString *)deviceID
{
    Proto proto=createProto();
    if (self.connectState == atHome) {
        proto.cmd=0x04;
    }else if (self.connectState == outDoor){
        proto.cmd=0x03;
    }
    proto.action.state=action;
    NSString *enumber=[SQLManager getENumber:[deviceID integerValue]];
    NSString *eid=[SQLManager getEType:[deviceID integerValue]];
    proto.deviceID=CFSwapInt16BigToHost([PackManager NSDataToUint16:enumber]);
    proto.deviceType=[PackManager NSDataToUint8:eid];
    return dataFromProtocol(proto);
}

-(NSData *) action:(uint8_t)action deviceID:(NSString *)deviceID value:(uint8_t)value
{
    
    NSData *data = [self action:action deviceID:deviceID];
    Proto proto = protocolFromData(data);
    
    proto.action.RValue=value;
    return dataFromProtocol(proto);
}

-(NSData *) action:(uint8_t)action deviceID:(NSString *)deviceID R:(uint8_t)red  G:(uint8_t)green B:(uint8_t)blue
{
    NSData *data = [self action:action deviceID:deviceID];
    Proto proto = protocolFromData(data);
    
    proto.action.RValue=red;
    proto.action.B=blue;
    proto.action.G=green;

    return dataFromProtocol(proto);
}

-(NSData *) author
{
    Proto proto=createProto();
    if (self.connectState==outDoor) {
        if (self.masterPort == [IOManager tcpPort]) {
            proto.cmd=0x82;
        }else{
            proto.cmd=0x85;
        }
    }else if (self.connectState==atHome){
        proto.cmd=0x84;
    }
    proto.deviceType=0x00;
    proto.deviceID=0x00;
    proto.action.state=0x00;
    proto.action.RValue=0x00;
    proto.action.G=0x00;
    proto.action.B=0x00;
    return dataFromProtocol(proto);
}

#pragma mark - public
//TV,DVD,NETV,BGMusic
-(NSData *) previous:(NSString *)deviceID
{
    if (deviceID) {
        return [self action:PROTOCOL_PREVIOUS deviceID:deviceID];
    }else{
        return [self action:PROTOCOL_PREVIOUS];
    }
}

-(NSData *) forward:(NSString *)deviceID
{
    return [self action:PROTOCOL_FORWARD deviceID:deviceID];
}

-(NSData *) backward:(NSString *)deviceID
{
    return [self action:PROTOCOL_BACKWARD deviceID:deviceID];
}

-(NSData *) next:(NSString *)deviceID
{
    if (deviceID) {
        return [self action:PROTOCOL_NEXT deviceID:deviceID];
    }else{
        return [self action:PROTOCOL_NEXT];
    }
}

-(NSData *) play:(NSString *)deviceID
{
    if (deviceID) {
        return [self action:PROTOCOL_PLAY deviceID:deviceID];
    }else{
        return [self action:PROTOCOL_PLAY];
    }
}

-(NSData *) pause:(NSString *)deviceID
{
    if (deviceID) {
        return [self action:PROTOCOL_PAUSE deviceID:deviceID];
    }else{
        return [self action:PROTOCOL_PAUSE];
    }
}

-(NSData *) stop:(NSString *)deviceID
{
    return [self action:PROTOCOL_STOP deviceID:deviceID];
}

-(NSData *) changeVolume:(uint8_t)percent deviceID:(NSString *)deviceID
{
    return [self action:PROTOCOL_VOLUME deviceID:deviceID value:percent];
}

-(NSData *) mute:(NSString *)deviceID
{
    return [self action:PROTOCOL_MUTE deviceID:deviceID];
}

-(NSData *) volumeUp:(NSString *)deviceID
{
    return [self action:PROTOCOL_VOLUME_UP deviceID:deviceID];
}

-(NSData *) volumeDown:(NSString *)deviceID
{
    return [self action:PROTOCOL_VOLUME_DOWN deviceID:deviceID];
}

//TV,DVD,NETV
-(NSData *) sweepLeft:(NSString *)deviceID
{
    return [self action:PROTOCOL_LEFT deviceID:deviceID];
}

-(NSData *) sweepRight:(NSString *)deviceID
{
    return [self action:PROTOCOL_RIGHT deviceID:deviceID];
}

-(NSData *) sweepUp:(NSString *)deviceID
{
    return [self action:PROTOCOL_UP deviceID:deviceID];
}

-(NSData *) sweepDown:(NSString *)deviceID
{
    return [self action:PROTOCOL_DOWN deviceID:deviceID];
}

#pragma mark - lighter
-(NSData *) toogleLight:(uint8_t)toogle deviceID:(NSString *)deviceID
{
    return [self action:toogle deviceID:deviceID];
}

-(NSData *) changeColor:(NSString *)deviceID R:(uint8_t)red  G:(uint8_t)green B:(uint8_t)blue
{
    return [self action:0x1B deviceID:deviceID R:red G:green B:blue];
}

-(NSData *) changeBright:(uint8_t)bright deviceID:(NSString *)deviceID
{
    return [self action:0x1a deviceID:deviceID value:bright];
}

#pragma mark - curtain
-(NSData *) roll:(uint8_t)percent deviceID:(NSString *)deviceID
{
    return [self action:0x2A deviceID:deviceID value:percent];
}

-(NSData *) open:(NSString *)deviceID
{
    return [self action:0x01 deviceID:deviceID];
}

-(NSData *) close:(NSString *)deviceID
{
    return [self action:0x00 deviceID:deviceID];
}

#pragma mark - TV
-(NSData *) switchProgram:(uint8_t)program deviceID:(NSString *)deviceID
{
    return [self action:0x3A deviceID:deviceID value:program];
}

-(NSData *) changeTVolume:(uint8_t)percent deviceID:(NSString *)deviceID
{
    return [self action:0xAA deviceID:deviceID value:percent];
}

#pragma mark - DVD
-(NSData *) home:(NSString *)deviceID
{
    return [self action:0x11 deviceID:deviceID];
}

-(NSData *) pop:(NSString *)deviceID
{
    return [self action:0x20 deviceID:deviceID];
}

#pragma mark - NETV
-(NSData *) NETVhome:(NSString *)deviceID
{
    return [self action:0x11 deviceID:deviceID];
}

-(NSData *) back:(NSString *)deviceID
{
    return [self action:0x10 deviceID:deviceID];
}

-(NSData *) confirm:(NSString *)deviceID
{
    return [self action:0x09 deviceID:deviceID];
}

#pragma mark - FM
-(NSData *) switchFMProgram:(uint8_t)program deviceID:(NSString *)deviceID
{
    return [self action:program deviceID:deviceID];
}

#pragma mark - Guard / Projector
-(NSData *) toogle:(uint8_t)toogle deviceID:(NSString *)deviceID
{
    return [self action:toogle deviceID:deviceID];
}

#pragma mark - Screen
-(NSData *) drop:(uint8_t)droped deviceID:(NSString *)deviceID
{
    return [self action:0x34-droped deviceID:deviceID];
}

#pragma mark - Air
-(NSData *) toogleAirCon:(uint8_t)toogle deviceID:(NSString *)deviceID
{
    return [self action:toogle deviceID:deviceID];
}
-(NSData *) changeTemperature:(uint8_t)action deviceID:(NSString *)deviceID value:(uint8_t)temperature
{
    return [self action:action deviceID:deviceID value:temperature];
}
-(NSData *) changeDirect:(uint8_t)direct deviceID:(NSString *)deviceID
{
    return [self action:direct deviceID:deviceID];
}
-(NSData *) changeSpeed:(uint8_t)speed deviceID:(NSString *)deviceID
{
    return [self action:speed deviceID:deviceID];
}
-(NSData *) changeMode:(uint8_t)mode deviceID:(NSString *)deviceID
{
    return [self action:mode deviceID:deviceID];
}
-(NSData *) changeInterval:(uint8_t)interval deviceID:(NSString *)deviceID
{
    return [self action:interval deviceID:deviceID];
}

@end
