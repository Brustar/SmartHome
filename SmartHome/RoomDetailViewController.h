//
//  RoomDetailViewController.h
//  SmartHome
//
//  Created by KobeBryant on 2017/1/5.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SQLManager.h"
#import "EditSceneCell.h"
#import "TVController.h"
#import "LightController.h"
#import "CurtainController.h"
#import "DVDController.h"
#import "FMController.h"
#import "AirController.h"
//#import "NetvController.h"
#import "CameraController.h"
#import "GuardController.h"
#import "ScreenCurtainController.h"
#import "ProjectController.h"
#import "AmplifierController.h"
#import "WindowSlidingController.h"
#import "BgMusicController.h"
#import "PluginViewController.h"
#import "MBProgressHUD+NJ.h"

@interface RoomDetailViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *deviceTypeTableView;
@property (weak, nonatomic) IBOutlet UITableView *deviceSubTypeTableView;

@property(nonatomic, strong) NSMutableArray *deviceTypes;//设备大类
@property(nonatomic, strong) NSMutableArray *deviceSubTypes;//设备小类
@property(nonatomic, assign) int roomID;
@property (weak, nonatomic) UIViewController *currentViewController;

@end
