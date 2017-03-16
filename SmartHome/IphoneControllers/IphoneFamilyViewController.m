
//
//  IphoneFamilyViewController.m
//  SmartHome
//
//  Created by 逸云科技 on 2016/11/11.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#define cellWidth self.collectionView.frame.size.width / 2.0 -20
#define  minSpace 20
#define  maxSpace 40

#import "IphoneFamilyViewController.h"
#import "HttpManager.h"
#import "MBProgressHUD+NJ.h"
#import "FamilyCell.h"
#import "Scene.h"
#import "Room.h"
#import "SQLManager.h"
#import "PackManager.h"
#import "SocketManager.h"
#import "SceneManager.h"
#import "IphoneLightController.h"
#import "IPhoneRoom.h"
#import "DeviceInfo.h"
#import "ObjectFunction.h"
#import "UIImage+ImageEffects.h"
#import "AppDelegate.h"


@interface IphoneFamilyViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,TcpRecvDelegate>
@property (weak, nonatomic)  IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic)  IBOutlet UIView *supView;
@property (nonatomic,strong) NSMutableArray * roomIdArrs;//房间数量
@property (nonatomic,strong) NSArray *rooms;
//@property (nonatomic,strong) IPhoneRoom * room;
//@property (nonatomic,strong) FamilyCell *cell;
//@property (nonatomic,strong)NSMutableArray  *iPhoneRoomList;
@property (nonatomic,assign)  int roomID;
@property (nonatomic,strong)  NSArray * deviceArr;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *fixTimeBarBtn;//是否存在定时设备或者场景
@property (nonatomic, weak) UIViewController *selectController;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *netBarBtnItem;
@property (weak, nonatomic) IBOutlet UIImageView *XGImageView;

@property (nonatomic,strong) IphoneFamilyViewController * familyVC;
@end

@implementation IphoneFamilyViewController
-(NSMutableArray *)roomIdArrs
{
    if (!_roomIdArrs) {
        _roomIdArrs = [NSMutableArray array];
    }
    
    return _roomIdArrs;

}

- (void)handleTimer:(NSTimer *)theTimer {
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timer:) userInfo:nil repeats:YES];
}

-(void)timer:(NSTimer *)timer
{
    SocketManager *sock = [SocketManager defaultManager];
    DeviceInfo *device =[DeviceInfo defaultManager];
    if (device.connectState == outDoor && device.masterID) {
        NSData *data = [[SceneManager defaultManager] getRealSceneData];
        [sock.socket writeData:data withTimeout:1 tag:0];
        [timer invalidate];
    }
}

-(void)connect
{
    SocketManager *sock = [SocketManager defaultManager];
    if ([[UD objectForKey:@"HostID"] intValue] > 0x8000) {
        [sock connectUDP:[IOManager udpPort]];
    }else{
        [sock connectTcp];
    }
    sock.delegate = self;
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
    
  
     NSLog(@"NetworkReachabilityStatus: %d", status);

    
}

- (void)setupSlideButton {
    UIButton *menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    menuBtn.frame = CGRectMake(0, 0, 44, 44);
    [menuBtn setImage:[UIImage imageNamed:@"logo"] forState:UIControlStateNormal];
    [menuBtn addTarget:self action:@selector(menuBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menuBtn];
}

- (void)menuBtnAction:(UIButton *)sender {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (appDelegate.LeftSlideVC.closed)
    {
        [appDelegate.LeftSlideVC openLeftView];
    }
    else
    {
        [appDelegate.LeftSlideVC closeLeftView];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupSlideButton];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.rooms = [SQLManager getAllRoomsInfo];
    for (Room * room in self.rooms) {
        self.roomID = room.rId;
        self.deviceArr = [SQLManager deviceSubTypeByRoomId:self.roomID];
    }

    //开启网络状况监听器
    [self updateInterfaceWithReachability];

    //init nest dataSource
    [self initNestDataSource];
    
    if ([[UD objectForKey:@"HostID"] intValue] == 258) { //九号大院
        
        self.title = @"九号大院";
        //nest login
        [self nestLogin];
        SocketManager *sock = [SocketManager defaultManager];
        [sock connectTcp];
        sock.delegate = self;
    }else{
        [self connect];
    }

      [self.XGImageView setContentMode:UIViewContentModeScaleAspectFill];
     [self.XGImageView setImage:[ObjectFunction blurryImage:[UIImage imageNamed:@"test.jpeg"] withBlurLevel:10.0f]];
}
//监听到网络状态改变
- (void) reachabilityUpdate: (NSNotification* )note
{
    [self updateInterfaceWithReachability];
}
//处理连接改变后的情况
- (void)updateInterfaceWithReachability
{
    _afNetworkReachabilityManager = [AFNetworkReachabilityManager sharedManager];
    
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
    }];
    
    [_afNetworkReachabilityManager startMonitoring];//开启网络监视器；
    
}
- (void)initNestDataSource {
    _nest_devices_arr = [[NSMutableArray alloc] init];
    _nest_curr_temperature_arr = [[NSMutableArray alloc] init];
    _nest_curr_humidity_arr = [[NSMutableArray alloc] init];
    _nest_en_room_name_arr = [NSMutableArray arrayWithObjects:@"Bedroom", @"Dining Room", @"KTV", @"Living Room" ,@"Master Bedroom", nil];
}

