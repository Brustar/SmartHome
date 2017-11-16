//
//  SceneManager.m
//  SmartHome
//
//  Created by Brustar on 16/5/18.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "SceneManager.h"
#import "PackManager.h"
#import "RegexKitLite.h"
#import "Device.h"
#import "SQLManager.h"
#import "Schedule.h"
#import "MBProgressHUD+NJ.h"
#import "AudioManager.h"
#import "Screen.h"
#import "WinOpener.h"
#import "HttpManager.h"
#import "Projector.h"
#import "SocketManager.h"
#import "AppDelegate.h"
//#import "SceneController.h"
#import "AFHTTPSessionManager.h"
#import "UploadManager.h"
#import "MBProgressHUD+NJ.h"
#import "Plugin.h"
#import "IphoneSceneController.h"

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

- (void)addScene:(Scene *)scene withName:(NSString *)name withImage:(UIImage *)image withiSactive:(NSInteger)isactive
{
    if (name.length >0) {
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyyMMddHHmmss";
        NSString *str = [formatter stringFromDate:[NSDate date]];
        NSString *imgFileName = [NSString stringWithFormat:@"%@.png", str];

        //同步云端
        NSString *sceneFile = [NSString stringWithFormat:@"%@_0.plist",SCENE_FILE_NAME];
        NSString *scenePath = [[IOManager scenesPath] stringByAppendingPathComponent:sceneFile];
        
        NSString *URL = [NSString stringWithFormat:@"%@Cloud/scene_add.aspx",[IOManager httpAddr]];
        NSString *fileName = [NSString stringWithFormat:@"%@_%d.plist",SCENE_FILE_NAME,scene.sceneID];
        NSDictionary *parameter;
        int isplan;
        
        NSMutableArray *schedulesTemp = [NSMutableArray array];
        
        for (NSDictionary *dict in scene.schedules) {
            Schedule *schedule = [[Schedule alloc] initWhithoutSchedule];
            
            [schedule setValuesForKeysWithDictionary:dict];
            
            [schedulesTemp addObject:schedule];
        }
        
        scene.schedules = [schedulesTemp copy];
        if(scene.schedules.count > 0)
        {
             parameter = @{
                           @"token":[UD objectForKey:@"AuthorToken"],
                           @"optype":@(0),
                           @"scencename":name,
                           @"imgname":imgFileName,
                           @"scencefile":scenePath,
                           @"isplan":@(1),
                           @"roomid":@(scene.roomID),
                           @"isactive":@(isactive)
                           };
            isplan = 1;
        }else {
            parameter = @{
                          @"token":[UD objectForKey:@"AuthorToken"],
                          @"optype":@(0),
                          @"scencename":name,
                          @"imgname":imgFileName,
                          @"scencefile":scenePath,
                          @"isplan":@(0),
                          @"roomid":@(scene.roomID),
                          @"isactive":@(isactive)
                          };
            isplan = 0;
        }
        NSData *imgData = UIImageJPEGRepresentation(image, 0.5);
        NSLog(@"imgDataSize: %.2f M", (float)imgData.length/1024/1024);
        
        NSData *fileData = [NSData dataWithContentsOfFile:scenePath];
        
        [[UploadManager defaultManager] uploadScene:fileData url:URL dic:parameter fileName:fileName imgData:imgData imgFileName:imgFileName completion:^(id responseObject) {
            
            NSNumber *result = [responseObject objectForKey:@"result"];
            NSString *msg = [responseObject objectForKey:@"msg"];
            
            if(result.integerValue == 0) { //成功
                
                NSDictionary *sceneDict = [responseObject objectForKey:@"scene"];
                if ([sceneDict isKindOfClass:[NSDictionary class]] && sceneDict.count >0) {
                    scene.sceneID = [[sceneDict objectForKey:@"scence_id"] intValue];
                    scene.sceneName = name;
                    
                    [IOManager writeScene:[NSString stringWithFormat:@"%@_%d.plist" , SCENE_FILE_NAME, scene.sceneID]  scene:scene];
                    NSString *roomName = [SQLManager getRoomNameByRoomID:(int)scene.roomID];
                    
                    //插入数据库
                    FMDatabase *db = [SQLManager connectdb];
                    if([db open])
                    {
                         NSString *sql = [NSString stringWithFormat:@"insert into Scenes values(%d,'%@','%@','%@',%ld,%d,'%@',%d,null,'%ld','%d','%d','%ld')",scene.sceneID,name,roomName,[sceneDict objectForKey:@"image_url"],(long)scene.roomID,2,@"0",0,[[DeviceInfo defaultManager] masterID],0,isplan,isactive];
                        BOOL result = [db executeUpdate:sql];
                        if(result)
                        {   [MBProgressHUD showSuccess:@"新增成功"];
                            NSLog(@"新增场景，入库成功！");
                             [IOManager removeTempFile];
                           
                            
                        }else {
                            [MBProgressHUD showSuccess:@"新增失败"];
                            NSLog(@"新增场景，入库失败！");
                             [IOManager removeTempFile];
                        }
                    }
                    [db close];
                }else {
                    [MBProgressHUD showSuccess:@"新增失败"];
                    NSLog(@"ERROR: sceneDict 为 null 或 不是NSDictionary类型");
                }
                
                
            }else { //失败
                [MBProgressHUD showError:msg];
                NSLog(@"ERROR :%@", msg);
            }
            
            
        }];
        
        return;
        
    }else {
      //编辑设备时，修改本地plist文件
      [IOManager writeScene:[NSString stringWithFormat:@"%@_%d.plist" , SCENE_FILE_NAME, scene.sceneID] scene:scene];
  }
    
}

