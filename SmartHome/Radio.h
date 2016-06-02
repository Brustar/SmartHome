//
//  Radio.h
//  SmartHome
//
//  Created by Brustar on 16/5/23.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Radio : NSObject

//设备id
@property (nonatomic) int deviceID;
//开关状态
@property (nonatomic) bool isPoweron;
//音量
@property (nonatomic) int volume;

@end
