//
//  IphoneEditSceneController.h
//  SmartHome
//
//  Created by 逸云科技 on 16/10/10.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomViewController.h"
//#import "LightCell.h"
#import "AireTableViewCell.h"
#import "CurtainTableViewCell.h"
#import "TVTableViewCell.h"
#import "OtherTableViewCell.h"
#import "ScreenTableViewCell.h"
#import "DVDTableViewCell.h"
#import "ScreenCurtainCell.h"
#import "AddDeviceCell.h"
#import "BjMusicTableViewCell.h"
#import "LoadMaskHelper.h"

@interface IphoneEditSceneController : CustomViewController<SingleMaskViewDelegate>
@property(nonatomic,assign) int sceneID;
//@property(nonatomic,assign) int deviceID;
@property(nonatomic,assign) int roomID;
@property (nonatomic,assign) BOOL isFavor;
@property (nonatomic,strong) NSString * sceneid;
@property (nonatomic, assign) BOOL isGloom;
@property (nonatomic, assign) BOOL isRomantic;
@property (nonatomic, assign) BOOL isSprightly;
@property(nonatomic, strong) NSString *startTime;
@property(nonatomic, strong) NSString *endTime;
@property(nonatomic, strong) NSString *repeatition;
@property(nonatomic, strong) NSMutableString *repeatString;
@property (nonatomic, assign) NSInteger hostType;//主机类型：0，creston   1, C4
@property (nonatomic, assign) int currentBrightness;//当前亮度

@end
