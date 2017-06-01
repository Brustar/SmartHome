//
//  AddIpadSceneVC.h
//  SmartHome
//
//  Created by zhaona on 2017/6/1.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddIpadSceneVC : UISplitViewController


@property (nonatomic,assign) int roomID;
//场景id
@property (nonatomic,assign) int sceneID;

@property (strong, nonatomic) NSArray *devices;

@end
