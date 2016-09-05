//
//  FMController.m
//  SmartHome
//
//  Created by Brustar on 16/6/13.
//  Copyright © 2016年 Brustar. All rights reserved.
//
#import "FMController.h"
#import "FMCollectionViewCell.h"
#import "TVChannel.h"
#import "TXHRrettyRuler.h"
#import "SceneManager.h"
#import "MBProgressHUD+NJ.h"
#import "VolumeManager.h"
#import "SocketManager.h"
#import "DeviceManager.h"
#import "ChannelManager.h"
#import "HttpManager.h"

#import "PackManager.h"


@interface FMController ()<UICollectionViewDelegate,UICollectionViewDataSource,UIScrollViewDelegate,TXHRrettyRulerDelegate,UIGestureRecognizerDelegate,FMCollectionViewCellDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollerContentViewWidth;
@property (nonatomic,strong) NSMutableArray *allFavouriteChannels;

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

@property (nonatomic,strong) FMCollectionViewCell *cell;

@end

@implementation FMController

-(NSMutableArray *)allFavouriteChannels
{
    if(!_allFavouriteChannels)
    {
        _allFavouriteChannels = [NSMutableArray array];
        _allFavouriteChannels = [ChannelManager getAllChannelForFavoritedForType:@"FM"];
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
        self.deviceid = [DeviceManager deviceIDWithRoomID:self.roomID withType:@"FM"];
    }
    
    
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.hzLabel.transform = CGAffineTransformMakeRotation(M_PI/2 + M_PI);
    self.collectionView.pagingEnabled = YES;
    
    self.volume.continuous = NO;
    [self.volume addTarget:self action:@selector(save:) forControlEvents:UIControlEventValueChanged];
    
    self.eNumber = [DeviceManager getENumber:[self.deviceid intValue]];
    DeviceInfo *device=[DeviceInfo defaultManager];
    [device addObserver:self forKeyPath:@"volume" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
    VolumeManager *volume=[VolumeManager defaultManager];
    [volume start:device];
    // Do any additional setup after loading the view.
    if ([self.sceneid intValue]>0) {
        
        _scene=[[SceneManager defaultManager] readSceneByID:[self.sceneid intValue]];
        for(int i=0;i<[_scene.devices count];i++)
        {
            if ([[_scene.devices objectAtIndex:i] isKindOfClass:[Radio class]]) {
                self.volume.value=((Radio*)[_scene.devices objectAtIndex:i]).rvolume/100.0;
                self.numberOfChannel.text=  [NSString stringWithFormat:@"%.1f", ((Radio*)[_scene.devices objectAtIndex:i]).channel];
            }
        }
    }
    [self setUpPageController];
    
    [self setRuleForFMChannel];
    
    SocketManager *sock=[SocketManager defaultManager];
    sock.delegate=self;
}

-(void)setRuleForFMChannel
{
    CGFloat rule = [self.numberOfChannel.text floatValue];
    NSLog(@"\n\n\n\n\n rule = %f",rule);
    TXHRrettyRuler *ruler = [[TXHRrettyRuler alloc] initWithFrame:CGRectMake(30, 150, self.fmView.bounds.size.width - 30 * 2, 150)];
    ruler.rulerDelegate = self;
    [ruler showRulerScrollViewWithCount:205 average:[NSNumber numberWithFloat:0.1] currentValue:rule smallMode:NO];
    [self.fmView addSubview:ruler];

}

- (void)txhRrettyRuler:(TXHRulerScrollView *)rulerScrollView {
    self.numberOfChannel.text = [NSString stringWithFormat:@"%.1f",rulerScrollView.rulerValue];
    
  //  [self save:nil];
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
        cell.chanelNum.text = [NSString stringWithFormat:@"%ld",channel.channel_id];
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
    NSString *url = [NSString stringWithFormat:@"%@FMChannelRemove.aspx",[IOManager httpAddr]];
    NSString *authorToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"];
    NSDictionary *dic = @{@"AuthorToken":authorToken,@"RecordID":[NSNumber numberWithInteger:channel.channel_id]};
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

-(IBAction)save:(id)sender
{
    NSData *data=[[DeviceInfo defaultManager] changeVolume:self.volume.value*100 deviceID:self.deviceid];
    SocketManager *sock=[SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
    
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
    
    [[SceneManager defaultManager] addScene:_scene withName:nil withPic:@""];
    
}
//收藏当前频道
- (IBAction)storeFMChannel:(id)sender {
    self.editView.hidden = NO;
    self.channelIDEdit.text = self.numberOfChannel.text;
    
}
-(void)sendStoreChannelRequest
{
    
    NSString *url = [NSString stringWithFormat:@"%@FMChannelUpload.aspx",[IOManager httpAddr]];
    NSString *authorToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"];
    NSDictionary *dic = @{@"AuthorToken":authorToken,@"EID":self.deviceid,@"CNumber":self.numberOfChannel.text,@"CName":self.channelNameEdit.text,@"ImgFileName":@"store",@"ImgFile":@""};
    HttpManager *http = [HttpManager defaultManager];
    http.delegate = self;
    http.tag = 1;
    [http sendPost:url param:dic];

    
    
}
-(void) httpHandler:(id) responseObject tag:(int)tag
{
    if(tag == 1)
    {
        if([responseObject[@"Result"] intValue] == 0)
        {
            //保存成功后存到数据库
            [self writeFMChannelsConfigDataToSQL:responseObject withParent:@"FM"];
            self.editView.hidden = YES;
            self.unstoreLabel.hidden = YES;
            self.collectionView.backgroundColor = [UIColor lightGrayColor];
            self.allFavouriteChannels = [ChannelManager getAllChannelForFavoritedForType:@"FM"];
            [self.collectionView reloadData];
        }else{
            [MBProgressHUD showError:@"Msg"];
        }

    }else if(tag == 2)
    {
        if([responseObject[@"Result"] intValue] == 0)
        {
            NSIndexPath *indexPath = [self.collectionView indexPathForCell:self.cell];
            TVChannel *channel = self.allFavouriteChannels[indexPath.row];
            BOOL isSuccess = [ChannelManager deleteChannelForChannelID:channel.channel_id];
            if(!isSuccess)
            {
                [MBProgressHUD showError:@"删除失败，请稍后再试"];
                return;
            }
            [self.allFavouriteChannels removeObject:channel];
            [self.collectionView reloadData];
            
        }else{
            [MBProgressHUD showError:responseObject[@"Msg"]];
        }

    }
}



-(void)writeFMChannelsConfigDataToSQL:(NSDictionary *)responseObject withParent:(NSString *)parent
{
    NSString *dbPath = [[IOManager sqlitePath] stringByAppendingPathComponent:@"smartDB"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    if([db open])
    {
        int cNumber = [self.numberOfChannel.text intValue];
        NSString *sql = [NSString stringWithFormat:@"insert into Channels values(%d,%d,%d,'%@','%@','%@',%d,'%@')",[responseObject[@"fmId"] intValue],[self.deviceid intValue],cNumber,self.channelNameEdit.text,responseObject[@"imgUrl"],parent,1,self.eNumber];
        BOOL result = [db executeUpdate:sql];
        if(result)
        {
            NSLog(@"insert 成功");
        }else{
            NSLog(@"insert 失败");
        }
        
        
        
        
    }
    [db close];

}
#pragma mark - TCP recv delegate
-(void)recv:(NSData *)data withTag:(long)tag
{
    Proto proto=protocolFromData(data);
    
    if (proto.masterID != [[DeviceInfo defaultManager] masterID]) {
        return;
    }
    
    if (tag==0) {
        if (proto.action.state == PROTOCOL_VOLUME_UP || proto.action.state == PROTOCOL_VOLUME_DOWN || proto.action.state == PROTOCOL_MUTE) {
            self.volume.value=proto.action.RValue/100.0;
        }
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"volume"])
    {
        DeviceInfo *device=[DeviceInfo defaultManager];
        self.volume.value=[[device valueForKey:@"volume"] floatValue];
        [self save:nil];
    }
}

-(void)dealloc
{
    DeviceInfo *device=[DeviceInfo defaultManager];
    [device removeObserver:self forKeyPath:@"volume" context:nil];
}


@end
