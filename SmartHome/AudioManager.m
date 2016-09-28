//
//  AudioManager.m
//  SmartHome
//
//  Created by Brustar on 16/5/6.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "AudioManager.h"

@implementation AudioManager

+ (instancetype)defaultManager {
    static AudioManager *sharedInstance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

-(NSMutableArray *)songs
{
    if (_songs == nil) {
        _songs=[NSMutableArray new];
    }
    return _songs;
}

-(NSArray *)allSongs
{
    MPMediaQuery *everything = [[MPMediaQuery alloc] init];
    NSArray *itemsFromGenericQuery = [everything items];
    for (MPMediaItem *song in itemsFromGenericQuery) {
        NSString *songTitle = [song valueForProperty: MPMediaItemPropertyTitle];
        NSLog (@"%@", songTitle);
        [self.songs addObject:songTitle];
    }
    return itemsFromGenericQuery;
}

-(void)initMusicAndPlay
{
    if ([self.songs count]==0) {
        MPMediaItemCollection *mediaItemCollection = [[MPMediaItemCollection alloc] initWithItems:[self allSongs]];
    
        _musicPlayer = [MPMusicPlayerController applicationMusicPlayer];
        [_musicPlayer setShuffleMode: MPMusicShuffleModeOff];
        [_musicPlayer setRepeatMode: MPMusicRepeatModeNone];
        [_musicPlayer setQueueWithItemCollection:mediaItemCollection];
        
        [_musicPlayer play];
    }
}

- (void)addSongsToMusicPlayer:(UINavigationController *)controller
{
    MPMediaPickerController *mpController = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeMusic];
    mpController.delegate = self;
    mpController.prompt = @"";
    mpController.allowsPickingMultipleItems = YES;
    
    [controller presentViewController:mpController animated:YES completion:nil];
}

- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection
{
    _musicPlayer = [MPMusicPlayerController applicationMusicPlayer];
    [_musicPlayer setShuffleMode: MPMusicShuffleModeOff];
    [_musicPlayer setRepeatMode: MPMusicRepeatModeNone];
    [_musicPlayer setQueueWithItemCollection:mediaItemCollection];
    [_musicPlayer play];
    [mediaPicker dismissViewControllerAnimated:YES completion:nil];
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker
{
    [mediaPicker dismissViewControllerAnimated:YES completion:nil];
}

@end
