//
//  BgMusicController.m
//  SmartHome
//
//  Created by Brustar on 16/6/21.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "BgMusicController.h"
#import "VolumeManager.h"
#import "SocketManager.h"
#import "SceneManager.h"
#import "BgMusic.h"
#import "PackManager.h"
#import "DeviceInfo.h"
#import "AudioManager.h"

#import "SQLManager.h"

#import <AVFoundation/AVFoundation.h>


@interface BgMusicController ()
@property (weak, nonatomic) IBOutlet UISlider *volume;
@property (weak, nonatomic) IBOutlet UILabel *voiceValue;
@property (weak, nonatomic) IBOutlet UILabel *songTitle;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *voiceWeakLeftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *voiceStrongRightConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewLeftConstraint;

@end

@implementation BgMusicController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        self.voiceStrongRightConstraint.constant = [[UIScreen mainScreen] bounds].size.width * 0.05;
        self.voiceWeakLeftConstraint.constant = self.voiceStrongRightConstraint.constant;
        self.viewLeftConstraint.constant = 20;
    }
    
    AudioManager *audio=[AudioManager defaultManager];
    [audio initMusicAndPlay];
    self.songTitle.text=[audio.songs objectAtIndex:[audio.musicPlayer indexOfNowPlayingItem]];
}

#pragma mark - 通知
/**
 *  添加通知
 */
-(void)addNotification{
    AudioManager *audio=[AudioManager defaultManager];
    NSNotificationCenter *notificationCenter=[NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(playbackStateChange:) name:MPMusicPlayerControllerPlaybackStateDidChangeNotification object:audio.musicPlayer];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([[DeviceInfo defaultManager] editingScene]) {
        NSArray *bgmusicIDS = [SQLManager getDeviceByTypeName:@"背景音乐" andRoomID:self.roomID];
        self.deviceid = bgmusicIDS[0];
    }
    
    float vol = [[AVAudioSession sharedInstance] outputVolume];
    self.volume.value=vol*100;
    self.voiceValue.text = [NSString stringWithFormat:@"%d%%",(int)self.volume.value];

    self.volume.continuous = NO;
    [self.volume addTarget:self action:@selector(save:) forControlEvents:UIControlEventValueChanged];
    
    if ([self.sceneid intValue]>0) {
        
        _scene=[[SceneManager defaultManager] readSceneByID:[self.sceneid intValue]];
        for(int i=0;i<[_scene.devices count];i++)
        {
            if ([[_scene.devices objectAtIndex:i] isKindOfClass:[BgMusic class]]) {
                self.volume.value=((BgMusic*)[_scene.devices objectAtIndex:i]).bgvolume/100.0;
            }
        }
    }
    
    SocketManager *sock=[SocketManager defaultManager];
    sock.delegate=self;
    
    DeviceInfo *info = [DeviceInfo defaultManager];
    [info addObserver:self forKeyPath:@"volume" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
    VolumeManager *volume=[VolumeManager defaultManager];
    [volume start];
    
    AudioManager *audio=[AudioManager defaultManager];
    [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:YES block:^(NSTimer *timer){
        self.songTitle.text=[audio.songs objectAtIndex:[audio.musicPlayer indexOfNowPlayingItem]];
    }];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"volume"])
    {
        DeviceInfo *info = [DeviceInfo defaultManager];
        self.volume.value=[[info valueForKey:@"volume"] floatValue]*100;
        /*
        KEVolumeUtil *volumeManager=[KEVolumeUtil shareInstance];
        NSData *data=nil;
        if (volumeManager.willup) {
            data = [[DeviceInfo defaultManager] volumeUp:self.deviceid];
        }else{
            data = [[DeviceInfo defaultManager] volumeDown:self.deviceid];
        }
        SocketManager *sock=[SocketManager defaultManager];
        [sock.socket writeData:data withTimeout:1 tag:1];
        */
        self.voiceValue.text = [NSString stringWithFormat:@"%d%%",(int)self.volume.value];
        [self save:nil];
    }
}

-(IBAction)save:(id)sender
{
    if ([sender isEqual:self.volume]) {
        NSData *data=[[DeviceInfo defaultManager] changeVolume:self.volume.value deviceID:self.deviceid];
        SocketManager *sock=[SocketManager defaultManager];
        [sock.socket writeData:data withTimeout:1 tag:1];
        self.voiceValue.text = [NSString stringWithFormat:@"%d%%",(int)self.volume.value];
        AudioManager *audio=[AudioManager defaultManager];
        [audio.musicPlayer setVolume:self.volume.value/100.0];
    }
    BgMusic *device=[[BgMusic alloc] init];
    [device setDeviceID:[self.deviceid intValue]];
    [device setBgvolume:self.volume.value];
    
    [_scene setSceneID:[self.sceneid intValue]];
    [_scene setRoomID:self.roomID];
    [_scene setMasterID:[[DeviceInfo defaultManager] masterID]];
    [_scene setReadonly:NO];
    
    NSArray *devices=[[SceneManager defaultManager] addDevice2Scene:_scene withDeivce:device withId:device.deviceID];
    [_scene setDevices:devices];
    
    [[SceneManager defaultManager] addScene:_scene withName:nil withImage:[UIImage imageNamed:@""]];
}

#pragma mark - TCP recv delegate
-(void)recv:(NSData *)data withTag:(long)tag
{
    Proto proto=protocolFromData(data);
    
    if (proto.masterID != [[DeviceInfo defaultManager] masterID]) {
        return;
    }
    
    if (tag==0) {
        if (proto.action.state == PROTOCOL_VOLUME_UP || proto.action.state == PROTOCOL_VOLUME_DOWN || proto.action.state == PROTOCOL_MUTE) {
            self.volume.value=proto.action.RValue/100.0;
        }
    }
}

- (IBAction)nextMusic:(id)sender {
    NSData *data=[[DeviceInfo defaultManager] next:self.deviceid];
    SocketManager *sock=[SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
    
    AudioManager *audio= [AudioManager defaultManager];
    
    if ([[audio musicPlayer] indexOfNowPlayingItem]<audio.songs.count-1) {
        [[audio musicPlayer] skipToNextItem];
        self.songTitle.text=[audio.songs objectAtIndex:[audio.musicPlayer indexOfNowPlayingItem]];
    }
}

- (IBAction)previousMusic:(id)sender {
    NSData *data=[[DeviceInfo defaultManager] previous:self.deviceid];
    SocketManager *sock=[SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
    
    AudioManager *audio= [AudioManager defaultManager];
    if ([[audio musicPlayer] indexOfNowPlayingItem]>0) {
        [[audio musicPlayer] skipToPreviousItem];
        self.songTitle.text=[audio.songs objectAtIndex:[audio.musicPlayer indexOfNowPlayingItem]];
    }
}

- (IBAction)pauseMusic:(id)sender {
    NSData *data=[[DeviceInfo defaultManager] pause:self.deviceid];
    SocketManager *sock=[SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
    
    [[[AudioManager defaultManager] musicPlayer] pause];
}

- (IBAction)playMusic:(id)sender {
    NSData *data=[[DeviceInfo defaultManager] play:self.deviceid];
    SocketManager *sock=[SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
    
    [[[AudioManager defaultManager] musicPlayer] play];
}

- (IBAction)addSongsToMusicPlayer:(id)sender
{
    [[AudioManager defaultManager] addSongsToMusicPlayer:self.navigationController];
}

-(void)dealloc
{
    DeviceInfo *info = [DeviceInfo defaultManager];
    [info removeObserver:self forKeyPath:@"volume" context:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
