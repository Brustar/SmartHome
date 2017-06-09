//
//  PlaneGraphViewController.m
//  SmartHome
//
//  Created by KobeBryant on 2017/5/25.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "PlaneGraphViewController.h"

@interface PlaneGraphViewController ()

@end

@implementation PlaneGraphViewController

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
    
    self.floorScrollView.contentSize = CGSizeMake(self.view.bounds.size.width, 0);
    
    //self.floorScrollView.pagingEnabled = YES;
    self.floorScrollView.scrollEnabled = NO;
    self.floorScrollView.bounces = NO;
    //self.floorScrollView.showsHorizontalScrollIndicator = YES;
    //self.floorScrollView.delegate = self;
    
    self.roomStatusCollectionView.backgroundColor = [UIColor clearColor];
    
    _roomArray = [NSMutableArray array];
    //开启网络状况监听器
    [self updateInterfaceWithReachability];
    [self setupPlaneGraph];
    //[self fetchRoomDeviceStatus];//获取房间设备状态，温度，湿度, PM2.5
    
    [self performSelector:@selector(fetchRoomDeviceStatus) withObject:nil afterDelay:2];
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
}

#pragma mark - TouchImageDelegate
- (void)openRoom:(NSNumber *)roomId {
    //鉴权一下
    int roomAuth = [SQLManager getRoomAuthority:roomId.intValue];
    if (roomAuth == 1) {
        UIStoryboard * storyBoard = [UIStoryboard storyboardWithName:@"Family" bundle:nil];
        FamilyHomeDetailViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"familyHomeDetailVC"];
        vc.roomID = [roomId integerValue];
        //vc.roomName
        [self.navigationController pushViewController:vc animated:YES];
    }else {
        [MBProgressHUD showError:@"你无权限打开此房间"];
    }
}

- (void)setupPlaneGraph {
    self.planeGraph.viewFrom=PLANE_IMAGE;
    self.planeGraph.delegate = self;
    
    //先读缓存，没有缓存数据，再请求服务器获取
    [self getPlaneGraphConfiguration];
}

//获取平面图配置
- (void)getPlaneGraphConfiguration
{
    NSString *auothorToken = [UD objectForKey:@"AuthorToken"];
    
    if (auothorToken.length >0) {
    
    NSString *url = [NSString stringWithFormat:@"%@%@",[IOManager httpAddr], @"Cloud/scene_config_list.aspx"];
    
    NSDictionary *dic = @{
                          @"token":  auothorToken,
                          @"optype": @(1)
                          };
    
    HttpManager *http = [HttpManager defaultManager];
    http.delegate = self;
    http.tag = 1;
    [http sendPost:url param:dic];
   
    }
}

#pragma mark -

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
    __block PlaneGraphViewController  *blockSelf = self;
    
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
    return CGSizeMake(CollectionCell_W, CollectionCell_W);
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
    if (tag == 1) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            if ([responseObject[@"result"] integerValue] == 0) {
                NSDictionary *infoDict = responseObject[@"info"];
                if ([infoDict isKindOfClass:[NSDictionary class]]) {
                    NSString *bgImgUrl = infoDict[@"imgpath"];//设置平面背景
                    if (bgImgUrl.length >0) {
                        [self.planeGraph sd_setImageWithURL:[NSURL URLWithString:bgImgUrl] placeholderImage:[UIImage imageNamed:@"PlaneGraph"] options:SDWebImageRetryFailed];
                    }
                    NSString *plistURL = infoDict[@"plist_path"];
                    if (plistURL.length >0) {
                        //下载plist
                        [self downloadPlist:plistURL];
                    }
                }
            }
        }
    }
    
    else if(tag == 4) {
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
            
            [self.roomStatusCollectionView reloadData];//左侧房间信息圆盘
            
            [self getAllDevicesStatusIcon];//平面图房间设备状态icon
        }
    }
}

//下载场景plist文件到本地
-(void)downloadPlist:(NSString *)plistURL
{
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:plistURL]];
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        
        //下载进度
        NSLog(@"%@",downloadProgress);
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        //下载到哪个文件夹
        NSString *path = [[IOManager planeScenePath] stringByAppendingPathComponent:response.suggestedFilename];
        
        return [NSURL fileURLWithPath:path];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        NSLog(@"planeGraphPlistFile下载完了 %@",filePath);
        
        NSString *plistFilePath = [[filePath absoluteString] substringFromIndex:7];
        //保存到UD
        [UD setObject:plistFilePath forKey:@"Plane_Graph_PlistFile"];
        [UD synchronize];
        
        //获取所有房间的区域信息
        [self getAllRoomsRectWithPlistFilePath:plistFilePath];
        
    }];
    
    [task resume];
}

