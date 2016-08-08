//
//  Device.m
//  SmartHome
//
//  Created by 逸云科技 on 16/8/5.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "Device.h"

@implementation Device
+ (instancetype)deviceWithDict:(NSDictionary *)dict
{
    Device *device = [[Device alloc] init];
    [device setValuesForKeysWithDictionary:dict];
    return device;
}
@end
