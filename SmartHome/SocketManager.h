//
//  SocketManager.h
//  SmartHome
//
//  Created by Brustar on 16/5/26.
//  Copyright © 2016年 Brustar. All rights reserved.
//
#import "AsyncSocket.h"

enum{
    SocketOfflineByServer,// 服务器掉线，默认为0
    SocketOfflineByUser,  // 用户主动cut
};

@interface SocketManager : NSObject

@property (nonatomic, strong) AsyncSocket    *socket;       // socket
@property (nonatomic, copy  ) NSString       *socketHost;   // socket的Host
@property (nonatomic, assign) UInt16         socketPort;    // socket的prot

@property (nonatomic, retain) NSTimer        *connectTimer; // 计时器

+ (id)defaultManager;
-(void)socketConnectHost;// socket连接
-(void)cutOffSocket; // 断开socket连接

@end
