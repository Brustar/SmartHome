//
//  BgMusicController.h
//  SmartHome
//
//  Created by Brustar on 16/6/21.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#define BLUETOOTH_MUSIC false

@interface BgMusicController : UIViewController

@property (nonatomic,weak) NSString *sceneid;
@property (nonatomic,weak) NSString *deviceid;
@property (nonatomic,assign) int roomID;
@property (strong, nonatomic) Scene *scene;
@property (nonatomic,assign) BOOL isAddDevice;
@property (nonatomic, assign) NSInteger playState;//播放状态： 0:停止 1:播放

@end
