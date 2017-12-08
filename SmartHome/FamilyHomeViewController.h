//
//  FamilyHomeViewController.h
//  SmartHome
//
//  Created by KobeBryant on 2017/4/9.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFNetworking.h"
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
#import "LoadMaskHelper.h"

#define  CollectionCellWidth  self.roomCollectionView.frame.size.width / 2.0 -20
#define  iPadCollectionCellWidth  self.roomCollectionView.frame.size.width / 3.0 -40
#define  minSpace 20
#define  maxSpace 40

@interface FamilyHomeViewController : CustomViewController<UICollectionViewDataSource,UICollectionViewDelegate, HttpDelegate, TcpRecvDelegate, NowMusicControllerDelegate, SingleMaskViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *roomCollectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *RoomCollectionViewTop;

@property (nonatomic, strong) NSMutableArray *roomArray;
@property(nonatomic, strong) AFNetworkReachabilityManager *afNetworkReachabilityManager;
@property (weak, nonatomic) IBOutlet UIImageView *lightIcon;
@property (weak, nonatomic) IBOutlet UIImageView *avIcon;
@property (weak, nonatomic) IBOutlet UIImageView *airIcon;
@property (nonatomic, readonly) UIButton *naviRightBtn;
@property (nonatomic, strong) NowMusicController * nowMusicController;
@property (nonatomic, strong) NSMutableArray *deviceArray;
@property (nonatomic, assign) NSInteger totalCmds;//指令总数
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, assign) NSInteger hostType;//主机类型：0，creston   1, C4

@end
