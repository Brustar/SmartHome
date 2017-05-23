//
//  FamilyHomeViewController.m
//  SmartHome
//
//  Created by KobeBryant on 2017/4/9.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "FamilyHomeViewController.h"

@interface FamilyHomeViewController ()

@end

@implementation FamilyHomeViewController

- (void)setupNaviBar {
    [self setNaviBarTitle:[UD objectForKey:@"homename"]]; //设置标题
    
    NSString *music_icon = nil;
    NSInteger isPlaying = [[UD objectForKey:@"IsPlaying"] integerValue];
    if (isPlaying) {
        music_icon = @"music-red";
    }else {
        music_icon = @"music_white";
    }
    
    _naviRightBtn = [CustomNaviBarView createImgNaviBarBtnByImgNormal:music_icon imgHighlight:music_icon target:self action:@selector(rightBtnClicked:)];
    [self setNaviBarRightBtn:_naviRightBtn];
}

- (void)rightBtnClicked:(UIButton *)btn {
    UIStoryboard * HomeStoryBoard = [UIStoryboard storyboardWithName:@"Home" bundle:nil];
    if (_nowMusicController == nil) {
        _nowMusicController = [HomeStoryBoard instantiateViewControllerWithIdentifier:@"NowMusicController"];
        _nowMusicController.delegate = self;
        [self.view addSubview:_nowMusicController.view];
        [self.view bringSubviewToFront:_nowMusicController.view];
    }else {
        [_nowMusicController.view removeFromSuperview];
        _nowMusicController = nil;
    }
}

- (void)onBgButtonClicked:(UIButton *)sender {
    if (_nowMusicController) {
        [_nowMusicController.view removeFromSuperview];
        _nowMusicController = nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addNotifications];
    [self setupNaviBar];
    [self showNetStateView];
    self.lightIcon.layer.cornerRadius =  self.lightIcon.frame.size.width/2;
    self.lightIcon.layer.masksToBounds = YES;
    self.lightIcon.backgroundColor = RGB(243, 152, 0, 1);
    
    self.avIcon.layer.cornerRadius =  self.avIcon.frame.size.width/2;
    self.avIcon.layer.masksToBounds = YES;
    self.avIcon.backgroundColor = RGB(217, 55, 75, 1);
    
    self.airIcon.layer.cornerRadius =  self.airIcon.frame.size.width/2;
    self.airIcon.layer.masksToBounds = YES;
    self.airIcon.backgroundColor = RGB(0, 172, 151, 1);
    
    _roomArray = [NSMutableArray array];
    //开启网络状况监听器
    [self updateInterfaceWithReachability];
    
    [self fetchRoomDeviceStatus];//获取房间设备状态，温度，湿度, PM2.5
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    
}

- (void)fetchRoomDeviceStatus {
    NSString *url = [NSString stringWithFormat:@"%@Cloud/room_status_list.aspx",[IOManager httpAddr]];
    NSString *auothorToken = [UD objectForKey:@"AuthorToken"];
    
    if (auothorToken.length >0) {
        NSDictionary *dict = @{@"token":auothorToken,
                               @"optype":@(0)
                               };
        HttpManager *http=[HttpManager defaultManager];
        http.delegate = self;
        http.tag = 4;
        [http sendPost:url param:dict showProgressHUD:NO];
    }
}

//处理连接改变后的情况
- (void)updateInterfaceWithReachability
{
    __block FamilyHomeViewController  *blockSelf = self;
    
    _afNetworkReachabilityManager = [AFNetworkReachabilityManager sharedManager];
    
    [_afNetworkReachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        DeviceInfo *info = [DeviceInfo defaultManager];
        if(status == AFNetworkReachabilityStatusReachableViaWWAN) //手机自带网络
        {
            if (info.connectState==outDoor) {
                [blockSelf setNetState:netState_outDoor_4G];
                NSLog(@"外出模式-4g");
            }else if (info.connectState == atHome){
                [blockSelf setNetState:netState_atHome_4G];
                NSLog(@"在家模式-4G");
                
            }else if (info.connectState == offLine) {
                [blockSelf setNetState:netState_notConnect];
                NSLog(@"离线模式");
                
            }
            
        }
        else if(status == AFNetworkReachabilityStatusReachableViaWiFi) //WIFI
        {
            if (info.connectState == atHome) {
                [blockSelf setNetState:netState_atHome_WIFI];
                NSLog(@"在家模式-WIFI");
                
                
            }else if (info.connectState == outDoor){
                [blockSelf setNetState:netState_outDoor_WIFI];
                NSLog(@"外出模式-WIFI");
                
            }else if (info.connectState == offLine) {
                [blockSelf setNetState:netState_notConnect];
                NSLog(@"离线模式");
                
                
            }
        }else if(status == AFNetworkReachabilityStatusNotReachable){ //没有网络(断网)
            [blockSelf setNetState:netState_notConnect];
            NSLog(@"离线模式");
        }else if (status == AFNetworkReachabilityStatusUnknown) { //未知网络
            [blockSelf setNetState:netState_notConnect];
        }
    }];
    
    [_afNetworkReachabilityManager startMonitoring];//开启网络监视器；
    
}

