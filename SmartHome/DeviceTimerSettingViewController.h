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
#import "DeviceListTimeVC.h"
#import "IpadDVDTableViewCell.h"
#import "IpadTVCell.h"
#import "PowerLightCell.h"

@interface DeviceTimerSettingViewController : CustomViewController<UITableViewDataSource, UITableViewDelegate,  HttpDelegate, NewLightCellDelegate, NewColourCellDelegate, CurtainTableViewCellDelegate, AireTableViewCellDelegate, TVTableViewCellDelegate, DVDTableViewCellDelegate, BjMusicTableViewCellDelegate, FMTableViewCellDelegate, ScreenCurtainCellDelegate, OtherTableViewCellDelegate>

@property(nonatomic, strong) UITableView *timerTableView;
@property(nonatomic, strong) Device *device;
@property(nonatomic, assign) NSInteger roomID;
@property(nonatomic, assign) NSInteger scheduleId;//定时器id
@property(nonatomic, assign) NSInteger isActive;
@property(nonatomic, strong) NSString *startTime;
@property(nonatomic, strong) NSString *endTime;
@property(nonatomic, strong) NSString *repeatition;
@property(nonatomic, strong) NSMutableString *startValue;
@property(nonatomic, strong) NSMutableString *repeatString;
@property (nonatomic,strong) UIButton * naviRightBtn;
@property(nonatomic, strong) NSString *switchBtnString;//开关按钮指令字符串
@property(nonatomic, strong) NSString *sliderBtnString;//滑动按钮指令字符串
@property(nonatomic, strong) NSString *FMChannelSliderString;//FM频道指令字符串
@property(nonatomic, assign) BOOL isEditMode;//编辑模式

//设备状态：
@property(nonatomic, assign) int power;// 开关状态：1:开 0:关
@property(nonatomic, assign) int bright;//灯的亮度 (0~100)
@property(nonatomic, assign) int position;//窗帘的位置(0~100)
@property(nonatomic, strong) NSString *color;//灯的颜色 RGB
@property(nonatomic, assign) int temperature;//空调温度
@property(nonatomic, assign) int volume;//音量 (0~100)

@end
