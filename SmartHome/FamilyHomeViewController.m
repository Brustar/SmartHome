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
        music_icon = @"Ipad-NowMusic-red";
    }else {
        music_icon = @"Ipad-NowMusic";
    }
    
    _naviRightBtn = [CustomNaviBarView createImgNaviBarBtnByImgNormal:music_icon imgHighlight:music_icon target:self action:@selector(rightBtnClicked:)];
    if (isPlaying) {
        UIImageView * imageView = _naviRightBtn.imageView ;
        
        imageView.animationImages = [NSArray arrayWithObjects:
                                     [UIImage imageNamed:@"Ipad-NowMusic-red2"],
                                     [UIImage imageNamed:@"Ipad-NowMusic-red3"],
                                     [UIImage imageNamed:@"Ipad-NowMusic-red4"],
                                     [UIImage imageNamed:@"Ipad-NowMusic-red5"],
                                     [UIImage imageNamed:@"Ipad-NowMusic-red6"],
                                     [UIImage imageNamed:@"Ipad-NowMusic-red7"],
                                     [UIImage imageNamed:@"Ipad-NowMusic-red8"],
                                     [UIImage imageNamed:@"Ipad-NowMusic-red9"],
                                     [UIImage imageNamed:@"Ipad-NowMusic-red10"],
                                     [UIImage imageNamed:@"Ipad-NowMusic-red11"],
                                     [UIImage imageNamed:@"Ipad-NowMusic-red12"],
                                     [UIImage imageNamed:@"Ipad-NowMusic-red13"],
                                     [UIImage imageNamed:@"Ipad-NowMusic-red14"],
                                     [UIImage imageNamed:@"Ipad-NowMusic-red15"],
                                     [UIImage imageNamed:@"Ipad-NowMusic-red16"],
                                     [UIImage imageNamed:@"Ipad-NowMusic-red17"],
                                     [UIImage imageNamed:@"Ipad-NowMusic-red18"],
                                     [UIImage imageNamed:@"Ipad-NowMusic-red19"],
                                     
                                     nil];
        
        //设置动画总时间
        imageView.animationDuration = 2.0;
        //设置重复次数，0表示无限
        imageView.animationRepeatCount = 0;
        //开始动画
        if (! imageView.isAnimating) {
            [imageView startAnimating];
        }
    }
    [self setNaviBarRightBtn:_naviRightBtn];
}

- (void)rightBtnClicked:(UIButton *)btn {
    
    NSInteger isPlaying = [[UD objectForKey:@"IsPlaying"] integerValue];
    if (isPlaying == 0) {
        [MBProgressHUD showError:@"没有正在播放的设备"];
        return;
    }
    
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
    
    //获取房间状态
    [self getRoomStateInfoByTcp];
    
    //开启网络状况监听器
    [self updateInterfaceWithReachability];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    
}

- (void)getRoomStateInfoByTcp {
    _deviceArray = [NSMutableArray array];
    _roomArray = [NSMutableArray array];
   [_roomArray addObjectsFromArray:[SQLManager getAllRoomsInfoWithoutIsAll]];
    
    //TCP 获取房间状态
    SocketManager *sock = [SocketManager defaultManager];
    sock.delegate = self;
    NSData *data = [[DeviceInfo defaultManager] getRoomStateData];
    [sock.socket writeData:data withTimeout:1 tag:100];
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
    [self getRoomStateInfoByTcp];//获取房间设备状态，温度，湿度, PM2.5
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [LoadMaskHelper showMaskWithType:FamilyHome onView:self.tabBarController.view delay:0.5 delegate:self];
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
    
    Room *roomInfo = self.roomArray[indexPath.row];
    
    [cell setRoomAndDeviceStatus:roomInfo];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UIStoryboard * storyBoard = [UIStoryboard storyboardWithName:@"Family" bundle:nil];
    FamilyHomeDetailViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"familyHomeDetailVC"];
    Room *roomInfo = self.roomArray[indexPath.row];
    vc.roomID = roomInfo.rId;
    vc.roomName = roomInfo.rName;
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