- (void)addNotifications {
    [NC addObserver:self selector:@selector(netWorkDidChangedNotification:) name:@"NetWorkDidChangedNotification" object:nil];
    [NC addObserver:self selector:@selector(refreshRoomDeviceStatus:) name:@"refreshRoomDeviceStatusNotification" object:nil];
}

- (void)refreshRoomDeviceStatus:(NSNotification *)noti {
    [self fetchRoomDeviceStatus];//获取房间设备状态，温度，湿度, PM2.5
}

- (void)netWorkDidChangedNotification:(NSNotification *)noti {
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];//开启网络监视器；
}

- (void)removeNotifications {
    [NC removeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (_afNetworkReachabilityManager.reachableViaWiFi) {
        NSLog(@"WIFI: %d", _afNetworkReachabilityManager.reachableViaWiFi);
    }
    
    if (_afNetworkReachabilityManager.reachableViaWWAN) {
        NSLog(@"WWAN: %d", _afNetworkReachabilityManager.reachableViaWWAN);
    }
    
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (_nowMusicController) {
        [_nowMusicController.view removeFromSuperview];
        _nowMusicController = nil;
    }
}

#pragma  mark - UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
   
    return self.roomArray.count;
    
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FamilyHomeCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"familyHomePageCell" forIndexPath:indexPath];
    
    RoomStatus *roomInfo = self.roomArray[indexPath.row];
    
    [cell setRoomAndDeviceStatus:roomInfo];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UIStoryboard * storyBoard = [UIStoryboard storyboardWithName:@"Family" bundle:nil];
    FamilyHomeDetailViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"familyHomeDetailVC"];
    RoomStatus *roomInfo = self.roomArray[indexPath.row];
    vc.roomID = roomInfo.roomId;
    vc.roomName = roomInfo.roomName;
    [self.navigationController pushViewController:vc animated:YES];
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return CGSizeMake(iPadCollectionCellWidth, iPadCollectionCellWidth);
    }else {
        return CGSizeMake(CollectionCellWidth, CollectionCellWidth);
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return minSpace;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return maxSpace;
}

#pragma mark - Http callback
- (void)httpHandler:(id)responseObject tag:(int)tag
{
    if(tag == 4) {
        if ([responseObject[@"result"] intValue] == 0) {
            [_roomArray removeAllObjects];
            NSArray *roomStatusList = responseObject[@"room_status_list"];
            if ([roomStatusList isKindOfClass:[NSArray class]]) {
                for (NSDictionary *roomStatus in roomStatusList) {
                    if ([roomStatus isKindOfClass:[NSDictionary class]]) {
                        RoomStatus *roomStatusInfo = [[RoomStatus alloc] init];
                        roomStatusInfo.roomId = [roomStatus[@"roomid"] integerValue];
                        roomStatusInfo.roomName = roomStatus[@"roomname"];
                        roomStatusInfo.temperature = roomStatus[@"temperature"];
                        roomStatusInfo.humidity = roomStatus[@"humidity"];
                        roomStatusInfo.pm25 = roomStatus[@"pm"];
                        roomStatusInfo.lightStatus = [roomStatus[@"light"] integerValue];
                        roomStatusInfo.curtainStatus = [roomStatus[@"curtain"] integerValue];
                        roomStatusInfo.mediaStatus = [roomStatus[@"media"] integerValue];
                        roomStatusInfo.airconditionerStatus = [roomStatus[@"aircondition"] integerValue];
                        
                        if ([[UD objectForKey:@"HostID"] intValue] == 258) { //九号大院(要过滤掉没有温湿度的房间)
                            if (roomStatusInfo.roomId == 188  || roomStatusInfo.roomId == 190  ||roomStatusInfo.roomId == 191  ||roomStatusInfo.roomId == 193  ||roomStatusInfo.roomId == 196) {
                                [_roomArray addObject:roomStatusInfo];
                            }
                        }else {
                            [_roomArray addObject:roomStatusInfo];
                        }
                        
                    }
                }
            }
            
            [self.roomCollectionView reloadData];
        }
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [self removeNotifications];
}

@end
