//
//  NowMusicController.m
//  SmartHome
//
//  Created by zhaona on 2017/4/14.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "NowMusicController.h"
#import "SocketManager.h"
#import "SceneManager.h"
#import "BgMusic.h"
#import "PackManager.h"
#import "DeviceInfo.h"
#import "AudioManager.h"
#import "SQLManager.h"
#import "HttpManager.h"
#import "Room.h"
#import <AVFoundation/AVFoundation.h>

@interface RoomModel : NSObject
@property (nonatomic,copy) NSString *roomname;
@property (nonatomic,strong) NSMutableArray *eqinfoList;


@end

@implementation RoomModel

-(NSMutableArray *)eqinfoList{
    if (!_eqinfoList) {
        _eqinfoList = [NSMutableArray new];
    }
    return _eqinfoList;
}

@end

@interface NowMusicController ()<UITableViewDataSource,UITableViewDelegate, HttpDelegate>
@property (nonatomic,strong) NSMutableArray * bgmusicIDS;
@property (nonatomic,strong) NSMutableArray * bgmusicNameS;
@property (nonatomic,assign) int Volume;
@property (nonatomic,strong) NSMutableArray * AllRooms;
@property (nonatomic,assign) int seleteDeviceId;

@end

@implementation NowMusicController

-(void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:YES];
    if (ON_IPAD) {
        self.ViewleadingConstraint.constant = 200;
        self.ViewTrailingConstraint.constant = 200;
        self.tableViewConstraint.constant = 30;
    }
  
}
- (void)viewDidLoad {
    [super viewDidLoad];
    _bgmusicNameS = [[NSMutableArray alloc] init];
     _AllRooms = [[NSMutableArray alloc] init];
    _bgmusicIDS = [[NSMutableArray alloc] init];
    NSArray * roomArr = [SQLManager getAllRoomsInfo];
    for (int i = 0; i < roomArr.count; i ++) {
        Room * roomName = roomArr[i];
        if (![SQLManager isWholeHouse:roomName.rId]) {
             self.deviceid = [SQLManager singleDeviceWithCatalogID:bgmusic byRoom:roomName.rId];
        }
        if (self.deviceid.length != 0) {
            [_bgmusicIDS addObject:self.deviceid];
        }
         self.deviceName = [SQLManager deviceNameByDeviceID:[self.deviceid intValue]];
        if (self.deviceName.length != 0) {
            [_bgmusicNameS addObject:self.deviceName];
        }
        if (self.deviceid.length != 0) {
            [_AllRooms addObject:roomName.rName];
        }
      
    }
//    for (int i =0; i < self.bgmusicIDarray.count; i ++) {
//        self.deviceName = [SQLManager deviceNameByDeviceID:[self.bgmusicIDarray[i] intValue]];
//         [_bgmusicNameS addObject:self.deviceName];
//        
//    }

    if (BLUETOOTH_MUSIC) {
        AudioManager *audio=[AudioManager defaultManager];
        [audio initMusicAndPlay];
    }
    _Volume = 0;

//    [self fetchPlayingEquipmentList];
     self.MusicTableView.tableFooterView = [UIView new];
    
}

- (void)fetchPlayingEquipmentList {
    NSString *url = [NSString stringWithFormat:@"%@Cloud/current_player_list.aspx",[IOManager httpAddr]];
    NSString *auothorToken = [UD objectForKey:@"AuthorToken"];
    
    if (auothorToken.length >0) {
        NSDictionary *dict = @{@"token":auothorToken,
                               @"optype":@(0)
                               };
        HttpManager *http=[HttpManager defaultManager];
        http.delegate = self;
        http.tag = 1;
        [http sendPost:url param:dict];
    }
}

