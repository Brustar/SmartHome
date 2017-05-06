//
//  Device.h
//  SmartHome
//
//  Created by 逸云科技 on 16/8/5.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, deviceType) {
    light = 1,
    curtain = 7,
    TVtype = 12,
    DVDtype = 13,
    bgmusic = 14,
    FM = 15,
    air = 31,
    doorclock = 40,
    projector = 16,
    screen = 17,
    amplifier = 18,
    camera = 45,
    plugin = 41
};

typedef NS_ENUM(NSUInteger, catalog) {
    cata_light = 1,
    cata_env ,
    cata_media ,
    cata_single_product = 5,
    cata_curtain = 7
};

@interface Device : NSObject

@property (nonatomic,assign) int eID;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *sn;
@property (nonatomic,strong) NSString *birth;
@property (nonatomic,strong) NSString *guarantee;
@property (nonatomic,strong) NSString *model;
@property (nonatomic,assign) double price;
@property (nonatomic,strong) NSString *purchase;
@property (nonatomic,strong) NSString *producer;
@property (nonatomic,strong) NSString *gua_tel;
@property (nonatomic,assign) NSInteger power;
@property (nonatomic,assign) double current;
@property (nonatomic,assign) NSInteger voltage;
@property (nonatomic,strong) NSString *protocol;
@property (nonatomic,assign) NSInteger rID;//房间id
@property (nonatomic,strong) NSString *rName;//房间名
@property (nonatomic,assign) NSInteger eNumber;
@property (nonatomic,assign) NSInteger hTypeId;
@property (nonatomic,assign) NSInteger subTypeId;
@property (nonatomic,strong) NSString *typeName;
@property (nonatomic,strong) NSString *subTypeName;

+ (instancetype)deviceWithDict:(NSDictionary *)dict;
@end
