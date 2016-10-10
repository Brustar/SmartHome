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


- (void) delScene:(Scene *)scene;

- (void) editScene:(Scene *)scene;

- (void) favoriteScene:(Scene *)newScene withName:(NSString *)name;
-(void)deleteFavoriteScene:(Scene *)scene withName:(NSString *)name;
- (Scene *)readSceneByID:(int)sceneid;
-(void)saveAsNewScene:(Scene *)scene withName:(NSString *)name withPic:(UIImage *)image;

-(NSArray *)addDevice2Scene:(Scene *)scene withDeivce:(id)device withId:(int)deviceID;

-(void) startScene:(int)sceneid;
-(void) poweroffAllDevice:(int)sceneid;


@end
