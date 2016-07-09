//
//  TVChannel.h
//  SmartHome
//
//  Created by 逸云科技 on 16/6/13.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TVChannel : NSObject
@property (nonatomic,assign) NSInteger ID;
@property (nonatomic,strong)  NSString *channel_name;
@property (nonatomic,assign) NSInteger channel_id;
@property (nonatomic,strong) NSString *channel_pic;
@property (nonatomic,strong) NSString *parent;
@property (nonatomic,assign) BOOL isFavorite;

+(instancetype)getChannelFromChannelID:(NSInteger)channel_id;
+(NSMutableArray *)getAllChannelForFavoritedForType:(NSString *)type;
+(BOOL)deleteChannelForChannelID:(NSInteger)channel_id;
+(BOOL)upDateChannelForChannelID:(NSInteger)channel_id andNewChannel_Name:(NSString *)newName;

@end
