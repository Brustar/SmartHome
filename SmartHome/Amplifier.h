//
//  Amplifier.h
//  SmartHome
//
//  Created by Brustar on 16/8/29.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <Foundation/Foundation.h>
//功放
@interface Amplifier : NSObject

//设备id
@property (nonatomic) int deviceID;

//是否放映
@property (nonatomic) bool waiting;

@end
