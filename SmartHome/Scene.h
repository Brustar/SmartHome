//
//  Scene.h
//  SmartHome
//
//  Created by Brustar on 16/5/6.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SCENE_FILE_NAME [[NSUserDefaults standardUserDefaults] objectForKey:@"hostId"]


@interface Scene : NSObject
//场景id
@property (nonatomic,assign) int sceneID;
//场景名称
@property (nonatomic,strong) NSString *sceneName;
//房间id
@property (nonatomic) int roomID;
//房间名称
@property (nonatomic,strong)NSString *roomName;
//场景图片url
@property (nonatomic,strong) NSString *picName;
//场景开始时间
@property(nonatomic,strong)NSString *startTime;
//天文时间
@property(nonatomic,strong)NSString *astronomicalTime;
//每周运行时间
@property(nonatomic,strong)NSString *weekValue;
//是否每周重复（1 重复，0 不重复）
@property(nonatomic,assign) BOOL weekRepeat;
//是否为收藏场景
@property(nonatomic,assign) BOOL isFavorite;
//户型id
@property (nonatomic) long masterID;
//是否系统场景
@property (nonatomic) bool readonly;
//设备列表
@property (strong,nonatomic) NSArray *devices;

- (instancetype)initWhithoutSchedule;

@end
