//
//  IphoneSceneController.h
//  SmartHome
//
//  Created by 逸云科技 on 16/9/19.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomViewController.h"
#import "NowMusicController.h"
#import "AFNetworkReachabilityManager.h"

@interface IphoneSceneController : CustomViewController<NowMusicControllerDelegate>

@property (nonatomic,strong) NSString * shortcutName;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, readonly) UIButton *naviRightBtn;
@property (nonatomic, readonly) UIButton *naviLeftBtn;
@property (nonatomic, strong) NowMusicController * nowMusicController;
@property(nonatomic, strong) AFNetworkReachabilityManager *afNetworkReachabilityManager;
@end
