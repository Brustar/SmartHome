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
#import "SQLManager.h"

#import "MBProgressHUD+NJ.h"

#import "Screen.h"
#import "WinOpener.h"
#import "HttpManager.h"
#import "Projector.h"
#import "SocketManager.h"
#import "AppDelegate.h"
#import "SceneController.h"
#import "AFHTTPSessionManager.h"
#import "UploadManager.h"
#import "MBProgressHUD+NJ.h"

@implementation SceneManager

+ (instancetype) defaultManager
{
    static SceneManager *sharedInstance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    
    
    return sharedInstance;
}

- (void) addScene:(Scene *)scene withName:(NSString *)name withImage:(UIImage *)image
{
    if (name) {
        
      // int sceneid=[SQLManager saveMaxSceneId:scene name:name pic:@""];
       // scene.sceneID=sceneid;
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyyMMddHHmmss";
        NSString *str = [formatter stringFromDate:[NSDate date]];
        NSString *imgFileName = [NSString stringWithFormat:@"%@.png", str];

        //同步云端
        NSString *sceneFile = [NSString stringWithFormat:@"%@_0.plist",SCENE_FILE_NAME];
        NSString *scenePath=[[IOManager scenesPath] stringByAppendingPathComponent:sceneFile];
        NSString *URL = [NSString stringWithFormat:@"%@SceneAdd.aspx",[IOManager httpAddr]];
        NSString *fileName = [NSString stringWithFormat:@"%@_%d.plist",SCENE_FILE_NAME,scene.sceneID];
        NSDictionary *parameter;
        if(![scene.startTime isEqualToString:@""])
        {
            parameter = @{@"AuthorToken":[[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"],@"ScenceName":name,@"ImgName":imgFileName,@"ScenceFile":scenePath,@"isPlan":[NSNumber numberWithInt:1],@"StartTime":scene.startTime,@"AstronomicalTime":scene.astronomicalTime,@"PlanType":[NSNumber numberWithInt:scene.planType],@"WeekValue":scene.weekValue,@"RoomID":[NSNumber numberWithInt:scene.roomID]};
        }else{
            
            parameter = @{@"AuthorToken":[[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"],@"ScenceName":name,@"ImgName":imgFileName,@"ScenceFile":scenePath,@"isPlan":[NSNumber numberWithInt:2],@"RoomID":[NSNumber numberWithInt:scene.roomID]};
        }
        
        
        NSData *imgData = UIImagePNGRepresentation(image);
        
        
        
        
        NSData *fileData = [NSData dataWithContentsOfFile:scenePath];
        [[UploadManager defaultManager] uploadScene:fileData url:URL dic:parameter fileName:fileName imgData:imgData imgFileName:imgFileName completion:^(id responseObject) {
            
            [IOManager writeScene:[NSString stringWithFormat:@"%@_%d.plist" , SCENE_FILE_NAME, [responseObject[@"SID"] intValue]] scene:scene];
            NSString *roomName = [SQLManager getRoomNameByRoomID:[responseObject[@"SID"] intValue]];
            //插入数据库
            FMDatabase *db = [SQLManager connetdb];
            if([db open])
            {
               
              
                
                NSString *sql = [NSString stringWithFormat:@"insert into Scenes values(%d,'%@','%@','%@',%d,%d,'%@',%d,null)",[responseObject[@"SID"] intValue],name,roomName,responseObject[@"ImgUrl"] ,scene.roomID,2,@"0",0];
               BOOL result = [db executeUpdate:sql];
                if(result)
                {
                    NSLog(@"更新成功");
                }
                
            }
            [db close];
        }];
    }
    [IOManager writeScene:[NSString stringWithFormat:@"%@_%d.plist" , SCENE_FILE_NAME, scene.sceneID] scene:scene];
    
    
}

//另存为(保存为一个新的场景）
-(void)saveAsNewScene:(Scene *)scene withName:(NSString *)name withPic:(UIImage *)image
{
    if (name) {
        
        
        //同步云端
        NSString *fileName = [NSString stringWithFormat:@"%@_%d.plist",SCENE_FILE_NAME,scene.sceneID];
        NSString *scenePath=[[IOManager scenesPath] stringByAppendingPathComponent:fileName];
        NSString *URL = [NSString stringWithFormat:@"%@SceneAdd.aspx",[IOManager httpAddr]];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyyMMddHHmmss";
        NSString *str = [formatter stringFromDate:[NSDate date]];
        NSString *imgFileName = [NSString stringWithFormat:@"%@.png", str];
        NSData *imgData = UIImagePNGRepresentation(image);
        
        NSDictionary *parameter;
        int sceneid=[SQLManager saveMaxSceneId:scene name:name pic:@""];
        scene.sceneID=sceneid;
       
        if(![scene.startTime isEqualToString:@""] )
        {
            parameter = @{@"AuthorToken":[[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"],@"ScenceName":name,@"ImgName":imgFileName,@"ScenceFile":scenePath,@"isPlan":[NSNumber numberWithInt:1],@"StartTime":scene.startTime,@"AstronomicalTime":scene.astronomicalTime,@"PlanType":[NSNumber numberWithInt:scene.planType],@"WeekValue":scene.weekValue,@"RoomID":[NSNumber numberWithInt:scene.roomID],@"PlistName":fileName};
        }else{
            
            parameter = @{@"AuthorToken":[[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"],@"ScenceName":name,@"ImgName":imgFileName,@"ScenceFile":scenePath,@"isPlan":[NSNumber numberWithInt:2],@"RoomID":[NSNumber numberWithInt:scene.roomID],@"PlistName":fileName};
        }

        NSData *fileData = [NSData dataWithContentsOfFile:scenePath];
        [[UploadManager defaultManager] uploadScene:fileData url:URL dic:parameter fileName:fileName imgData:imgData imgFileName:imgFileName completion:^(id responseObject) {
            
             [IOManager writeScene:[NSString stringWithFormat:@"%@_%d.plist" , SCENE_FILE_NAME, [responseObject[@"SID"] intValue]] scene:scene];
            FMDatabase *db = [SQLManager connetdb];
            if([db open])
            {
                
                NSString *sql = [NSString stringWithFormat:@"update Scenes set pic = '%@' where ID = %d",responseObject[@"ImgUrl"],scene.sceneID];
                BOOL result = [db executeUpdate:sql];
                if(result)
                {
                    NSLog(@"更新成功");
                }
                
            }
            [db close];
            
        }];

    }
    [IOManager writeScene:[NSString stringWithFormat:@"%@_%d.plist" , SCENE_FILE_NAME, scene.sceneID] scene:scene];

}


-(void)upLoadFile
{
   
}

- (void) delScene:(Scene *)scene
{
    if (!scene.readonly) {
        NSString *filePath=[NSString stringWithFormat:@"%@/%@_%d.plist",[IOManager scenesPath], SCENE_FILE_NAME, scene.sceneID];
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        if(data)
        {
            [IOManager removeFile:filePath];
        }
       
    }
   
    //上传文件
}

//保证newScene的ID不变
- (void) editScene:(Scene *)newScene
{
    [IOManager writeScene:[NSString stringWithFormat:@"%@_%d.plist" , SCENE_FILE_NAME, newScene.sceneID ] scene:newScene];
    //同步云端
    NSString *fileName = [NSString stringWithFormat:@"%@_%d.plist",SCENE_FILE_NAME,newScene.sceneID];
    newScene.sceneName = [SQLManager getSceneName:newScene.sceneID];
    NSString *scenePath=[[IOManager scenesPath] stringByAppendingPathComponent:fileName];
     NSDictionary *parameter;
    if(newScene.isPlan == 1)
    
    {
        parameter = @{@"AuthorToken":[[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"],@"ScenceName":newScene.sceneName,@"ImgName":newScene.picName,@"ScenceFile":fileName,@"RoomID":[NSNumber numberWithInt:newScene.roomID],@"IsPlan":@"1",@"StartTime":newScene.startTime,@"AstronomicalTime":newScene.astronomicalTime,@"PlanType":[NSNumber numberWithInt:newScene.planType],@"WeekValue":newScene.weekValue,@"ScenceID":[NSNumber numberWithInt:newScene.sceneID]};
    }else{
        parameter = @{@"AuthorToken":[[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"],@"ScenceName":newScene.sceneName,@"ImgName":newScene.picName,@"ScenceFile":fileName,@"RoomID":[NSNumber numberWithInt:newScene.roomID],@"IsPlan":@"2",@"ScenceID":[NSNumber numberWithInt:newScene.sceneID]};
    }
    NSData *fileData = [NSData dataWithContentsOfFile:scenePath];
    NSString *URL = [NSString stringWithFormat:@"%@SceneEdit.aspx",[IOManager httpAddr]];
    [[UploadManager defaultManager] uploadScene:fileData url:URL dic:parameter fileName:fileName imgData:nil imgFileName:@"" completion:^(id responseObject) {
        
    }];
    
  
}

- (void) favoriteScene:(Scene *)newScene withName:(NSString *)name
{
    NSString *scenePath=[[IOManager favoritePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%d.plist" , SCENE_FILE_NAME, newScene.sceneID ]];
    NSDictionary *dic = [PrintObject getObjectData:newScene];
    BOOL ret = [dic writeToFile:scenePath atomically:YES];
    if(ret)
    {
       // 写sqlite更新场景文件名
        FMDatabase *db = [SQLManager connetdb];
        if (![db open]) {
            NSLog(@"Could not open db.");
            return ;
        }
        BOOL result =[db executeUpdate:@"UPDATE Scenes SET isFavorite = 1 WHERE id = ?",[NSNumber numberWithInt:newScene.sceneID]];
        if(result)
        {
            NSLog(@"收藏成功");
        }
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
        Scene *scene=nil;
        if ([dictionary objectForKey:@"startTime"]) {
            scene=[[Scene alloc] init];
            [scene setStartTime:[dictionary objectForKey:@"startTime"]];
            if([dictionary objectForKey:@"planType"])
            {
                [scene setPlanType:[[dictionary objectForKey:@"planType"] intValue]];
            }
            if([dictionary objectForKey:@"weekValue"])
            {
                [scene setWeekValue:[dictionary objectForKey:@"weekValue"]];
            }else{
                [scene setWeekValue:@""];
            }
            if([dictionary objectForKey:@"astronomicalTime"])
            {
                [scene setAstronomicalTime:[dictionary objectForKey:@"astronomicalTime"]];
            }else{
                [scene setWeekValue:@""];
            }
            [scene setRoomName:@""];
            [scene setSceneName:@""];
            
        }else{
            scene=[[Scene alloc] initWhithoutSchedule];
        }
        scene.sceneID=sceneid;
        scene.readonly=[dictionary objectForKey:@"readonly"];
        scene.picName=[dictionary objectForKey:@"picName"];
        scene.roomID=[[dictionary objectForKey:@"roomID"] intValue];
        scene.masterID=[[dictionary objectForKey:@"masterID"] intValue];
        
        NSMutableArray *devices=[[NSMutableArray alloc] init];
        for (NSDictionary *dic in [dictionary objectForKey:@"devices"]) {
            if ([dic objectForKey:@"isPoweron"]) {
                Light *device=[[Light alloc] init];
                device.deviceID=[[dic objectForKey:@"deviceID"] intValue];
                if ([dic objectForKey:@"color"]) {
                    device.color=[dic objectForKey:@"color"];
                }else{
                    device.color=@[];
                }
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
            if ([dic objectForKey:@"dropped"]) {
                Screen *device=[[Screen alloc] init];
                device.dropped=[[dic objectForKey:@"dropped"] intValue];
                [devices addObject:device];
            }
            if ([dic objectForKey:@"showed"]) {
                Projector *device=[[Projector alloc] init];
                device.showed=[[dic objectForKey:@"showed"] intValue];
                [devices addObject:device];
            }
            if ([dic objectForKey:@"waiting"]) {
                Amplifier *device=[[Amplifier alloc] init];
                device.waiting=[[dic objectForKey:@"waiting"] intValue];
                [devices addObject:device];
            }
            
            if ([dic objectForKey:@"pushing"]) {
                WinOpener *device=[[WinOpener alloc] init];
                device.pushing=[[dic objectForKey:@"pushing"] intValue];
                [devices addObject:device];
            }
        }
        scene.devices=devices;
        return scene;
    }else{
        return [[Scene alloc] initWhithoutSchedule];
    }
}

-(void) poweroffAllDevice:(int)sceneid
{
    NSData *data=nil;
    SocketManager *sock=[SocketManager defaultManager];
    
    Scene *scene=[self readSceneByID:sceneid];
    for (id device in scene.devices)
    {
        if ([device respondsToSelector:@selector(deviceID)])
        {
            NSString *deviceid=[NSString stringWithFormat:@"%d", [device deviceID]];
            data=[[DeviceInfo defaultManager] close:deviceid];
            [sock.socket writeData:data withTimeout:1 tag:1];
        }
    }
}

-(void) startScene:(int)sceneid
{
    NSData *data=nil;
    SocketManager *sock=[SocketManager defaultManager];
    //面板场景
    if ([SQLManager getReadOnly:sceneid]) {
        data = [[DeviceInfo defaultManager] startScenenAtMaster:sceneid];
        [sock.socket writeData:data withTimeout:1 tag:1];
        return;
    }
    
    Scene *scene=[self readSceneByID:sceneid];
    for (id device in scene.devices) {
        if ([device isKindOfClass:[TV class]]) {
            TV *tv=(TV *)device;
            NSString *deviceid=[NSString stringWithFormat:@"%d", tv.deviceID];
            data=[[DeviceInfo defaultManager] open:deviceid];
            [sock.socket writeData:data withTimeout:1 tag:1];
            if (tv.volume>0) {
                data=[[DeviceInfo defaultManager] changeTVolume:tv.volume deviceID:deviceid];
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
                data=[[DeviceInfo defaultManager] changeTVolume:dvd.dvolume deviceID:deviceid];
                [sock.socket writeData:data withTimeout:1 tag:1];
            }
        }
        
        if ([device isKindOfClass:[Netv class]]) {
            Netv *netv=(Netv *)device;
            NSString *deviceid=[NSString stringWithFormat:@"%d", netv.deviceID];
            data=[[DeviceInfo defaultManager] open:deviceid];
            [sock.socket writeData:data withTimeout:1 tag:1];
            if (netv.nvolume>0) {
                data=[[DeviceInfo defaultManager] changeTVolume:netv.nvolume deviceID:deviceid];
                [sock.socket writeData:data withTimeout:1 tag:1];
            }
        }
        
        if ([device isKindOfClass:[Radio class]]) {
            Radio *fm=(Radio *)device;
            NSString *deviceid=[NSString stringWithFormat:@"%d", fm.deviceID];
            data=[[DeviceInfo defaultManager] open:deviceid];
            [sock.socket writeData:data withTimeout:1 tag:1];
            if (fm.rvolume>0) {
                data=[[DeviceInfo defaultManager] changeTVolume:fm.rvolume deviceID:deviceid];
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
                data=[[DeviceInfo defaultManager] changeTVolume:music.bgvolume deviceID:deviceid];
                [sock.socket writeData:data withTimeout:1 tag:1];
            }
        }
        
        if ([device isKindOfClass:[Light class]]) {
            Light *light=(Light *)device;
            NSString *deviceid=[NSString stringWithFormat:@"%d", light.deviceID];
            data=[[DeviceInfo defaultManager] toogleLight:light.isPoweron deviceID:deviceid];
            [sock.socket writeData:data withTimeout:1 tag:1];
            if (light.brightness>0) {
                data=[[DeviceInfo defaultManager] changeBright:light.brightness deviceID:deviceid];
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
                data=[[DeviceInfo defaultManager] roll:curtain.openvalue deviceID:deviceid];
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
            if (screen.dropped) {
                data=[[DeviceInfo defaultManager] drop:screen.dropped deviceID:deviceid];
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
        
        if ([device isKindOfClass:[Amplifier class]]) {
            Amplifier *projector=(Amplifier *)device;
            NSString *deviceid=[NSString stringWithFormat:@"%d", projector.deviceID];
            if (projector.waiting) {
                data=[[DeviceInfo defaultManager] toogle:projector.waiting deviceID:deviceid];
                [sock.socket writeData:data withTimeout:1 tag:1];
            }
        }
        
        if ([device isKindOfClass:[WinOpener class]]) {
            WinOpener *opener=(WinOpener *)device;
            NSString *deviceid=[NSString stringWithFormat:@"%d", opener.deviceID];
            if (opener.pushing) {
                data=[[DeviceInfo defaultManager] toogle:opener.pushing deviceID:deviceid];
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
        if (!array) {
            array= [NSArray new];
        }
        
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


@end