- (void) addScene:(Scene *)scene withName:(NSString *)name withImage:(UIImage *)image withiSactive:(NSInteger)isactive block:(SaveOK )block {
    self.block = block;
    
    if (name.length >0) {
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyyMMddHHmmss";
        NSString *str = [formatter stringFromDate:[NSDate date]];
        NSString *imgFileName = [NSString stringWithFormat:@"%@.png", str];
        
        //同步云端
        NSString *sceneFile = [NSString stringWithFormat:@"%@_0.plist",SCENE_FILE_NAME];
        NSString *scenePath = [[IOManager scenesPath] stringByAppendingPathComponent:sceneFile];
        
        NSString *URL = [NSString stringWithFormat:@"%@Cloud/scene_add.aspx",[IOManager httpAddr]];
        NSString *fileName = [NSString stringWithFormat:@"%@_%d.plist",SCENE_FILE_NAME,scene.sceneID];
        NSDictionary *parameter;
        int isplan;
        
        NSMutableArray *schedulesTemp = [NSMutableArray array];
        
        for (NSDictionary *dict in scene.schedules) {
            Schedule *schedule = [[Schedule alloc] initWhithoutSchedule];
            
            [schedule setValuesForKeysWithDictionary:dict];
            
            [schedulesTemp addObject:schedule];
        }
        
        scene.schedules = [schedulesTemp copy];
        if(scene.schedules.count > 0)
        {
            parameter = @{
                          @"token":[UD objectForKey:@"AuthorToken"],
                          @"optype":@(0),
                          @"scencename":name,
                          @"imgname":imgFileName,
                          @"scencefile":scenePath,
                          @"isplan":@(1),
                          @"roomid":@(scene.roomID),
                          @"isactive":@(isactive)
                          };
            isplan = 1;
        }else {
            parameter = @{
                          @"token":[UD objectForKey:@"AuthorToken"],
                          @"optype":@(0),
                          @"scencename":name,
                          @"imgname":imgFileName,
                          @"scencefile":scenePath,
                          @"isplan":@(0),
                          @"roomid":@(scene.roomID),
                          @"isactive":@(isactive)
                          };
            isplan = 0;
        }
        NSData *imgData = UIImageJPEGRepresentation(image, 0.5);
        NSLog(@"imgDataSize: %.2f M", (float)imgData.length/1024/1024);
        
        NSData *fileData = [NSData dataWithContentsOfFile:scenePath];
        
        [[UploadManager defaultManager] uploadScene:fileData url:URL dic:parameter fileName:fileName imgData:imgData imgFileName:imgFileName completion:^(id responseObject) {
            
            NSNumber *result = [responseObject objectForKey:@"result"];
            NSString *msg = [responseObject objectForKey:@"msg"];
            
            if(result.integerValue == 0) { //成功
                
                NSDictionary *sceneDict = [responseObject objectForKey:@"scene"];
                if ([sceneDict isKindOfClass:[NSDictionary class]] && sceneDict.count >0) {
                    scene.sceneID = [[sceneDict objectForKey:@"scence_id"] intValue];
                    scene.sceneName = name;
                    scene.isplan = isplan;
                    scene.isactive = (int)isactive;
                    
                    [IOManager writeScene:[NSString stringWithFormat:@"%@_%d.plist" , SCENE_FILE_NAME, scene.sceneID]  scene:scene];
                    NSString *roomName = [SQLManager getRoomNameByRoomID:(int)scene.roomID];
                    
                    //插入数据库
                    FMDatabase *db = [SQLManager connectdb];
                    if([db open])
                    {
                        NSString *sql = [NSString stringWithFormat:@"insert into Scenes values(%d,'%@','%@','%@',%ld,%d,'%@',%d,null,'%ld','%d','%d','%ld')",scene.sceneID,name,roomName,[sceneDict objectForKey:@"image_url"],(long)scene.roomID,0,@"0",0,[[DeviceInfo defaultManager] masterID],0,isplan, isactive];
                        BOOL result = [db executeUpdate:sql];
                        if(result)
                        {   [MBProgressHUD showSuccess:@"新增成功"];
                            NSLog(@"新增场景，入库成功！");
                            if (self.block) {
                                self.block(YES);
                            }
                            [IOManager removeTempFile];
                            
                            //判断是否有定时，并且定时是否已开启，好发送8A指令通知C4主机下载plist文件
                            if (isplan == 1 && isactive == 1) {
                                //发TCP定时指令给主机
                                NSData *data = [[DeviceInfo defaultManager] scheduleScene:isactive sceneID:[NSString stringWithFormat:@"%d",scene.sceneID]];
                                SocketManager *sock = [SocketManager defaultManager];
                                [sock.socket writeData:data withTimeout:1 tag:1];
                            }
                            
                            
                        }else {
                            [MBProgressHUD showSuccess:@"新增失败"];
                            NSLog(@"新增场景，入库失败！");
                            [IOManager removeTempFile];
                        }
                    }
                    [db close];
                }else {
                    [MBProgressHUD showSuccess:@"新增失败"];
                    NSLog(@"ERROR: sceneDict 为 null 或 不是NSDictionary类型");
                }
                
                
            }else { //失败
                [MBProgressHUD showError:msg];
                NSLog(@"ERROR :%@", msg);
            }
            
            
        }];
        
        return;
        
    }else {
        //编辑设备时，修改本地plist文件
        [IOManager writeScene:[NSString stringWithFormat:@"%@_%d.plist" , SCENE_FILE_NAME, scene.sceneID] scene:scene];
    }
    
}

