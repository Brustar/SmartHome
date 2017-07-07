//
//  PlaneGraphViewController.h
//  SmartHome
//
//  Created by KobeBryant on 2017/5/25.
//  Copyright © 2017年 Brustar. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <AFNetworking.h>
#import "AFHTTPSessionManager.h"
#import "HttpManager.h"
#import "MBProgressHUD+NJ.h"
#import "Scene.h"
#import "Room.h"
#import "RoomStatus.h"
#import "SQLManager.h"
#import "PackManager.h"
#import "SocketManager.h"
#import "SceneManager.h"
#import "IPhoneRoom.h"
#import "DeviceInfo.h"
#import "AppDelegate.h"
#import "FamilyHomeCell.h"
#import "CustomViewController.h"
#import "FamilyHomeDetailViewController.h"
#import "NowMusicController.h"
#import "TouchImage.h"
#import "UIImageView+WebCache.h"
#import "LoadMaskHelper.h"

#define  CollectionCell_W  self.roomStatusCollectionView.frame.size.width -40
#define  iPadCollectionCellW  self.roomStatusCollectionView.frame.size.width / 3.0 -40
#define  minSpace 20
#define  maxSpace 40

@interface PlaneGraphViewController : CustomViewController<UICollectionViewDelegate, UICollectionViewDataSource,HttpDelegate, NowMusicControllerDelegate, TouchImageDelegate, SingleMaskViewDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *roomStatusCollectionView;
@property (nonatomic, strong) NSMutableArray *roomArray;
@property(nonatomic, strong) AFNetworkReachabilityManager *afNetworkReachabilityManager;
@property (weak, nonatomic) IBOutlet UIImageView *lightIcon;
@property (weak, nonatomic) IBOutlet UIImageView *avIcon;
@property (weak, nonatomic) IBOutlet UIImageView *airIcon;
@property (nonatomic, readonly) UIButton *naviRightBtn;
@property (nonatomic, strong) NowMusicController * nowMusicController;
@property (weak, nonatomic) IBOutlet UIScrollView *floorScrollView;
@property (weak, nonatomic) IBOutlet TouchImage *planeGraph;
@property (nonatomic,strong) BaseTabBarController *baseTabbarController;

@end
