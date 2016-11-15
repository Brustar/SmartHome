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

@end
