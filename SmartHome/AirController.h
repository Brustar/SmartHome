//
//  AirController.h
//  SmartHome
//
//  Created by Brustar on 16/6/17.
//  Copyright © 2016年 Brustar. All rights reserved.
//
enum AIR_TARGET
{
    mode,
    direction,
    level,
    timing
};

@interface AirController : UIViewController

@property (nonatomic,weak) NSString *sceneid;
@property (nonatomic,weak) NSString *deviceid;
@property (nonatomic,weak) NSString *actKey;
@property (nonatomic,strong) NSArray *params;
@property (nonatomic) int currentIndex;
@property (nonatomic) int currentButton;

@property (nonatomic) int currentMode;
@property (nonatomic) int currentLevel;
@property (nonatomic) int currentDirection;
@property (nonatomic) int currentTiming;

@property (nonatomic,assign) int roomID;
@property (strong, nonatomic) Scene *scene;

@end
