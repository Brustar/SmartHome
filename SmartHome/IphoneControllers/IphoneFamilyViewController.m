
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



@interface IphoneFamilyViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (weak, nonatomic)  IBOutlet UIView *supView;
@property (nonatomic,strong) NSArray * dataSource;
@property (nonatomic,strong) NSMutableArray * roomIdArrs;//房间数量
@property (nonatomic,assign) NSInteger selectedSId;
@property (nonatomic,assign) int selected;
@property (nonatomic,assign) int roomID;
@property (nonatomic,strong) NSArray *rooms;
@property (nonatomic,strong) NSMutableArray *roomNames;

@end

@implementation IphoneFamilyViewController

-(NSMutableArray *)roomIdArrs
{
    if (!_roomIdArrs) {
        _roomIdArrs = [NSMutableArray array];
    }
    
    return _roomIdArrs;

}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.rooms = [SQLManager getAllRoomsInfo];
    _roomNames = [NSMutableArray array];
    
    for (Room *room in self.rooms) {
        NSString *roomName = room.rName;
      
        [_roomNames addObject:roomName];
    }
    SocketManager *sock = [SocketManager defaultManager];
    sock.delegate = self;
    
    NSData *data = [[SceneManager defaultManager] getRealSceneData];
    [sock.socket writeData:data withTimeout:1 tag:1];
    
   // [self sendRequestForGettingSceneConfig:@"cloud/RoomStatusList.aspx" withTag:1];
  
    [self reachNotification];
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
            NSDictionary *infoDict = responseObject[@"list"];
            if ([infoDict isKindOfClass:[NSDictionary class]]) {
               
                
            }
        }
    }
}


#pragma mark - TCP recv delegate
- (void)recv:(NSData *)data withTag:(long)tag
{
    FamilyCell * cell ;
    Proto proto = protocolFromData(data);
    
    if (CFSwapInt16BigToHost(proto.masterID) != [[DeviceInfo defaultManager] masterID]) {
        return;
    }
    
    if (tag==0) {
        if (proto.action.state==0x7A) {
            cell.tempLabel.text = [NSString stringWithFormat:@"%d°C",proto.action.RValue];
        }
        if (proto.action.state==0x8A) {
            NSString *valueString = [NSString stringWithFormat:@"%d %%",proto.action.RValue];
            cell.humidityLabel.text = valueString;
        }
    }
}

#pragma  mark - UICollectionViewDelegate
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    return self.roomNames.count;

}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
   FamilyCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    cell.layer.masksToBounds = YES;
    cell.supImageView.layer.cornerRadius = cell.supImageView.bounds.size.width / 2.0;
    cell.subImageView.layer.cornerRadius = cell.subImageView.bounds.size.width /2.0;
    cell.lightImageVIew.layer.cornerRadius = cell.lightImageVIew.bounds.size.width /2.0;
    cell.curtainImageView.layer.cornerRadius = cell.curtainImageView.bounds.size.width / 2.0;
    cell.airImageVIew.layer.cornerRadius = cell.airImageVIew.bounds.size.width / 2.0;
    cell.DVDImageView.layer.cornerRadius = cell.DVDImageView.bounds.size.width / 2.0;
    cell.TVImageView.layer.cornerRadius = cell.TVImageView.bounds.size.width / 2.0;
    cell.musicImageVIew.layer.cornerRadius = cell.musicImageVIew.bounds.size.width / 2.0;
    
    cell.nameLabel.text = _roomNames[indexPath.row];
    

    return cell;
}
-(void)reachNotification{
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(familyNotification:) name:@"subType" object:nil];
}
- (void)familyNotification:(NSNotification *)notification
{
    NSDictionary *dict = notification.userInfo;
    
    self.roomID = [dict[@"subType"] intValue];
    
    self.rooms = [SQLManager getScensByRoomId:self.roomID];
    
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
//    Scene * scene = self.rooms[indexPath.row];
//    self.selectedSId = scene.roomID;
    
    
    FamilyCell * cell = self.rooms[indexPath.row];
    self.selectedSId = self.roomID;
    
    if (cell && indexPath.row < self.roomNames.count) {
        
       [self performSegueWithIdentifier:@"iphoneFamilyController" sender:self];
        
    
    }
        
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
