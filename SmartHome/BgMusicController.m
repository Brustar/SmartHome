//
//  BgMusicController.m
//  SmartHome
//
//  Created by Brustar on 16/6/21.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "BgMusicController.h"
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
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewRightConstraint;
@property (weak, nonatomic) IBOutlet UIButton *lastBtn;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;

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
        self.viewRightConstraint.constant = self.viewLeftConstraint.constant;
    }
    if (BLUETOOTH_MUSIC) {
        AudioManager *audio=[AudioManager defaultManager];
        
        [audio.musicPlayer beginGeneratingPlaybackNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(musicPlayerStatedChanged:) name:MPMusicPlayerControllerPlaybackStateDidChangeNotification object:audio.musicPlayer];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nowPlayingItemIsChanged:) name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification object:audio.musicPlayer];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(volumeIsChanged:) name:MPMusicPlayerControllerVolumeDidChangeNotification object:audio.musicPlayer];
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //if ([[DeviceInfo defaultManager] editingScene]) {
    NSArray *bgmusicIDS = [SQLManager getDeviceByTypeName:@"背景音乐" andRoomID:self.roomID];
    if ([bgmusicIDS count]>0) {
        self.deviceid = bgmusicIDS[0];
    }
    //}
    
    float vol = BLUETOOTH_MUSIC ? 0 : [[AVAudioSession sharedInstance] outputVolume];
    self.volume.value=vol*100;
    self.voiceValue.text = [NSString stringWithFormat:@"%d%%",(int)self.volume.value];

    self.volume.continuous = NO;
    [self.volume addTarget:self action:@selector(save:) forControlEvents:UIControlEventValueChanged];
    _scene=[[SceneManager defaultManager] readSceneByID:[self.sceneid intValue]];
    
    if ([self.sceneid intValue]>0) {
        for(int i=0;i<[_scene.devices count];i++)
        {
            if ([[_scene.devices objectAtIndex:i] isKindOfClass:[BgMusic class]]) {
                self.volume.value=((BgMusic*)[_scene.devices objectAtIndex:i]).bgvolume;
                self.voiceValue.text = [NSString stringWithFormat:@"%d%%",(int)self.volume.value];
            }
        }
    }
    
    SocketManager *sock=[SocketManager defaultManager];
    sock.delegate=self;
    if (BLUETOOTH_MUSIC) {
        AudioManager *audio=[AudioManager defaultManager];
        [audio initMusicAndPlay];
    }
}

