//
//  IbeaconManager.m
//  SmartHome
//
//  Created by Brustar on 16/5/9.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "IbeaconManager.h"

@implementation IbeaconManager

+ (id)defaultManager
{
    static IbeaconManager *sharedInstance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });


    return sharedInstance;
}

-(void) start:(DeviceInfo *)beacon
{
    self.beaconArr = [[NSArray alloc] init];
    self.locationmanager = [[CLLocationManager alloc] init];//初始化
    self.locationmanager.delegate = self;
    NSUUID *uuid=[[NSUUID alloc] initWithUUIDString:BEACONUUID];
    self.beacon = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:[uuid UUIDString]];//初始化监测的iBeacon信息
    [self.locationmanager requestAlwaysAuthorization];//设置location是一直允许
    
    self.ibeacon=beacon;
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    if (status == kCLAuthorizationStatusAuthorizedAlways) {
        [self.locationmanager startMonitoringForRegion:self.beacon];//开始MonitoringiBeacon
    }
}

//发现有iBeacon进入监测范围
-(void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region{
    [self.locationmanager startRangingBeaconsInRegion:self.beacon];//开始RegionBeacons
}

//找的iBeacon后扫描它的信息
- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region{
    //如果存在不是我们要监测的iBeacon那就停止扫描他
    if (![[region.proximityUUID UUIDString] isEqualToString:BEACONUUID]){
        [self.locationmanager stopMonitoringForRegion:region];
        [self.locationmanager stopRangingBeaconsInRegion:region];
    }
    //打印所有iBeacon的信息
    for (CLBeacon* beacon in beacons) {
        NSLog(@"rssi is :%d",beacon.rssi);
        NSLog(@"beacon.proximity %d",beacon.proximity);
    }

    [self.ibeacon setValue:beacons forKey:@"beacons"];
}

@end
