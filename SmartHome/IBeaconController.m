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
#import "HttpManager.h"
#import "MBProgressHUD+NJ.h"
#import "ProtocolManager.h"
#import "UIImageView+AFNetworking.h"
#import "RegexKitLite.h"
#import "IbeaconManager.h"
#import "VolumeManager.h"
#import "AudioManager.h"

@implementation IBeaconController

-(void) viewDidLoad
{
    DeviceInfo *device=[DeviceInfo defaultManager];
    [device addObserver:self forKeyPath:@"beacons" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
    
    IbeaconManager *beaconManager=[IbeaconManager defaultManager];
    [beaconManager start:device];
    
    [device addObserver:self forKeyPath:@"volume" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
    VolumeManager *volume=[VolumeManager defaultManager];
    [volume start:device];
    
    
    //开启网络状况的监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
    self.hostReach = [Reachability reachabilityWithHostname:@"www.apple.com"];
    [self.hostReach startNotifier];  //开始监听,会启动一个run loop
    [self updateInterfaceWithReachability: self.hostReach];
    NSURL *url=[NSURL URLWithString:@"http://e-cloudcn.com/img/cj_kt.jpg"];
    [self.imagev setImageWithURL:url];

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
    SocketManager *sock=[SocketManager defaultManager];
    if(status == ReachableViaWWAN)
    {
        printf("\n3g/4G/2G\n");
        if (sock.netMode==outDoor) {
            return;
        }
        //connect master
        NSUserDefaults *userdefault=[NSUserDefaults standardUserDefaults];
        [sock initTcp:[userdefault objectForKey:@"tcpServer"] port:[[userdefault objectForKey:@"tcpPort"] intValue] mode:atHome delegate:self];
        NSLog(@"外出模式");
    }
    else if(status == ReachableViaWiFi)
    {
        printf("\nwifi\n");
        if (sock.netMode==atHome) {
            
            return;
        }else if (sock.netMode==outDoor){
            NSLog(@"外出模式");
            
        }else{
            
        }
        //connect cloud
        [sock initTcp:[IOManager tcpAddr] port:[IOManager tcpPort] mode:outDoor delegate:self];
        NSLog(@"在家模式");
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
    
    NSDictionary *dict = @{@"UserID":[[NSUserDefaults standardUserDefaults] objectForKey:@"UserID"]};

    NSString *url = [NSString stringWithFormat:@"%@UserLogOut.aspx",[IOManager httpAddr]];
    HttpManager *http=[HttpManager defaultManager];
    http.delegate=self;
    [http sendPost:url param:dict];
    
}
-(void) httpHandler:(id) responseObject
{
    if([responseObject[@"Result"] intValue] == 0)
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"token"];
    }
    [MBProgressHUD showSuccess:responseObject[@"Msg"]];
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
    NSUserDefaults *userdefault=[NSUserDefaults standardUserDefaults];
    
    [sock initTcp:[userdefault objectForKey:@"tcpServer"] port:[[userdefault objectForKey:@"tcpPort"] intValue] mode:atHome delegate:self];
    //[sock initTcp:[IOManager tcpAddr] port:[IOManager tcpPort] mode:outDoor delegate:self];
}

-(IBAction)sendMsg:(id)sender
{
    //NSString *cmd=@"EC00000000FF0000FFEA";
    NSString *cmd=@"EC060101000000000000EA";
    SocketManager *sock=[SocketManager defaultManager];
    [sock.socket writeData:[PackManager dataFormHexString:cmd] withTimeout:1 tag:1];
    [sock.socket readDataToData:[NSData dataWithBytes:"\xEA" length:1] withTimeout:1 tag:1];
    
    //self.timer =  [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(myLog:) userInfo:nil repeats:YES];
}

-(IBAction)myLog:(id)sender
{
    NSLog(@"log...");
    SocketManager *sock=[SocketManager defaultManager];
    [sock.socket readDataWithTimeout:-1 tag:1];
}

-(void)recv:(NSData *)data withTag:(long)tag
{
    NSLog(@"data:%@,tag:%ld",data,tag);
}

-(IBAction)disconnect:(id)sender
{
    SocketManager *sock=[SocketManager defaultManager];
    [sock cutOffSocket];
}

-(IBAction)sendSearchBroadcast:(id)sender
{
    NSString *str =@"ec8ff600c0a8c7ef1f4167ea";
    NSData *data =[PackManager dataFormHexString:str];
    Proto proto=protocolFromData(data);
    NSLog(@"cmd:%d,action:%d",proto.masterID,proto.action.G);
    
    NSLog(@"Data:%@,proto:%@",data,[NSData dataWithBytes:&proto length:sizeof(proto)]);
    
    Proto pro;
    pro.head=0xEC;
    pro.tail=0xEA;
    pro.cmd=1;
    pro.deviceID=2;
    pro.deviceType=3;
    pro.masterID=4;
    pro.action.state=5;
    pro.action.RValue=1;
    NSLog(@"pro:%@",dataFromProtocol(pro));
    
    ProtocolManager *protos = [ProtocolManager defaultManager];
    [protos fetchAll];
    [protos trace];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"beacons"])
    {
        NSString *position;
        DeviceInfo *device=[DeviceInfo defaultManager];
        NSArray *beacons=[device valueForKey:@"beacons"];
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
        DeviceInfo *device=[DeviceInfo defaultManager];
        self.volumeLabel.text=[NSString stringWithFormat:@"%@",[device valueForKey:@"volume"]];
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
    DeviceInfo *device=[DeviceInfo defaultManager];
    [device removeObserver:self forKeyPath:@"beacons" context:NULL];
    [device removeObserver:self forKeyPath:@"volume" context:NULL];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    [self.timer invalidate];
}

@end