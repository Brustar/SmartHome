//
//  TV.h
//  SmartHome
//
//  Created by Brustar on 16/5/23.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "AVMedia.h"

@interface TV : AVMedia
//视频源id
@property (nonatomic) int HDMIID;
//频道id
@property (nonatomic) int channelID;

@end
