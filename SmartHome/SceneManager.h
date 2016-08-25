//
//  SceneManager.h
//  SmartHome
//
//  Created by Brustar on 16/5/18.
//  Copyright © 2016年 Brustar. All rights reserved.
//
#import "public.h"
#import "Light.h"
#import "Curtain.h"
#import "TV.h"
#import "DVD.h"
#import "Radio.h"
#import "Netv.h"
#import "FMDB.h"
#import "EntranceGuard.h"
#import "Aircon.h"
#import "BgMusic.h"

@interface SceneManager : NSObject

+ (id) defaultManager;

- (void) addScenen:(Scene *)scene withName:(NSString *)name withPic:(NSString *)picurl;

- (void) delScenen:(Scene *)scene;

- (void) editScenen:(Scene *)scene;

- (void) favoriteScenen:(Scene *)newScene withName:(NSString *)name;

- (Scene *)readSceneByID:(int)sceneid;

-(NSArray *)addDevice2Scene:(Scene *)scene withDeivce:(id)device withId:(int)deviceID;

-(void) startScene:(int)sceneid
//得到所有场景
+(NSArray *)allSceneModels;
+(NSArray *)devicesBySceneID:(int)sId;

//根据房间ID的到所有的场景
+ (NSArray *)getAllSceneWithRoomID:(int)roomID;



@end
