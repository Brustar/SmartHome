//
//  DeviceTimingViewController.h
//  SmartHome
//
//  Created by zhaona on 2017/4/28.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomViewController.h"

@interface DeviceTimingViewController : CustomViewController

@property (weak, nonatomic) IBOutlet UIButton *DeviceTimingBtn;
@property (weak, nonatomic) IBOutlet UILabel *DeviceTimingLabel;
@property (nonatomic,assign) int roomId;
@property (nonatomic,assign) int sceneID;

@end
