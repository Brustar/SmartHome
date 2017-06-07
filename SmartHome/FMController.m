//
//  FMController.m
//  SmartHome
//
//  Created by Brustar on 16/6/13.
//  Copyright © 2016年 Brustar. All rights reserved.
//
#import "FMController.h"
#import "FMCollectionViewCell.h"
#import "IphoneRoomView.h"
#import "SceneManager.h"
#import "MBProgressHUD+NJ.h"
#import "VolumeManager.h"
#import "SocketManager.h"
#import "SQLManager.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "HttpManager.h"
#import "PackManager.h"
#import "TVChannel.h"
#import "UIViewController+Navigator.h"

@interface FMController ()<UICollectionViewDelegate,UICollectionViewDataSource,UIScrollViewDelegate,UIGestureRecognizerDelegate,FMCollectionViewCellDelegate,IphoneRoomViewDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollerContentViewWidth;
@property (nonatomic,strong) NSMutableArray *allFavouriteChannels;
@property (nonatomic,strong) NSArray *menus;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UILabel *numberOfChannel;
@property (weak, nonatomic) IBOutlet UIView *fmView;

@property (weak, nonatomic) IBOutlet UIView *coverView;
@property (weak, nonatomic) IBOutlet UILabel *unstoreLabel;

@property (weak, nonatomic) IBOutlet UITextField *channelNameEdit;
@property (weak, nonatomic) IBOutlet UITextField *channelIDEdit;

@property (weak, nonatomic) IBOutlet UIView *editView;
@property (weak, nonatomic) IBOutlet UILabel *hzLabel;
@property (weak, nonatomic) IBOutlet UIPageControl *pageController;
@property (nonatomic,strong) NSString *eNumber;
@property (weak, nonatomic) IBOutlet UIButton *power;

@property (nonatomic,strong) FMCollectionViewCell *cell;
@property (weak, nonatomic) IBOutlet UILabel *voiceValue;
@property (weak, nonatomic) IBOutlet UIStackView *channelContainer;
@property (weak, nonatomic) IBOutlet UIStackView *menuContainer;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *voiceLeft;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *voiceRight;
@property (weak, nonatomic) IBOutlet UIImageView *ear;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;
@property (weak, nonatomic) IBOutlet UIButton *prevoius;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *menuTop;
@property (weak, nonatomic) IBOutlet UIButton *ipadPower;

@end

@implementation FMController

-(NSMutableArray *)allFavouriteChannels
{
    if(!_allFavouriteChannels)
    {
        _allFavouriteChannels = [NSMutableArray array];
        _allFavouriteChannels = [SQLManager getAllChannelForFavoritedForType:@"FM" deviceID:[self.deviceid intValue]];
        if(_allFavouriteChannels == nil || _allFavouriteChannels.count == 0)
        {
            self.unstoreLabel.hidden = NO;
            self.collectionView.backgroundColor = [UIColor whiteColor];
            
        }
        
    }
    return _allFavouriteChannels;
}

- (void)setRoomID:(int)roomID
{
    _roomID = roomID;
    if(roomID)
    {
        self.deviceid = [SQLManager singleDeviceWithCatalogID:FM byRoom:self.roomID];
    } 
    
}

-(void)setUpRoomScrollerView
{
    NSMutableArray *deviceNames = [NSMutableArray array];
    
    for (Device *device in self.menus) {
        NSString *deviceName = device.typeName;
        [deviceNames addObject:deviceName];
    }
    
    IphoneRoomView *menu = [[IphoneRoomView alloc] initWithFrame:CGRectMake(0,0, 320, 40)];
    
    menu.dataArray = deviceNames;
    menu.delegate = self;
    
    [menu setSelectButton:0];
    [self.menuContainer addSubview:menu];
}

