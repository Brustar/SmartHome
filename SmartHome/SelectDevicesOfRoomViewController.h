//
//  SelectDevicesOfRoomViewController.h
//  SmartHome
//
//  Created by KobeBryant on 2017/5/9.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "CustomViewController.h"
#import "SQLManager.h"
#import "DeviceTimerSettingViewController.h"
#import "HttpManager.h"

@interface SelectDevicesOfRoomViewController : CustomViewController<UITableViewDelegate, UITableViewDataSource, HttpDelegate>

@property(nonatomic, assign) NSInteger roomID;
@property(nonatomic, strong) NSMutableArray *deviceArray;
@property(nonatomic, strong) UITableView *deviceTableView;

@end