- (void)addDeviceTimer:(DeviceSchedule *)timer  isEdited:(BOOL)isEdited  mode:(int)mode isActive:(NSInteger)isActive block:(SaveOK )block {
    self.block = block;
    
    if (!isEdited) {
        
        //同步云端
        NSString *deviceTimerFile = [NSString stringWithFormat:@"%@_%ld_%d.plist",DEVICE_TIMER_FILE_NAME, [[DeviceInfo defaultManager] masterID], [SQLManager getENumberByDeviceID:timer.deviceID]];
        NSString *deviceTimerPath = [[IOManager deviceTimerPath] stringByAppendingPathComponent:deviceTimerFile];
        
        NSString *URL = [NSString stringWithFormat:@"%@Cloud/eq_timing.aspx",[IOManager httpAddr]];
        
        NSString *fileName = [NSString stringWithFormat:@"%@_%ld_%d.plist",DEVICE_TIMER_FILE_NAME, [[DeviceInfo defaultManager] masterID], [SQLManager getENumberByDeviceID:timer.deviceID]];
        NSDictionary *parameter;
        
        NSMutableArray *schedulesTemp = [NSMutableArray array];
        
        for (NSDictionary *dict in timer.schedules) {
            Schedule *schedule = [[Schedule alloc] initWhithoutSchedule];
            
            [schedule setValuesForKeysWithDictionary:dict];
            
            [schedulesTemp addObject:schedule];
        }
        
        timer.schedules = [schedulesTemp copy];
        if(timer.schedules.count >0)
        {
            parameter = @{
                          @"token":[UD objectForKey:@"AuthorToken"],
                          @"optype":@(mode),
                          @"scencefile":deviceTimerPath,
                          @"isactive":@(1)
                          };
        }
        
        
        NSData *fileData = [NSData dataWithContentsOfFile:deviceTimerPath];
        
        [[UploadManager defaultManager] uploadDeviceTimer:fileData url:URL dic:parameter fileName:fileName completion:^(id responseObject) {
            
            NSNumber *result = [responseObject objectForKey:@"result"];
            //NSString *msg = [responseObject objectForKey:@"msg"];
            
            if(result.integerValue == 0) { //成功
                
                //[MBProgressHUD showSuccess:@"新增成功"];
                
                if (self.block) {
                    self.block(YES);
                }
                
            }else { //失败
                //[MBProgressHUD showError:@"新增失败"];
                if (self.block) {
                    self.block(NO);
                }
            }
            
            
        }];
        
    }else {
        //编辑设备定时时，修改本地plist文件
        [IOManager writeDeviceTimer:[NSString stringWithFormat:@"%@_%ld_%d.plist",DEVICE_TIMER_FILE_NAME, [[DeviceInfo defaultManager] masterID], [SQLManager getENumberByDeviceID:timer.deviceID]] timer:timer]; 
    }
    
}



