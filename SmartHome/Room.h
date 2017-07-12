//
//  Room.h
//  SmartHome
//
//  Created by 逸云科技 on 16/8/8.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Room : NSObject
@property (nonatomic,assign) int rId;
@property (nonatomic,strong) NSString *rName;
@property (nonatomic,assign) NSInteger pm25;//PM2.5
@property (nonatomic,assign) NSInteger noise;
@property (nonatomic,assign) NSInteger tempture;//温度
@property (nonatomic,assign) NSInteger humidity;//湿度
@property (nonatomic,assign) NSInteger airStatus;//空调状态
@property (nonatomic,assign) NSInteger avStatus;//影音状态
@property (nonatomic,assign) NSInteger lightStatus;//灯状态
@property (nonatomic,assign) NSInteger co2;
@property (nonatomic,assign) NSInteger moisture;
@property (nonatomic,strong) NSString *imgUrl;
@property (nonatomic,assign) int ibeacon;


+(instancetype)roomWithDict:(NSDictionary *)dict;
@end
