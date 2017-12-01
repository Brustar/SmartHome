//
//  DeviceSource.h
//  SmartHome
//
//  Created by KobeBryant on 2017/11/3.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceSource : NSObject

@property(nonatomic, assign) NSInteger deviceid;
@property(nonatomic, strong) NSString *sourceName;
@property(nonatomic, strong) NSString *channelID;

@end
