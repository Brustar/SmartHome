//
//  DetailList.h
//  SmartHome
//
//  Created by 逸云科技 on 16/6/1.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DetailList : NSObject

@property (nonatomic,assign) NSInteger ID;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *sn;
@property (nonatomic,strong) NSDate *birth;
@property (nonatomic,strong) NSDate *guarantee;
@property (nonatomic,strong) NSString *model;
@property (nonatomic,assign) float price;
@property (nonatomic,strong) NSDate *purchase;
@property (nonatomic,strong) NSString *producer;
@property (nonatomic,strong) NSString *gua_tel;
@property (nonatomic,assign) NSInteger power;
@property (nonatomic,assign) float current;
@property (nonatomic,assign) NSInteger voltage;
@property (nonatomic,strong) NSString *protocol;

+(NSArray *)getDetailListWithID:(NSInteger) ID;
+(NSArray *)getDeviceForModel:(NSString *)str;
@end