//根据plist文件获取全屋所有房间的区域信息
- (void)getAllRoomsRectWithPlistFilePath:(NSString *)plistFilePath {
    NSDictionary *plistDic = [NSDictionary dictionaryWithContentsOfFile:plistFilePath];
    NSLog(@"planeScenePlistFilePath: %@", plistFilePath);
    NSLog(@"planeScenePlistDict: %@", plistDic);
    
    //获取全屋设备
//    NSArray *deviceArray = [plistDic objectForKey:@"devices"];
//    if ([deviceArray isKindOfClass:[NSArray class]] && deviceArray.count >0) {
//        [self addLights:deviceArray];
//    }
    
    //获取所有房间
    NSArray *roomArray = [plistDic objectForKey:@"rooms"];
    if ([roomArray isKindOfClass:[NSArray class]] && roomArray.count >0) {
        [self.planeGraph addRoom:roomArray];
    }
}

- (void)getAllDevicesStatusIcon {
    NSString *plistFilePath = [UD objectForKey:@"Plane_Graph_PlistFile"];
    if (plistFilePath.length >0) {
        NSDictionary *plistDic = [NSDictionary dictionaryWithContentsOfFile:plistFilePath];
        NSArray *deviceIconPositionArray = [plistDic objectForKey:@"room_positions"];
        if ([deviceIconPositionArray isKindOfClass:[NSArray class]]) {
            
            for (NSDictionary *dict in deviceIconPositionArray) {
                
                //roomID
                NSNumber *roomID = [dict objectForKey:@"roomID"];
                
                for (RoomStatus *roomInfo in self.roomArray) {
                    if (roomInfo.roomId == [roomID integerValue]) {
                        NSString *iconRectStr = [dict objectForKey:@"rect"];
                        CGRect iconRect = CGRectFromString(iconRectStr);
                        
                        CGFloat temp_origin_x = iconRect.origin.x;
                        CGFloat iconWidth = 20.0f;
                        CGFloat iconHeight = 20.0f;
                        CGFloat gap = 6.0f;
                        
                        if (roomInfo.lightStatus == 1) {
                            UIButton *lightIcon = [[UIButton alloc] initWithFrame:CGRectMake(temp_origin_x, iconRect.origin.y, iconWidth, iconHeight)];
                            [lightIcon setBackgroundImage:[UIImage imageNamed:@"planeLightIcon"] forState:UIControlStateNormal];
                            lightIcon.tag = 777;
                            
                            UIView *lastIcon = [self.planeGraph viewWithTag:777];
                            [lastIcon removeFromSuperview];
                            
                            [self.planeGraph addSubview:lightIcon];
                            
                            temp_origin_x += (iconWidth + gap);
                        }else {
                            UIView *lastIcon = [self.planeGraph viewWithTag:777];
                            [lastIcon removeFromSuperview];
                        }
                        
                        if (roomInfo.airconditionerStatus == 1) {
                            UIButton *airIcon = [[UIButton alloc] initWithFrame:CGRectMake(temp_origin_x, iconRect.origin.y, iconWidth, iconHeight)];
                            
                            [airIcon setBackgroundImage:[UIImage imageNamed:@"planeAirIcon"] forState:UIControlStateNormal];
                            airIcon.tag = 888;
                            
                            UIView *lastIcon = [self.planeGraph viewWithTag:888];
                            [lastIcon removeFromSuperview];
                            
                            [self.planeGraph addSubview:airIcon];
                            
                            temp_origin_x += (iconWidth + gap);
                        }else {
                            UIView *lastIcon = [self.planeGraph viewWithTag:888];
                            [lastIcon removeFromSuperview];
                        }
                        
                        if (roomInfo.mediaStatus == 1) {
                            UIButton *mediaIcon = [[UIButton alloc] initWithFrame:CGRectMake(temp_origin_x, iconRect.origin.y, iconWidth, iconHeight)];
                            
                            [mediaIcon setBackgroundImage:[UIImage imageNamed:@"planeMediaIcon"] forState:UIControlStateNormal];
                            mediaIcon.tag = 999;
                            
                            
                            UIView *lastIcon = [self.planeGraph viewWithTag:999];
                            [lastIcon removeFromSuperview];
                            
                            [self.planeGraph addSubview:mediaIcon];
                            
                            temp_origin_x += (iconWidth + gap);
                        }else {
                            UIView *lastIcon = [self.planeGraph viewWithTag:999];
                            [lastIcon removeFromSuperview];
                        }
                        
                        break;
                    }
                }
                
            }
            
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