-(IBAction)save:(id)sender
{
    if ([sender isEqual:self.volume]) {
        NSData *data=[[DeviceInfo defaultManager] changeVolume:self.volume.value deviceID:self.deviceid];
        SocketManager *sock=[SocketManager defaultManager];
        [sock.socket writeData:data withTimeout:1 tag:1];
        self.voiceValue.text = [NSString stringWithFormat:@"%d%%",(int)self.volume.value];
        if (BLUETOOTH_MUSIC) {
            AudioManager *audio=[AudioManager defaultManager];
            [audio.musicPlayer setVolume:self.volume.value/100.0];
        }
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
    
    if (CFSwapInt16BigToHost(proto.masterID) != [[DeviceInfo defaultManager] masterID]) {
        return;
    }
    
    if (tag==0) {
        if (proto.action.state == PROTOCOL_VOLUME_UP || proto.action.state == PROTOCOL_VOLUME_DOWN || proto.action.state == PROTOCOL_MUTE)
        {
            self.volume.value=proto.action.RValue/100.0;
        }
    }
}

#pragma mark - MusicPlayer delegate
-(void)musicPlayerStatedChanged:(NSNotification *)paramNotification
{
    NSLog(@"Player State Changed");
    self.songTitle.text=[self titleOfNowPlaying];
    NSNumber * stateAsObject = [paramNotification.userInfo objectForKey:@"MPMusicPlayerControllerPlaybackStateKey"];
    NSInteger state = [stateAsObject integerValue];
    switch (state) {
        case MPMusicPlaybackStateStopped:
            
            break;
        case MPMusicPlaybackStatePlaying:
            break;
        case MPMusicPlaybackStatePaused:
            break;
        case MPMusicPlaybackStateInterrupted:
            break;
        case MPMusicPlaybackStateSeekingForward:
            break;
        case MPMusicPlaybackStateSeekingBackward:
            break;
            
        default:
            break;
    }
}

-(void)nowPlayingItemIsChanged:(NSNotification *)paramNotification
{
    NSLog(@"Playing Item is Changed");
    self.songTitle.text=[self titleOfNowPlaying];
}

-(void)volumeIsChanged:(NSNotification *)paramNotification
{
    NSLog(@"Volume Is Changed");
    AudioManager *audio=[AudioManager defaultManager];
    self.volume.value=audio.musicPlayer.volume*100;
    self.voiceValue.text = [NSString stringWithFormat:@"%d%%",(int)self.volume.value];
    [self save:nil];
}

-(NSString*)titleOfNowPlaying
{
    AudioManager *audio=[AudioManager defaultManager];
    if( audio.musicPlayer == nil ) {
        return @"music Player is nil.";
    }
    
    MPMediaItem* item = audio.musicPlayer.nowPlayingItem;
    if( item == nil ) {
        return @"playing.";
    }
    NSString* title = [item valueForKey:MPMediaItemPropertyTitle];
    return title;
}

- (IBAction)nextMusic:(id)sender {
    NSData *data=[[DeviceInfo defaultManager] next:self.deviceid];
    SocketManager *sock=[SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
    if (BLUETOOTH_MUSIC) {
        AudioManager *audio= [AudioManager defaultManager];
        
        if ([[audio musicPlayer] indexOfNowPlayingItem]<audio.songs.count-1) {
            [[audio musicPlayer] skipToNextItem];
        }
    }
}

- (IBAction)previousMusic:(id)sender {
    NSData *data=[[DeviceInfo defaultManager] previous:self.deviceid];
    SocketManager *sock=[SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
    if (BLUETOOTH_MUSIC) {
        AudioManager *audio= [AudioManager defaultManager];
        if ([[audio musicPlayer] indexOfNowPlayingItem]>0) {
            [[audio musicPlayer] skipToPreviousItem];
        }
    }
}

- (IBAction)pauseMusic:(id)sender {
    NSData *data=[[DeviceInfo defaultManager] pause:self.deviceid];
    SocketManager *sock=[SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
    if (BLUETOOTH_MUSIC) {
        AudioManager *audio= [AudioManager defaultManager];
        [[audio musicPlayer] pause];
    }
}

- (IBAction)playMusic:(id)sender {
    UIButton *btn = (UIButton *)sender;
    
    if (_playState == 0) {
        _playState = 1;
        [btn setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
        //发送播放指令
        NSData *data=[[DeviceInfo defaultManager] play:self.deviceid];
        SocketManager *sock=[SocketManager defaultManager];
        [sock.socket writeData:data withTimeout:1 tag:1];
        
        if (BLUETOOTH_MUSIC) {
            AudioManager *audio= [AudioManager defaultManager];
            [[audio musicPlayer] play];
        }
    }else if (_playState == 1) {
        _playState = 0;
       [btn setImage:[UIImage imageNamed:@"broadcast"] forState:UIControlStateNormal];
        //发送停止指令
        NSData *data=[[DeviceInfo defaultManager] pause:self.deviceid];
        SocketManager *sock=[SocketManager defaultManager];
        [sock.socket writeData:data withTimeout:1 tag:1];
        if (BLUETOOTH_MUSIC) {
            AudioManager *audio= [AudioManager defaultManager];
            [[audio musicPlayer] pause];
        }
    }
    
    
}

- (IBAction)addSongsToMusicPlayer:(id)sender
{
    //[[AudioManager defaultManager] addSongsToMusicPlayer:self.navigationController];
}

-(void)dealloc
{
    if (BLUETOOTH_MUSIC) {
        AudioManager *audio= [AudioManager defaultManager];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMusicPlayerControllerPlaybackStateDidChangeNotification object:audio.musicPlayer];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification object:audio.musicPlayer];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMusicPlayerControllerVolumeDidChangeNotification object:audio.musicPlayer];
    }
}

@end
