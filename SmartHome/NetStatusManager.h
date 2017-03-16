//
//  NetStatusManager.h
//  SmartHome
//
//  Created by Brustar on 16/7/8.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetStatusManager : NSObject

+ (BOOL) reachable;
+ (NSString *)getWifiName;
+ (BOOL) isEnableWIFI;
+ (BOOL) isEnableWWAN;

@end
