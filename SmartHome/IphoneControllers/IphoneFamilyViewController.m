
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

@interface IphoneFamilyViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,TcpRecvDelegate>
@property (weak, nonatomic)  IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic)  IBOutlet UIView *supView;
@property (nonatomic,strong) NSMutableArray * roomIdArrs;//房间数量
@property (nonatomic,strong) NSArray *rooms;
//@property (nonatomic,strong) IPhoneRoom * room;
@property (nonatomic,strong) FamilyCell *cell;
//@property (nonatomic,strong)NSMutableArray  *iPhoneRoomList;
@property (nonatomic,assign)  int roomID;
@property (nonatomic,strong)  NSArray * deviceArr;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *fixTimeBarBtn;//是否存在定时设备或者场景
@property (nonatomic, weak) UIViewController *selectController;

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
    [sock connectTcp];
    sock.delegate = self;
    DeviceInfo *device =[DeviceInfo defaultManager];
    if (device.connectState == outDoor && device.masterID) {
        NSData *data = [[SceneManager defaultManager] getRealSceneData];
        [sock.socket writeData:data withTimeout:1 tag:1];
        [timer invalidate];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.rooms = [SQLManager getAllRoomsInfo];
    for (Room * room in self.rooms) {
        self.roomID = room.rId;
        self.deviceArr = [SQLManager deviceSubTypeByRoomId:self.roomID];
    }
    
    SocketManager *sock = [SocketManager defaultManager];
    sock.delegate = self;
    
    NSData *data = [[SceneManager defaultManager] getRealSceneData];
    [sock.socket writeData:data withTimeout:1 tag:1];
    NSLog(@"TCP请求Data:%@", data);
    //init nest dataSource
    [self initNestDataSource];
    
    if ([[UD objectForKey:@"HostID"] intValue] == 258) { //九号大院
        
        self.title = @"九号大院";
        //nest login
        [self nestLogin];
    }
    //查询设备状态
    NSData *subdata = [[DeviceInfo defaultManager] query:self.deviceid];
    [sock.socket writeData:subdata withTimeout:1 tag:1];

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
            //[SQLManager addStates:proto.deviceID onoff:proto.action.RValue];
        }
        
        if (proto.action.state==0x6A) {
            
            self.cell.tempLabel.text = [NSString stringWithFormat:@"%d°C",proto.action.RValue];
        }
        if (proto.action.state==0x8A) {
            NSString *valueString = [NSString stringWithFormat:@"%d %%",proto.action.RValue];
            self.cell.humidityLabel.text = valueString;
        }
        if (proto.action.state ==0x7D) {
            if (proto.action.state == PROTOCOL_OFF) {
                if (proto.deviceType == 01 || proto.deviceType == 02 || proto.deviceType == 03) {
                    self.cell.lightImageVIew.hidden = YES;
                }else if (proto.deviceType == 21 || proto.deviceType == 22){
                    self.cell.curtainImageView.hidden = YES;
                }else if (proto.deviceType == 12){
                    self.cell.TVImageView.hidden = YES;
                }else if (proto.deviceType == 13){
                    self.cell.DVDImageView.hidden = YES;
                }else if (proto.deviceType == 14){
                    self.cell.musicImageVIew.hidden = YES;
                }else if (proto.deviceType == 31){
                    self.cell.airImageVIew.hidden = YES;
                }
            }
        }if (proto.action.state==0x7D) {
           if (proto.action.state == PROTOCOL_ON) {
                if (proto.deviceType == 01 || proto.deviceType == 02 || proto.deviceType == 03) {
                    self.cell.lightImageVIew.hidden = NO;
                }else if (proto.deviceType == 21 || proto.deviceType == 22){
                    self.cell.curtainImageView.hidden = NO;
                }else if (proto.deviceType == 12){
                    self.cell.TVImageView.hidden = NO;
                }else if (proto.deviceType == 13){
                    self.cell.DVDImageView.hidden = NO;
                }else if (proto.deviceType == 14){
                    self.cell.musicImageVIew.hidden = NO;
                }else if (proto.deviceType == 31){
                    self.cell.airImageVIew.hidden = NO;
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

    self.cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    Room * room = self.rooms[indexPath.row];
    self.cell.nameLabel.text = room.rName;
    
    if ([[UD objectForKey:@"HostID"] intValue] == 258) {  //九号大院
        self.cell.nameLabel.text = [NSString stringWithFormat:@"%@", [_nest_en_room_name_arr objectAtIndex:indexPath.row]];
        self.cell.tempLabel.text =  [NSString stringWithFormat:@"%@%@", [_nest_curr_temperature_arr objectAtIndex:indexPath.row], @"℃"];
        self.cell.humidityLabel.text = [NSString stringWithFormat:@"%@%@", [_nest_curr_humidity_arr objectAtIndex:indexPath.row], @"%"];
    }

    return  self.cell;
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
