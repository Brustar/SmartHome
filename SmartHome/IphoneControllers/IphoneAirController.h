//
//  IphoneAirController.h
//  SmartHome
//
//  Created by 逸云科技 on 16/9/23.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IphoneAirController : UIViewController
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
@property (nonatomic,assign) BOOL isAddDevice;
@end