//另存为(保存为一个新的场景）
- (void)saveAsNewScene:(Scene *)scene withName:(NSString *)name withPic:(UIImage *)image
{
    if(name) {
        //同步云端
        NSString *fileName = [NSString stringWithFormat:@"%@_%d.plist",SCENE_FILE_NAME,scene.sceneID];
        NSString *scenePath = [[IOManager scenesPath] stringByAppendingPathComponent:fileName];
        NSString *URL = [NSString stringWithFormat:@"%@Cloud/scene_add.aspx",[IOManager httpAddr]];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyyMMddHHmmss";
        NSString *str = [formatter stringFromDate:[NSDate date]];
        NSString *imgFileName = [NSString stringWithFormat:@"%@.png", str];
    
        NSData *imgData = UIImageJPEGRepresentation(image, 0.5);
        NSLog(@"imgDataSize: %.2f M", (float)imgData.length/1024/1024);
        
        NSDictionary *parameter;
        scene.sceneName = name;
        
        if(scene.schedules.count > 0)
        {

            parameter = @{
                          @"token":[UD objectForKey:@"AuthorToken"],
                          @"optype":@(0),
                          @"scencename":name,
                          @"imgname":imgFileName,
                          @"scencefile":scenePath,
                          @"isplan":@(1),
                          @"roomid":@(scene.roomID)
                          };

        }else {
            parameter = @{
                          @"token":[UD objectForKey:@"AuthorToken"],
                          @"optype":@(0),
                          @"scencename":name,
                          @"imgname":imgFileName,
                          @"scencefile":scenePath,
                          @"isplan":@(0),
                          @"roomid":@(scene.roomID)
                          };
        }

        NSData *fileData = [NSData dataWithContentsOfFile:scenePath];
        [[UploadManager defaultManager] uploadScene:fileData url:URL dic:parameter fileName:fileName imgData:imgData imgFileName:imgFileName completion:^(id responseObject) {
                NSNumber *result = [responseObject objectForKey:@"result"];
                NSString *msg = [responseObject objectForKey:@"msg"];
            
              if(result.integerValue == 0) { //成功
                  
                  NSDictionary *sceneDict = [responseObject objectForKey:@"scene"];
                  if ([sceneDict isKindOfClass:[NSDictionary class]] && sceneDict.count >0) {
                      
                      //更新场景ID
                      scene.sceneID = [[sceneDict objectForKey:@"scence_id"] intValue];
                      
                      //imageURL
                      NSString *imgUrl =[sceneDict objectForKey:@"image_url"];
                      
                      //写Plist
                      [IOManager writeScene:[NSString stringWithFormat:@"%@_%d.plist" , SCENE_FILE_NAME, scene.sceneID] scene:scene];
                      
                      //获取房间名
                      NSString *roomName = [SQLManager getRoomNameByRoomID:(int)scene.roomID];
                      
                      //插入数据库
                      FMDatabase *db = [SQLManager connectdb];
                      if([db open])
                      {
                          NSString *sql = [NSString stringWithFormat:@"insert into Scenes values(%d,'%@','%@','%@',%ld,%d,'%@',%d,null,null,'%ld')",scene.sceneID,name,roomName,imgUrl,(long)scene.roomID,2,@"0",0,[[DeviceInfo defaultManager] masterID]];
                          BOOL result = [db executeUpdate:sql];
                          if (result) {
                              [MBProgressHUD showError:@"新增成功"];
                              NSLog(@"新增场景，入库成功！");
                               [IOManager removeTempFile];
                          }else{
                              [MBProgressHUD showError:@"新增失败"];
                               NSLog(@"新增场景，入库失败！");
                               [IOManager removeTempFile];
                          }
                      }
                      [db close];
                      
                  }else {
                      [MBProgressHUD showError:@"新增失败"];
                      NSLog(@"ERROR: sceneDict 为 null 或 不是NSDictionary类型");
                  }
                  
              }else { //失败
                  [MBProgressHUD showError:msg];
                  NSLog(@"ERROR :%@", msg);
              }
            
        }];

    }
    
    //编辑设备时，修改本地plist文件
    [IOManager writeScene:[NSString stringWithFormat:@"%@_%d.plist" , SCENE_FILE_NAME, scene.sceneID] scene:scene];

}

- (void)delScene:(Scene *)scene
{
    if (!scene.readonly) {
        NSString *filePath=[NSString stringWithFormat:@"%@/%@_%d.plist",[IOManager scenesPath], SCENE_FILE_NAME, scene.sceneID];
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        if(data)
        {
            [IOManager removeFile:filePath];
        }
       
    }
}

-(void) saveDeviceSchedule:(NSString *)plistName
{
    NSString *plistPath=[[IOManager scenesPath] stringByAppendingPathComponent:plistName];
    NSDictionary *parameter = @{@"plist_file":plistPath,@"token":[UD objectForKey:@"AuthorToken"]};

    NSData *fileData = [NSData dataWithContentsOfFile:plistPath];
    NSString *URL = [NSString stringWithFormat:@"%@Cloud/upload_plist.aspx",[IOManager httpAddr]];
    [[UploadManager defaultManager] uploadScene:fileData url:URL dic:parameter fileName:plistName imgData:nil imgFileName:@"" completion:^(id responseObject) {
        NSNumber *result = [responseObject objectForKey:@"result"];
        NSString *msg = [responseObject objectForKey:@"msg"];
        
        if(result.integerValue == 0) { //成功
            [MBProgressHUD showSuccess:@"保存成功"];
            
        }else { //失败
            [MBProgressHUD showError:msg];
        }
    }];
}

