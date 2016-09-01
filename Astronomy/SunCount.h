//
//  SunCount.h
//  定位location
//
//  Created by Brusar on 15/9/5.
//  Copyright (c) 2015年 U1KJ. All rights reserved.
//
#import "SunString.h"

@interface SunCount : NSObject

+(void)sunrisetWithLongitude:(double)longitude andLatitude:(double)latitude andResponse:(void(^)(SunString *sunString))responseBlock;

@end