#pragma mark - Http callback
- (void)httpHandler:(id)responseObject tag:(int)tag
{
    if(tag == 1) {
        [self.AllRooms removeAllObjects];
        if ([responseObject[@"result"] intValue] == 0) {
            NSArray *roomList = responseObject[@"current_player_list"];
            if ([roomList isKindOfClass:[NSArray class]]) {
                for (NSDictionary *room in roomList) {
                    
                    if ([room isKindOfClass:[NSDictionary class]]) {
                        NSString *rName = room[@"roomname"];
                        NSArray *equipmentList = room[@"eqinfolist"];
                        RoomModel *roomMODEL = [RoomModel new];
                        roomMODEL.roomname = rName;
                        if ([equipmentList isKindOfClass:[NSArray class]]) {
                            for (NSDictionary *device in equipmentList) {
                                if ([device isKindOfClass:[NSDictionary class]]) {
                                    Device *devInfo = [[Device alloc] init];
                                    devInfo.rName = rName;
                                    devInfo.eID = [device[@"eqid"] intValue];
                                    devInfo.name = device[@"eqname"];
                                    
                                    [roomMODEL.eqinfoList addObject:devInfo];
                                    
                                }
                            }
                            
                            [self.AllRooms addObject:roomMODEL];
                        }
                        
                    }
                    
                }
            }
            
            [self.MusicTableView reloadData];
        }
    }
}
#pragma mark - MusicPlayer delegate
-(void)musicPlayerStatedChanged:(NSNotification *)paramNotification
{
    NSLog(@"Player State Changed");
//    self.songTitle.text=[self titleOfNowPlaying];
    NSNumber * stateAsObject = [paramNotification.userInfo objectForKey:@"MPMusicPlayerControllerPlaybackStateKey"];
    NSInteger state = [stateAsObject integerValue];
    switch (state) {
        case MPMusicPlaybackStateStopped:
            
            break;
        case MPMusicPlaybackStatePlaying:
            break;
        case MPMusicPlaybackStatePaused:
            break;
        case MPMusicPlaybackStateInterrupted:
            break;
        case MPMusicPlaybackStateSeekingForward:
            break;
        case MPMusicPlaybackStateSeekingBackward:
            break;
            
        default:
            break;
    }
}

-(NSString*)titleOfNowPlaying
{
    AudioManager *audio=[AudioManager defaultManager];
    if( audio.musicPlayer == nil ) {
        return @"music Player is nil.";
    }
    
    MPMediaItem* item = audio.musicPlayer.nowPlayingItem;
    if( item == nil ) {
        return @"playing.";
    }
    NSString* title = [item valueForKey:MPMediaItemPropertyTitle];
    return title;
}

//减音量
- (IBAction)smallVolume:(id)sender {
    if (_Volume > 0) {
        _Volume -= 10;
        _loseBtn.titleLabel.text = [NSString stringWithFormat:@"%d",_Volume];
    }
    NSData *data=[[DeviceInfo defaultManager] changeVolume:_Volume deviceID:[NSString stringWithFormat:@"%d",self.seleteDeviceId]];
    SocketManager *sock=[SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
}
//加音量
- (IBAction)additionVolume:(id)sender {
    if (_Volume <= 100) {
        _Volume += 10;
        _loseBtn.titleLabel.text = [NSString stringWithFormat:@"%d",_Volume];
    }
    
    NSData *data=[[DeviceInfo defaultManager] changeVolume:_Volume deviceID:[NSString stringWithFormat:@"%d",self.seleteDeviceId]];
    SocketManager *sock=[SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
}

//开关
- (IBAction)switchPower:(id)sender {
    
        UIButton *btn = (UIButton *)sender;
        [btn setSelected:!btn.isSelected];
        if (btn.isSelected) {
            [btn setImage:[UIImage imageNamed:@"close_red"] forState:UIControlStateNormal];
            //发送播放指令
            NSData *data=[[DeviceInfo defaultManager] play:[NSString stringWithFormat:@"%d",self.seleteDeviceId]];
            SocketManager *sock=[SocketManager defaultManager];
            [sock.socket writeData:data withTimeout:1 tag:1];
    
        }else{
            [btn setImage:[UIImage imageNamed:@"close_white"] forState:UIControlStateNormal];
            // 发送停止指令
            NSData *data=[[DeviceInfo defaultManager] pause:[NSString stringWithFormat:@"%d",self.seleteDeviceId]];
            SocketManager *sock=[SocketManager defaultManager];
            [sock.socket writeData:data withTimeout:1 tag:1];
    
        }
}
-(void)dealloc
{
    if (BLUETOOTH_MUSIC) {
        AudioManager *audio= [AudioManager defaultManager];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMusicPlayerControllerPlaybackStateDidChangeNotification object:audio.musicPlayer];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification object:audio.musicPlayer];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMusicPlayerControllerVolumeDidChangeNotification object:audio.musicPlayer];
    }
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.AllRooms.count;

}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSMutableArray * de = [[NSMutableArray alloc] init];
    [de addObject:self.bgmusicNameS[section]];
    return de.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(!cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        
    }
    cell.backgroundColor = [UIColor clearColor];
    [cell.textLabel setTextColor:[UIColor whiteColor]];
    NSString * str = self.bgmusicNameS[indexPath.section];
     cell.textLabel.text = str;
