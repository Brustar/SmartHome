//
//  IpadAddDeviceTypeVC.h
//  SmartHome
//
//  Created by zhaona on 2017/6/1.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomViewController.h"

@interface IpadAddDeviceTypeVC :CustomViewController

@property (nonatomic,strong) NSArray * deviceIdArr;
@property (nonatomic,weak) NSString *sceneid;
@property (nonatomic,weak) NSString *deviceid;
@property (nonatomic,assign) int roomID;
@property(nonatomic,assign) int sceneID;


-(void)refreshData:(NSArray *)data;

@end
