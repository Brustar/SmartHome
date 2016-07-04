//
//  DeviceList.h
//  SmartHome
//
//  Created by Brustar on 16/5/19.
//  Copyright © 2016年 Brustar. All rights reserved.
//

@interface DeviceList : UITableViewController

@property (strong, nonatomic) NSArray *devices;
@property (strong, nonatomic) NSArray *segues;
@property (nonatomic,weak) NSString *sceneid;
@property (nonatomic,strong) NSString *deviceid;

@end
