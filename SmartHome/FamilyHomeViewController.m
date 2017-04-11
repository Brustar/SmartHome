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
    [self setNaviBarTitle:@"家庭名称"]; //设置标题
    //_naviLeftBtn = [CustomNaviBarView createImgNaviBarBtnByImgNormal:@"clound_white" imgHighlight:@"clound_white" target:self action:@selector(leftBtnClicked:)];
    _naviRightBtn = [CustomNaviBarView createImgNaviBarBtnByImgNormal:@"music_white" imgHighlight:@"music_white" target:self action:@selector(rightBtnClicked:)];
    [self setNaviBarRightBtn:_naviRightBtn];
}

- (void)rightBtnClicked:(UIButton *)btn {
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNaviBar];
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
    
    [self fetchRoomDeviceStatus];//获取房间设备状态，温度，湿度
    
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
        [http sendPost:url param:dict];
    }
}

//处理连接改变后的情况
- (void)updateInterfaceWithReachability
{
    /*_afNetworkReachabilityManager = [AFNetworkReachabilityManager sharedManager];
    
    [_afNetworkReachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        DeviceInfo *info = [DeviceInfo defaultManager];
        if(status == AFNetworkReachabilityStatusReachableViaWWAN) //手机自带网络
        {
            if (info.connectState==outDoor) {
                NSLog(@"外出模式");
                [self.netBarBtnItem setImage:[UIImage imageNamed:@"4g"]];
            }
            if (info.connectState==offLine) {
                NSLog(@"离线模式");
                [self.netBarBtnItem setImage:[UIImage imageNamed:@"4g"]];
            }
        }
        else if(status == AFNetworkReachabilityStatusReachableViaWiFi) //WIFI
        {
            if (info.connectState==atHome) {
                NSLog(@"在家模式");
                [self.netBarBtnItem setImage:[UIImage imageNamed:@"atHome"]];
                
            }else if (info.connectState==outDoor){
                NSLog(@"外出模式");
                [self.netBarBtnItem setImage:[UIImage imageNamed:@"Iphonewifi"]];
            }else if (info.connectState==offLine) {
                NSLog(@"离线模式");
                [self.netBarBtnItem setImage:[UIImage imageNamed:@"Iphonewifi"]];
                
            }
        }else if(status == AFNetworkReachabilityStatusNotReachable){ //没有网络(断网)
            NSLog(@"离线模式");
            [self.netBarBtnItem setImage:[UIImage imageNamed:@"breakWifi"]];
        }else if (status == AFNetworkReachabilityStatusUnknown) { //未知网络
            [self.netBarBtnItem setImage:[UIImage imageNamed:@"breakWifi"]];
        }
    }];*/
    
    [_afNetworkReachabilityManager startMonitoring];//开启网络监视器；
    
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
    
    NSInteger status = _afNetworkReachabilityManager.networkReachabilityStatus;
    NSLog(@"NetworkReachabilityStatus: %ld", (long)status);
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
    UIStoryboard * oneStory = [UIStoryboard storyboardWithName:@"iPhone" bundle:nil];
    IphoneLightController * VC = [oneStory instantiateViewControllerWithIdentifier:@"LightController"];
    RoomStatus *roomInfo = self.roomArray[indexPath.row];
    VC.roomID = (int)roomInfo.roomId;
    [self.navigationController pushViewController:VC animated:YES];
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(CollectionCellWidth, CollectionCellWidth);
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
            NSArray *roomStatusList = responseObject[@"room_status_list"];
            if ([roomStatusList isKindOfClass:[NSArray class]]) {
                for (NSDictionary *roomStatus in roomStatusList) {
                    if ([roomStatus isKindOfClass:[NSDictionary class]]) {
                        RoomStatus *roomStatusInfo = [[RoomStatus alloc] init];
                        roomStatusInfo.roomId = [roomStatus[@"roomid"] integerValue];
                        roomStatusInfo.roomName = roomStatus[@"roomname"];
                        roomStatusInfo.temperature = roomStatus[@"temperature"];
                        roomStatusInfo.humidity = roomStatus[@"humidity"];
                        roomStatusInfo.lightStatus = [roomStatus[@"light"] integerValue];
                        roomStatusInfo.curtainStatus = [roomStatus[@"curtain"] integerValue];
                        roomStatusInfo.mediaStatus = [roomStatus[@"media"] integerValue];
                        roomStatusInfo.airconditionerStatus = [roomStatus[@"aircondition"] integerValue];
                        
                        [_roomArray addObject:roomStatusInfo];
                        
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


@end
