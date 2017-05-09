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
        
        [self setSceneName:@""];
        [self setPicName:@""];
        [self setRoomName:@""];
        [self setSchedules:@[]];
        [self setDevices:@[]];
        
        
    }
    return self;
}

@end
