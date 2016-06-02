//
//  EntranceGuard.h
//  SmartHome
//
//  Created by Brustar on 16/5/23.
//  Copyright © 2016年 Brustar. All rights reserved.
// 门禁

#import <Foundation/Foundation.h>

@interface EntranceGuard : NSObject

//设备id
@property (nonatomic) int deviceID;
//开关状态
@property (nonatomic) bool isPoweron;

@end