- (void)iphoneRoomView:(UIView *)view didSelectButton:(int)index {
    Device *device = self.menus[index];
    [self.navigationController pushViewController:[DeviceInfo calcController:device.hTypeId] animated:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if(self.roomID == 0) self.roomID = (int)[DeviceInfo defaultManager].roomID;
    NSString *roomName = [SQLManager getRoomNameByRoomID:self.roomID];
    [self setNaviBarTitle:[NSString stringWithFormat:@"%@ - 收音机",roomName]];
    [self initSlider];
    self.menus = [SQLManager mediaDeviceNamesByRoom:self.roomID];
    if (self.menus.count<6) {
        [self initMenuContainer:self.menuContainer andArray:self.menus andID:self.deviceid];
    }else{
        [self setUpRoomScrollerView];
    }
    [self naviToDevice];
    [self initChannelContainer];
    
    self.hzLabel.transform = CGAffineTransformMakeRotation(M_PI/2 + M_PI);
    self.collectionView.pagingEnabled = YES;
    [self.power setImage:[UIImage imageNamed:@"TV_on"] forState:UIControlStateSelected];
    
    self.volume.continuous = NO;
    [self.volume addTarget:self action:@selector(changeVolume) forControlEvents:UIControlEventValueChanged];
    
    self.eNumber = [SQLManager getENumber:[self.deviceid intValue]];
    DeviceInfo *device=[DeviceInfo defaultManager];
    [device addObserver:self forKeyPath:@"volume" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
    VolumeManager *volume=[VolumeManager defaultManager];
    [volume start];
    // Do any additional setup after loading the view.
    _scene=[[SceneManager defaultManager] readSceneByID:[self.sceneid intValue]];
    if ([self.sceneid intValue]>0) {
        for(int i=0;i<[_scene.devices count];i++)
        {
            if ([[_scene.devices objectAtIndex:i] isKindOfClass:[Radio class]]) {
                self.volume.value=((Radio*)[_scene.devices objectAtIndex:i]).rvolume/100.0;
                self.numberOfChannel.text=  [NSString stringWithFormat:@"%.1f", ((Radio*)[_scene.devices objectAtIndex:i]).channel];
            }
        }
    }
    [self setUpPageController];
    
    SocketManager *sock=[SocketManager defaultManager];
    sock.delegate=self;
    //查询设备状态
    NSData *data = [[DeviceInfo defaultManager] query:self.deviceid];
    [sock.socket writeData:data withTimeout:1 tag:1];
    if (ON_IPAD) {
        self.menuTop.constant = 0;
        self.voiceLeft.constant = self.voiceRight.constant = 100;
        //self.controlLeft.constant = self.controlRight.constant = 200;
        //self.controlBottom.constant = 160;
        self.ear.hidden = self.btnNext.hidden = self.prevoius.hidden = self.ipadPower.hidden = NO;
    }
}

-(void)initChannelContainer
{
    self.deviceid = [SQLManager singleDeviceWithCatalogID:FM byRoom:self.roomID];
    self.allFavouriteChannels = [SQLManager getAllChannelForFavoritedForType:@"fm" deviceID:[self.deviceid intValue]];
    for(TVChannel *ch in self.allFavouriteChannels)
    {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.contentMode = UIViewContentModeScaleAspectFit;
        
        [btn setTitle:ch.channel_name  forState:UIControlStateNormal];
        [[btn rac_signalForControlEvents:UIControlEventTouchUpInside]
         subscribeNext:^(id x) {
             NSData *data = [[DeviceInfo defaultManager] switchProgram:ch.channel_number deviceID:self.deviceid];
             SocketManager *sock=[SocketManager defaultManager];
             [sock.socket writeData:data withTimeout:1 tag:1];
         }];
        [self.channelContainer addArrangedSubview:btn];
        [self.channelContainer layoutIfNeeded];
    }
}

-(void) initSlider
{
    self.frequence.continuous = NO;
    [self.frequence setThumbImage:[UIImage imageNamed:@"fm_thumb"] forState:UIControlStateNormal];
    self.frequence.maximumTrackTintColor = self.frequence.minimumTrackTintColor = [UIColor clearColor];
    [self.frequence addTarget:self action:@selector(adjustFrequence:) forControlEvents:UIControlEventValueChanged];
    
    [self.volume setThumbImage:[UIImage imageNamed:@"lv_btn_adjust_normal"] forState:UIControlStateNormal];
    self.volume.maximumTrackTintColor = [UIColor colorWithRed:16/255.0 green:17/255.0 blue:21/255.0 alpha:1];
    self.volume.minimumTrackTintColor = [UIColor colorWithRed:253/255.0 green:254/255.0 blue:254/255.0 alpha:1];
}

- (IBAction)adjustFrequence:(id)sender {
    UISlider *slider = (UISlider *)sender;
    float frequence = 80+slider.value*40;
    self.numberOfChannel.text = [NSString stringWithFormat:@"%.1fFM",frequence];
    int dec = (int)((frequence - (int)frequence)*10);
    NSData *data=[[DeviceInfo defaultManager] switchFMProgram:(int)frequence dec:dec deviceID:self.deviceid];
    SocketManager *sock=[SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
}

- (IBAction)control:(id)sender {
    UIButton *btn = (UIButton *)sender;
    NSData *data;
    SocketManager *sock=[SocketManager defaultManager];
    switch (btn.tag) {
        case 0:
            data = [[DeviceInfo defaultManager] previous:self.deviceid];
            break;
        case 1:
            btn.selected = !btn.selected;
            if (btn.selected) {
                data = [[DeviceInfo defaultManager] open:self.deviceid];
            }else{
                data = [[DeviceInfo defaultManager] close:self.deviceid];
            }
            break;
        case 2:
            data = [[DeviceInfo defaultManager] next:self.deviceid];
            break;
        default:
            break;
    }
    [sock.socket writeData:data withTimeout:1 tag:1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//设置pageController
-(void)setUpPageController
{
    self.pageController.numberOfPages = [self.collectionView numberOfItemsInSection:0] / 4;
    self.pageController.pageIndicatorTintColor = [UIColor whiteColor];
    self.pageController.currentPageIndicatorTintColor = [UIColor blackColor];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGPoint point = scrollView.contentOffset;
    self.pageController.currentPage = round(point.x/scrollView.bounds.size.width);
}

#pragma mark - UICollectionDelegate

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if(self.allFavouriteChannels.count % 4 == 0)
    {
        return self.allFavouriteChannels.count;
    }else{
        int i = 4 - self.allFavouriteChannels.count % 4;
        return self.allFavouriteChannels.count + i;
        
    };
    
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FMCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"collectionCell" forIndexPath:indexPath];
    
    cell.delegate = self;
    [cell hiddenBtns];
    if(indexPath.row > self.allFavouriteChannels.count - 1 )
    {
        cell.chanelNum.text = nil;
        cell.channelName.text = nil;
        cell.userInteractionEnabled = NO;
    }else{
        TVChannel *channel = self.allFavouriteChannels[indexPath.row];
        cell.chanelNum.text = [NSString stringWithFormat:@"%ld",(long)channel.channel_id];
        cell.channelName.text = [NSString stringWithFormat:@"%@",channel.channel_name];
        [cell useLongPressGesture];
    }
    
    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    FMCollectionViewCell *cell =(FMCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    [cell hiddenBtns];
    [cell useLongPressGesture];
}


#pragma mark - -(void)unUseLongPressGesture
//删除FM频道
-(void)FmDeleteAction:(FMCollectionViewCell *)cell
{
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    self.cell = cell;
    
    TVChannel *channel = [self.allFavouriteChannels objectAtIndex: indexPath.row];
    //发送删除频道请求
    NSString *url = [NSString stringWithFormat:@"%@Cloud/store_fm.aspx",[IOManager httpAddr]];
    NSString *authorToken = [UD objectForKey:@"AuthorToken"];
    NSDictionary *dic = @{
                          @"token":authorToken,
                          @"optype":@(1),
                          @"chid":@(channel.channel_id)
                          };
    HttpManager *http = [HttpManager defaultManager];
    http.delegate = self;
    http.tag = 2;
    [http sendPost:url param:dic];
    
}

-(void)FmEditAction:(FMCollectionViewCell *)cell
{
    self.coverView.hidden = NO;
    self.editView.hidden = NO;
    self.channelNameEdit.text = cell.channelName.text;
    self.channelIDEdit.text = cell.chanelNum.text;
    
}
//编辑FM频道
- (IBAction)cancelEdit:(id)sender {
    self.coverView.hidden = YES;
    self.editView.hidden = YES;
}
- (IBAction)sureEdit:(id)sender {
    
    [self sendStoreChannelRequest];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    id theSegue = segue.destinationViewController;
    [theSegue setValue:self.deviceid forKey:@"deviceid"];
}

-(void)changeVolume
{
    NSData *data=[[DeviceInfo defaultManager] changeVolume:self.volume.value*100 deviceID:self.deviceid];
    SocketManager *sock=[SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
}

-(IBAction)save:(id)sender
{
    self.voiceValue.text = [NSString stringWithFormat:@"%d%%",(int)self.volume.value];
    
    Radio *device=[[Radio alloc] init];
    [device setDeviceID:6];
    [device setRvolume:self.volume.value*100];
    [device setChannel:[self.numberOfChannel.text floatValue]];
    
    [_scene setSceneID:[self.sceneid intValue]];
    [_scene setRoomID:self.roomID];
    [_scene setMasterID:[[DeviceInfo defaultManager] masterID]];
    
    [_scene setReadonly:NO];
    
    NSArray *devices=[[SceneManager defaultManager] addDevice2Scene:_scene withDeivce:device withId:device.deviceID];
    [_scene setDevices:devices];
    
    [[SceneManager defaultManager] addScene:_scene withName:nil withImage:[UIImage imageNamed:@""]];
    
}
//收藏当前频道
- (IBAction)storeFMChannel:(id)sender {
    self.editView.hidden = NO;
    self.channelIDEdit.text = self.numberOfChannel.text;
    
}
-(void)sendStoreChannelRequest
{
    
    NSString *url = [NSString stringWithFormat:@"%@Cloud/store_fm.aspx",[IOManager httpAddr]];
    NSString *authorToken = [UD objectForKey:@"AuthorToken"];
    NSDictionary *dic = @{
                          @"token":authorToken,
                          @"eqid":self.deviceid,
                          @"optype":@(0),
                          @"cnumber":self.numberOfChannel.text,
                          @"cname":self.channelNameEdit.text,
                          @"imgname":@"store",
                          @"imgdata":@""
                          };
    HttpManager *http = [HttpManager defaultManager];
    http.delegate = self;
    http.tag = 1;
    [http sendPost:url param:dic];    
}

-(void) httpHandler:(id) responseObject tag:(int)tag
{
    if(tag == 1)
    {
        if([responseObject[@"result"] intValue] == 0)
        {
            //保存成功后存到数据库
            BOOL saveSucceed = [self writeFMChannelsConfigDataToSQL:responseObject withParent:@"FM"];
            
            if (saveSucceed) {
                [MBProgressHUD showSuccess:@"收藏成功"];
            }else {
                [MBProgressHUD showError:@"收藏失败"];
            }
            
            self.editView.hidden = YES;
            self.unstoreLabel.hidden = YES;
            self.collectionView.backgroundColor = [UIColor lightGrayColor];
            self.allFavouriteChannels = [SQLManager getAllChannelForFavoritedForType:@"FM" deviceID:[self.deviceid intValue]];
            [self.collectionView reloadData];
        }else{
            [MBProgressHUD showError:responseObject[@"msg"]];
        }

    }else if(tag == 2)
    {
        if([responseObject[@"result"] intValue] == 0)
        {
            NSIndexPath *indexPath = [self.collectionView indexPathForCell:self.cell];
            TVChannel *channel = self.allFavouriteChannels[indexPath.row];
            BOOL isSuccess = [SQLManager deleteChannelForChannelID:channel.channel_id];
            if(!isSuccess)
            {
                [MBProgressHUD showError:@"删除失败，请稍后再试"];
                return;
            }
            [self.allFavouriteChannels removeObject:channel];
            if(self.allFavouriteChannels.count == 0 || self.allFavouriteChannels == nil)
            {
                self.unstoreLabel.hidden = NO;
                self.collectionView.backgroundColor = [UIColor whiteColor];

            }
            [self.collectionView reloadData];
            
        }else{
            [MBProgressHUD showError:responseObject[@"msg"]];
        }

    }
}



-(BOOL)writeFMChannelsConfigDataToSQL:(NSDictionary *)responseObject withParent:(NSString *)parent
{
    BOOL result = NO;
    
    FMDatabase *db = [SQLManager connetdb];
    if([db open])
    {
        int cNumber = [self.numberOfChannel.text intValue];

        NSString *sql = [NSString stringWithFormat:@"insert into Channels values(%d,%d,%d,%d,'%@','%@','%@',%d,'%@','%@')",[responseObject[@"fmId"] intValue],[self.deviceid intValue],0,cNumber,self.channelNameEdit.text,responseObject[@"imgUrl"],parent,1,self.eNumber, [NSString stringWithFormat:@"%ld", [[DeviceInfo defaultManager] masterID]]];
        
        result = [db executeUpdate:sql];
        

        if(result)
        {
            NSLog(@"FM频道信息 入库成功");
        }else{
            NSLog(@"FM频道信息 入库失败");
        }
    }
    [db close];
    
    
    return result;
}
#pragma mark - TCP recv delegate
-(void)recv:(NSData *)data withTag:(long)tag
{
    Proto proto=protocolFromData(data);
    
    if (CFSwapInt16BigToHost(proto.masterID) != [[DeviceInfo defaultManager] masterID]) {
        return;
    }
    
    if (proto.cmd==0x01) {
        NSString *devID=[SQLManager getDeviceIDByENumber:CFSwapInt16BigToHost(proto.deviceID)];
        if ([devID intValue]==[self.deviceid intValue]) {
            if (proto.action.state == PROTOCOL_VOLUME) {
                self.volume.value=proto.action.RValue/100.0;
            }
        }
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"volume"])
    {
        DeviceInfo *device=[DeviceInfo defaultManager];
        self.volume.value=[[device valueForKey:@"volume"] floatValue]*100;

    }
}

-(void)dealloc
{
    DeviceInfo *device=[DeviceInfo defaultManager];
    [device removeObserver:self forKeyPath:@"volume" context:nil];
}


@end
