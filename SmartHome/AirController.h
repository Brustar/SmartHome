#include "CustomViewController.h"
//
//  AirController.h
//  SmartHome
//
//  Created by Brustar on 16/6/17.
//  Copyright © 2016年 Brustar. All rights reserved.
//
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

@interface AirController : CustomViewController

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

@property (nonatomic,assign) int roomID;
@property (strong, nonatomic) Scene *scene;
@property (nonatomic,assign) BOOL isAddDevice;

@end
