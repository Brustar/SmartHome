//
//  IpadSceneDetailVC.h
//  SmartHome
//
//  Created by zhaona on 2017/5/25.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomViewController.h"

@interface IpadSceneDetailVC : CustomViewController

@property (nonatomic,strong) NSArray * deviceIdArr;
@property (nonatomic,weak) NSString *sceneid;
@property (nonatomic,weak) NSString *deviceid;
@property (nonatomic,assign) int roomID;
@property(nonatomic,assign) int sceneID;

@end
