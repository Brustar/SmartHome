
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



@interface IphoneFamilyViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic)  IBOutlet UIView *supView;
@property (nonatomic,strong) NSMutableArray * roomIdArrs;//房间数量
@property (nonatomic,strong) NSArray *rooms;
@property (nonatomic,strong) IPhoneRoom * room;

//======add by zxp
@property (nonatomic,strong)NSMutableArray  *iPhoneRoomList;


@end

@implementation IphoneFamilyViewController


//--add by zxp
-(NSArray  *)iPhoneRoomList{
    if(!_iPhoneRoomList){
    
        _iPhoneRoomList = [NSMutableArray array];
    }
    return _iPhoneRoomList;
}


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
//    [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:YES block:^(NSTimer *timer){
//        NSLog(@"timer...");
//        SocketManager *sock = [SocketManager defaultManager];
//        sock.delegate = self;
//        DeviceInfo *device =[DeviceInfo defaultManager];
//        if (device.connectState == outDoor && device.masterID) {
//            NSData *data = [[SceneManager defaultManager] getRealSceneData];
//            [sock.socket writeData:data withTimeout:1 tag:1];
//            [timer invalidate];
//        }
//        
//    }];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.rooms = [SQLManager getAllRoomsInfo];
    SocketManager *sock = [SocketManager defaultManager];
    [sock connectTcp];
    sock.delegate = self;
    [self sendRequestForGettingSceneConfig:@"cloud/RoomStatusList.aspx" withTag:1];

    
}

//获取全屋配置
- (void)sendRequestForGettingSceneConfig:(NSString *)str withTag:(int)tag;
{
    NSString *url = [NSString stringWithFormat:@"%@%@",[IOManager httpAddr],str];
    
    NSDictionary *dic = @{
                          @"AuthorToken" : [[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"],
                          
                    
                          };
    HttpManager *http = [HttpManager defaultManager];
    http.delegate = self;
    http.tag = tag;
    [http sendPost:url param:dic];
    NSLog(@"Request URL:%@", url);
}

#pragma mark - Http callback
- (void)httpHandler:(id)responseObject tag:(int)tag
{
    if ([responseObject isKindOfClass:[NSDictionary class]]) {
        NSLog(@"responseObject:%@", responseObject);
        if ([responseObject[@"Result"] integerValue] == 0) {

            NSArray    *arr = responseObject[@"list"];
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
                
                [self.iPhoneRoomList addObject:room];
            }
        
            [self.collectionView reloadData];
           
        }
    }
}



#pragma  mark - UICollectionViewDelegate
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    

    return self.iPhoneRoomList.count;

}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{

    FamilyCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
 
    
    IPhoneRoom *iphoneRoom = self.iPhoneRoomList[indexPath.row];
    

    [cell setModel:iphoneRoom];

    return  cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    UIStoryboard * oneStory = [UIStoryboard storyboardWithName:@"iPhone" bundle:nil];
    IphoneLightController * VC = [oneStory instantiateViewControllerWithIdentifier:@"LightController"];
//    Room *room = self.rooms[indexPath.row];
    IPhoneRoom * room = self.iPhoneRoomList[indexPath.row];
    VC.roomID = room.roomId;
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
-(void)recv:(NSData *)data withTag:(long)tag
{


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
