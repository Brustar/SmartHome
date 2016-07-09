//
//  IBeaconController.m
//  SmartHome
//
//  Created by Brustar on 16/5/10.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "IBeaconController.h"
#import "CryptoManager.h"
#import "PackManager.h"
#import "NetStatusManager.h"

@implementation IBeaconController

-(void) viewDidLoad
{
    self.beacon=[[IBeacon alloc] init];
    [self.beacon addObserver:self forKeyPath:@"beacons" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    
    IbeaconManager *beaconManager=[IbeaconManager defaultManager];
    [beaconManager start:self.beacon];
    
    [self.beacon addObserver:self forKeyPath:@"volume" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    VolumeManager *volume=[VolumeManager defaultManager];
    [volume start:self.beacon];
    
    
    //开启网络状况的监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
    self.hostReach = [Reachability reachabilityWithHostname:@"www.apple.com"];
    [self.hostReach startNotifier];  //开始监听,会启动一个run loop
    [self updateInterfaceWithReachability: self.hostReach];
}

//监听到网络状态改变
- (void) reachabilityChanged: (NSNotification* )note
{
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    [self updateInterfaceWithReachability: curReach];
}


//处理连接改变后的情况
- (void) updateInterfaceWithReachability: (Reachability*) curReach
{
    //对连接改变做出响应的处理动作。
    NetworkStatus status = [curReach currentReachabilityStatus];
    if(status == ReachableViaWWAN)
    {
        printf("\n3g/2G\n");
        NSLog(@"外出模式");
    }
    else if(status == ReachableViaWiFi)
    {
        printf("\nwifi\n");
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"tcpPort"] intValue]>0) {
            NSLog(@"在家模式");
        }else{
            NSLog(@"外出模式");
        }
    }else
    {
        printf("\n无网络\n");
        NSLog(@"离线模式");
    }
    
}

- (IBAction)addSongsToMusicPlayer:(id)sender
{
    [[AudioManager defaultManager] addSongsToMusicPlayer];
}

-(NSURLSessionDownloadTask *)task{
    
    if (!_task) {
        
        AFHTTPSessionManager *session=[AFHTTPSessionManager manager];
        
        NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://120.25.226.186:32812/resources/videos/minion_01.mp4"]];
        
        _task=[session downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
            
            //下载进度
            NSLog(@"%@",downloadProgress);
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                
                //self.pro.progress=downloadProgress.fractionCompleted;
                
            }];
            
        } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
            
            //下载到哪个文件夹
            NSString *cachePath=NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
            
            NSString *fileName=[cachePath stringByAppendingPathComponent:response.suggestedFilename];
            
            return [NSURL fileURLWithPath:fileName];
            
        } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
            NSLog(@"下载完成了 %@",filePath);
        }];
    }
    
    return _task;
}

- (IBAction)download:(id)sender
{
    [self.task resume]; 
}

-(IBAction)upload:(id)sender
{
    NSString *cachepath=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject];
    NSString *path=[cachepath stringByAppendingPathComponent:@"0b7b02087bf40ad1f0dd605a572c11dfa9ecce4a.jpg"];
    
    NSString *URL = @"http://localhost:3000/upload";
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    // 实际上就是AFN没有对响应数据做任何处理的情况
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    // formData是遵守了AFMultipartFormData的对象
    [manager POST:URL parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        // 将本地的文件上传至服务器
        //NSURL *fileURL = [NSURL URLWithString:path];
        NSData *fileData = [NSData dataWithContentsOfFile:path];
        [formData appendPartWithFileData:fileData name:@"upload" fileName:@"a.jpg" mimeType:@"multipart/form-data"];
        //[formData appendPartWithFileURL:fileURL name:@"upload" error:NULL];
    } progress:nil success:^(NSURLSessionDataTask *operation, id responseObject) {
        NSString *result = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"完成 %@", result);
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        NSLog(@"错误 %@", error.localizedDescription);
    }];

}

- (IBAction)logout:(id)sender
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"token"];
}

