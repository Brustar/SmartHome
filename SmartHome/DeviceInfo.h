//
//  IBeacon.h
//  SmartHome
//
//  Created by Brustar on 16/5/10.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceInfo : NSObject
{
    NSArray *beacons;
    float volume;
}

+ (id)defaultManager;
@end
