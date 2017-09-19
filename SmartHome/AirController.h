#include "CustomViewController.h"
//
//  AirController.h
//  SmartHome
//
//  Created by Brustar on 16/6/17.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "LoadMaskHelper.h"
#import "UIViewController+Navigator.h"
#import "IphoneRoomView.h"

typedef NS_ENUM(NSUInteger,mode)
{
    heat,
    cool
};

typedef NS_ENUM(NSUInteger,wind)
{
    speed=1,
    direction
};

@interface AirController : CustomViewController<SingleMaskViewDelegate,IphoneRoomViewDelegate>

@property (nonatomic,weak) NSString *sceneid;
@property (nonatomic,weak) NSString *deviceid;
@property (nonatomic,weak) NSString *actKey;
@property (nonatomic,strong) NSArray *params;

@property (nonatomic) int currentButton;

@property (nonatomic) int currentMode;
@property (nonatomic) int airMode;
@property (nonatomic) int currentLevel;
@property (nonatomic) int currentDirection;
@property (nonatomic) int currentTiming;

@property (nonatomic) int currentDegree;

@property (nonatomic,assign) int roomID;

@property (nonatomic,assign) BOOL isAddDevice;
@property (weak, nonatomic) IBOutlet UIStackView *menuContainer;
@property (nonatomic,strong) NSArray *menus;

@end
