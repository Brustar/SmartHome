//
//  IBeaconController.m
//  SmartHome
//
//  Created by Brustar on 16/5/10.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "IBeaconController.h"
#import "SocketManager.h"
#import "PackManager.h"
#import "CryptoManager.h"

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

-(IBAction)tcp:(id)sender
{
    SocketManager *sock=[SocketManager defaultManager];
    sock.socketHost = @"192.168.1.183";// host设定
    sock.socketPort = 1000;// port设定
    
    // 在连接前先进行手动断开
    sock.socket.userData = SocketOfflineByUser;
    [sock cutOffSocket];
    
    // 确保断开后再连，如果对一个正处于连接状态的socket进行连接，会出现崩溃
    sock.socket.userData = SocketOfflineByServer;
    [sock socketConnectHost];

    NSString *cmd=@"hello firefly2\r\n\r";
    [sock.socket writeData:[PackManager fireflyProtocol:cmd] withTimeout:1 tag:1];
    [sock.socket readDataToData:[AsyncSocket CRLFData] withTimeout:1 tag:1];
}

-(IBAction)sendSearchBroadcast:(id)sender
{
        NSString* bchost=@"255.255.255.255"; //这里发送广播
        [self sendToUDPServer:@"hello udp" address:bchost port:10000];
}

-(void)sendToUDPServer:(NSString*) msg address:(NSString*)address port:(int)port{
    AsyncUdpSocket *udpSocket=[[AsyncUdpSocket alloc]initWithDelegate:self]; //得到udp util
    NSLog(@"address:%@,port:%d,msg:%@",address,port,msg);
    //receiveWithTimeout is necessary or you won't receive anything
    [udpSocket receiveWithTimeout:10 tag:2]; //设置超时10秒
    [udpSocket enableBroadcast:YES error:nil]; //如果你发送广播，这里必须先enableBroadcast
    NSData *data=[msg dataUsingEncoding:NSUTF8StringEncoding];
    [udpSocket sendData:data toHost:address port:port withTimeout:10 tag:1]; //发送udp
}

-(BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)host port:(UInt16)port
{
    NSString* rData= [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"onUdpSocket:didReceiveData:---%@",rData);
    return YES;
}

-(void)onUdpSocket:(AsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
    NSLog(@"didNotSendDataWithTag----");
}

-(void)onUdpSocket:(AsyncUdpSocket *)sock didNotReceiveDataWithTag:(long)tag dueToError:(NSError *)error
{
    NSLog(@"didNotReceiveDataWithTag----");
}

-(void)onUdpSocket:(AsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
    NSLog(@"didSendDataWithTag----");
}

-(void)onUdpSocketDidClose:(AsyncUdpSocket *)sock
{
    NSLog(@"onUdpSocketDidClose----");
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


@end
