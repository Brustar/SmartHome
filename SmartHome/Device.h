//
//  Device.h
//  SmartHome
//
//  Created by Brustar on 16/5/6.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Device : NSObject

//设备id
@property (nonatomic) int deviceID;
//开关状态
@property (nonatomic) bool isPoweron;
//定时启动时间 now+延时秒数=延时启动
@property (nonatomic) int timer;

@end
