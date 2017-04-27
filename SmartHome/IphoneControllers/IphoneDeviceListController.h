//
//  IphoneDeviceListController.h
//  SmartHome
//
//  Created by 逸云科技 on 16/9/19.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomViewController.h"
#import "NowMusicController.h"

typedef NS_ENUM(NSUInteger, deviceType) {
    
    light = 1,
    curtain = 7,
    netTV = 11,
    TVtype = 12,
    DVDtype = 13,
    bgmusic = 14,
    FM = 15,
    air = 31,
    doorclock = 40,
    projector = 16,
    screen = 17,
    amplifier = 18,
    camera = 45,
    plugin = 41
};

@interface IphoneDeviceListController : CustomViewController<NowMusicControllerDelegate>

@property (nonatomic,strong) Scene *scene;

@property (nonatomic, readonly) UIButton *naviRightBtn;
@property (nonatomic, readonly) UIButton *naviLeftBtn;
@property (nonatomic, strong) NowMusicController * nowMusicController;

@end
