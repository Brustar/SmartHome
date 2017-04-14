//
//  NowMusicController.m
//  SmartHome
//
//  Created by zhaona on 2017/4/14.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "NowMusicController.h"
#import "SocketManager.h"
#import "SceneManager.h"
#import "BgMusic.h"
#import "PackManager.h"
#import "DeviceInfo.h"
#import "AudioManager.h"
#import "SQLManager.h"
#import <AVFoundation/AVFoundation.h>

@interface NowMusicController ()<UITableViewDataSource,UITableViewDataSource>
@property (nonatomic,strong) NSArray * bgmusicIDS;
@property (nonatomic,strong) NSMutableArray * bgmusicNameS;
@property (nonatomic,assign) int Volume;
@end

@implementation NowMusicController

-(NSArray *)dataArray
{
    if (!_bgmusicIDS) {
        _bgmusicIDS = [NSArray array];
    }

    return _bgmusicIDS;
}
-(void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:YES];
  
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _bgmusicNameS = [[NSMutableArray alloc] init];
    _bgmusicIDS = [SQLManager getDeviceByTypeName:@"影音"];
    for (int i = 0; i < _bgmusicIDS.count; i ++) {
         NSString * deviceName = [SQLManager deviceNameByDeviceID:[_bgmusicIDS[i] intValue]];
         [_bgmusicNameS addObject:deviceName];
    }
   
    if ([_bgmusicIDS count]>0) {
        self.deviceid = _bgmusicIDS[0];
    }
    SocketManager *sock=[SocketManager defaultManager];
    sock.delegate=self;
    if (BLUETOOTH_MUSIC) {
        AudioManager *audio=[AudioManager defaultManager];
        [audio initMusicAndPlay];
    }
    _Volume = 0;
 
    
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
//            self.volume.value=proto.action.RValue/100.0;
        }
    }
}

#pragma mark - MusicPlayer delegate
-(void)musicPlayerStatedChanged:(NSNotification *)paramNotification
{
    NSLog(@"Player State Changed");
//    self.songTitle.text=[self titleOfNowPlaying];
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

//减音量
- (IBAction)smallVolume:(id)sender {
    if (_Volume > 0) {
        _Volume -= 10;
        _loseBtn.titleLabel.text = [NSString stringWithFormat:@"%d",_Volume];
    }
    NSData *data=[[DeviceInfo defaultManager] changeVolume:[_loseBtn.titleLabel.text intValue] deviceID:self.deviceid];
    SocketManager *sock=[SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
//    self.voiceValue.text = [NSString stringWithFormat:@"%d%%",(int)self.volume.value];
    if (BLUETOOTH_MUSIC) {
        AudioManager *audio=[AudioManager defaultManager];
        [audio.musicPlayer setVolume:[_loseBtn.titleLabel.text intValue]/100.0];
    }
}
//加音量
- (IBAction)additionVolume:(id)sender {
    if (_Volume <= 100) {
        _Volume += 10;
        _loseBtn.titleLabel.text = [NSString stringWithFormat:@"%d",_Volume];
    }
    
    NSData *data=[[DeviceInfo defaultManager] changeVolume:[_loseBtn.titleLabel.text intValue] deviceID:self.deviceid];
    SocketManager *sock=[SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
    //    self.voiceValue.text = [NSString stringWithFormat:@"%d%%",(int)self.volume.value];
    if (BLUETOOTH_MUSIC) {
        AudioManager *audio=[AudioManager defaultManager];
        [audio.musicPlayer setVolume:[_loseBtn.titleLabel.text intValue]/100.0];
    }
}

//开关
- (IBAction)switchPower:(id)sender {
    
    UIButton *btn = (UIButton *)sender;
    
    if (_playState == 0) {
        _playState = 1;
        [btn setBackgroundImage:[UIImage imageNamed:@"close_red"] forState:UIControlStateNormal];
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
        [btn setBackgroundImage:[UIImage imageNamed:@"close_white"] forState:UIControlStateNormal];
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
-(void)dealloc
{
    if (BLUETOOTH_MUSIC) {
        AudioManager *audio= [AudioManager defaultManager];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMusicPlayerControllerPlaybackStateDidChangeNotification object:audio.musicPlayer];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification object:audio.musicPlayer];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMusicPlayerControllerVolumeDidChangeNotification object:audio.musicPlayer];
    }
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _bgmusicNameS.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(!cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        
    }
    cell.backgroundColor = [UIColor clearColor];
    [cell.textLabel setTextColor:[UIColor whiteColor]];
    cell.textLabel.text = _bgmusicNameS[indexPath.row];
    return cell;
}
- (IBAction)musicSwitchChanged:(id)sender {
    UISwitch *musicSwitch = (UISwitch *)sender;
    if (musicSwitch.on) {
        //开指令
        NSData *data=[[DeviceInfo defaultManager] open:self.deviceid];
        SocketManager *sock=[SocketManager defaultManager];
        [sock.socket writeData:data withTimeout:1 tag:1];
        
    }else {
        //关指令
        NSData *data=[[DeviceInfo defaultManager] close:self.deviceid];
        SocketManager *sock=[SocketManager defaultManager];
        [sock.socket writeData:data withTimeout:1 tag:1];
    }
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
