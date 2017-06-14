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
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "UIViewController+Navigator.h"
#import "IphoneRoomView.h"
@interface BgMusicController ()<IphoneRoomViewDelegate>

@property (weak, nonatomic) IBOutlet UISlider *volume;
@property (weak, nonatomic) IBOutlet UILabel *voiceValue;
@property (weak, nonatomic) IBOutlet UILabel *songTitle;
@property (nonatomic,strong) NSArray *menus;
@property (weak, nonatomic) IBOutlet UIButton *lastBtn;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;
@property (weak, nonatomic) IBOutlet UIImageView *diskView;
@property (weak, nonatomic) IBOutlet UIImageView *pre;
@property (weak, nonatomic) IBOutlet UIImageView *next;
@property (weak, nonatomic) IBOutlet UISlider *voiceSlider;
@property (weak, nonatomic) IBOutlet UIStackView *menuContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *menuTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *voiceLeft;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *voiceRight;
@property (weak, nonatomic) IBOutlet UIImageView *ear;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;
@property (weak, nonatomic) IBOutlet UIButton *prevoius;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shuffleRight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shuffleTop;
@property (weak, nonatomic) IBOutlet UIButton *ipadPlay;

@end

@implementation BgMusicController


// an ivar for your class:
BOOL animating;

- (void) spinWithOptions: (UIViewAnimationOptions) options {
    // this spin completes 360 degrees every 2 seconds
    [UIView animateWithDuration: 1.0f
                          delay: 0.0f
                        options: options
                     animations: ^{
                         _diskView.transform = CGAffineTransformRotate(_diskView.transform, M_PI / 2);
                     }
                     completion: ^(BOOL finished) {
                         if (finished) {
                             if (animating) {
                                 // if flag still set, keep spinning with constant speed
                                 [self spinWithOptions: UIViewAnimationOptionCurveLinear];
                             } else if (options != UIViewAnimationOptionCurveEaseOut) {
                                 // one last spin, with deceleration
                                 [self spinWithOptions: UIViewAnimationOptionCurveEaseOut];
                             }
                         }
                     }];
}

- (void) startSpin {
    if (!animating) {
        animating = YES;
        [self spinWithOptions: UIViewAnimationOptionCurveEaseIn];
    }
}

- (void) stopSpin {
    // set the flag to stop spinning after one last 90 degree increment
    animating = NO;
}

-(void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:YES];

    if (BLUETOOTH_MUSIC) {
        AudioManager *audio=[AudioManager defaultManager];
        
        [audio.musicPlayer beginGeneratingPlaybackNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(musicPlayerStatedChanged:) name:MPMusicPlayerControllerPlaybackStateDidChangeNotification object:audio.musicPlayer];//播放时的操作（下一曲、上一曲、暂停）
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nowPlayingItemIsChanged:) name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification object:audio.musicPlayer];//正在播放的曲目
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(volumeIsChanged:) name:MPMusicPlayerControllerVolumeDidChangeNotification object:audio.musicPlayer];//调节音量的
    }
}

-(void) initSlider
{
    [self.voiceSlider setThumbImage:[UIImage imageNamed:@"lv_btn_adjust_normal"] forState:UIControlStateNormal];
    self.voiceSlider.maximumTrackTintColor = [UIColor colorWithRed:16/255.0 green:17/255.0 blue:21/255.0 alpha:1];
    self.voiceSlider.minimumTrackTintColor = [UIColor colorWithRed:253/255.0 green:254/255.0 blue:254/255.0 alpha:1];
}

-(void)setUpRoomScrollerView
{
    NSMutableArray *deviceNames = [NSMutableArray array];
    
    for (Device *device in self.menus) {
        NSString *deviceName = device.typeName;
        [deviceNames addObject:deviceName];
    }
    
    IphoneRoomView *menu = [[IphoneRoomView alloc] initWithFrame:CGRectMake(0,0, [UIScreen mainScreen].bounds.size.width
                                                                            , 40)];
    
    menu.dataArray = deviceNames;
    menu.delegate = self;
    
    [menu setSelectButton:0];
    [self.menuContainer addSubview:menu];
}

