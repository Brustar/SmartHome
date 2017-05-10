//
//  DeviceTimerSettingViewController.h
//  SmartHome
//
//  Created by KobeBryant on 2017/5/9.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "CustomViewController.h"
#import "Device.h"
#import "NewLightCell.h"
#import "AireTableViewCell.h"
#import "CurtainTableViewCell.h"
#import "TVTableViewCell.h"
#import "OtherTableViewCell.h"
#import "ScreenTableViewCell.h"
#import "DVDTableViewCell.h"
#import "ScreenCurtainCell.h"
#import "BjMusicTableViewCell.h"

@interface DeviceTimerSettingViewController : CustomViewController<UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, strong) UITableView *timerTableView;
@property(nonatomic, strong) Device *device;
@property(nonatomic, assign) NSInteger roomID;

@end
