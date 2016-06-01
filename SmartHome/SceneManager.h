//
//  SceneManager.h
//  SmartHome
//
//  Created by Brustar on 16/5/18.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "public.h"
#import "Light.h"
#import "FMDB.h"

@interface SceneManager : NSObject

+ (id) defaultManager;

- (void) addScenen:(Scene *)scene withName:(NSString *)name withPic:(NSString *)picurl;

- (void) delScenen:(Scene *)scene;

- (void) editScenen:(Scene *)scene;

- (void) favoriteScenen:(Scene *)newScene withName:(NSString *)name;

-(Scene *)readSceneByID:(int)sceneid;

@end
