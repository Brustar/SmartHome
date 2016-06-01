//
//  VolumeManager.h
//  SmartHome
//
//  Created by Brustar on 16/5/10.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IBeacon.h"

@interface VolumeManager : NSObject

+ (id)defaultManager;
-(void) start:(IBeacon *)beacon;

@property (strong, nonatomic) IBeacon *ibeacon;

@end
