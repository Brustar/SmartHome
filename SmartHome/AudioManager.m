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

-(NSArray *)allSongs
{
    MPMediaQuery *everything = [[MPMediaQuery alloc] init];
    NSArray *itemsFromGenericQuery = [everything items];
    for (MPMediaItem *song in itemsFromGenericQuery) {
        NSString *songTitle = [song valueForProperty: MPMediaItemPropertyTitle];
        NSLog (@"%@", songTitle);
    }
    return itemsFromGenericQuery;
}

- (void)addSongsToMusicPlayer
{
    MPMediaPickerController *mpController = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeMusic];
    mpController.delegate = self;
    mpController.prompt = @"Add songs to play";
    mpController.allowsPickingMultipleItems = YES;
    [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentModalViewController:mpController animated:YES];
}

- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection
{
    MPMusicPlayerController* musicPlayer =
    [MPMusicPlayerController applicationMusicPlayer];
    [musicPlayer setShuffleMode: MPMusicShuffleModeOff];
    [musicPlayer setRepeatMode: MPMusicRepeatModeNone];
    [musicPlayer setQueueWithItemCollection:mediaItemCollection];
    [musicPlayer play];
    [[[[UIApplication sharedApplication] keyWindow] rootViewController] dismissModalViewControllerAnimated:YES];
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker
{
    [[[[UIApplication sharedApplication] keyWindow] rootViewController] dismissModalViewControllerAnimated:YES];
}

@end
