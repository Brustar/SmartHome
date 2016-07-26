//
//  IBeacon.h
//  SmartHome
//
//  Created by Brustar on 16/5/10.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <Foundation/Foundation.h>

enum{
    UNKNOWN,
    iPhone,
    iPhone3G,
    iPhone3GS,
    iPhone4,
    iPhone4S,
    iPhone5,
    iPhone5C,
    iPhone5S,
    iPhoneSE,
    iPhone6,
    iPhone6S,
    iPhone6Plus,
    iPhone6SPlus,
    
    iPod,
    iPod2,
    iPod3,
    iPod4,
    iPod5,
    
    iPad,
    iPad2,
    iPad3,
    iPad4,
    iPadMini,
    iPadMini2,
    iPadMini3,
    iPadAir,
    iPadAir2,
    iPadPro
};

@interface DeviceInfo : NSObject

@property (nonatomic, strong) NSArray *beacons;
@property (nonatomic) float volume;
@property (nonatomic) int reachbility;
@property (nonatomic) int genaration;
@property (nonatomic, strong) NSString *pushToken;

@property (nonatomic) long masterID;
@property (nonatomic, strong) NSString *masterIP;
@property (nonatomic) int masterPort;

+ (id) defaultManager;
- (void) deviceGenaration;
- (void) initConfig;
- (void) netReachbility;

#pragma mark - public

//TV,DVD,NETV,BGMusic
-(NSData *) previous:(NSString *)deviceID;
-(NSData *) forward:(NSString *)deviceID; //快进
-(NSData *) backward:(NSString *)deviceID; //快退
-(NSData *) next:(NSString *)deviceID;

-(NSData *) play:(NSString *)deviceID;
-(NSData *) pause:(NSString *)deviceID;
-(NSData *) stop:(NSString *)deviceID;

-(NSData *) changeVolume:(uint8_t)percent deviceID:(NSString *)deviceID; //mute:pecent=0

//TV,DVD,NETV
-(NSData *) sweepLeft:(NSString *)deviceID;
-(NSData *) sweepRight:(NSString *)deviceID;
-(NSData *) sweepUp:(NSString *)deviceID;
-(NSData *) sweepDown:(NSString *)deviceID;

#pragma mark - lighter
-(NSData *) toogleLight:(uint8_t)toogle deviceID:(NSString *)deviceID;
-(NSData *) changeColor:(uint8_t)color deviceID:(NSString *)deviceID;
-(NSData *) changeBright:(uint8_t)bright deviceID:(NSString *)deviceID;

#pragma mark - curtain
-(NSData *) roll:(uint8_t)percent deviceID:(NSString *)deviceID; //开:percent=100,关percent=0
-(NSData *) open:(NSString *)deviceID;
-(NSData *) close:(NSString *)deviceID;

#pragma mark - TV
-(NSData *) switchProgram:(uint8_t)program deviceID:(NSString *)deviceID; //切换台

#pragma mark - DVD
-(NSData *) home:(NSString *)deviceID; //主页
-(NSData *) pop:(NSString *)deviceID; //出仓

#pragma mark - NETV
-(NSData *) NETVhome:(NSString *)deviceID; //主页

-(NSData *) back:(NSString *)deviceID;

#pragma mark - FM
-(NSData *) switchFMProgram:(uint8_t)program deviceID:(NSString *)deviceID; //切换台

#pragma mark - Guard
-(NSData *) toogle:(uint8_t)toogle deviceID:(NSString *)deviceID;

#pragma mark - Air
-(NSData *) toogleAirCon:(uint8_t)toogle deviceID:(NSString *)deviceID; //开:1,关:0
-(NSData *) changeTemperature:(uint8_t)temperature deviceID:(NSString *)deviceID;
-(NSData *) changeDirect:(uint8_t)direct deviceID:(NSString *)deviceID;
-(NSData *) changeSpeed:(uint8_t)speed deviceID:(NSString *)deviceID;
-(NSData *) changeMode:(uint8_t)mode deviceID:(NSString *)deviceID;
-(NSData *) changeInterval:(uint8_t)interval deviceID:(NSString *)deviceID;

#pragma mark - BGMusic CALL PUBLIC

@end
