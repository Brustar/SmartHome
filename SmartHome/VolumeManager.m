//
//  VolumeManager.m
//  SmartHome
//
//  Created by Brustar on 16/5/10.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "VolumeManager.h"
#import <AudioToolbox/AudioSession.h>
#import <MediaPlayer/MediaPlayer.h>

@implementation VolumeManager

+ (instancetype)defaultManager {
    static VolumeManager *sharedInstance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

-(void) start:(UIView *)view
{
    AudioSessionInitialize(NULL, NULL, NULL, NULL);
    AudioSessionSetActive(true);
    AudioSessionAddPropertyListener(kAudioSessionProperty_CurrentHardwareOutputVolume ,
                                    volumeListenerCallback,
                                    (__bridge void *)(self)
                                    );
    if (view) {
        self.launchVolume = [[MPMusicPlayerController applicationMusicPlayer] volume];
        CGRect frame = CGRectMake(0, -100, 10, 0);
        MPVolumeView *volumeView = [[MPVolumeView alloc] initWithFrame:frame];
        [volumeView sizeToFit];
        [view addSubview: volumeView];
    }
}

void volumeListenerCallback (void *inClientData,AudioSessionPropertyID inID,UInt32 inDataSize,const void *inData)
{
    const float *volumePointer = inData;
    float volume = *volumePointer;
    NSLog(@"volumeListenerCallback %f", volume);

    [[DeviceInfo defaultManager] setValue:[NSString stringWithFormat:@"%f",volume] forKey:@"volume"];
    
    if (volume > [(__bridge VolumeManager*)inClientData launchVolume])
    {
        [(__bridge VolumeManager*)inClientData volumeUp];
    }
    else if (volume < [(__bridge VolumeManager*)inClientData launchVolume])
    {
        [(__bridge VolumeManager*)inClientData volumeDown];
    }
}

-(void) volumeUp
{
    if (self.upBlock)
    {
        [[MPMusicPlayerController applicationMusicPlayer] setVolume:self.launchVolume];
        self.upBlock();
    }
}

-(void) volumeDown
{
    if (self.downBlock)
    {
        [[MPMusicPlayerController applicationMusicPlayer] setVolume:self.launchVolume];
        self.downBlock();
    }
}

@end
