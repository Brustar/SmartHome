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
    TVtype = 11,
    DVDtype = 13,
    bgmusic = 14,
    FM = 15,
    air = 31,
    doorclock = 40,
    projector = 16,
    screen = 17,
    amplifier = 18,
    camera = 45,
    plugin = 41,
    windowOpener = 42,
    flowering = 33,
    feeding = 34,
    Wetting
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
@property (nonatomic,assign) NSInteger power;//status: 开／关
@property (nonatomic, assign) NSInteger bright;//灯光亮度
@property (nonatomic, strong) NSString *color;//灯颜色
@property (nonatomic, assign) NSInteger position;//窗帘位置
@property (nonatomic, assign) NSInteger temperature;//空调的设定温度
@property (nonatomic, assign) NSInteger fanspeed;//空调风速
@property (nonatomic, assign) NSInteger air_model;//空调模式:制冷，制热，送风，除湿
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