//保证newScene的ID不变修改定时
- (void)editSceneTimer:(Scene *)newScene
{
    [IOManager writeScene:[NSString stringWithFormat:@"%@_%d.plist" , SCENE_FILE_NAME, newScene.sceneID ] scene:newScene];
    
    //同步云端
    NSString *fileName = [NSString stringWithFormat:@"%@_%d.plist",SCENE_FILE_NAME,newScene.sceneID];
    
    Scene *tempScene =  [SQLManager sceneBySceneID:newScene.sceneID];
    newScene.sceneName = tempScene.sceneName;
    newScene.isplan =  tempScene.isplan;
    newScene.isactive = tempScene.isactive;
    
    NSString *scenePath=[[IOManager scenesPath] stringByAppendingPathComponent:fileName];
    NSDictionary *parameter;
    if (newScene.isplan == 0) {
        for (Schedule *schedule in newScene.schedules) {
            parameter = @{
                          @"token":[UD objectForKey:@"AuthorToken"],
                          @"optype":@(6),
                          @"scencefile":scenePath,
                          @"starttime":schedule.startTime,
                          @"endtime":schedule.endTime,
                          @"weekvalue":schedule.weekDays,
                          @"isactive":@(newScene.isactive),
                          @"sceneid":@(newScene.sceneID)
                          };
        }
    }else{
        for (Schedule *schedule in newScene.schedules) {
            parameter = @{
                          @"token":[UD objectForKey:@"AuthorToken"],
                          @"optype":@(7),
                          @"scencefile":scenePath,
                          @"starttime":schedule.startTime,
                          @"endtime":schedule.endTime,
                          @"weekvalue":schedule.weekDays,
                          @"isactive":@(newScene.isactive),
                          @"sceneid":@(newScene.sceneID)
                          };
        }
    }
    NSData *fileData = [NSData dataWithContentsOfFile:scenePath];
    NSString *URL = [NSString stringWithFormat:@"%@Cloud/eq_timing.aspx",[IOManager httpAddr]];
    [[UploadManager defaultManager] uploadScene:fileData url:URL dic:parameter fileName:fileName imgData:nil imgFileName:@"" completion:^(id responseObject) {
        
        NSLog(@"修改场景定时 --- responseObject: %@", responseObject);
        
        NSNumber *result = [responseObject objectForKey:@"result"];
        NSString *msg = [responseObject objectForKey:@"msg"];
        
        if(result.integerValue == 0) { //成功
            [MBProgressHUD showSuccess:@"修改定时成功"];
            
            //先发取消定时指令给主机
            NSData *data = [[DeviceInfo defaultManager] scheduleScene:0 sceneID:[NSString stringWithFormat:@"%d",newScene.sceneID]];
            SocketManager *sock = [SocketManager defaultManager];
            [sock.socket writeData:data withTimeout:1 tag:1];
            
            
            //再发8A指令，通知主机启动新的定时
            data = [[DeviceInfo defaultManager] scheduleScene:newScene.isactive sceneID:[NSString stringWithFormat:@"%d",newScene.sceneID]];
            
            [sock.socket writeData:data withTimeout:1 tag:1];
            
            
            
        }else { //失败
            [MBProgressHUD showError:msg];
        }
    }];
    
}

//保证newScene的ID不变
- (void)editScene:(Scene *)newScene
{
    [IOManager writeScene:[NSString stringWithFormat:@"%@_%d.plist" , SCENE_FILE_NAME, newScene.sceneID ] scene:newScene];
    //同步云端
    NSString *fileName = [NSString stringWithFormat:@"%@_%d.plist",SCENE_FILE_NAME,newScene.sceneID];
    newScene.sceneName = [SQLManager getSceneName:newScene.sceneID];
    NSString *scenePath=[[IOManager scenesPath] stringByAppendingPathComponent:fileName];
    NSDictionary *parameter;
    if(newScene.schedules.count > 0) //有定时
    {
        for (Schedule *schedule in newScene.schedules) {
                parameter = @{
                              @"token":[UD objectForKey:@"AuthorToken"],
                              @"optype":@(0),
                              @"scenceid":@(newScene.sceneID),
                              @"scencename":newScene.sceneName,
                              @"roomid":@(newScene.roomID),
                              @"isplan":@(1),
                              @"plistname":fileName,
                              @"scencefile":scenePath,
                              @"starttime":schedule.startTime,
                              @"endtime":schedule.endTime,
                              @"starttype":@(1),
                              @"weekvalue":schedule.weekDays
                              };
        }
    }else{ //没有定时
        
        if (newScene.sceneName && newScene.picName && fileName && newScene.roomID) {
        
            parameter = @{
                          @"token":[UD objectForKey:@"AuthorToken"],
                          @"optype":@(0),
                          @"scenceid":@(newScene.sceneID),
                          @"scencename":newScene.sceneName,
                          @"roomid":@(newScene.roomID),
                          @"isplan":@(0),
                          @"plistname":fileName,
                          @"scencefile":scenePath
                          };
        }
        
    }
   
    NSData *fileData = [NSData dataWithContentsOfFile:scenePath];
    NSString *URL = [NSString stringWithFormat:@"%@Cloud/scene_edit.aspx",[IOManager httpAddr]];
    [[UploadManager defaultManager] uploadScene:fileData url:URL dic:parameter fileName:fileName imgData:nil imgFileName:@"" completion:^(id responseObject) {
        
        NSLog(@"scene_edit --- responseObject: %@", responseObject);
        
        NSNumber *result = [responseObject objectForKey:@"result"];
        NSString *msg = [responseObject objectForKey:@"msg"];
        
        if(result.integerValue == 0) { //成功
            [MBProgressHUD showSuccess:@"保存成功"];
            [IOManager removeTempFile];
        }else { //失败
            [MBProgressHUD showError:msg];
        }
    }];
}

