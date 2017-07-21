//
//  IpadFirstViewController.h
//  SmartHome
//
//  Created by zhaona on 2017/5/22.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomViewController.h"
#import "PlaneGraphViewController.h"
#import "iPadMyViewController.h"
#import "AFNetworking.h"
#import "LoadMaskHelper.h"
#import "SocketManager.h"
#import "SceneManager.h"

@interface IpadFirstViewController : CustomViewController<NowMusicControllerDelegate, SingleMaskViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property(nonatomic, strong) AFNetworkReachabilityManager *afNetworkReachabilityManager;
@property (nonatomic, strong) NowMusicController * nowMusicController;
@property (nonatomic, strong) NSMutableArray *shortcutsArray;
@property (nonatomic,strong) Scene * info1;
@property (nonatomic,strong) Scene * info2;
@property (nonatomic,strong) Scene * info3;

@end
