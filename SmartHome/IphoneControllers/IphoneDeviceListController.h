//
//  IphoneDeviceListController.h
//  SmartHome
//
//  Created by 逸云科技 on 16/9/19.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomViewController.h"

@interface IphoneDeviceListController : CustomViewController

-(void)goDeviceByRoomID:(int)roomID typeName:(NSString *)typeName;
@property (nonatomic,strong) Scene *scene;

@property (nonatomic, readonly) UIButton *naviRightBtn;
@property (nonatomic, readonly) UIButton *naviLeftBtn;

@end
