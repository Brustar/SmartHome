//
//  IphoneEditSceneController.h
//  SmartHome
//
//  Created by 逸云科技 on 16/10/10.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IphoneEditSceneController : UIViewController
@property(nonatomic,assign) int sceneID;
@property(nonatomic,assign) int deviceID;
@property(nonatomic,assign) int roomID;
@property (nonatomic,assign) BOOL isFavor;
@property (nonatomic,strong) NSString * sceneid;

@end