- (void)getFamilyRoomStatusFromPlist {
    NSString *familyRoomStatusPath = [[IOManager familyRoomStatusPath] stringByAppendingPathComponent:@"FamilyRoomStatusList.plist"];
    NSDictionary *dictionary = [[NSDictionary alloc] initWithContentsOfFile:familyRoomStatusPath];
    if (dictionary) {
        NSArray *roomStatusList = dictionary[@"room_status_list"];
        if (roomStatusList && [roomStatusList isKindOfClass:[NSArray class]]) {
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
                
                //保存至plist(缓存)
                NSString *familyRoomStatusPath = [[IOManager familyRoomStatusPath] stringByAppendingPathComponent:@"FamilyRoomStatusList.plist"];
                [responseObject writeToFile:familyRoomStatusPath atomically:YES];
            }
            
            [self.roomCollectionView reloadData];
        }
    }
}

#pragma mark - TCP recv delegate
-(void)recv:(NSData *)data withTag:(long)tag
{
        Proto proto=protocolFromData(data);
        if (CFSwapInt16BigToHost(proto.masterID) != [[DeviceInfo defaultManager] masterID]) {
            return;
        }
        //同步设备状态
        if(proto.cmd == 0x01) {
            
            NSString *devID=[SQLManager getDeviceIDByENumber:CFSwapInt16BigToHost(proto.deviceID)];
            Device *device = [SQLManager getDeviceWithDeviceID:devID.intValue];
            
            if (device) {
                device.actionState = proto.action.state;
                
                if (proto.action.state==0x6A) { //温度
                    device.currTemp  = proto.action.RValue;
                    
                }
                if (proto.action.state==0x8A) { // 湿度
                    device.humidity = proto.action.RValue;
                }
                if (proto.action.state==0x7F) { // PM2.5
                    device.pm25 = proto.action.RValue;
                }
                
                if (proto.action.state == PROTOCOL_OFF || proto.action.state == PROTOCOL_ON) { //开关
                    device.power = proto.action.state;
                }
                
                [_deviceArray addObject:device];
            }
            
        }else if (proto.cmd == 0x06) { //  结束标志
            // 处理接收到的数据
            [self handleData];
            [self.roomCollectionView reloadData];
        }
    
}

- (void)handleData {
    [_roomArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        Room *room = (Room *)obj;
        [_deviceArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
          
            Device *device = (Device *)obj;
            if (device.rID == room.rId) {
                
                if (device.actionState == 0x6A) {   //温度
                    room.tempture = device.currTemp;
                }else if (device.actionState == 0x8A) {   // 湿度
                    room.humidity = device.humidity;
                }else if (device.actionState == 0x7F) {   //PM2.5
                    room.pm25 = device.pm25;
                }else if (device.actionState == PROTOCOL_OFF) {  // 关
                    
                }else if (device.actionState == PROTOCOL_ON) {   // 开
                    if (device.subTypeId == 1) {   //灯光
                        room.lightStatus = 1;
                    }else if(device.subTypeId == 2) {   //空调
                        room.airStatus = 1;
                    }else if (device.subTypeId == 3) {    //影音
                        room.avStatus = 1;
                    }
                }
                
                
            }
            
        }];
    
    }];
}

#pragma mark - SingleMaskViewDelegate
- (void)onNextButtonClicked:(UIButton *)btn pageType:(PageTye)pageType {
    UIStoryboard * storyBoard = [UIStoryboard storyboardWithName:@"Family" bundle:nil];
    FamilyHomeDetailViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"familyHomeDetailVC"];
    if (self.roomArray.count >1) {
        Room *roomInfo = self.roomArray[1];
        vc.roomID = roomInfo.rId;
        vc.roomName = roomInfo.rName;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)onSkipButtonClicked:(UIButton *)btn pageType:(PageTye)pageType {
    [UD setObject:@"haveShownMask" forKey:ShowMaskViewFamilyHomeDetail];
    [UD synchronize];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onTransparentBtnClicked:(UIButton *)btn {
    UIStoryboard * storyBoard = [UIStoryboard storyboardWithName:@"Family" bundle:nil];
    FamilyHomeDetailViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"familyHomeDetailVC"];
    if (self.roomArray.count >1) {
        Room *roomInfo = self.roomArray[1];
        vc.roomID = roomInfo.rId;
        vc.roomName = roomInfo.rName;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark -
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [self removeNotifications];
}

@end
