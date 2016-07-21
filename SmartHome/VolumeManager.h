//
//  VolumeManager.h
//  SmartHome
//
//  Created by Brustar on 16/5/10.
//  Copyright © 2016年 Brustar. All rights reserved.
//

@interface VolumeManager : NSObject

+ (id)defaultManager;
-(void) start:(DeviceInfo *)beacon;

@property (strong, nonatomic) DeviceInfo *ibeacon;

@end
