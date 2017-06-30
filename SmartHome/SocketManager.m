//
//  SocketManager.m
//  SmartHome
//
//  Created by Brustar on 16/5/26.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "SocketManager.h"
#import "AsyncUdpSocket.h"
#import "PackManager.h"
#import "MBProgressHUD+NJ.h"
#import "SceneManager.h"
#import "NetStatusManager.h"

@implementation SocketManager

+ (instancetype)defaultManager {
    static SocketManager *sharedInstance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

// socket连接
-(void)socketConnectHost
{
    self.socket = [[AsyncSocket alloc] initWithDelegate:self];
    NSError *error = nil;
    [self.socket connectToHost:self.socketHost onPort:self.socketPort error:&error];
}

// 切断socket
-(void)cutOffSocket{
    self.socket.userData = SocketOfflineByUser;// 声明是由用户主动切断
    [self.connectTimer invalidate];
    [self.socket disconnect];
}

// 心跳连接
-(void)longConnectToSocket
{
    // 根据服务器要求发送固定格式的数据，假设为指令@"longConnect"，但是一般不会是这么简单的指令
    NSString *longConnect = @"longConnect\r\n";
    NSData   *dataStream  = [longConnect dataUsingEncoding:NSUTF8StringEncoding];
    [self.socket writeData:dataStream withTimeout:1 tag:1];
    [self.socket readDataToData:[AsyncSocket CRLFData] withTimeout:-1 tag:1];
}

-(void)connectUDP:(int)port
{
    if (![NetStatusManager isEnableWIFI]) {
        [self connectTcp];
        return;
    }
    [self connectUDP:port delegate:self];
}

-(void)connectUDP:(int)port delegate:(id)delegate
{
    NSError *bindError = nil;
    AsyncUdpSocket *udpSocket=[[AsyncUdpSocket alloc] initWithDelegate:delegate];
    [udpSocket bindToPort:port error:&bindError];
    
    if (bindError) {
        [self connectTcp];
        NSLog(@"bindError = %@",bindError);
        return;
    }
    
    [udpSocket receiveWithTimeout:5 tag:1]; //接收数据
}

-(void)initTcp:(NSString *)addr port:(int)port delegate:(id)delegate
{
    self.socketHost = addr;
    self.socketPort = port;
    self.delegate = delegate;
    // 在连接前先进行手动断开
    [self cutOffSocket];
    
    // 确保断开后再连，如果对一个正处于连接状态的socket进行连接，会出现崩溃
    [self socketConnectHost];
}

- (void) connectTcp
{
    //请求协调服务器
    [self initTcp:[IOManager tcpAddr] port:[IOManager tcpPort] delegate:nil];
    DeviceInfo *device=[DeviceInfo defaultManager];
    device.masterPort=[IOManager tcpPort];
    device.masterIP=[IOManager tcpAddr];
    device.connectState=outDoor;
    
    NSData *data=[device author];
    [self.socket writeData:data withTimeout:1 tag:1000];
    [self.socket readDataToData:[NSData dataWithBytes:"\xEA" length:1] withTimeout:-1 tag:1000];
}

- (void) handleUDP:(NSData *)data
{
    DeviceInfo *info=[DeviceInfo defaultManager];
    if ([PackManager checkProtocol:data cmd:0x80] || [PackManager checkProtocol:data cmd:0x81]) {
        
        NSData *ip=[data subdataWithRange:NSMakeRange(4, 4)];
        NSData *port=[data subdataWithRange:NSMakeRange(8, 2)];
             
        info.masterIP=[PackManager NSDataToIP:ip];
        //info.masterPort=(int)[PackManager dataToUInt16:port];
        info.connectState=atHome;

        //release 不能马上去连，要暂停0.1S,再连从服务器，不然会崩溃
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(100 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
            [self initTcp:[PackManager NSDataToIP:ip] port:(int)[PackManager dataToUInt16:port] delegate:nil];
            //[self.socket writeData:[[DeviceInfo defaultManager] localAuthor] withTimeout:-1 tag:0];
            [self.socket readDataToData:[NSData dataWithBytes:"\xEA" length:1] withTimeout:-1 tag:0];
        });
    }else{
        [self connectTcp];
    }
}

