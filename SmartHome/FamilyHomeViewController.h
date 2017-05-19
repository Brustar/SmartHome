//
//  FamilyHomeViewController.h
//  SmartHome
//
//  Created by KobeBryant on 2017/4/9.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AFNetworking.h>
#import "HttpManager.h"
#import "MBProgressHUD+NJ.h"
#import "Scene.h"
#import "Room.h"
#import "RoomStatus.h"
#import "SQLManager.h"
#import "PackManager.h"
#import "SocketManager.h"
#import "SceneManager.h"
#import "IphoneLightController.h"
#import "IPhoneRoom.h"
#import "DeviceInfo.h"
//#import "ObjectFunction.h"

#import "AppDelegate.h"
#import "FamilyHomeCell.h"
#import "CustomViewController.h"
#import "FamilyHomeDetailViewController.h"
#import "NowMusicController.h"

#define  CollectionCellWidth self.roomCollectionView.frame.size.width / 2.0 -20
#define  minSpace 20
#define  maxSpace 40

@interface FamilyHomeViewController : CustomViewController<UICollectionViewDataSource,UICollectionViewDelegate,HttpDelegate, NowMusicControllerDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *roomCollectionView;
@property (nonatomic, strong) NSMutableArray *roomArray;
@property(nonatomic, strong) AFNetworkReachabilityManager *afNetworkReachabilityManager;
@property (weak, nonatomic) IBOutlet UIImageView *lightIcon;
@property (weak, nonatomic) IBOutlet UIImageView *avIcon;
@property (weak, nonatomic) IBOutlet UIImageView *airIcon;
@property (nonatomic, readonly) UIButton *naviRightBtn;
@property (nonatomic, strong) NowMusicController * nowMusicController;
@end
