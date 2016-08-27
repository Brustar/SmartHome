//
//  TVController.m
//  SmartHome
//
//  Created by Brustar on 16/6/7.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "TVController.h"
#import "TV.h"
#import "SceneManager.h"
#import "TVChannel.h"
#import "DVCollectionViewCell.h"
#import "TVLogoCell.h"
#import "MBProgressHUD+NJ.h"
#import "KxMenu.h"
#import "VolumeManager.h"
#import "SCWaveAnimationView.h"
#import "ProtocolManager.h"
#import "SocketManager.h"
#import "DeviceManager.h"
#import "HttpManager.h"
#import "ChannelManager.h"
#import "MBProgressHUD+NJ.h"
#import "PackManager.h"
#import "ChannelManager.h"

@interface TVController ()<UIScrollViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,TVLogoCellDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIView *touchpad;
@property (weak, nonatomic) IBOutlet UILabel *unstoreLabel;


@property (weak, nonatomic) IBOutlet UISlider *volume;
@property (weak, nonatomic) IBOutlet UIPageControl *pageController;

@property (weak, nonatomic) IBOutlet UICollectionView *tvLogoCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *numbersCollectionView;

@property (nonatomic,strong) NSArray *btnTitles;

@property (nonatomic,strong) NSMutableArray *allFavourTVChannels;
@property (nonatomic,strong) TVLogoCell *cell;

//编辑电视属性
@property (weak, nonatomic) IBOutlet UITextField *channelName;
@property (weak, nonatomic) IBOutlet UITextField *channeNumber;
@property (weak, nonatomic) IBOutlet UIView *editView;
@property (weak, nonatomic) IBOutlet UIView *coverView;
@property (weak, nonatomic) IBOutlet UIButton *editChannelImgBtn;
@property (nonatomic,strong) NSString *eNumber;
@property (nonatomic,strong) UIImage *chooseImg;
- (IBAction)editChannelImgBtn:(UIButton *)sender;

@end

@implementation TVController

-(NSArray *)btnTitles
{
    if(!_btnTitles)   
    {
        _btnTitles = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"0"];
    }
    return _btnTitles;
    
    
    
}
-(NSMutableArray*)allFavourTVChannels
{
    if(!_allFavourTVChannels)
    {
        _allFavourTVChannels = [NSMutableArray array];
        _allFavourTVChannels = [ChannelManager getAllChannelForFavoritedForType:@"TV"];
        if(_allFavourTVChannels == nil || _allFavourTVChannels.count == 0)
        {
            self.unstoreLabel.hidden = NO;
            self.tvLogoCollectionView.backgroundColor = [UIColor whiteColor];
        }
    }
    return _allFavourTVChannels;
}
- (void)setRoomID:(int)roomID
{
    _roomID = roomID;
    
    self.deviceid = [DeviceManager deviceIDWithRoomID:self.roomID withType:@"网络电视"];
    //self.deviceid = [DeviceManager getDeviceByTypeName:@"TV" andRoomID:self.roomID];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"电视";
     self.eNumber = [DeviceManager getENumber:[self.deviceid intValue]];
    self.volume.continuous = NO;
    [self.volume addTarget:self action:@selector(save:) forControlEvents:UIControlEventValueChanged];
    
    
    DeviceInfo *device=[DeviceInfo defaultManager];
    [device addObserver:self forKeyPath:@"volume" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
    VolumeManager *volume=[VolumeManager defaultManager];
    [volume start:device];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    if ([self.sceneid intValue]>0) {
        
        Scene *scene=[[SceneManager defaultManager] readSceneByID:[self.sceneid intValue]];
        for(int i=0;i<[scene.devices count];i++)
        {
            if ([[scene.devices objectAtIndex:i] isKindOfClass:[TV class]]) {
                self.volume.value=((TV *)[scene.devices objectAtIndex:i]).volume/100.0;
            }
        }
    }
    [self setUpPageController];
    
    UISwipeGestureRecognizer *recognizer;
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [[self touchpad] addGestureRecognizer:recognizer];
    
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [[self touchpad] addGestureRecognizer:recognizer];
    
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionUp)];
    [[self touchpad] addGestureRecognizer:recognizer];
    
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionDown)];
    [[self touchpad] addGestureRecognizer:recognizer];
    
    NSData *data=[[DeviceInfo defaultManager] open:self.deviceid];
    SocketManager *sock=[SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
    
    sock.delegate=self;
}

