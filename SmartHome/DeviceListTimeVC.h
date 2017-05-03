//
//  DeviceListTimeVC.h
//  SmartHome
//
//  Created by zhaona on 2017/1/9.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DeviceTimerCell.h"
#import "DeviceTimerInfo.h"
#import "CustomViewController.h"

@interface DeviceListTimeVC : CustomViewController

@property(nonatomic, strong) NSMutableArray *timerList;//设备定时列表

@end
