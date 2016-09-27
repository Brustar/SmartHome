//
//  AudioManager.h
//  SmartHome
//
//  Created by Brustar on 16/5/6.
//  Copyright © 2016年 Brustar. All rights reserved.
//
#import <MediaPlayer/MediaPlayer.h>

@interface AudioManager : NSObject<MPMediaPickerControllerDelegate>

@property(nonatomic,strong)MPMusicPlayerController* musicPlayer;
@property(nonatomic,strong) NSMutableArray* songs;

+ (instancetype)defaultManager;
- (void)initMusicAndPlay;
- (void)addSongsToMusicPlayer:(UIViewController *)controller;

@end
