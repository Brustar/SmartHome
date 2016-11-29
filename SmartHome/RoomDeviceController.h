//
//  RoomDeviceController.h
//  SmartHome
//
//  Created by 逸云科技 on 2016/11/28.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RoomDeviceController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *devTableView;
@property (nonatomic, assign) int roomID;
@property (nonatomic,strong)  NSArray * lightArrs;
@property (nonatomic,strong)  NSString * deviceid;

@end
