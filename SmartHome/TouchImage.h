//
//  TouchImage.h
//  SmartHome
//
//  Created by Brustar on 16/5/25.
//  Copyright © 2016年 Brustar. All rights reserved.
//
#define REAL_IMAGE 1
#define PLANE_IMAGE 2

@protocol TouchImageDelegate;

@interface TouchImage : UIImageView

@property (nonatomic) int viewFrom;

@property (nonatomic) int count;

@property (nonatomic, assign) BOOL powerOn;//灯的开关状态

@property (nonatomic, assign) id<TouchImageDelegate>delegate;

@property (nonatomic, strong) NSMutableArray *roomArray;//房间数组

- (void)addRoom:(NSArray *)array;

@end

@protocol TouchImageDelegate <NSObject>

@optional
- (void)openDeviceWithDeviceID:(NSString *)deviceID;
- (void)closeDeviceWithDeviceID:(NSString *)deviceID;
- (void)openRoom:(NSNumber *)roomId;

@end
