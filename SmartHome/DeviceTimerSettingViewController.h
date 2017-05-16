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
#import "NewColourCell.h"
#import "FMTableViewCell.h"
#import "AireTableViewCell.h"
#import "CurtainTableViewCell.h"
#import "TVTableViewCell.h"
#import "OtherTableViewCell.h"
#import "ScreenTableViewCell.h"
#import "DVDTableViewCell.h"
#import "ScreenCurtainCell.h"
#import "BjMusicTableViewCell.h"
#import "IphoneNewAddSceneTimerVC.h"
#import "HttpManager.h"
#import "MBProgressHUD+NJ.h"

@interface DeviceTimerSettingViewController : CustomViewController<UITableViewDataSource, UITableViewDelegate,  HttpDelegate, NewLightCellDelegate, CurtainTableViewCellDelegate, AireTableViewCellDelegate>

@property(nonatomic, strong) UITableView *timerTableView;
@property(nonatomic, strong) Device *device;
@property(nonatomic, assign) NSInteger roomID;
@property(nonatomic, assign) NSInteger isActive;
@property(nonatomic, strong) NSString *startTime;
@property(nonatomic, strong) NSString *endTime;
@property(nonatomic, strong) NSString *repeatition;
@property(nonatomic, strong) NSMutableString *startValue;
@property(nonatomic, strong) NSMutableString *repeatString;
@property (nonatomic,strong) UIButton * naviRightBtn;
@property(nonatomic, strong) NSString *switchBtnString;//开关按钮指令字符串
@property(nonatomic, strong) NSString *sliderBtnString;//滑动按钮指令字符串

@end
