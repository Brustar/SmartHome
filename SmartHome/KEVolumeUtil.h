//
//  KEVolumeUtil.h
//  SmartHome
//
//  Created by Brustar on 16/8/31.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#define Volume_Change_Notification @"Volume_Change_Notification"

@interface KEVolumeUtil : NSObject

@property (nonatomic,assign) CGFloat volumeValue;
@property (nonatomic,assign) CGFloat systemVolumeValue;
@property (nonatomic) bool willup;

+ (KEVolumeUtil *) shareInstance;

-(void)loadMPVolumeView;

- (void)registerVolumeChangeEvent;

- (void)unregisterVolumeChangeEvent;

-(CGFloat) systemVolumeValue;

@end
