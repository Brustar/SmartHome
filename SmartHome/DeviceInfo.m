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
#import "HttpManager.h"
#import "MBProgressHUD+NJ.h"
#import "FMDatabase.h"
#import "DeviceManager.h"
#import "HttpManager.h"

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
    //创建sqlite数据库及结构
    [self initSQlite];
    
    //先判断版本号
    //更新设备，房间，场景表，protocol,写入sqlite
    //缓存协议
    /*
    NSString *url = [NSString stringWithFormat:@"%@GetProtocolConfig.aspx",[IOManager httpAddr]];
    id ver=[[NSUserDefaults standardUserDefaults] objectForKey:@"protocolVer"];
    NSDictionary *param = @{@"version":[NSString stringWithFormat:@"%@" ,ver]};
    HttpManager *http=[HttpManager defaultManager];
    http.delegate=self;
    http.tag = 1;
    [http sendPost:url param:param];
    */
}

-(void) httpHandler:(id) responseObject tag:(int)tag
{
    if(tag == 1)
    {
        NSString *dbPath = [[IOManager sqlitePath] stringByAppendingPathComponent:@"smartDB"];
        FMDatabase *db = [FMDatabase databaseWithPath:dbPath] ;
        if([responseObject[@"Result"] isEqualToString:@"0"]){
            if ([db open]) {
                [db executeQuery:@"delete from t_protocol_config"];
                int i=0;
                for (NSDictionary *dic in responseObject[@"messageInfo"]) {
                    NSString *sql=[NSString stringWithFormat:@"insert into t_protocol_config values(%d,%@,%@,'%@','%@','%@','%@','%@')",i++,dic[@"pId"],dic[@"pId"],dic[@"typeName"],dic[@"typeId"],dic[@"actName"],dic[@"actNameKey"],dic[@"actCode"]];
                    BOOL result=[db executeUpdate:sql];
                    if (result) {
                        NSLog(@"insert 成功");
                    }else{
                        NSLog(@"insert 失败");
                    }
                }
                [IOManager writeUserdefault:responseObject[@"Ver"] forKey:@"protocolVer"];
            }
        }
        //[[ProtocolManager defaultManager] fetchAll];
        [db close];
    }
}

