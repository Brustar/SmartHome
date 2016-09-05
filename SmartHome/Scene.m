//
//  Scene.m
//  SmartHome
//
//  Created by Brustar on 16/5/6.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "Scene.h"

@implementation Scene

- (instancetype)initWhithoutSchedule
{
    self=[super init];
    if (self) {
        [self setStartTime:@""];
        [self setWeekValue:@""];
        [self setAstronomicalTime:@""];
        [self setRoomName:@""];
        [self setSceneName:@""];
        [self setPicName:@""];
    }
    return self;
}

@end
