//
//  IBeacon.m
//  SmartHome
//
//  Created by Brustar on 16/5/10.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "DeviceInfo.h"
#import "sys/utsname.h"
#import <Reachability/Reachability.h>
#import "PackManager.h"
#import "ProtocolManager.h"

@implementation DeviceInfo

+ (id)defaultManager
{
    static DeviceInfo *sharedInstance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (void) netReachbility
{
    Reachability *curReach = [Reachability reachabilityWithHostname:@"www.apple.com"];
    NetworkStatus status = [curReach currentReachabilityStatus];
    self.reachbility=status;
}

-(void)initConfig
{
    //更新设备，房间，场景表
    
}

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

    NSLog(@"NOTE: Unknown device type: %@", deviceString);
    self.genaration = UNKNOWN;
}

-(NSData *) action:(uint8_t)action deviceID:(NSString *)deviceID
{
    Proto proto=createProto();
    proto.cmd=0x03;
    proto.action.state=action;
    ProtocolManager *manager=[ProtocolManager defaultManager];
    proto.deviceID=[[manager queryProtocol:deviceID] intValue];
    proto.deviceType=[manager queryAction:deviceID];
    proto.masterID=self.masterID;
    return dataFromProtocol(proto);
}

-(NSData *) action:(uint8_t)action deviceID:(NSString *)deviceID value:(uint8_t)value
{
    Proto proto=createProto();
    proto.cmd=0x03;
    proto.action.state=action;
    proto.action.RValue=value;
    ProtocolManager *manager=[ProtocolManager defaultManager];
    proto.deviceID=[[manager queryProtocol:deviceID] intValue];
    proto.deviceType=[manager queryAction:deviceID];
    proto.masterID=self.masterID;
    return dataFromProtocol(proto);
}

#pragma mark - public
//TV,DVD,NETV,BGMusic
-(NSData *) previous:(NSString *)deviceID
{
    return [self action:PROTOCOL_PREVIOUS deviceID:deviceID];
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
    return [self action:PROTOCOL_FORWARD deviceID:deviceID];
}

-(NSData *) play:(NSString *)deviceID
{
    return [self action:PROTOCOL_PLAY deviceID:deviceID];
}

-(NSData *) pause:(NSString *)deviceID
{
    return [self action:PROTOCOL_PAUSE deviceID:deviceID];
}

-(NSData *) stop:(NSString *)deviceID
{
    return [self action:PROTOCOL_STOP deviceID:deviceID];
}

-(NSData *) changeVolume:(uint8_t)percent deviceID:(NSString *)deviceID
{
    return [self action:PROTOCOL_VOLUME deviceID:deviceID value:percent];
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

-(NSData *) changeColor:(uint8_t)color deviceID:(NSString *)deviceID
{
    return [self action:color deviceID:deviceID];
}

-(NSData *) changeBright:(uint8_t)bright deviceID:(NSString *)deviceID
{
    return [self action:bright deviceID:deviceID];
}

#pragma mark - curtain
-(NSData *) roll:(uint8_t)percent deviceID:(NSString *)deviceID
{
    return [self action:0x2A deviceID:deviceID value:percent];
}

-(NSData *) open:(NSString *)deviceID
{
    return [self action:0x64 deviceID:deviceID];
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
    return [self action:0x3A deviceID:deviceID value:percent];
}

#pragma mark - DVD
-(NSData *) home:(NSString *)deviceID
{
    return [self action:0x20 deviceID:deviceID];
}

-(NSData *) pop:(NSString *)deviceID
{
    return [self action:0x30 deviceID:deviceID];
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

#pragma mark - FM
-(NSData *) switchFMProgram:(uint8_t)program deviceID:(NSString *)deviceID
{
    return [self action:program deviceID:deviceID];
}

#pragma mark - Guard
-(NSData *) toogle:(uint8_t)toogle deviceID:(NSString *)deviceID
{
    return [self action:toogle deviceID:deviceID];
}

#pragma mark - Air
-(NSData *) toogleAirCon:(uint8_t)toogle deviceID:(NSString *)deviceID
{
    return [self action:toogle deviceID:deviceID];
}
-(NSData *) changeTemperature:(uint8_t)temperature deviceID:(NSString *)deviceID
{
    return [self action:temperature deviceID:deviceID];
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