- (void)iphoneRoomView:(UIView *)view didSelectButton:(int)index {
    Device *device = self.menus[index];
    [self.navigationController pushViewController:[DeviceInfo calcController:device.hTypeId] animated:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if(self.roomID == 0) self.roomID = (int)[DeviceInfo defaultManager].roomID;
    NSString *roomName = [SQLManager getRoomNameByRoomID:self.roomID];
    [self setNaviBarTitle:[NSString stringWithFormat:@"%@ - 背景音乐",roomName]];
    [self initSlider];
    self.menus = [SQLManager mediaDeviceNamesByRoom:self.roomID];
    if (self.menus.count<6) {
        [self initMenuContainer:self.menuContainer andArray:self.menus andID:self.deviceid];
    }else{
        [self setUpRoomScrollerView];
    }
    [self naviToDevice];
    self.deviceid = [SQLManager singleDeviceWithCatalogID:bgmusic byRoom:self.roomID];
    
    float vol = BLUETOOTH_MUSIC ? 0 : [[AVAudioSession sharedInstance] outputVolume];
    self.volume.value=vol*100;
    self.voiceValue.text = [NSString stringWithFormat:@"%d%%",(int)self.volume.value];

    self.volume.continuous = NO;
    [self.volume addTarget:self action:@selector(changeVolume) forControlEvents:UIControlEventValueChanged];
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
    
    [self.lastBtn setBackgroundImage:[UIImage imageNamed:@"control_button_pressed"] forState:UIControlStateSelected];
    [self.ipadPlay setImage:[UIImage imageNamed:@"TV_on"] forState:UIControlStateSelected];
    //查询设备状态
    NSData *data = [[DeviceInfo defaultManager] query:self.deviceid];
    [sock.socket writeData:data withTimeout:1 tag:1];
    if (ON_IPAD) {
        self.menuTop.constant = 0;
        self.voiceLeft.constant = self.voiceRight.constant = 100;
        self.shuffleTop.constant = 40;
        self.shuffleRight.constant = 600;
        self.ear.hidden = self.btnNext.hidden = self.prevoius.hidden = self.ipadPlay.hidden = NO;
    }
}

-(void)changeVolume
{
    NSData *data=[[DeviceInfo defaultManager] changeVolume:self.volume.value*100 deviceID:self.deviceid];
    SocketManager *sock=[SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
}

-(IBAction)save:(id)sender
{
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
    
    if (proto.cmd==0x01) {
        NSString *devID=[SQLManager getDeviceIDByENumber:CFSwapInt16BigToHost(proto.deviceID)];
        if ([devID intValue]==[self.deviceid intValue]) {
            if (proto.action.state == PROTOCOL_VOLUME) {
                self.volume.value=proto.action.RValue/100.0;
            }
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
    //[self save:nil];
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

- (IBAction)toogle:(id)sender {
    UIButton *btn = (UIButton *)sender;
    NSData *data;
    
    btn.selected = !btn.selected;
    if (btn.selected) {
        data = [[DeviceInfo defaultManager] open:self.deviceid];
    }else{
        data = [[DeviceInfo defaultManager] close:self.deviceid];
    }
    
    SocketManager *sock=[SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
}

- (IBAction)repeat:(id)sender {
    NSData *data=[[DeviceInfo defaultManager] repeat:self.deviceid];
    SocketManager *sock=[SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
}

- (IBAction)shuffle:(id)sender {
    NSData *data=[[DeviceInfo defaultManager] shuffle:self.deviceid];
    SocketManager *sock=[SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
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
    [btn setSelected:!btn.isSelected];
    if (btn.isSelected) {
        [btn setImage:[UIImage imageNamed:@"DVD_pause"] forState:UIControlStateNormal];
        //发送播放指令
        NSData *data=[[DeviceInfo defaultManager] play:self.deviceid];
        SocketManager *sock=[SocketManager defaultManager];
        [sock.socket writeData:data withTimeout:1 tag:1];
        
        if (BLUETOOTH_MUSIC) {
            AudioManager *audio= [AudioManager defaultManager];
            [[audio musicPlayer] play];
        }
        [self startSpin];
    }else{
       [btn setImage:[UIImage imageNamed:@"DVD_play"] forState:UIControlStateNormal];
        //发送停止指令
        NSData *data=[[DeviceInfo defaultManager] pause:self.deviceid];
        SocketManager *sock=[SocketManager defaultManager];
        [sock.socket writeData:data withTimeout:1 tag:1];
        if (BLUETOOTH_MUSIC) {
            AudioManager *audio= [AudioManager defaultManager];
            [[audio musicPlayer] pause];
        }
        [self stopSpin];
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
