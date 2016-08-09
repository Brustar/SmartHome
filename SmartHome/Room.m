//
//  Room.m
//  SmartHome
//
//  Created by 逸云科技 on 16/8/8.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "Room.h"

@implementation Room
+(instancetype)roomWithDict:(NSDictionary *)dict
{
    Room *room = [[Room alloc]init];
    [room setValuesForKeysWithDictionary:dict];
    return room;
}
@end