- (void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer{
    NSData *data=nil;
    switch (recognizer.direction) {
        case UISwipeGestureRecognizerDirectionLeft:
            data=[[DeviceInfo defaultManager] sweepLeft:self.deviceid];
            NSLog(@"Left");
            break;
        case UISwipeGestureRecognizerDirectionRight:
            data=[[DeviceInfo defaultManager] sweepRight:self.deviceid];
            NSLog(@"right");
            break;
        case UISwipeGestureRecognizerDirectionUp:
            data=[[DeviceInfo defaultManager] sweepUp:self.deviceid];
            NSLog(@"up");
            break;
        case UISwipeGestureRecognizerDirectionDown:
            data=[[DeviceInfo defaultManager] sweepDown:self.deviceid];
            NSLog(@"down");
            break;
            
        default:
            break;
    }
    
    SocketManager *sock=[SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
    
    [SCWaveAnimationView waveAnimationAtDirection:recognizer.direction view:self.touchpad];
}


-(IBAction)save:(id)sender
{
    NSData *data=[[DeviceInfo defaultManager] changeVolume:self.volume.value*100 deviceID:self.deviceid];
    SocketManager *sock=[SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
    
    TV *device=[[TV alloc] init];
    [device setDeviceID:[self.deviceid intValue]];
    [device setVolume:self.volume.value*100];
    
    Scene *scene=[[Scene alloc] init];
    [scene setSceneID:[self.sceneid intValue]];
    [scene setRoomID:4];
    [scene setHouseID:3];
    [scene setPicID:66];
    [scene setReadonly:NO];
    
    NSArray *devices=[[SceneManager defaultManager] addDevice2Scene:scene withDeivce:device withId:device.deviceID];
    [scene setDevices:devices];
    
    [scene setStartTime:@""];
    [scene setWeekValue:@""];
    [scene setAstronomicalTime:@""];
    [scene setWeekRepeat:0];
    [scene setRoomName:@""];
    [scene setSceneName:@""];
    
    [[SceneManager defaultManager] addScenen:scene withName:nil withPic:@""];
    
}

#pragma mark - TCP recv delegate
-(void)recv:(NSData *)data withTag:(long)tag
{
    Proto proto=protocolFromData(data);
    if (tag==0) {
        if (proto.action.state == 0x02 || proto.action.state == 0x03 || proto.action.state == 0x04) {
            self.volume.value=proto.action.RValue/100.0;
        }
    }
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
   
    id theSegue = segue.destinationViewController;
    [theSegue setValue:@"1" forKey:@"deviceid"];
}


- (IBAction)domute:(id)sender
{
    self.volume.value=0.0;
    
    NSData *data=[[DeviceInfo defaultManager] mute:self.deviceid];
    SocketManager *sock=[SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
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

//设置pageController
-(void)setUpPageController
{
    self.pageController.numberOfPages = [self.tvLogoCollectionView numberOfItemsInSection:0] / 4;
    self.pageController.pageIndicatorTintColor = [UIColor whiteColor];
    self.pageController.currentPageIndicatorTintColor = [UIColor blackColor];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGPoint point = scrollView.contentOffset;
    self.pageController.currentPage = round(point.x/scrollView.bounds.size.width);
}

#pragma mark - UICollectionViewDelgate
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if(collectionView == self.tvLogoCollectionView)
    {
        if(self.allFavourTVChannels.count % 4 == 0)
        {
            return self.allFavourTVChannels.count;
        }else{
            int i = 4 - self.allFavourTVChannels.count % 4;
            return  self.allFavourTVChannels.count + i;
        }
       
    }
    return self.btnTitles.count + 1;
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(collectionView  == self.tvLogoCollectionView)
    {
        TVLogoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"tvLogoCell" forIndexPath:indexPath];
        cell.delegate = self;
        [cell hiddenEditBtnAndDeleteBtn];
        if(indexPath.row > self.allFavourTVChannels.count -1)
        {
            cell.label.text = @"";
            cell.imgView.image = nil;
            cell.userInteractionEnabled = NO;
        }else{
            TVChannel *channel = self.allFavourTVChannels[indexPath.row];
            cell.imgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@",channel.channel_pic]];
            cell.label.text = channel.channel_name;
            
            [cell useLongPressGesture];
        }
        
        
        return cell;
    }
    DVCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"collectionCell" forIndexPath:indexPath];
    if(indexPath.row == self.btnTitles.count)
    {
        [cell.btn setImage:[UIImage imageNamed:@"quiet"] forState:UIControlStateNormal];
        [cell.btn addTarget:self action:@selector(domute:) forControlEvents:UIControlEventTouchUpInside];
        
    }else{
        [cell.btn setTitle:[NSString stringWithFormat:@"%@",self.btnTitles[indexPath.row]] forState:UIControlStateNormal];
        [cell.btn addTarget:self action:@selector(btntouched:) forControlEvents:UIControlEventTouchUpInside];
    }
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(collectionView == self.tvLogoCollectionView)
    {
        TVLogoCell *cell =(TVLogoCell*)[collectionView cellForItemAtIndexPath:indexPath];
        [cell hiddenEditBtnAndDeleteBtn];
        [cell useLongPressGesture];
        
        int channelValue=(int)[[self.allFavourTVChannels objectAtIndex:indexPath.row] channel_number];
        NSData *data=[[DeviceInfo defaultManager] switchProgram:channelValue deviceID:self.deviceid];
        SocketManager *sock=[SocketManager defaultManager];
        [sock.socket writeData:data withTimeout:1 tag:1];
    }

}

-(IBAction)btntouched:(id)sender
{
    UIButton *button=(UIButton *)sender;
    if ([self.timer isValid]) {
        self.retChannel = self.retChannel*10+[button.titleLabel.text intValue];
        NSLog(@"%d",self.retChannel);
        NSData *data=[[DeviceInfo defaultManager] switchProgram:self.retChannel deviceID:self.deviceid];
        SocketManager *sock=[SocketManager defaultManager];
        [sock.socket writeData:data withTimeout:1 tag:1];
    }else{
        button.backgroundColor = [UIColor grayColor];
        self.timer=[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(changecolor) userInfo:sender repeats:NO];
        self.retChannel=[button.titleLabel.text intValue];
    }
}

-(void)changecolor
{
    UIButton *button=[self.timer userInfo];
    button.backgroundColor = [UIColor clearColor];
    if (self.retChannel<10) {
        self.retChannel=[button.titleLabel.text intValue];
        NSLog(@"%d",self.retChannel);
        NSData *data=[[DeviceInfo defaultManager] switchProgram:self.retChannel deviceID:self.deviceid];
        SocketManager *sock=[SocketManager defaultManager];
        [sock.socket writeData:data withTimeout:1 tag:1];
    }
    [self.timer invalidate];
}

#pragma mark - TVLogoCellDelegate
-(void)tvDeleteAction:(TVLogoCell *)cell
{
    self.cell = cell;
    NSIndexPath *indexPath = [self.tvLogoCollectionView indexPathForCell:cell];
    TVChannel *channel = self.allFavourTVChannels[indexPath.row];
    
    //发送删除频道请求
    NSString *url = [NSString stringWithFormat:@"%@TVChannelRemove.aspx",[IOManager httpAddr]];
    NSString *authorToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"];
    NSDictionary *dic = @{@"AuthorToken":authorToken,@"RecordID":[NSNumber numberWithInteger:channel.channel_id]};
    HttpManager *http = [HttpManager defaultManager];
    http.delegate = self;
    http.tag = 2;
    [http sendPost:url param:dic];
   
    
}
-(void)tvEditAction:(TVLogoCell *)cell
{
    NSIndexPath *indexPath = [self.tvLogoCollectionView indexPathForCell:cell];
    TVChannel *channel = self.allFavourTVChannels[indexPath.row];
    [self.editChannelImgBtn setBackgroundImage:cell.imgView.image forState:UIControlStateNormal];
    self.channelName.text = channel.channel_name;
    self.channeNumber.text = [NSString stringWithFormat:@"%ld",channel.channel_number];
    [self showCoverView];
}

-(void)showCoverView
{
    self.coverView.hidden = NO;
    self.editView.hidden = NO;
}

-(void)hiddenCoverView{
    self.coverView.hidden = YES;
    self.editView.hidden = YES;
}

#pragma mark - 编辑电视频道
//编辑完成后保存频道
- (IBAction)clickSureBtnAfterEdited:(id)sender

{
   
    [self sendStoreChannelRequest];
    
}

-(void)sendStoreChannelRequest
{
    NSString *url = [NSString stringWithFormat:@"%@TVChannelUpload.aspx",[IOManager httpAddr]];
    NSString *authorToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"];
    NSDictionary *dic = @{@"AuthorToken":authorToken,@"EID":self.deviceid,@"Cnumber":self.channeNumber.text,@"CName":self.channelName.text,@"ImgFileName":@"store",@"ImgFile":@""};
    HttpManager *http = [HttpManager defaultManager];
    http.delegate = self;
    http.tag = 1;
    [http sendPost:url param:dic];
    
    [self hiddenCoverView];
}
-(void) httpHandler:(id) responseObject tag:(int)tag
{
    if(tag == 1)
    {
        if([responseObject[@"Result"] intValue] == 0)
        {
            //保存成功后存到数据库
            [self writeTVChannelsConfigDataToSQL:responseObject withParent:@"TV"];
            self.allFavourTVChannels = [ChannelManager getAllChannelForFavoritedForType:@"TV"];
            self.unstoreLabel.hidden = YES;
            self.tvLogoCollectionView.backgroundColor = [UIColor lightGrayColor];
            [self.tvLogoCollectionView reloadData];
            
            
        }else{
            [MBProgressHUD showError:@"Msg"];
        }
    }else if(tag == 2)
    {
        if([responseObject[@"Result"] intValue] == 0)
        {
            //从数据库中删除数据
            NSIndexPath *indexPath = [self.tvLogoCollectionView indexPathForCell:self.cell];
            TVChannel *channel = self.allFavourTVChannels[indexPath.row];
            BOOL isSuccess = [ChannelManager deleteChannelForChannelID:channel.channel_id];
            if(!isSuccess)
            {
                [MBProgressHUD showError:@"删除失败，请稍后再试"];
                return;
            }
            [self.allFavourTVChannels removeObject:channel];
            [self.tvLogoCollectionView reloadData];
            
        }else{
            [MBProgressHUD showError:responseObject[@"Msg"]];
        }
    }
}

-(void)writeTVChannelsConfigDataToSQL:(NSDictionary *)responseObject withParent:(NSString *)parent
{
    NSString *dbPath = [[IOManager sqlitePath] stringByAppendingPathComponent:@"smartDB"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    if([db open])
    {
        int cNumber = [self.channeNumber.text intValue];
        NSString *sql = [NSString stringWithFormat:@"insert into Channels values(%d,%d,%d,'%@','%@','%@',%d,'%@')",[responseObject[@"cId"] intValue],[self.deviceid intValue],cNumber,self.channelName.text,self.chooseImg,parent,1,self.eNumber];
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

- (IBAction)cancelEdit:(id)sender
{
    [self hiddenCoverView];
}

- (IBAction)editChannelImgBtn:(UIButton *)sender
{
    UIButton *btn = sender;
    UIView *view = btn.superview;
    CGFloat y = view.frame.origin.y -(view.frame.size.width - btn.frame.size.width);
    [KxMenu showMenuInView:self.view fromRect:CGRectMake(view.frame.origin.x, y , view.frame.size.width, view.frame.size.height) menuItems:@[
                                                                      [KxMenuItem menuItem:@"预置台标"
                                                                                     image:nil
                                                                                    target:self
                                                                                    action:@selector(preset:)],
                                                                      [KxMenuItem menuItem:@"本地图库"
                                                                                     image:nil
                                                                                    target:self
                                                                                    action:@selector(selectPhoto:)],
                                                                      [KxMenuItem menuItem:@"现在拍摄"
                                                                                     image:nil
                                                                                    target:self
                                                                                    action:@selector(takePhoto:)],
                                                                      ]];
}

-(void)preset:(KxMenuItem *)item{
    
}

- (void)selectPhoto:(KxMenuItem *)item {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)takePhoto:(KxMenuItem *)item {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    self.chooseImg = info[UIImagePickerControllerEditedImage];
    [self.editChannelImgBtn setBackgroundImage:self.chooseImg forState:UIControlStateNormal];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - touch detection
- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint touchPoint = [[touches anyObject] locationInView:[[UIApplication sharedApplication] keyWindow]];
    CGRect rect=[self.touchpad convertRect:self.touchpad.bounds toView:self.view];
    if (CGRectContainsPoint(rect,touchPoint)) {
        NSLog(@"%.0fx%.0fpx", touchPoint.x, touchPoint.y);
        [SCWaveAnimationView waveAnimationAtPosition:touchPoint];
    }
}

- (IBAction)storeTVChannel:(UIBarButtonItem *)sender {
//    self.channelName.text = nil;
//    self.channeNumber.text = nil;
    self.editView.hidden = NO;
//    [self sendStoreChannelRequest];
    
}


-(void)dealloc
{
    DeviceInfo *device=[DeviceInfo defaultManager];
    [device removeObserver:self forKeyPath:@"volume" context:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   
}

@end