//保证newScene的ID不变只改变场景图片
- (void)editScene:(Scene *)newScene newSceneImage:(UIImage *)newSceneImage
{
    [IOManager writeScene:[NSString stringWithFormat:@"%@_%d.plist" , SCENE_FILE_NAME, newScene.sceneID ] scene:newScene];
    //同步云端
    NSString *fileName = [NSString stringWithFormat:@"%@_%d.plist",SCENE_FILE_NAME,newScene.sceneID];
    newScene.sceneName = [SQLManager getSceneName:newScene.sceneID];
    NSString *scenePath=[[IOManager scenesPath] stringByAppendingPathComponent:fileName];
    NSData *imgData = UIImageJPEGRepresentation(newSceneImage, 0.5);
    NSDictionary *parameter = @{
                                @"token":[UD objectForKey:@"AuthorToken"],
                                @"optype":@(0),
                                @"scenceid":@(newScene.sceneID),
                                @"scencename":newScene.sceneName,
                                @"roomid":@(newScene.roomID),
                                @"plistname":fileName,
                                @"scencefile":scenePath,
                                @"imgfile":[NSString stringWithFormat:@"scene_%d.png",newScene.sceneID]
                                };
    
    NSData *fileData = [NSData dataWithContentsOfFile:scenePath];
    NSString *URL = [NSString stringWithFormat:@"%@Cloud/scene_edit.aspx",[IOManager httpAddr]];

    [[UploadManager defaultManager] uploadScene:fileData url:URL dic:parameter fileName:fileName imgData:imgData imgFileName:[NSString stringWithFormat:@"scene_%d.png",newScene.sceneID] completion:^(id responseObject) {
        
        NSNumber *result = [responseObject objectForKey:@"result"];
        NSString *msg = [responseObject objectForKey:@"msg"];
        
        if(result.integerValue == 0) { //成功
            
            [SQLManager updateScenePic:[NSString stringWithFormat:@"%@UploadFiles/images/scene/scene_%d.png",[IOManager httpAddr],newScene.sceneID] sceneID:newScene.sceneID];
             [MBProgressHUD showSuccess:@"更换图片成功"];
            
        }else {
            //失败
            [MBProgressHUD showError:msg];
        }
    }];
}

//收藏场景
- (BOOL)favoriteScene:(Scene *)newScene
{
       // 写sqlite更新场景表的isFavorite字段
        FMDatabase *db = [SQLManager connectdb];
        if (![db open]) {
            NSLog(@"Could not open db.");
            return NO;
        }
        BOOL result = [db executeUpdate:@"UPDATE Scenes SET isFavorite = 2 WHERE id = ?",@(newScene.sceneID)];
    
        [db close];
    return result;
}

