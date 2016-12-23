//
//  Light.h
//  SmartHome
//
//  Created by Brustar on 16/5/20.
//  Copyright © 2016年 Brustar. All rights reserved.
//
#import "HRSampleColorPickerViewController.h"
#import "public.h"
#import "SceneManager.h"
#import "Light.h"
#import "ColourTableViewCell.h"
#import "DetailTableViewCell.h"
#import "SocketManager.h"

@interface LightController : UIViewController<HRColorPickerViewControllerDelegate,TcpRecvDelegate>

@property (strong, nonatomic) IBOutlet ColourTableViewCell *cell;
@property (strong, nonatomic) IBOutlet DetailTableViewCell *detailCell;
@property (strong, nonatomic) IBOutlet HRColorPickerView *colorPickerView;

@property (nonatomic,weak) NSString *sceneid;
@property (nonatomic,weak) NSString *deviceid;
@property (strong, nonatomic) IBOutlet UIButton *favorite;
@property (nonatomic,assign) int roomID;
@property (nonatomic,assign) BOOL isAddDevice;

@property (strong, nonatomic) Scene *scene;
@property (nonatomic, assign) BOOL showLightView;

@end
