//
//  IbeaconManager.h
//  SmartHome
//
//  Created by Brustar on 16/5/9.
//  Copyright © 2016年 Brustar. All rights reserved.
//
#import<CoreLocation/CoreLocation.h>

#define BEACONUUID @"FDA50693-A4E2-4FB1-AFCF-C6EB07647825"//iBeacon的uuid可以换成自己设备的uuid

@interface IbeaconManager : NSObject<CLLocationManagerDelegate>

@property (nonatomic, strong) NSArray *beaconArr;//存放扫描到的iBeacon

@property (strong, nonatomic) CLBeaconRegion *beacon;//被扫描的iBeacon

@property (strong, nonatomic) CLLocationManager * locationmanager;

@property (strong, nonatomic) DeviceInfo *ibeacon;

+ (id)defaultManager;
-(void) start:(DeviceInfo *)beacon;

@end