-(void)deleteFavoriteScene:(Scene *)scene withName:(NSString *)name
{
    
    NSString *scenePath=[[IOManager favoritePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%d.plist" , SCENE_FILE_NAME, scene.sceneID]];
    NSDictionary *dic = [PrintObject getObjectData:scene];
    BOOL ret = [dic writeToFile:scenePath atomically:YES];
    if(ret)
    {
        // 写sqlite更新场景文件名
        FMDatabase *db = [SQLManager connectdb];
        if (![db open]) {
            NSLog(@"Could not open db.");
            return ;
        }
        BOOL result =[db executeUpdate:@"UPDATE Scenes SET isFavorite = 1 WHERE id = ?",[NSNumber numberWithInt:scene.sceneID]];
        if(result)
        {
            NSLog(@"删除成功");
        }
        [db close];
    }

}

- (Scene *)readSceneByID:(int)sceneid
{
    NSString *scenePath=[[IOManager scenesPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%d.plist" , SCENE_FILE_NAME, sceneid]];
    
    NSDictionary *dictionary = [[NSDictionary alloc] initWithContentsOfFile:scenePath];
    if (dictionary) {
        Scene *scene=nil;
        if ([dictionary objectForKey:@"schedules"]) {
            scene=[[Scene alloc] init];
            
            [scene setSceneName:@""];
            NSMutableArray *schedules=[NSMutableArray new];
            for (NSDictionary *sch in [dictionary objectForKey:@"schedules"]) {
                Schedule *schedule=[[Schedule alloc] init];
                schedule.startTime=sch[@"startTime"];
                schedule.endTime=sch[@"endTime"];
                schedule.weekDays=sch[@"weekDays"];
                [schedules addObject:schedule];
            }
            scene.schedules=schedules;
        }else{
            scene=[[Scene alloc] initWhithoutSchedule];
        }
        scene.sceneID=sceneid;
        scene.readonly=[[dictionary objectForKey:@"readonly"] boolValue];
        scene.picName=[dictionary objectForKey:@"picName"];
        scene.roomID=[[dictionary objectForKey:@"roomID"] intValue];
        scene.roomName=[dictionary objectForKey:@"roomName"];
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
                device.poweron = [[dic objectForKey:@"poweron"] intValue];
                [devices addObject:device];
            }
            if ([dic objectForKey:@"dvolume"]) {
                DVD *device=[[DVD alloc] init];
                device.deviceID=[[dic objectForKey:@"deviceID"] intValue];
                device.dvolume=[[dic objectForKey:@"dvolume"] intValue];
                device.poweron = [[dic objectForKey:@"poweron"] intValue];
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
                device.poweron = [[dic objectForKey:@"poweron"] intValue];
                [devices addObject:device];
            }
            if ([dic objectForKey:@"unlock"]) {
                EntranceGuard *device=[[EntranceGuard alloc] init];
                device.deviceID=[[dic objectForKey:@"deviceID"] intValue];
                device.unlock=[[dic objectForKey:@"unlock"] intValue];
                [devices addObject:device];
            }
            if ([dic objectForKey:@"temperature"]) {
                Aircon *device=[[Aircon alloc] init];
                device.deviceID=[[dic objectForKey:@"deviceID"] intValue];
                device.temperature=[[dic objectForKey:@"temperature"] intValue];
                device.timing=[[dic objectForKey:@"timing"] intValue];
                device.WindLevel=[[dic objectForKey:@"WindLevel"] intValue];
                device.Windirection=[[dic objectForKey:@"Windirection"] intValue];
                device.mode=[[dic objectForKey:@"mode"] intValue];
                device.poweron=[[dic objectForKey:@"poweron"] intValue];
                [devices addObject:device];
            }
            if ([dic objectForKey:@"dropped"]) {
                Screen *device=[[Screen alloc] init];
                device.deviceID=[[dic objectForKey:@"deviceID"] intValue];
                device.dropped=[[dic objectForKey:@"dropped"] intValue];
                [devices addObject:device];
            }
            if ([dic objectForKey:@"showed"]) {
                Projector *device=[[Projector alloc] init];
                device.deviceID=[[dic objectForKey:@"deviceID"] intValue];
                device.showed=[[dic objectForKey:@"showed"] intValue];
                [devices addObject:device];
            }
            if ([dic objectForKey:@"waiting"]) {
                Amplifier *device=[[Amplifier alloc] init];
                device.deviceID=[[dic objectForKey:@"deviceID"] intValue];
                device.waiting=[[dic objectForKey:@"waiting"] intValue];
                [devices addObject:device];
            }
            
            if ([dic objectForKey:@"pushing"]) {
                WinOpener *device=[[WinOpener alloc] init];
                device.deviceID=[[dic objectForKey:@"deviceID"] intValue];
                device.pushing=[[dic objectForKey:@"pushing"] intValue];
                [devices addObject:device];
            }
            
            if ([dic objectForKey:@"switchon"]) {
                Plugin *device=[[Plugin alloc] init];
                device.deviceID=[[dic objectForKey:@"deviceID"] intValue];
                device.switchon=[[dic objectForKey:@"switchon"] intValue];
                [devices addObject:device];
            }
        }
        scene.devices=devices;
        return scene;
    }else{
        return [[Scene alloc] initWhithoutSchedule];
    }
}

- (void)poweroffAllDevice:(int)sceneid
{
    NSData *data=nil;
    SocketManager *sock=[SocketManager defaultManager];
    
    Scene *scene=[self readSceneByID:sceneid];
    for (id device in scene.devices)
    {
        if ([device respondsToSelector:@selector(deviceID)])
        {
            NSString *deviceid=[NSString stringWithFormat:@"%d",[device deviceID]];
            data=[[DeviceInfo defaultManager] close:deviceid];
            [sock.socket writeData:data withTimeout:1 tag:1];
        }
    }
    
    [[[AudioManager defaultManager] musicPlayer] stop];
}

-(void) dimingRoom:(int)roomid brightness:(int)bright
{
    SocketManager *sock=[SocketManager defaultManager];
    NSArray *lightIDS=[SQLManager getDimmerByRoom:roomid];
    for (NSString *lightID in lightIDS) {
        NSData *data=[[DeviceInfo defaultManager] changeBright:bright deviceID:lightID];
        [sock.socket writeData:data withTimeout:1 tag:1];
    }
}

-(void) sprightlyRoom:(int)roomid
{
    [self dimingRoom:roomid brightness:90];
}

-(void) gloomRoom:(int)roomid
{
    [self dimingRoom:roomid brightness:20];
}

-(void) romanticRoom:(int)roomid
{
    [self dimingRoom:roomid brightness:50];
}

-(void) dimingScene:(int)sceneid brightness:(int)bright
{
    SocketManager *sock=[SocketManager defaultManager];
    Scene *scene=[self readSceneByID:sceneid];
    for (id device in scene.devices) {
        if ([device isKindOfClass:[Light class]]) {
            Light *light=(Light *)device;
            NSString *deviceid=[NSString stringWithFormat:@"%d", light.deviceID];
            NSData *data=[[DeviceInfo defaultManager] changeBright:bright deviceID:deviceid];
            [sock.socket writeData:data withTimeout:1 tag:1];
        }
    }
}

//调节房间所有灯的氛围
- (void)dimingRoomLights:(NSArray *)lightIDs brightness:(int)bright
{
    SocketManager *sock = [SocketManager defaultManager];
    for (NSNumber *lightID in lightIDs) {
        NSData *data=[[DeviceInfo defaultManager] changeBright:bright deviceID:[NSString stringWithFormat:@"%@", lightID]];
        [sock.socket writeData:data withTimeout:1 tag:1];
    }
}

- (void)sprightlyForRoomLights:(NSArray *)lightIDs {
    [self dimingRoomLights:lightIDs brightness:90];
}

- (void)sprightlyForRoomLights:(NSArray *)lightIDs brightness:(int)brightness {
    [self dimingRoomLights:lightIDs brightness:brightness];
}

- (void)gloomForRoomLights:(NSArray *)lightIDs {
    [self dimingRoomLights:lightIDs brightness:20];
}

- (void)gloomForRoomLights:(NSArray *)lightIDs brightness:(int)brightness {
    [self dimingRoomLights:lightIDs brightness:brightness];
}

- (void)romanticForRoomLights:(NSArray *)lightIDs {
    [self dimingRoomLights:lightIDs brightness:50];
}

-(void) sprightly:(int)sceneid
{
    [self dimingScene:sceneid brightness:90];
}

-(void) gloom:(int)sceneid
{
    [self dimingScene:sceneid brightness:20];
}

-(void) romantic:(int)sceneid
{
    [self dimingScene:sceneid brightness:50];
}

-(void) startScene:(int)sceneid
{
    __block NSData *data=nil;
    SocketManager *sock=[SocketManager defaultManager];
    //面板场景
    if ([SQLManager getReadOnly:sceneid]==1) {
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
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (tv.volume>0) {
                    data=[[DeviceInfo defaultManager] changeTVolume:tv.volume deviceID:deviceid];
                    [sock.socket writeData:data withTimeout:1 tag:1];
                }
                if (tv.channelID>0) {
                    data=[[DeviceInfo defaultManager] switchProgram:tv.channelID deviceID:deviceid];
                    [sock.socket writeData:data withTimeout:1 tag:1];
                }
            });
        }
        
        if ([device isKindOfClass:[DVD class]]) {
            DVD *dvd=(DVD *)device;
            NSString *deviceid=[NSString stringWithFormat:@"%d", dvd.deviceID];
            data=[[DeviceInfo defaultManager] open:deviceid];
            [sock.socket writeData:data withTimeout:1 tag:1];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                data=[[DeviceInfo defaultManager] play:deviceid];
                [sock.socket writeData:data withTimeout:1 tag:1];
                if (dvd.dvolume>0) {
                    data=[[DeviceInfo defaultManager] changeTVolume:dvd.dvolume deviceID:deviceid];
                    [sock.socket writeData:data withTimeout:1 tag:1];
                }
            });
        }
        
        if ([device isKindOfClass:[Netv class]]) {
            Netv *netv=(Netv *)device;
            NSString *deviceid=[NSString stringWithFormat:@"%d", netv.deviceID];
            data=[[DeviceInfo defaultManager] open:deviceid];
            [sock.socket writeData:data withTimeout:1 tag:1];
            if (netv.nvolume>0) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    data=[[DeviceInfo defaultManager] changeTVolume:netv.nvolume deviceID:deviceid];
                    [sock.socket writeData:data withTimeout:1 tag:1];
                });
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
        
        if ([device isKindOfClass:[Plugin class]]) {
            Plugin *plugin=(Plugin *)device;
            NSString *deviceid=[NSString stringWithFormat:@"%d", plugin.deviceID];
            if (plugin.switchon) {
                data=[[DeviceInfo defaultManager] toogle:plugin.switchon deviceID:deviceid];
                [sock.socket writeData:data withTimeout:1 tag:1];
            }
        }
        
        if ([device isKindOfClass:[Aircon class]]) {
            Aircon *aircon=(Aircon *)device;
            NSString *deviceid=[NSString stringWithFormat:@"%d", aircon.deviceID];
            Device *device = [SQLManager getDeviceWithDeviceHtypeID:air roomID:scene.roomID];
            data=[[DeviceInfo defaultManager] toogleAirCon:YES deviceID:deviceid roomID:device.airID];
            [sock.socket writeData:data withTimeout:1 tag:1];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
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
            });
        }
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_USEC)), dispatch_get_main_queue(), ^{
        [self interlockScene:sceneid withRoom:scene.roomID];
    });
}


