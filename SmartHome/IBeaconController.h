//
//  IBeaconController.h
//  SmartHome
//
//  Created by Brustar on 16/5/10.
//  Copyright © 2016年 Brustar. All rights reserved.
//
#import <AFNetworking.h>
#import <HomeKit/HomeKit.h>
#import "public.h"
#import "Light.h"
#import "AsyncUdpSocket.h"

@interface IBeaconController : UIViewController<HMHomeManagerDelegate,HMAccessoryBrowserDelegate>

@property (strong, nonatomic) IBeacon *beacon;
@property (strong, nonatomic) IBOutlet UILabel *myLabel;
@property (strong, nonatomic) IBOutlet UILabel *volumeLabel;

@property(nonatomic,strong) NSURLSessionDownloadTask *task;

@end