-(void)initSQlite
{
    NSString *dbPath = [[IOManager sqlitePath] stringByAppendingPathComponent:@"smartDB"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath] ;
    if ([db open]) {

        NSString *sqlRoom=@"CREATE TABLE IF NOT EXISTS Rooms(ID INT PRIMARY KEY NOT NULL, NAME TEXT NOT NULL, \"PM25\" INTEGER, \"NOISE\" INTEGER, \"TEMPTURE\" INTEGER, \"CO2\" INTEGER, \"moisture\" INTEGER, \"imgUrl\" TEXT)";
        NSString *sqlChannel=@"CREATE TABLE IF NOT EXISTS Channels (\"id\" INTEGER PRIMARY KEY  NOT NULL  UNIQUE ,\"eqId\" INTEGER,\"cNumber\" INTEGER, \"Channel_name\" TEXT,\"Channel_pic\" TEXT, \"parent\" CHAR(2) NOT NULL  DEFAULT TV, \"isFavorite\" BOOL DEFAULT 0, \"eqNumber\" TEXT)";
        NSString *sqlDevice=@"CREATE TABLE IF NOT EXISTS Devices(ID INT PRIMARY KEY NOT NULL, NAME TEXT NOT NULL, \"sn\" TEXT, \"birth\" DATETIME, \"guarantee\" DATETIME, \"model\" TEXT, \"price\" FLOAT, \"purchase\" DATETIME, \"producer\" TEXT, \"gua_tel\" TEXT, \"power\" INTEGER, \"current\" FLOAT, \"voltage\" INTEGER, \"protocol\" TEXT, \"rID\" INTEGER, \"eNumber\" TEXT, \"hTypeId\" TEXT, \"subTypeId\" INTEGER, \"typeName\" TEXT, \"subTypeName\" TEXT, \"masterID\" TEXT)";
        NSString *sqlScene=@"CREATE TABLE IF NOT EXISTS \"Scenes\" (\"ID\" INT PRIMARY KEY  NOT NULL ,\"NAME\" TEXT NOT NULL ,\"roomName\" TEXT,\"pic\" CHAR(50) DEFAULT (null) ,\"isFavorite\" Key Boolean DEFAULT (0), \"eId\" INTEGER, \"startTime\" TEXT, \"astronomicalTime\" TEXT, \"weekValue\" TEXT, \"weekRepeat\" INTEGER, \"rId\" INTEGER)";
        //NSString *sqlProtocol=@"CREATE TABLE IF NOT EXISTS [t_protocol_config]([rid] [int] IDENTITY(1,1) NOT NULL,[eid] [int] NULL,[enumber] [varchar](64) NULL,[ename] [varchar](64) NULL,[etype] [varchar](64) NULL,[actname] [varchar](256) NULL,[actcode] [varchar](256) NULL, \"actKey\" VARCHAR)";
        NSArray *sqls=@[sqlRoom,sqlChannel,sqlDevice,sqlScene];//,sqlProtocol];
        //4.创表
        for (NSString *sql in sqls) {
            BOOL result=[db executeUpdate:sql];
            if (result) {
                NSLog(@"创表成功");
            }else{
                NSLog(@"创表失败");
            }
        }
    }else{
        NSLog(@"Could not open db.");
    }
    
    [db close];
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

-(NSData *) action:(uint8_t)action deviceID:(NSString *)deviceID
{
    Proto proto=createProto();
    if (self.connectState == atHome) {
        proto.cmd=0x04;
    }else if (self.connectState == outDoor){
        proto.cmd=0x03;
    }
    proto.action.state=action;
    NSString *enumber=[DeviceManager getENumber:[deviceID integerValue]];
    NSString *eid=[DeviceManager getEType:[deviceID integerValue]];
    proto.deviceID=CFSwapInt16BigToHost([PackManager NSDataToUint16:enumber]);
    proto.deviceType=[PackManager NSDataToUint8:eid];
    return dataFromProtocol(proto);
}

-(NSData *) action:(uint8_t)action deviceID:(NSString *)deviceID value:(uint8_t)value
{
    Proto proto=createProto();
    if (self.connectState == atHome) {
        proto.cmd=0x04;
    }else if (self.connectState == outDoor){
        proto.cmd=0x03;
    }
    proto.action.state=action;
    proto.action.RValue=value;
    NSString *eid=[DeviceManager getEType:[deviceID integerValue]];
    NSString *enumber=[DeviceManager getENumber:[deviceID integerValue]];
    proto.deviceID=CFSwapInt16BigToHost([PackManager NSDataToUint16:enumber]);
    proto.deviceType=[PackManager NSDataToUint8:eid];
    return dataFromProtocol(proto);
}

-(NSData *) action:(uint8_t)action deviceID:(NSString *)deviceID R:(uint8_t)red  G:(uint8_t)green B:(uint8_t)blue
{
    Proto proto=createProto();
    if (self.connectState == atHome) {
        proto.cmd=0x04;
    }else if (self.connectState == outDoor){
        proto.cmd=0x03;
    }
    proto.action.state=action;
    proto.action.RValue=red;
    proto.action.B=blue;
    proto.action.G=green;
    NSString *eid=[DeviceManager getEType:[deviceID integerValue]];
    NSString *enumber=[DeviceManager getENumber:[deviceID integerValue]];
    proto.deviceID=CFSwapInt16BigToHost([PackManager NSDataToUint16:enumber]);
    proto.deviceType=[PackManager NSDataToUint8:eid];
    return dataFromProtocol(proto);
}

-(NSData *) author
{
    Proto proto=createProto();
    if (self.connectState==outDoor) {
        if (self.masterPort==[IOManager tcpPort]) {
            proto.cmd=0x82;
        }else{
            proto.cmd=0x85;
        }
    }else if (self.connectState==atHome){
        proto.cmd=0x84;
    }
    proto.deviceType=0x00;
    proto.deviceID=0x00;
    
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