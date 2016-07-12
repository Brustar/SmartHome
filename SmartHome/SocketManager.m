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

@implementation SocketManager

+ (id)defaultManager {
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
    [self.socket connectToHost:self.socketHost onPort:self.socketPort withTimeout:3 error:&error];
}

// 切断socket
-(void)cutOffSocket{
    self.socket.userData = SocketOfflineByUser;// 声明是由用户主动切断
    [self.connectTimer invalidate];
    [self.socket disconnect];
}

// 心跳连接
-(void)longConnectToSocket{
    // 根据服务器要求发送固定格式的数据，假设为指令@"longConnect"，但是一般不会是这么简单的指令
    NSString *longConnect = @"longConnect\r\n";
    NSData   *dataStream  = [longConnect dataUsingEncoding:NSUTF8StringEncoding];
    [self.socket writeData:dataStream withTimeout:1 tag:1];
    [self.socket readDataToData:[AsyncSocket CRLFData] withTimeout:1 tag:1];
}

-(void)initUDP:(int)port
{
    NSError *bindError = nil;
    AsyncUdpSocket *udpSocket=[[AsyncUdpSocket alloc]initWithDelegate:self];
    [udpSocket bindToPort:40000 error:&bindError];
    
    if (bindError) {
        NSLog(@"bindError = %@",bindError);
    }
    
    [udpSocket receiveWithTimeout:5000 tag:1]; //接收数据
}

-(void)initTcp:(NSString *)addr port:(int)port mode:(int)mode delegate:(id)delegate
{
    self.socketHost = addr;
    self.socketPort = port;
    self.delegate=delegate;
    self.netMode=mode;
    // 在连接前先进行手动断开
    [self cutOffSocket];
    
    // 确保断开后再连，如果对一个正处于连接状态的socket进行连接，会出现崩溃
    [self socketConnectHost];
}

#pragma mark  - TCP delegate
-(void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    NSLog(@"socket连接成功,host:%@,port:%d",host,port);
    // 每隔30s像服务器发送心跳包
    //self.connectTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(longConnectToSocket) userInfo:nil repeats:YES];
    //[self.connectTimer fire];
}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    //NSString *recv=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"received data:%@",data);
    [self.delegate recv:data withTag:tag];
}

-(void)onSocket:(AsyncSocket *)sock didReadPartialDataOfLength:(long)partialLength tag:(long)tag
{
    NSLog(@"Received bytes: %ld",partialLength);
}

-(void)onSocketDidDisconnect:(AsyncSocket *)sock
{
    NSLog(@"sorry the connect is failure %ld",sock.userData);
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
    [PackManager handleUDP:data];
    return YES;
}

-(void)onUdpSocket:(AsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
    NSLog(@"didNotSendDataWithTag.");
}

-(void)onUdpSocket:(AsyncUdpSocket *)sock didNotReceiveDataWithTag:(long)tag dueToError:(NSError *)error
{
    NSLog(@"didNotReceiveDataWithTag.");
}

-(void)onUdpSocket:(AsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
    NSLog(@"didSendDataWithTag.");
}

-(void)onUdpSocketDidClose:(AsyncUdpSocket *)sock
{
    NSLog(@"onUdpSocketDidClose.");
}

@end
