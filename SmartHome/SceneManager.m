//
//  SceneManager.m
//  SmartHome
//
//  Created by Brustar on 16/5/18.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "SceneManager.h"

@implementation SceneManager

+ (id) defaultManager
{
    static SceneManager *sharedInstance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    
    
    return sharedInstance;
}

- (void) addScenen:(Scene *)scene withName:(NSString *)name withPic:(NSString *)picurl
{
    
    [IOManager writeScene:[NSString stringWithFormat:@"%@_%d.plist" , SCENE_FILE_NAME, scene.sceneID ] scene:scene];
    //同步云端
    
    //上传文件
    
}

- (void) delScenen:(Scene *)scene
{
    if (!scene.readonly) {
        NSString *filePath=[NSString stringWithFormat:@"%@/%@_%d.plist",[IOManager scenesPath], SCENE_FILE_NAME, scene.sceneID];
        [IOManager removeFile:filePath];
    }
    //同步云端
    
    //上传文件
}

//保证newScene的ID不变
- (void) editScenen:(Scene *)newScene
{
    [IOManager writeScene:[NSString stringWithFormat:@"%@_%d.plist" , SCENE_FILE_NAME, newScene.sceneID ] scene:newScene];
    //同步云端
    
    //上传文件
}

- (void) favoriteScenen:(Scene *)newScene withName:(NSString *)name
{
    NSString *scenePath=[[IOManager favoritePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%d.plist" , SCENE_FILE_NAME, newScene.sceneID ]];
    NSDictionary *dic = [PrintObject getObjectData:newScene];
    BOOL ret = [dic writeToFile:scenePath atomically:YES];
    if(ret)
    {
        //写sqlite更新场景文件名
        NSString *dbPath = [[IOManager sqlitePath] stringByAppendingPathComponent:@"smartDB"];
        FMDatabase *db = [FMDatabase databaseWithPath:dbPath] ;
        if (![db open]) {
            NSLog(@"Could not open db.");
            return ;
        }
        [db executeUpdate:@"UPDATE Scenes SET name = ? , isFavorite = 1 WHERE id = ?",name,[NSNumber numberWithInt:newScene.sceneID]];
        [db close];
        //同步云端
        
        //上传文件
    }
    
}

-(Scene *)readSceneByID:(int)sceneid
{
    NSString *scenePath=[[IOManager scenesPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%d.plist" , SCENE_FILE_NAME, sceneid]];
    NSDictionary *dictionary = [[NSDictionary alloc] initWithContentsOfFile:scenePath];
    Scene *scene=[[Scene alloc] init];
    scene.sceneID=sceneid;
    scene.readonly=[dictionary objectForKey:@"readonly"];
    scene.picID=[[dictionary objectForKey:@"picID"] intValue];
    scene.roomID=[[dictionary objectForKey:@"roomID"] intValue];
    scene.houseID=[[dictionary objectForKey:@"houseID"] intValue];
    Light *device=[[Light alloc] init];
    NSDictionary *dic=[[dictionary objectForKey:@"devices"] firstObject];
    device.color=[dic objectForKey:@"color"];
    device.brightness=[[dic objectForKey:@"brightness"] intValue];
    device.isPoweron=[dic objectForKey:@"isPoweron"];
    /*
    device.HDMIID=[[dic objectForKey:@"HDMIID"] intValue];
    device.channelID=[[dic objectForKey:@"channelID"] intValue];
    device.delay=[[dic objectForKey:@"delay"] intValue];
    device.deviceID=[[dic objectForKey:@"deviceID"] intValue];
    device.temperature=[[dic objectForKey:@"temperature"] intValue];
    device.timer=[[dic objectForKey:@"timer"] intValue];
    device.volume=[[dic objectForKey:@"volume"] intValue];
    */
    NSArray *devices=[NSArray arrayWithObjects:device, nil];
    scene.devices=devices;
    return scene;
}

@end
