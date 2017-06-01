//
//  IpadDeviceListViewController.h
//  SmartHome
//
//  Created by zhaona on 2017/5/25.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IpadDeviceTypeVC.h"
#import "SQLManager.h"

@interface IpadDeviceListViewController : UISplitViewController

@property (nonatomic,assign) int roomID;
//场景id
@property (nonatomic,assign) int sceneID;
//场景下的所有设备
@property (nonatomic,strong) NSArray *DevicesArr;
//照明
@property (nonatomic,strong) NSArray * LightArray;
//影音
@property (nonatomic,strong) NSArray * AudiovisualArray;
//空调
@property (nonatomic,strong) NSArray * AirArray;
//窗帘
@property (nonatomic,strong) NSArray * CurtainArray;
//智能单品
@property (nonatomic,strong) NSArray * PluginArray;

@property (strong, nonatomic) NSMutableArray *devices;

@end
