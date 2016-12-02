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
#import "Amplifier.h"

@interface SceneManager : NSObject

+ (instancetype) defaultManager;


- (void) addScene:(Scene *)scene withName:(NSString *)name withImage:(UIImage *)image;

- (NSData *)getRealSceneData;

- (void) delScene:(Scene *)scene;

- (void) editScene:(Scene *)scene;

- (BOOL)favoriteScene:(Scene *)newScene;
-(void)deleteFavoriteScene:(Scene *)scene withName:(NSString *)name;
- (Scene *)readSceneByID:(int)sceneid;
-(void)saveAsNewScene:(Scene *)scene withName:(NSString *)name withPic:(UIImage *)image;

-(NSArray *)addDevice2Scene:(Scene *)scene withDeivce:(id)device withId:(int)deviceID;

-(void) startScene:(int)sceneid;
-(void) poweroffAllDevice:(int)sceneid;

//调整场景氛围
-(void) dimingScene:(int)sceneid brightness:(int)bright;
//明快
-(void) sprightly:(int)sceneid;
//幽静
-(void) gloom:(int)sceneid;
//浪漫
-(void) romantic:(int)sceneid;
//调整房间氛围
-(void) dimingRoom:(int)roomid brightness:(int)bright;
//明快
-(void) sprightlyRoom:(int)roomid;
//幽静
-(void) gloomRoom:(int)roomid;
//浪漫
-(void) romanticRoom:(int)roomid;


@end
