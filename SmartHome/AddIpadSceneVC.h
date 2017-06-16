//
//  AddIpadSceneVC.h
//  SmartHome
//
//  Created by zhaona on 2017/6/1.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomViewController.h"


@interface AddIpadSceneVC :CustomViewController


@property (nonatomic,assign) int roomID;
//场景id
@property (nonatomic,assign) int sceneID;
//@property(nonatomic,assign) int deviceID;
@property (strong, nonatomic) NSArray *devices;
@property (nonatomic, strong) Scene * scene;
@property (nonatomic, readonly) UIButton *naviRightBtn;
@property (nonatomic, readonly) UIButton *naviLeftBtn;

@end
