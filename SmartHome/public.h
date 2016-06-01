//
//  public.h
//  SmartHome
//
//  Created by Brustar on 16/5/6.
//  Copyright © 2016年 Brustar. All rights reserved.
//
#import "IOManager.h"
#import "AudioManager.h"
#import "IbeaconManager.h"
#import "VolumeManager.h"
#import "DownloadManager.h"
#import "Device.h"
#import "Scene.h"

#ifndef public_h
#define public_h

#if DEBUG
#define NSLog(FORMAT, ...) fprintf(stderr,"\nfunction:%s line:%d content:%s\n", __FUNCTION__, __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define NSLog(FORMAT, ...) nil
#endif


#endif /* public_h */
