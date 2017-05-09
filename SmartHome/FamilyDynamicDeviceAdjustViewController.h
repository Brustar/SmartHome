//
//  FamilyDynamicDeviceAdjustViewController.h
//  SmartHome
//
//  Created by KobeBryant on 2017/5/7.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "CustomViewController.h"
#import "MonitorViewController.h"
#import "SQLManager.h"
#import "NewLightCell.h"

@interface FamilyDynamicDeviceAdjustViewController : CustomViewController<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIView *monitorView;
@property (weak, nonatomic) IBOutlet UITableView *deviceTableView;

@property (nonatomic, strong) NSString *deviceID;
@property (nonatomic, strong) NSString *cameraURL;
@property (nonatomic, assign) NSInteger roomID;
@property (nonatomic, strong) NSString *roomName;

@property (nonatomic,strong) NSMutableArray * lightArray;//灯光(存储的是设备id)
@property (nonatomic, strong) NSMutableArray *deviceIDArray;//该房间的所有设备ID

@end
