//
//  NSString+RegMatch.h
//  SmartHome
//
//  Created by Brustar on 2016/11/15.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (RegMatch)

- (BOOL)isMobileNumber;

- (BOOL)isPassword;

@end
