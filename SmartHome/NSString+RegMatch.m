//
//  NSString+RegMatch.m
//  SmartHome
//
//  Created by Brustar on 2016/11/15.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "NSString+RegMatch.h"
#import "RegexKitLite.h"

@implementation NSString (RegMatch)


#pragma mark -判断手机号是否合法
- (BOOL)isMobileNumber
{
    NSString *regex=@"^1[3|4|5|6|7|8]\\d{9}$";
    return [self isMatchedByRegex:regex];
}

- (BOOL)isPassword
{
    return [self isMatchedByRegex:@"^.{6,8}$"];
}

-(BOOL)compareLater:(NSString*)date pattern:(NSString *)pattern{
    BOOL ci;
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:pattern];
    NSDate *dt1 = [[NSDate alloc] init];
    NSDate *dt2 = [[NSDate alloc] init];
    dt1 = [df dateFromString:date];
    dt2 = [df dateFromString:self];
    NSComparisonResult result = [dt1 compare:dt2];
    switch (result)
    {
            //date02比date01大
        case NSOrderedAscending: ci=YES; break;
            //date02比date01小
        case NSOrderedDescending: ci=NO; break;
            //date02=date01
        case NSOrderedSame: ci=NO; break;
        default: NSLog(@"erorr dates %@, %@", dt2, dt1); break;
    }
    return ci;
}

-(BOOL) laterDate:(NSString*)date
{
    return [self compareLater:date pattern:@"yyyy-MM-dd"];
}

-(BOOL) laterTime:(NSString*)time
{
    NSString *start = [NSString stringWithFormat:@"2016-01-01 %@",self];
    NSString *end = [NSString stringWithFormat:@"2016-01-01 %@",time];
    return [start compareLater:end pattern:@"yyyy-MM-dd HH:mm"];
}

@end
