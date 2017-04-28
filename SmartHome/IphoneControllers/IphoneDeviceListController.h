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

@interface IphoneDeviceListController : CustomViewController<NowMusicControllerDelegate>

@property (nonatomic,strong) Scene *scene;

@property (nonatomic, readonly) UIButton *naviRightBtn;
@property (nonatomic, readonly) UIButton *naviLeftBtn;
@property (nonatomic, strong) NowMusicController * nowMusicController;

@end
