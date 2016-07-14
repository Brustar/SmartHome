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

@end
