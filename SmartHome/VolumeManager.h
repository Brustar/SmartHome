//
//  VolumeManager.h
//  SmartHome
//
//  Created by Brustar on 16/5/10.
//  Copyright © 2016年 Brustar. All rights reserved.
//

@interface VolumeManager : NSObject

@property (nonatomic, readwrite) float launchVolume;
@property (nonatomic, copy) dispatch_block_t upBlock;
@property (nonatomic, copy) dispatch_block_t downBlock;

+ (instancetype)defaultManager;
-(void) start:(UIView *)view;

@end
