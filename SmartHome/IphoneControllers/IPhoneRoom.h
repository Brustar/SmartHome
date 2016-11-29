//
//  IPhoneRoom.h
//  SmartHome
//
//  Created by zhaona on 2016/11/28.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IPhoneRoom : NSObject
@property (nonatomic,assign) int roomId;
@property (nonatomic,assign) int light;
@property (nonatomic,assign) int curtain;
@property (nonatomic,assign) int bgmusic;
@property (nonatomic,assign) int aircondition;
@property (nonatomic,assign) int dvd;
@property (nonatomic,assign) int tv;

@property (nonatomic,assign) int temperature;
@property (nonatomic,assign) int humidity;

@property (nonatomic,strong) NSString *roomName;//房间名字

@end
