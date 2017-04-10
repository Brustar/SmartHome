//
//  WeChatPayManager.h
//  SmartHome
//
//  Created by KobeBryant on 2017/3/31.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WXApi.h"

@interface WeChatPayManager : NSObject<WXApiDelegate>

+ (instancetype)sharedInstance;
- (void)doPayWithPrepayId:(NSString *)prepayId;

@end