//获取全屋配置
- (void)sendRequestForGettingSceneConfig
{
    NSString *authorToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"];
    
    NSString *url = [NSString stringWithFormat:@"%@Cloud/room_status_list.aspx",[IOManager httpAddr]];
    if (authorToken) {
        NSDictionary *dic = @{@"token":authorToken,@"optype":[NSNumber numberWithInteger:0]};
        HttpManager *http=[HttpManager defaultManager];
        http.delegate = self;
        http.tag = 1;
        [http sendPost:url param:dic];
        
    }
}

#pragma mark - Nest API
- (void)nestLogin {
    NSString *requestURL = @"https://home.nest.com/user/login";
    NSDictionary *paramDict = @{
                                @"username":@"156810316@qq.com",
                                @"password":@"Stone4shi!"
                                };
    HttpManager *http = [HttpManager defaultManager];
    http.delegate = self;
    http.tag = 2;
    [http sendPost:requestURL param:paramDict];
}

- (void)fetchNestStatus {
    HttpManager *http = [HttpManager defaultManager];
    http.delegate = self;
    http.tag = 3;
    [http sendGet:_nest_status_req_url param:nil header:_nest_status_req_header];
}
#pragma mark - Http callback
- (void)httpHandler:(id)responseObject tag:(int)tag
{
    if (tag == 1) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSLog(@"responseObject:%@", responseObject);
            if ([responseObject[@"result"] integerValue] == 0) {
                NSArray    *arr = responseObject[@"room_status_list"];
                for(NSDictionary *dict in arr){
                    IPhoneRoom  *room = [IPhoneRoom new];
                    room.roomId =  [dict[@"roomid"]  intValue];
                    room.light  = [dict[@"light"] intValue];
                    room.curtain = [dict[@"curtain"] intValue];
                    room.bgmusic = [dict[@"bgmusic"] intValue];
                    room.aircondition = [dict[@"aircondition"] intValue];
                    room.dvd  = [dict[@"dvd"] intValue];
                    room.tv = [dict[@"tv"] intValue];
                    room.temperature = [dict[@"temperature"] intValue];
                    room.humidity = [dict[@"humidity"] intValue];
                    
                    //====从sqlite中通过id的到name
                    room.roomName = [SQLManager getRoomNameByRoomID:room.roomId];
                    
//                    [self.iPhoneRoomList addObject:room];
                }
                
                [self.collectionView reloadData];
                
            }
        }
    }else if (tag == 2) { //nest login callback
        NSLog(@"Nest login responseObject: %@", responseObject);
        _nest_access_token = responseObject[@"access_token"];
        _nest_user = responseObject[@"user"];
        _nest_user_id = responseObject[@"userid"];
        _nest_transport_url = responseObject[@"urls"][@"transport_url"];
        
        if (_nest_access_token.length >0 && _nest_user.length >0 && _nest_transport_url.length >0 && _nest_user_id.length >0) {
            _nest_status_req_url = [NSString stringWithFormat:@"%@/v3/mobile/%@", _nest_transport_url, _nest_user];
            _nest_status_req_header = @{
                                        @"X-nl-protocol-version":@"1",
                                        @"X-nl-user-id":_nest_user_id,
                                        @"Authorization":[NSString stringWithFormat:@"Basic %@", _nest_access_token]
                                        };
            [self fetchNestStatus];
        }else {
            NSLog(@"Nest login 返回参数错误！");
        }
    }else if (tag == 3) { //nest_status callback
        NSLog(@"Nest status responseObject: %@", responseObject);
        NSDictionary *nest_structure_dict =  responseObject[@"structure"];
        if ([nest_structure_dict isKindOfClass:[NSDictionary class]]) {
            [nest_structure_dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
                if ([obj isKindOfClass:[NSDictionary class]]) {
                    NSArray *devices = obj[@"devices"];
                    if ([devices isKindOfClass:[NSArray class]] && devices.count >0) {
                        [_nest_devices_arr addObjectsFromArray:devices];
                        *stop = YES;
                    }
                }
            
            }];
            
            //遍历 _nest_devices_arr， 获取 温度，湿度
            [_nest_devices_arr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
                NSString *deviceID = obj;
                if ([deviceID isKindOfClass:[NSString class]]) {
                    deviceID = [deviceID substringFromIndex:7];
                    NSString *temperatureObj = [NSString stringWithFormat:@"%.1f", [(responseObject[@"shared"][deviceID][@"current_temperature"]) floatValue]];//温度
                    if (temperatureObj) {
                        [_nest_curr_temperature_arr addObject:[temperatureObj description]];
                    }
                    NSString *humidityObj =[NSString stringWithFormat:@"%d", [responseObject[@"device"][deviceID][@"current_humidity"] intValue]];//湿度
                    if (humidityObj) {
                        [_nest_curr_humidity_arr addObject:humidityObj];
                    }
                }
            }];
            
            NSLog(@"_nest_curr_temperature_arr: %@", _nest_curr_temperature_arr);
            NSLog(@"_nest_curr_humidity_arr: %@", _nest_curr_humidity_arr);
            
            //刷新 collectionView
            [_collectionView reloadData];
            
        }
    }
}

