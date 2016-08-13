//
//  TVChannel.h
//  SmartHome
//
//  Created by 逸云科技 on 16/6/13.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TVChannel : NSObject
//设备ID，设备编号，频道名字，频道ID，频道图片，频道父类，是否收藏
@property (nonatomic,assign) NSInteger eID;
@property (nonatomic,assign) NSInteger eqNumber;
@property (nonatomic,strong) NSString *channel_name;
@property (nonatomic,assign) NSInteger channel_id;
@property (nonatomic,strong) NSString *channel_pic;
@property (nonatomic,strong) NSString *parent;
@property (nonatomic,assign) int channelValue;
@property (nonatomic,assign) BOOL isFavorite;


+(instancetype)getChannelFromChannelID:(NSInteger)channel_id;
+(NSMutableArray *)getAllChannelForFavoritedForType:(NSString *)type;
+(BOOL)deleteChannelForChannelID:(NSInteger)channel_id;
+(BOOL)upDateChannelForChannelID:(NSInteger)channel_id andNewChannel_Name:(NSString *)newName;

@end