-(void) interlockScene:(int)sceneid withRoom:(int)rid
{
    NSString *scenePath=[[IOManager scenesPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%d.plist" , SCENE_FILE_NAME, sceneid]];
    NSString *content = [NSString stringWithContentsOfFile:scenePath encoding:NSUTF8StringEncoding error:nil];
    NSString *idstring = [[content componentsMatchedByRegex:@"<key>deviceID</key>\\s+<integer>(\\d+)</integer>" capture:1L] componentsJoinedByString:@","];
    NSArray *ids = [SQLManager othersWithScene:idstring withRoom:rid];
    NSData *data=nil;
    SocketManager *sock=[SocketManager defaultManager];
    for(NSString *did in ids)
    {
        data = [[DeviceInfo defaultManager] toogle:0x00 deviceID:did];
        [sock.socket writeData:data withTimeout:1 tag:1];
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
        //if ([self inDeviceArray:array device:deviceID]==-1) {
            int i=[self inArray:[self allDeviceIDs:scene.sceneID] device:deviceID];
            if (i>=0) {
                NSMutableArray *arr=[array mutableCopy];
                [arr replaceObjectAtIndex:i withObject:device];
                array=arr;
            }else{
                array=[array arrayByAddingObject:device];
            }
        //}
    }else{
        array=[NSArray arrayWithObject:device];
    }
    return array;
}

-(NSArray *)subDeviceFromScene:(Scene *)scene withDeivce:(int)deviceID
{
    NSArray *devices = scene.devices;
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"deviceID != %d",deviceID];
    return [devices filteredArrayUsingPredicate:pred];
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

-(int)inDeviceArray:(NSArray *)array device:(int)deviceID
{
    int index=0;
    for (id device in array) {
        if ([[device valueForKey:@"deviceID"] intValue]==deviceID) {
            return index;
        }
        index++;
    }
    return -1;
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