- (void) handleTCP:(NSData *)data
{
    if (![PackManager checkProtocol:data cmd:0xef]) {
        NSData *ip=[data subdataWithRange:NSMakeRange(4, 4)];
        NSData *port=[data subdataWithRange:NSMakeRange(8, 2)];
        //release 不能马上去连，要暂停0.1S,再连从服务器，不然会崩溃
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(100 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
            [self initTcp:[PackManager NSDataToIP:ip] port:(int)[PackManager dataToUInt16:port] delegate:nil];
            DeviceInfo *device=[DeviceInfo defaultManager];
            device.masterPort=(int)[PackManager dataToUInt16:port];
            device.masterIP = [PackManager NSDataToIP:ip];
            NSData *masterID=[data subdataWithRange:NSMakeRange(2, 2)];
            device.masterID =(long)[PackManager dataToUInt16:masterID];
            
            //[self.socket writeData:[[DeviceInfo defaultManager] author] withTimeout:-1 tag:0];
            [self.socket readDataToData:[NSData dataWithBytes:"\xEA" length:1] withTimeout:-1 tag:0];
        });
        
    }
}

#pragma mark  - TCP delegate
-(void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    NSLog(@"socket连接成功,host:%@,port:%d",host,port);
    DeviceInfo *device=[DeviceInfo defaultManager];
    if (port == device.masterPort) {
        device.connectState=outDoor;
    }else{
        device.connectState=atHome;
    }
    [self.socket writeData:[[DeviceInfo defaultManager] author] withTimeout:-1 tag:0];
    [self.socket readDataToData:[NSData dataWithBytes:"\xEA" length:1] withTimeout:-1 tag:0];
    
    [NC postNotificationName:@"NetWorkDidChangedNotification" object:nil];
}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSLog(@"received %ld data:%@",tag,data);
    Proto proto=protocolFromData(data);
    if (proto.cmd == 0x8B) {
        [[NSNotificationCenter defaultCenter] postNotificationName:KICK_OUT object:nil];
        return;
    }
    
    if (tag==1000) {
        [self handleTCP:data];
    }else{
        if (self.delegate) {
            [self.delegate recv:data withTag:tag];
        }
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1000 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
        [self.socket readDataToData:[NSData dataWithBytes:"\xEA" length:1] withTimeout:-1 tag:0];
    });
}

-(void)onSocket:(AsyncSocket *)sock didReadPartialDataOfLength:(long)partialLength tag:(long)tag
{
    NSLog(@"Received bytes: %ld",partialLength);
}

-(void)onSocketDidDisconnect:(AsyncSocket *)sock
{
    NSLog(@"sorry the connect is failure %ld",sock.userData);
    DeviceInfo *device=[DeviceInfo defaultManager];
    device.connectState=offLine;
    if (sock.userData == SocketOfflineByServer) {// 服务器掉线，重连
        [self socketConnectHost];
    }else if (sock.userData == SocketOfflineByUser) {// 如果由用户断开，不进行重连
        return;
    }
}

#pragma mark  - UDP delegate
-(BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)host port:(UInt16)port
{
    NSLog(@"onUdpSocket:%@",data);
    [self handleUDP:data];
    return NO;
}

-(void)onUdpSocket:(AsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
    NSLog(@"didNotSendDataWithTag.");
}

-(void)onUdpSocket:(AsyncUdpSocket *)sock didNotReceiveDataWithTag:(long)tag dueToError:(NSError *)error
{
    DeviceInfo *device=[DeviceInfo defaultManager];
    if(device.connectState!=atHome)
    {
        [self connectTcp];
    }
    NSLog(@"didNotReceiveDataWithTag.");
}

-(void)onUdpSocket:(AsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
    NSLog(@"didSendDataWithTag.");
}

-(void)onUdpSocketDidClose:(AsyncUdpSocket *)sock
{
    NSLog(@"onUdpSocketDidClose.");
    [self connectTcp];
}

@end
