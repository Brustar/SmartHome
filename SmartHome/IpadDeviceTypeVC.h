//
//  IpadDeviceTypeVC.h
//  SmartHome
//
//  Created by zhaona on 2017/5/25.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomViewController.h"
#import "MBProgressHUD+NJ.h"

@class IpadDeviceTypeVC;

@protocol IpadDeviceTypeVCDelegate <NSObject>

@optional
-(void)IpadDeviceType:(IpadDeviceTypeVC *)centerListVC selected:(NSInteger)row;
-(void)IpadDeviceType:(IpadDeviceTypeVC *)centerListVC selected:(NSInteger)row typeName:(NSString *)typeName;

@end

@interface IpadDeviceTypeVC : CustomViewController

@property (nonatomic,assign) int roomID;

//场景id
@property (nonatomic,assign) int sceneID;
//场景下的所有设备
@property (nonatomic,strong) NSArray *DevicesArr;

@property (nonatomic,weak) id<IpadDeviceTypeVCDelegate> delegate;

@end
