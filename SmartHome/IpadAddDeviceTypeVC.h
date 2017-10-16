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
@property (nonatomic,strong) Scene * scene;
@property (nonatomic, assign) NSInteger hostType;//主机类型：0，creston   1, C4

-(void)refreshData:(NSArray *)data;

@end