- (IBAction)Des:(id)sender {
    NSString *str=@"hello";
    NSString *tar=@"ev/A2FRCkPM=";
    NSLog(@"md5:%@",[str md5]);
    NSLog(@"encr:%@",[str encryptWithText:@"des"]);
    NSLog(@"dec:%@",[tar decryptWithText:@"des"]);
}

- (IBAction)homekit:(id)sender {
    HMHomeManager *homeManager = [[HMHomeManager alloc] init];
    homeManager.delegate = self;
    HMAccessoryBrowser *accessoryBrowser = [[HMAccessoryBrowser alloc] init];
    accessoryBrowser.delegate = self;
    [accessoryBrowser startSearchingForNewAccessories];
}

- (void)accessoryBrowser:(HMAccessoryBrowser *)browser didFindNewAccessory:(HMAccessory *)accessory
{
    NSLog(@"found one");
}

- (IBAction)http:(id)sender
{
    NSString *url = @"http://localhost:3000/json";
    // GET
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    // 将数据作为参数传入
    //NSDictionary *dict = @{@"username":@"12",@"pwd":@"13"};
    [mgr GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"success:%@",responseObject);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"failure:%@",error);
    }];
}

-(IBAction)initTcp:(id)sender
{
    SocketManager *sock=[SocketManager defaultManager];
    sock.socketHost = [[NSUserDefaults standardUserDefaults] objectForKey:@"tcpServer"];
    sock.socketPort = [[[NSUserDefaults standardUserDefaults] objectForKey:@"tcpPort"] intValue];
    
    // 在连接前先进行手动断开
    [sock cutOffSocket];
    
    // 确保断开后再连，如果对一个正处于连接状态的socket进行连接，会出现崩溃
    [sock socketConnectHost];
}

-(IBAction)sendMsg:(id)sender
{
    NSString *cmd=@"EC00000000FF0000FFEA";
    SocketManager *sock=[SocketManager defaultManager];
    [sock.socket writeData:[PackManager dataFormHexString:cmd] withTimeout:1 tag:1];
    [sock.socket readDataToData:[NSData dataWithBytes:"\xEA" length:1] withTimeout:1 tag:1];
}

-(IBAction)disconnect:(id)sender
{
    SocketManager *sock=[SocketManager defaultManager];
    [sock cutOffSocket];
}

-(IBAction)sendSearchBroadcast:(id)sender
{
    NSString *str =@"ec80000000ff0006c0a8c7ef1f4167ea";
    NSData *data =[PackManager dataFormHexString:str];
    NSLog(@"Data:%@,checksum:%i",data,[PackManager checkProtocol:data cmd:0x80]);
    
    NSLog(@"wifi:%@",[NetStatusManager getWifiName]);
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"beacons"])
    {
        NSString *position;
        NSArray *beacons=[self.beacon valueForKey:@"beacons"];
        for (CLBeacon *beacon in beacons) {
            NSString *str;
            switch (beacon.proximity) {
                case CLProximityNear:
                    str = @"近";
                    position=[self beaconInfo:beacon distance:str];
                    break;
                case CLProximityImmediate:
                    str = @"超近";
                    position=[self beaconInfo:beacon distance:str];
                    break;
                case CLProximityFar:
                    str = @"远";
                    position=[self beaconInfo:beacon distance:str];
                    break;
                case CLProximityUnknown:
                    str = @"不见了";
                    position=[self beaconInfo:beacon distance:str];
                    break;
                default:
                    break;
            }
            
        }
        self.myLabel.text = position;
    }
    
    if([keyPath isEqualToString:@"volume"])
    {
        self.volumeLabel.text=[NSString stringWithFormat:@"%@",[self.beacon valueForKey:@"volume"]];
    }
}

-(NSString *) beaconInfo:(CLBeacon *)beacon distance:(NSString *)dis
{
    if ([beacon.major intValue]==10002) {
        return [NSString stringWithFormat:@"二楼 %@",dis];
    }else if ([beacon.major intValue]==10001) {
        return [NSString stringWithFormat:@"一楼 %@",dis];
    }
    return @"";
}


-(void)dealloc
{
    [self.beacon removeObserver:self forKeyPath:@"beacons" context:NULL];
    [self.beacon removeObserver:self forKeyPath:@"volume" context:NULL];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

@end
