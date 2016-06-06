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

- (IBAction)download:(id)sender
{
    DownloadManager *down=[DownloadManager defaultManager];
    NSURL *url=[NSURL URLWithString:@"http://imgsrc.baidu.com/baike/pic/item/0b7b02087bf40ad1f0dd605a572c11dfa9ecce4a.jpg"];
    [down download:url completion:^(){
        //[IOManager writeImage:@"a.jpg" image:image];
        NSLog(@"load.");
    }];
}

-(IBAction)upload:(id)sender
{
    NSString *cachepath=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject];
    NSString *path=[cachepath stringByAppendingPathComponent:@"0b7b02087bf40ad1f0dd605a572c11dfa9ecce4a.jpg"];
    
    NSURL *url = [NSURL URLWithString:@"http://localhost:3000/upload"];

}

- (IBAction)http:(id)sender
{
    NSURL *url = [NSURL URLWithString:@"http://localhost:3000/json"];
    
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
