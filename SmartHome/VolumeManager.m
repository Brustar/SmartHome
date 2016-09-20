//
//  VolumeManager.m
//  SmartHome
//
//  Created by Brustar on 16/5/10.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "VolumeManager.h"
#import <AudioToolbox/AudioSession.h>
#import "KEVolumeUtil.h"

@implementation VolumeManager

+ (instancetype)defaultManager {
    static VolumeManager *sharedInstance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

-(void) start:(DeviceInfo *)beacon
{
    AudioSessionInitialize(NULL, NULL, NULL, NULL);
    AudioSessionSetActive(true);
    AudioSessionAddPropertyListener(kAudioSessionProperty_CurrentHardwareOutputVolume ,
                                    volumeListenerCallback,
                                    (__bridge void *)(self)
                                    );
    self.ibeacon=beacon;
}

void volumeListenerCallback (void *inClientData,AudioSessionPropertyID inID,UInt32 inDataSize,const void *inData)
{
    const float *volumePointer = inData;
    float volume = *volumePointer;
    NSLog(@"volumeListenerCallback %f", volume);
    KEVolumeUtil *manager=[KEVolumeUtil shareInstance];
    NSLog(@"systemVolumeValue %f", [manager systemVolumeValue]);
    manager.willup = volume > [manager systemVolumeValue];
    [manager volumeValue];

    [((__bridge VolumeManager *)inClientData).ibeacon setValue:[NSString stringWithFormat:@"%f",volume] forKey:@"volume"];
}

@end
