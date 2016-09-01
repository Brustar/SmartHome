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
@property (nonatomic,assign) NSInteger pm25;
@property (nonatomic,assign) NSInteger noise;
@property (nonatomic,assign) NSInteger tempture;
@property (nonatomic,assign) NSInteger co2;
@property (nonatomic,assign) NSInteger moisture;
@property (nonatomic,strong) NSString *imgUrl;
@property (nonatomic,assign) int ibeacon;


+(instancetype)roomWithDict:(NSDictionary *)dict;
@end
