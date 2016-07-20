//
//  Globals.m
//  SCWaveAnimation
//
//  Created by Marton Fodor on 2/2/11.
//  Copyright 2011 The Subjective-C. No rights reserved.
//

#import "Globals.h"
//#import "SynthesizeSingleton.h"

@implementation Globals
@synthesize animationDuration;
@synthesize numberOfWaves;
@synthesize spawnInterval;
@synthesize spawnSize;
@synthesize scaleFactor;
@synthesize shadowRadius;

+ (Globals*) sharedGlobals
{
    static Globals *sharedInstance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}
@end
