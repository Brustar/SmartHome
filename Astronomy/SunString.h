//
//  SunString.h
//  定位location
//
//  Created by Brusar on 15/9/5.
//  Copyright (c) 2015年 U1KJ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SunString : NSObject

@property(nonatomic, strong) NSString *sunrise;

@property(nonatomic, strong) NSString *sunset;
//日出时间与天亮时间差地球自转6°,自转6°的时间=6/360*24*60=24 分钟
@property(nonatomic, strong) NSString *dayspring;

@property(nonatomic, strong) NSString *dusk;

@end
