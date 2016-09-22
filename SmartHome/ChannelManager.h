//
//  ChannelManager.h
//  SmartHome
//
//  Created by 逸云科技 on 16/8/16.
//  Copyright © 2016年 Brustar. All rights reserved.
//

@interface ChannelManager : NSObject

+(NSMutableArray *)getAllChannelForFavoritedForType:(NSString *)type deviceID:(int)deviceID;
+(BOOL)deleteChannelForChannelID:(NSInteger)channel_id;
+(BOOL)upDateChannelForChannelID:(NSInteger)channel_id andNewChannel_Name:(NSString *)newName;


@end
