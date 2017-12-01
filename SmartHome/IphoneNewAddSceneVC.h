//
//  IphoneNewAddSceneVC.h
//  SmartHome
//
//  Created by zhaona on 2017/4/6.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomViewController.h"
#import "SceneManager.h"

@interface IphoneNewAddSceneVC : CustomViewController

@property (nonatomic,assign) int roomID;
@property(nonatomic,assign) int sceneID;
@property (nonatomic,strong) Scene * scene;
@property (nonatomic, assign) NSInteger hostType;//主机类型：0，creston   1, C4

@end
