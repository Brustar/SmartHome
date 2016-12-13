
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
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic)  IBOutlet UIView *supView;
@property (nonatomic,strong) NSMutableArray * roomIdArrs;//房间数量
@property (nonatomic,strong) NSArray *rooms;
//@property (nonatomic,strong) IPhoneRoom * room;
@property (nonatomic,strong) FamilyCell *cell;
//@property (nonatomic,strong)NSMutableArray  *iPhoneRoomList;
@property (nonatomic,assign)  int roomID;
@property (nonatomic,strong)  NSArray * deviceArr;

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
//    [self sendRequestForGettingSceneConfig];

    
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
    }
}

#pragma mark - TCP recv delegate
- (void)recv:(NSData *)data withTag:(long)tag
{
//    NSArray * hTypeIdArr = @[@"01",@"02",@"03",@"12",@"13",@"14",@"21",@"22",@"31"];
    Proto proto = protocolFromData(data);
  
    if (CFSwapInt16BigToHost(proto.masterID) != [[DeviceInfo defaultManager] masterID]) {
        return;
    }
    if (tag==0) {
        if (proto.action.state==0x6A) {
            
            self.cell.tempLabel.text = [NSString stringWithFormat:@"%d°C",proto.action.RValue];
        }
        if (proto.action.state==0x8A) {
            NSString *valueString = [NSString stringWithFormat:@"%d %%",proto.action.RValue];
            self.cell.humidityLabel.text = valueString;
        }if (proto.action.state==0x00) {
            for (Device * device in self.deviceArr) {
                if (device.hTypeId == 01 || device.hTypeId == 02 || device.hTypeId == 03) {
                      self.cell.lightImageVIew.hidden = YES;
                }else if (device.hTypeId == 21 || device.hTypeId == 22){
                    self.cell.curtainImageView.hidden = YES;
                }else if (device.hTypeId == 12){
                      self.cell.TVImageView.hidden = YES;
                }else if (device.hTypeId == 13){
                    self.cell.DVDImageView.hidden = YES;
                }else if (device.hTypeId == 14){
                    self.cell.musicImageVIew.hidden = YES;
                }else if (device.hTypeId == 31){
                   self.cell.airImageVIew.hidden = YES;
                }
            }
          
        }if (proto.action.state==0x01) {
            for (Device * device in self.deviceArr) {
                if (device.hTypeId == 01 || device.hTypeId == 02 || device.hTypeId == 03) {
                    self.cell.lightImageVIew.hidden = NO;
                }else if (device.hTypeId == 21 || device.hTypeId == 22){
                    self.cell.curtainImageView.hidden = NO;
                }else if (device.hTypeId == 12){
                    self.cell.TVImageView.hidden = NO;
                }else if (device.hTypeId == 13){
                    self.cell.DVDImageView.hidden = NO;
                }else if (device.hTypeId == 14){
                    self.cell.musicImageVIew.hidden = NO;
                }else if (device.hTypeId == 31){
                    self.cell.airImageVIew.hidden = NO;
                }
            }
        }
    }
}
#pragma  mark - UICollectionViewDelegate
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.rooms.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    Room * room = self.rooms[indexPath.row];
    self.cell.nameLabel.text = room.rName;

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
