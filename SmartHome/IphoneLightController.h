//
//  IphoneLightController.h
//  SmartHome
//
//  Created by 逸云科技 on 2016/11/5.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HRSampleColorPickerViewController.h"
#import "public.h"
#import "SceneManager.h"
#import "Light.h"
#import "ColourTableViewCell.h"
#import "DetailTableViewCell.h"
#import "SocketManager.h"
@interface IphoneLightController : UIViewController<HRColorPickerViewControllerDelegate,TcpRecvDelegate>
@property (strong, nonatomic) IBOutlet ColourTableViewCell *cell;
@property (strong, nonatomic) IBOutlet DetailTableViewCell *detailCell;
@property (strong, nonatomic) IBOutlet HRColorPickerView *colorPickerView;

@property (nonatomic,weak) NSString *sceneid;
@property (nonatomic,weak) NSString *deviceid;
@property (strong, nonatomic) IBOutlet UIButton *favorite;
@property (nonatomic,assign) int roomID;
@property (nonatomic,assign) BOOL isAddDevice;

@property (strong, nonatomic) Scene *scene;
@end
