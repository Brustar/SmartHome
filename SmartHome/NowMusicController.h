//
//  NowMusicController.h
//  SmartHome
//
//  Created by zhaona on 2017/4/14.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomViewController.h"

#define BLUETOOTH_MUSIC false

@interface NowMusicController : CustomViewController
@property (weak, nonatomic) IBOutlet UITableView *MusicTableView;
@property (weak, nonatomic) IBOutlet UIButton *loseBtn;//音量减小的按钮
@property (weak, nonatomic) IBOutlet UIButton *AddBtn;//音量增加的按钮
@property (weak, nonatomic) IBOutlet UIButton *powerBtn;//开关按钮
@property (nonatomic,weak) NSString *sceneid;
@property (nonatomic,weak) NSString *deviceid;
@property (nonatomic,assign) int roomID;
@property (strong, nonatomic) Scene *scene;
@property (nonatomic,assign) BOOL isAddDevice;
@property (nonatomic, assign) NSInteger playState;//播放状态： 0:停止 1:播放
@end
