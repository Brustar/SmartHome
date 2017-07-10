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
#import "CustomViewController.h"
#import "NowMusicController.h"
#import "LoadMaskHelper.h"

@interface IpadDeviceListViewController : CustomViewController<SingleMaskViewDelegate>

//@property(nonatomic,assign) int deviceID;
@property (nonatomic,assign) int roomID;
//场景id
@property (nonatomic,assign) int sceneID;
//场景下的所有设备
@property (nonatomic,strong) NSArray *DevicesArr;

@property (strong, nonatomic) NSMutableArray *devices;



@end