#pragma mark - TCP recv delegate
- (void)recv:(NSData *)data withTag:(long)tag
{
    if ([[UD objectForKey:@"HostID"] intValue] == 258) {  //九号大院
        return;
    }
    Proto proto = protocolFromData(data);
    if (CFSwapInt16BigToHost(proto.masterID) != [[DeviceInfo defaultManager] masterID]) {
        return;
    }
    if (tag==0) {
        //缓存设备当前状态
        if (proto.cmd==0x01) {
            int tag = [SQLManager getRoomIDByNumber:[NSString stringWithFormat:@"%04X", CFSwapInt16BigToHost(proto.deviceID)]];
            FamilyCell *cell = [self.view viewWithTag:tag];
            if (proto.action.state==0x6A) {
                cell.tempLabel.text = [NSString stringWithFormat:@"%d°C",proto.action.RValue];
            }
            if (proto.action.state==0x8A) {
                NSString *valueString = [NSString stringWithFormat:@"%d %%",proto.action.RValue];
                cell.humidityLabel.text = valueString;
            }
            if (proto.action.state ==0x7D) {
                if (proto.deviceType == 01 || proto.deviceType == 02 || proto.deviceType == 03) {
                    cell.lightImageVIew.hidden = proto.action.RValue;
                }else if (proto.deviceType == 21 || proto.deviceType == 22){
                    cell.curtainImageView.hidden = proto.action.RValue;
                }else if (proto.deviceType == 12){
                    cell.TVImageView.hidden = proto.action.RValue;
                }else if (proto.deviceType == 13){
                    cell.DVDImageView.hidden = proto.action.RValue;
                }else if (proto.deviceType == 14){
                    cell.musicImageVIew.hidden = proto.action.RValue;
                }else if (proto.deviceType == 31){
                    cell.airImageVIew.hidden = proto.action.RValue;
                }
            }
        }
    }
}

#pragma  mark - UICollectionViewDelegate
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if ([[UD objectForKey:@"HostID"] intValue] == 258) { //九号大院
        return _nest_devices_arr.count;
    }else {
        return self.rooms.count;
    }
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FamilyCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    Room * room = self.rooms[indexPath.row];
    cell.nameLabel.text = room.rName;
    
    if ([[UD objectForKey:@"HostID"] intValue] == 258) {  //九号大院
        cell.nameLabel.text = [NSString stringWithFormat:@"%@", [_nest_en_room_name_arr objectAtIndex:indexPath.row]];
        cell.tempLabel.text =  [NSString stringWithFormat:@"%@%@", [_nest_curr_temperature_arr objectAtIndex:indexPath.row], @"℃"];
        cell.humidityLabel.text = [NSString stringWithFormat:@"%@%@", [_nest_curr_humidity_arr objectAtIndex:indexPath.row], @"%"];
    }else{
        cell.tag = room.rId;
    }

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UIStoryboard * oneStory = [UIStoryboard storyboardWithName:@"iPhone" bundle:nil];
    IphoneLightController * VC = [oneStory instantiateViewControllerWithIdentifier:@"LightController"];
    Room *room = self.rooms[indexPath.row];
    VC.roomID = room.rId;
    [self.navigationController pushViewController:VC animated:YES];
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(cellWidth, cellWidth);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return minSpace;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return maxSpace;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
