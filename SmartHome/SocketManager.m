//
//  SocketManager.m
//  SmartHome
//
//  Created by Brustar on 16/5/26.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "SocketManager.h"

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
-(void)socketConnectHost{
    self.socket = [[AsyncSocket alloc] initWithDelegate:self];
    NSError *error = nil;
    [self.socket connectToHost:self.socketHost onPort:self.socketPort withTimeout:3 error:&error];
}

#pragma mark  - 连接成功回调
-(void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    NSLog(@"socket连接成功");
    // 每隔30s像服务器发送心跳包
    self.connectTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(longConnectToSocket) userInfo:nil repeats:YES];// 在longConnectToSocket方法中进行长连接需要向服务器发送的讯息
    [self.connectTimer fire];
}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSString *recv=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@",recv);
}

-(void)onSocket:(AsyncSocket *)sock didReadPartialDataOfLength:(long)partialLength tag:(long)tag
{
    NSLog(@"Received bytes: %ld",partialLength);
}

// 切断socket
-(void)cutOffSocket{
    self.socket.userData = SocketOfflineByUser;// 声明是由用户主动切断
    [self.connectTimer invalidate];
    [self.socket disconnect];
}

-(void)onSocketDidDisconnect:(AsyncSocket *)sock
{
    NSLog(@"sorry the connect is failure %ld",sock.userData);
    if (sock.userData == SocketOfflineByServer) {
        // 服务器掉线，重连
        [self socketConnectHost];
    }
    else if (sock.userData == SocketOfflineByUser) {
        // 如果由用户断开，不进行重连
        return;
    }
}

// 心跳连接
-(void)longConnectToSocket{
    // 根据服务器要求发送固定格式的数据，假设为指令@"longConnect"，但是一般不会是这么简单的指令
    NSString *longConnect = @"longConnect\r\n";
    NSData   *dataStream  = [longConnect dataUsingEncoding:NSUTF8StringEncoding];
    [self.socket writeData:dataStream withTimeout:1 tag:1];
    [self.socket readDataToData:[AsyncSocket CRLFData] withTimeout:1 tag:1];
}
@end
