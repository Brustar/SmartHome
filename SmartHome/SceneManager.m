//
//  SceneManager.m
//  SmartHome
//
//  Created by Brustar on 16/5/18.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "SceneManager.h"
#import "RegexKitLite.h"
#import "Device.h"
#import "DeviceManager.h"
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

- (Scene *)readSceneByID:(int)sceneid
{
    NSString *scenePath=[[IOManager scenesPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%d.plist" , SCENE_FILE_NAME, sceneid]];
    NSDictionary *dictionary = [[NSDictionary alloc] initWithContentsOfFile:scenePath];
    if (dictionary) {
        Scene *scene=[[Scene alloc] init];
        scene.sceneID=sceneid;
        scene.readonly=[dictionary objectForKey:@"readonly"];
        scene.picID=[[dictionary objectForKey:@"picID"] intValue];
        scene.roomID=[[dictionary objectForKey:@"roomID"] intValue];
        scene.houseID=[[dictionary objectForKey:@"houseID"] intValue];
        
        NSMutableArray *devices=[[NSMutableArray alloc] init];
        for (NSDictionary *dic in [dictionary objectForKey:@"devices"]) {
            if ([dic objectForKey:@"color"]) {
                Light *device=[[Light alloc] init];
                device.deviceID=[[dic objectForKey:@"deviceID"] intValue];
                device.color=[dic objectForKey:@"color"];
                device.brightness=[[dic objectForKey:@"brightness"] intValue];
                device.isPoweron=[[dic objectForKey:@"isPoweron"] boolValue];
                [devices addObject:device];
            }
            if ([dic objectForKey:@"openvalue"]) {
                Curtain *device=[[Curtain alloc] init];
                device.deviceID=[[dic objectForKey:@"deviceID"] intValue];
                device.openvalue=[[dic objectForKey:@"openvalue"] intValue];
                [devices addObject:device];
            }
            if ([dic objectForKey:@"volume"]) {
                TV *device=[[TV alloc] init];
                device.deviceID=[[dic objectForKey:@"deviceID"] intValue];
                device.volume=[[dic objectForKey:@"volume"] intValue];
                [devices addObject:device];
            }
            if ([dic objectForKey:@"dvolume"]) {
                DVD *device=[[DVD alloc] init];
                device.deviceID=[[dic objectForKey:@"deviceID"] intValue];
                device.dvolume=[[dic objectForKey:@"dvolume"] intValue];
                [devices addObject:device];
            }
            if ([dic objectForKey:@"rvolume"]) {
                Radio *device=[[Radio alloc] init];
                device.deviceID=[[dic objectForKey:@"deviceID"] intValue];
                device.rvolume=[[dic objectForKey:@"rvolume"] intValue];
                device.channel=[[dic objectForKey:@"channel"] floatValue];
                [devices addObject:device];
            }
            if ([dic objectForKey:@"nvolume"]) {
                Netv *device=[[Netv alloc] init];
                device.deviceID=[[dic objectForKey:@"deviceID"] intValue];
                device.nvolume=[[dic objectForKey:@"nvolume"] intValue];
                [devices addObject:device];
            }
            if ([dic objectForKey:@"poweron"]) {
                EntranceGuard *device=[[EntranceGuard alloc] init];
                device.poweron=[[dic objectForKey:@"poweron"] intValue];
                [devices addObject:device];
            }
            if ([dic objectForKey:@"temperature"]) {
                Aircon *device=[[Aircon alloc] init];
                device.temperature=[[dic objectForKey:@"temperature"] intValue];
                device.timing=[[dic objectForKey:@"timing"] intValue];
                device.WindLevel=[[dic objectForKey:@"WindLevel"] intValue];
                device.Windirection=[[dic objectForKey:@"Windirection"] intValue];
                device.mode=[[dic objectForKey:@"mode"] intValue];
                [devices addObject:device];
            }
        }
        scene.devices=devices;
        return scene;
    }
    else{
        return nil;
    }
}

-(NSArray *)addDevice2Scene:(Scene *)scene withDeivce:(id)device withId:(int)deviceID
{
    NSArray *array;
    if ([self readSceneByID:scene.sceneID]) {
        scene=[self readSceneByID:scene.sceneID];
        array=scene.devices;
        if (![array containsObject:device]) {
            int i=[self inArray:[self allDeviceIDs:scene.sceneID] device:deviceID];
            if (i>=0) {
                NSMutableArray *arr=[array mutableCopy];
                [arr replaceObjectAtIndex:i withObject:device];
                array=arr;
            }else{
                array=[array arrayByAddingObject:device];
            }
            
        }
    }else{
        array=[NSArray arrayWithObject:device];
    }
    return array;
}

-(NSArray*)allDeviceIDs:(int)sceneid
{
    NSString *scenePath=[[IOManager scenesPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%d.plist" , SCENE_FILE_NAME, sceneid]];
    NSString *xml=[[NSString alloc] initWithContentsOfFile:scenePath encoding:NSUTF8StringEncoding error:nil];
    if (xml) {
        
        NSString *regexString  = @"<key>deviceID</key>\\s*<integer>(\\d+)</integer>";
        NSArray  *matchArray   = NULL;
        matchArray = [xml componentsMatchedByRegex:regexString capture:1L];
        NSLog(@"matchArray: %@", matchArray);
        return matchArray;
    }
    return nil;
}

-(int)inArray:(NSArray *)array device:(int)deviceID
{
    int index=0;
    for (NSString *ID in array) {
        if ([ID intValue]==deviceID) {
            return index;
        }
        index++;
    }
    return -1;
}

+(NSArray *)allSceneModels
{
    NSString *dbPath = [[IOManager sqlitePath] stringByAppendingPathComponent:@"smartDB"];
    
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    NSMutableArray *sceneModles = [NSMutableArray array];
    if([db open])
    {
        FMResultSet *resultSet = [db executeQuery:@"select * from Scenes"];
        while([resultSet next])
        {
            Scene *scene = [Scene new];
            scene.sceneID = [resultSet intForColumn:@"ID"];
            scene.sceneName = [resultSet stringForColumn:@"NAME"];
            scene.roomID = [resultSet intForColumn:@"room"];
            scene.picID = [resultSet intForColumn:@"pic"];
            scene.isFavorite = [resultSet boolForColumn:@"isFavorite"];
            scene.eID = [resultSet intForColumn:@"eId"];
            
            scene.startTime = [resultSet stringForColumn:@"startTime"];
            scene.astronomicalTime = [resultSet stringForColumn:@"astronomicalTime"];
            scene.weekValue = [resultSet stringForColumn:@"weekValue"];
            scene.weekRepeat = [resultSet intForColumn:@"weekRepeat"];
            
             scene.roomID = [resultSet intForColumn:@"rId"];
           
            [sceneModles addObject:scene];
            
        }
    }
    [db close];
    return [sceneModles copy];
}
//根据场景中的设备ID获得该场景中的所有设备
+(NSArray *)devicesBySceneID:(int)sId
{
    NSArray *devices = [NSArray array];
    NSArray *arrs = [self allSceneModels];
    for(Scene *scene in arrs)
    {
        if(scene.sceneID == sId)
        {
           devices = [DeviceManager devicesByRoomId:scene.eID];
        }
    }
    return devices;
}
+ (NSArray *)getAllSceneWithRoomID:(int)roomID
{
    NSString *dbPath = [[IOManager sqlitePath] stringByAppendingPathComponent:@"smartDB"];
    
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    NSMutableArray *sceneModles = [NSMutableArray array];
    if([db open])
    {
        NSString *sql = [NSString stringWithFormat:@"select * from Scenes where rId=%d", roomID];
        FMResultSet *resultSet = [db executeQuery:sql];
        while([resultSet next])
        {
            Scene *scene = [Scene new];
            scene.sceneID = [resultSet intForColumn:@"ID"];
            scene.sceneName = [resultSet stringForColumn:@"NAME"];
            scene.roomID = [resultSet intForColumn:@"room"];
            scene.picID = [resultSet intForColumn:@"pic"];
            scene.isFavorite = [resultSet boolForColumn:@"isFavorite"];
            scene.eID = [resultSet intForColumn:@"eId"];
            scene.startTime = [resultSet stringForColumn:@"startTime"];
            scene.astronomicalTime = [resultSet stringForColumn:@"astronomicalTime"];
            scene.weekValue = [resultSet stringForColumn:@"weekValue"];
            scene.weekRepeat = [resultSet intForColumn:@"weekRepeat"];
            scene.roomName = [resultSet stringForColumn:@"rId"];
            
            [sceneModles addObject:scene];
        }
    }
    [db close];
    return [sceneModles copy];
}

@end
