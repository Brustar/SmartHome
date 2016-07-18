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

#pragma mark - lighter
-(NSData *) toogleLight:(bool)toogle deviceID:(NSString *)deviceID;
-(NSData *) changeColor:(long)color deviceID:(NSString *)deviceID;
-(NSData *) changeBright:(int)bright deviceID:(NSString *)deviceID;

#pragma mark - curtain
-(NSData *) roll:(int)percent; //开:percent=100,关percent=0
-(NSData *) open;
-(NSData *) close;

#pragma mark - TV
-(NSData *) switchProgram:(int)program; //切换台
-(NSData *) sweepLeft;
-(NSData *) sweepRight;
-(NSData *) sweepUp;
-(NSData *) sweepDown;

-(NSData *) changeTVolume:(int)percent; //mute:pecent=0

#pragma mark - DVD
-(NSData *) home; //主页
-(NSData *) play;
-(NSData *) pause;
-(NSData *) stop;
-(NSData *) previous;
-(NSData *) next;
-(NSData *) first;
-(NSData *) last;
-(NSData *) pop; //出仓


-(NSData *) DVDsweepLeft;
-(NSData *) DVDsweepRight;
-(NSData *) DVDsweepUp;
-(NSData *) DVDsweepDown;

-(NSData *) changeDVDVolume:(int)percent; //mute:pecent=0

#pragma mark - NETV
-(NSData *) NETVhome; //主页
-(NSData *) NETVplay;
-(NSData *) NETVpause;
-(NSData *) NETVstop;
-(NSData *) NETVprevious;
-(NSData *) NETVnext;
-(NSData *) NETVfirst;
-(NSData *) NETVlast;
-(NSData *) NETVpop; //出仓
-(NSData *) back;

-(NSData *) NETVsweepLeft;
-(NSData *) NETVsweepRight;
-(NSData *) NETVsweepUp;
-(NSData *) NETVsweepDown;

-(NSData *) changeNETVolume:(int)percent; //mute:pecent=0

#pragma mark - FM
-(NSData *) switchFMProgram:(long)program; //切换台

-(NSData *) changeFMVolume:(int)percent; //mute:pecent=0

#pragma mark - Guard
-(NSData *) toogle:(bool)toogle;

#pragma mark - Air
-(NSData *) toogleAirCon:(bool)toogle; //开:1,关:0
-(NSData *) changeTemperature:(int)temperature;
-(NSData *) changeDirect:(int)direct;
-(NSData *) changeSpeed:(int)speed;
-(NSData *) changeMode:(int)mode;
-(NSData *) changeInterval:(int)interval;

@end
