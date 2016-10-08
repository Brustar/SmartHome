//
//  Schedule.m
//  SmartHome
//
//  Created by Brustar on 16/9/27.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "Schedule.h"

@implementation Schedule
- (instancetype)initWhithoutSchedule
{
    self = [super init];
    if(self)
    {
        [self setStartTime:@""];
        [self setEndTime:@""];
        [self setWeekDays:@[]];
    }
    return self;
}
@end
