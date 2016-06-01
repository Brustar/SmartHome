//
//  Scene.h
//  SmartHome
//
//  Created by Brustar on 16/5/6.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SCENE_FILE_NAME @"ecloud_scene"

@interface Scene : NSObject
//场景id
@property (nonatomic) int sceneID;
//房间id
@property (nonatomic) int roomID;
//场景图片id
@property (nonatomic) int picID;
//户型id
@property (nonatomic) int houseID;
//是否系统场景
@property (nonatomic) bool readonly;
//设备列表
@property (strong,nonatomic) NSArray *devices;

@end