//    cell.tag = devInfo.eID;
    //cell的点击颜色
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(100, 0, self.view.bounds.size.width, 0)];
    view.backgroundColor = [UIColor colorWithRed:67/255.0 green:68/255.0 blue:69/255.0 alpha:1];
    
    cell.selectedBackgroundView = view;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    self.seleteDeviceId = [self.bgmusicIDS[indexPath.section] intValue];
 
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 50)];
    view.backgroundColor = [UIColor clearColor];
    view.userInteractionEnabled = YES;
    UILabel * NameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 100, 50)];
    NameLabel.textColor = [UIColor whiteColor];
    NSString * str = self.AllRooms[section];
    NameLabel.text = str;
    [view addSubview:NameLabel];
    //线
    UIView * view1;
    UIButton *OpenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    OpenBtn.backgroundColor = [UIColor clearColor];
    OpenBtn.tag = section;
    [OpenBtn addTarget:self action:@selector(StopBtn:) forControlEvents:UIControlEventTouchUpInside];
    [OpenBtn setImage:[UIImage imageNamed:@"Video-close"] forState:UIControlStateNormal];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 49, self.view.bounds.size.width, 1)];
        OpenBtn.frame = CGRectMake(self.view.bounds.size.width-150, 15, 30, 30);
        
    }else {
         view1 = [[UIView alloc] initWithFrame:CGRectMake(10, 49, self.view.bounds.size.width-480, 1)];
         OpenBtn.frame = CGRectMake(self.view.bounds.size.width-520, 15, 30, 30);
    }
    
    view1.backgroundColor = [UIColor redColor];
    [view addSubview:view1];
    [view addSubview:OpenBtn];
    return view;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
       UIView * footerView = [[UIView alloc] init];
       footerView.backgroundColor = [UIColor clearColor];
       UILabel * line = [[UILabel alloc] init];
       line.backgroundColor = [UIColor whiteColor];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        footerView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 10);
        line.frame = CGRectMake(0, 0, self.view.bounds.size.width, 0.5);
    }else{
        footerView.frame = CGRectMake(10, 0, self.view.bounds.size.width-150, 10);
        line.frame = CGRectMake(10, 0, self.view.bounds.size.width-480, 0.5);
    }
   
    [footerView addSubview:line];
    
    return footerView;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
}

-(void)StopBtn:(UIButton *)bbt
{
   
    self.seleteSection = [self.bgmusicIDS[bbt.tag] intValue];
        NSData *data=[[DeviceInfo defaultManager] pause:[NSString stringWithFormat:@"%d",self.seleteSection]];
        SocketManager *sock=[SocketManager defaultManager];
        [sock.socket writeData:data withTimeout:1 tag:1];
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)bgBtnClicked:(id)sender {
    
    if (_delegate && [_delegate respondsToSelector:@selector(onBgButtonClicked:)]) {
        [_delegate onBgButtonClicked:sender];
    }
}
@end
