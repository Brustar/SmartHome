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

#import "MBProgressHUD+NJ.h"

#import "Screen.h"

#import "HttpManager.h"
#import "Projector.h"
#import "SocketManager.h"


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
    if (name) {
        int sceneid=[DeviceManager saveMaxSceneId:name];
        scene.sceneID=sceneid;
        //同步云端
        NSString *url = [NSString stringWithFormat:@"%@SceneUpload.aspx",[IOManager httpAddr]];
        NSDictionary *dic = @{@"AuthorToken":[[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"]};
        HttpManager *http = [HttpManager defaultManager];
        http.delegate = self;
        http.tag = 1;
        
        [http sendPost:url param:dic];
    }
    [IOManager writeScene:[NSString stringWithFormat:@"%@_%d.plist" , SCENE_FILE_NAME, scene.sceneID] scene:scene];
   

    //上传文件
    
}
-(void) httpHandler:(id) responseObject tag:(int)tag
{
    if(tag == 1)
    {
        if([responseObject[@"Result"] intValue] == 0)
        {
            [MBProgressHUD showSuccess:@"场景保存成功"];
        }else{
            [MBProgressHUD showError: responseObject[@"Msg"]];
        }
    }else if(tag == 2)
    {
        if([responseObject[@"Result"] intValue] == 0)
        {
            [MBProgressHUD showSuccess:@"场景保存成功"];
        }else{
            [MBProgressHUD showError: responseObject[@"Msg"]];
        }
    }

}

- (void) delScenen:(Scene *)scene
{
    if (!scene.readonly) {
        NSString *filePath=[NSString stringWithFormat:@"%@/%@_%d.plist",[IOManager scenesPath], SCENE_FILE_NAME, scene.sceneID];
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        if(data)
        {
            [IOManager removeFile:filePath];
        }
       
    }
    //同步云端
   
    NSString *url = [NSString stringWithFormat:@"%@SceneDelete.aspx",[IOManager httpAddr]];
    NSDictionary *dict = @{@"AuthorToken":[[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"],@"SID":[NSNumber numberWithInt:scene.sceneID]};
    HttpManager *http=[HttpManager defaultManager];
    http.delegate=self;
    http.tag = 2;
    [http sendPost:url param:dict];

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
            if ([dic objectForKey:@"isPoweron"]) {
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
            if ([dic objectForKey:@"bgvolume"]) {
                BgMusic *device=[[BgMusic alloc] init];
                device.deviceID=[[dic objectForKey:@"deviceID"] intValue];
                device.bgvolume=[[dic objectForKey:@"bgvolume"] intValue];
                [devices addObject:device];
            }
            if ([dic objectForKey:@"unlock"]) {
                EntranceGuard *device=[[EntranceGuard alloc] init];
                device.unlock=[[dic objectForKey:@"unlock"] intValue];
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
            if ([dic objectForKey:@"Dropped"]) {
                Screen *device=[[Screen alloc] init];
                device.Dropped=[[dic objectForKey:@"Dropped"] intValue];
                [devices addObject:device];
            }
            if ([dic objectForKey:@"showed"]) {
                Projector *device=[[Projector alloc] init];
                device.showed=[[dic objectForKey:@"showed"] intValue];
                [devices addObject:device];
            }
        }
        scene.devices=devices;
        return scene;
    }else{
        return nil;
    }
}

-(void) startScene:(int)sceneid
{
    NSData *data=nil;
    SocketManager *sock=[SocketManager defaultManager];
    
    Scene *scene=[self readSceneByID:sceneid];
    for (id device in scene.devices) {
        if ([device isKindOfClass:[TV class]]) {
            TV *tv=(TV *)device;
            NSString *deviceid=[NSString stringWithFormat:@"%d", tv.deviceID];
            data=[[DeviceInfo defaultManager] open:deviceid];
            [sock.socket writeData:data withTimeout:1 tag:1];
            if (tv.volume>0) {
                data=[[DeviceInfo defaultManager] changeTVolume:tv.volume*100 deviceID:deviceid];
                [sock.socket writeData:data withTimeout:1 tag:1];
            }
            if (tv.channelID>0) {
                data=[[DeviceInfo defaultManager] switchProgram:tv.channelID deviceID:deviceid];
                [sock.socket writeData:data withTimeout:1 tag:1];
            }
        }
        
        if ([device isKindOfClass:[DVD class]]) {
            DVD *dvd=(DVD *)device;
            NSString *deviceid=[NSString stringWithFormat:@"%d", dvd.deviceID];
            data=[[DeviceInfo defaultManager] open:deviceid];
            [sock.socket writeData:data withTimeout:1 tag:1];
            if (dvd.dvolume>0) {
                data=[[DeviceInfo defaultManager] changeTVolume:dvd.dvolume*100 deviceID:deviceid];
                [sock.socket writeData:data withTimeout:1 tag:1];
            }
        }
        
        if ([device isKindOfClass:[Netv class]]) {
            Netv *netv=(Netv *)device;
            NSString *deviceid=[NSString stringWithFormat:@"%d", netv.deviceID];
            data=[[DeviceInfo defaultManager] open:deviceid];
            [sock.socket writeData:data withTimeout:1 tag:1];
            if (netv.nvolume>0) {
                data=[[DeviceInfo defaultManager] changeTVolume:netv.nvolume*100 deviceID:deviceid];
                [sock.socket writeData:data withTimeout:1 tag:1];
            }
        }
        
        if ([device isKindOfClass:[Radio class]]) {
            Radio *fm=(Radio *)device;
            NSString *deviceid=[NSString stringWithFormat:@"%d", fm.deviceID];
            data=[[DeviceInfo defaultManager] open:deviceid];
            [sock.socket writeData:data withTimeout:1 tag:1];
            if (fm.rvolume>0) {
                data=[[DeviceInfo defaultManager] changeTVolume:fm.rvolume*100 deviceID:deviceid];
                [sock.socket writeData:data withTimeout:1 tag:1];
            }
            if (fm.channel>0) {
                data=[[DeviceInfo defaultManager] switchProgram:fm.channel deviceID:deviceid];
                [sock.socket writeData:data withTimeout:1 tag:1];
            }
        }
        
        if ([device isKindOfClass:[BgMusic class]]) {
            BgMusic *music=(BgMusic *)device;
            NSString *deviceid=[NSString stringWithFormat:@"%d", music.deviceID];
            data=[[DeviceInfo defaultManager] open:deviceid];
            [sock.socket writeData:data withTimeout:1 tag:1];
            if (music.bgvolume>0) {
                data=[[DeviceInfo defaultManager] changeTVolume:music.bgvolume*100 deviceID:deviceid];
                [sock.socket writeData:data withTimeout:1 tag:1];
            }
        }
        
        if ([device isKindOfClass:[Light class]]) {
            Light *light=(Light *)device;
            NSString *deviceid=[NSString stringWithFormat:@"%d", light.deviceID];
            data=[[DeviceInfo defaultManager] toogleLight:light.isPoweron deviceID:deviceid];
            [sock.socket writeData:data withTimeout:1 tag:1];
            if (light.brightness>0) {
                data=[[DeviceInfo defaultManager] changeBright:light.brightness*100 deviceID:deviceid];
                [sock.socket writeData:data withTimeout:1 tag:1];
            }
            if ([light.color count]>0) {
                int r = [[light.color firstObject] floatValue] * 255;
                int g = [[light.color objectAtIndex:1] floatValue] * 255;
                int b = [[light.color lastObject] floatValue] * 255;
                
                NSData *data=[[DeviceInfo defaultManager] changeColor:deviceid R:r G:g B:b];
                [sock.socket writeData:data withTimeout:1 tag:3];
            }
        }
        
        if ([device isKindOfClass:[Curtain class]]) {
            Curtain *curtain=(Curtain *)device;
            NSString *deviceid=[NSString stringWithFormat:@"%d", curtain.deviceID];
            if (curtain.openvalue>0) {
                data=[[DeviceInfo defaultManager] roll:curtain.openvalue*100 deviceID:deviceid];
                [sock.socket writeData:data withTimeout:1 tag:1];
            }
        }
        
        if ([device isKindOfClass:[EntranceGuard class]]) {
            EntranceGuard *guard=(EntranceGuard *)device;
            NSString *deviceid=[NSString stringWithFormat:@"%d", guard.deviceID];
            if (guard.unlock) {
                data=[[DeviceInfo defaultManager] toogle:guard.unlock deviceID:deviceid];
                [sock.socket writeData:data withTimeout:1 tag:1];
            }
        }
        
        if ([device isKindOfClass:[Screen class]]) {
            Screen *screen=(Screen *)device;
            NSString *deviceid=[NSString stringWithFormat:@"%d", screen.deviceID];
            if (screen.Dropped) {
                data=[[DeviceInfo defaultManager] drop:screen.Dropped deviceID:deviceid];
                [sock.socket writeData:data withTimeout:1 tag:1];
            }
        }
        
        if ([device isKindOfClass:[Projector class]]) {
            Projector *projector=(Projector *)device;
            NSString *deviceid=[NSString stringWithFormat:@"%d", projector.deviceID];
            if (projector.showed) {
                data=[[DeviceInfo defaultManager] toogle:projector.showed deviceID:deviceid];
                [sock.socket writeData:data withTimeout:1 tag:1];
            }
        }
        
        if ([device isKindOfClass:[Aircon class]]) {
            Aircon *aircon=(Aircon *)device;
            NSString *deviceid=[NSString stringWithFormat:@"%d", aircon.deviceID];
            data=[[DeviceInfo defaultManager] toogleAirCon:aircon.isPoweron deviceID:deviceid];
            [sock.socket writeData:data withTimeout:1 tag:1];
            if (aircon.mode>=0) {
                if (aircon.mode==0) {
                    data=[[DeviceInfo defaultManager] changeMode:0x39+aircon.mode deviceID:deviceid];
                }else{
                    data=[[DeviceInfo defaultManager] changeMode:0x3F+aircon.mode deviceID:deviceid];
                }
                [sock.socket writeData:data withTimeout:1 tag:1];
            }
            if (aircon.WindLevel>=0) {
                data=[[DeviceInfo defaultManager] changeMode:0x43+aircon.mode deviceID:deviceid];
                [sock.socket writeData:data withTimeout:1 tag:1];
            }
            if (aircon.Windirection>=0) {
                data=[[DeviceInfo defaultManager] changeMode:0x35+aircon.mode deviceID:deviceid];
                [sock.socket writeData:data withTimeout:1 tag:1];
            }
        }
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


+(BOOL)deleteScene:(int)sceneId
{
    NSString *dbPath = [[IOManager sqlitePath] stringByAppendingPathComponent:@"smartDB"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath] ;
    BOOL isSuccess = false;
    if([db open])
    {
        isSuccess = [db executeQueryWithFormat:@"delete from Scenes where ID = %d",sceneId];
        [db close];
    }
    return isSuccess;

}
@end
