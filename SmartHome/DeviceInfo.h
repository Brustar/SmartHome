//
//  IBeacon.h
//  SmartHome
//
//  Created by Brustar on 16/5/10.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <Foundation/Foundation.h>

enum{
    offLine,  //离线
    atHome,// 在家模式
    outDoor,  // 户外模式
};

typedef enum {
     netState_outDoor_4G,
     netState_outDoor_WIFI,
     netState_atHome_WIFI,
     netState_atHome_4G,
     netState_notConnect
    
}netState;

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

#define SMART_DB @"smartDB"

#define KICK_OUT @"kicking"

@interface DeviceInfo : NSObject
//是否编辑场景时
@property (nonatomic) bool editingScene;
//ios设备的音量
@property (nonatomic) float volume;

//设备的apple型号
@property (nonatomic) int genaration;
//apn推送token
@property (nonatomic, strong) NSString *pushToken;
//ibeacon信息
@property (nonatomic, strong) NSArray *beacons;

//主机ID
@property (nonatomic) long masterID;
//主机ID
@property (nonatomic) long roomID;
//主机ip
@property (nonatomic, strong) NSString *masterIP;
//主机端口
@property (nonatomic) int masterPort;

//连接状态
@property (nonatomic) int connectState;
//判断是不是调用了相册
@property (nonatomic, assign) BOOL isPhotoLibrary;

+ (instancetype) defaultManager;

- (void) deviceGenaration;
- (void) initConfig;

#pragma mark - public
-(NSData *) author;
-(NSData *)startScenenAtMaster:(int)sceneid;
-(NSData *)query:(NSString *)deviceID;

//TV,DVD,NETV,BGMusic
-(NSData *) previous:(NSString *)deviceID;
-(NSData *) forward:(NSString *)deviceID; //快进
-(NSData *) backward:(NSString *)deviceID; //快退
-(NSData *) next:(NSString *)deviceID;

-(NSData *) play:(NSString *)deviceID;
-(NSData *) pause:(NSString *)deviceID;
-(NSData *) stop:(NSString *)deviceID;

-(NSData *) changeVolume:(uint8_t)percent deviceID:(NSString *)deviceID; //mute:pecent=0
-(NSData *) mute:(NSString *)deviceID;
-(NSData *) volumeUp:(NSString *)deviceID;
-(NSData *) volumeDown:(NSString *)deviceID;

//TV,DVD,NETV
-(NSData *) sweepLeft:(NSString *)deviceID;
-(NSData *) sweepRight:(NSString *)deviceID;
-(NSData *) sweepUp:(NSString *)deviceID;
-(NSData *) sweepDown:(NSString *)deviceID;
-(NSData *) sweepSURE:(NSString *)deviceID;
-(NSData *) menu:(NSString *)deviceID;

#pragma mark - lighter
-(NSData *) toogleLight:(uint8_t)toogle deviceID:(NSString *)deviceID;
-(NSData *) changeColor:(NSString *)deviceID R:(uint8_t)red  G:(uint8_t)green B:(uint8_t)blue;
-(NSData *) changeBright:(uint8_t)bright deviceID:(NSString *)deviceID;

#pragma mark - curtain
-(NSData *) roll:(uint8_t)percent deviceID:(NSString *)deviceID; //开:percent=100,关percent=0
-(NSData *) open:(NSString *)deviceID;
-(NSData *) close:(NSString *)deviceID;

#pragma mark - TV
-(NSData *) nextProgram:(NSString *)deviceID;
-(NSData *) previousProgram:(NSString *)deviceID;
-(NSData *) switchProgram:(uint8_t)program deviceID:(NSString *)deviceID; //切换台
-(NSData *) changeTVolume:(uint8_t)percent deviceID:(NSString *)deviceID;

#pragma mark - DVD
-(NSData *) home:(NSString *)deviceID; //主页
-(NSData *) pop:(NSString *)deviceID; //出仓

#pragma mark - NETV
-(NSData *) NETVhome:(NSString *)deviceID; //主页
-(NSData *) confirm:(NSString *)deviceID; //确定
-(NSData *) back:(NSString *)deviceID;

#pragma mark - FM
-(NSData *) switchFMProgram:(uint8_t)program dec:(uint8_t)dec deviceID:(NSString *)deviceID; //切换台

#pragma mark - Guard / Projector
-(NSData *) toogle:(uint8_t)toogle deviceID:(NSString *)deviceID;

#pragma mark - Screen
-(NSData *) drop:(uint8_t)droped deviceID:(NSString *)deviceID;
-(NSData *) stopScreenByDeviceID:(NSString *)deviceID;
-(NSData *) upScreenByDeviceID:(NSString *)deviceID;
-(NSData *) downScreenByDeviceID:(NSString *)deviceID;

#pragma mark - Air
-(NSData *) toogleAirCon:(uint8_t)toogle deviceID:(NSString *)deviceID; //开:1,关:0
-(NSData *) changeTemperature:(uint8_t)action deviceID:(NSString *)deviceID value:(uint8_t)temperature;
-(NSData *) changeDirect:(uint8_t)direct deviceID:(NSString *)deviceID;
-(NSData *) changeSpeed:(uint8_t)speed deviceID:(NSString *)deviceID;
-(NSData *) changeMode:(uint8_t)mode deviceID:(NSString *)deviceID;
-(NSData *) changeInterval:(uint8_t)interval deviceID:(NSString *)deviceID;

#pragma mark - BGMusic CALL PUBLIC
-(NSData *) repeat:(NSString *)deviceID;
-(NSData *) shuffle:(NSString *)deviceID;

@end
