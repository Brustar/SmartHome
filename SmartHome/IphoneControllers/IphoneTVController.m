//
//  IphoneTVController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/9/23.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "IphoneTVController.h"
#import "IphoneRoomView.h"

#import "TVChannel.h"
#import "TVLogoCell.h"
#import "UIImageView+WebCache.h"
#import "SQLManager.h"
#import "MBProgressHUD+NJ.h"
#import "HttpManager.h"
#import "IphoneAddTVChannelController.h"
#import "TVIconController.h"
#import "VolumeManager.h"
#import "SceneManager.h"
#import "SocketManager.h"
#import "SCWaveAnimationView.h"
#import "PackManager.h"

@interface UIImagePickerController (LandScapeImagePicker)

- (UIStatusBarStyle)preferredStatusBarStyle;
- (NSUInteger)supportedInterfaceOrientations;
- (BOOL)prefersStatusBarHidden;
@end

@implementation UIImagePickerController (LandScapeImagePicker)

- (NSUInteger) supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        return UIInterfaceOrientationMaskLandscape;
    else
        return UIInterfaceOrientationMaskPortrait;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

@end

@interface IphoneTVController ()<UICollectionViewDelegate,UICollectionViewDataSource,TVLogoCellDelegate,UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UISlider *volumeSlider;
@property (weak, nonatomic) IBOutlet UIImageView *voiceStrongImg;

@property (weak, nonatomic) IBOutlet UIImageView *voiceWeakImg;

@property (weak, nonatomic) IBOutlet UIButton *lastBtn;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;

@property (nonatomic,strong) NSMutableArray *allFavourTVChannels;
@property (weak, nonatomic) IBOutlet UICollectionView *tvLogoCollectionView;

@property (weak, nonatomic) IBOutlet UIView *touchpad;


@property (nonatomic,strong) TVLogoCell *cell;

@end

@implementation IphoneTVController
{
    IphoneAddTVChannelController * iphoneVC;

}
-(NSMutableArray*)allFavourTVChannels
{
    if(!_allFavourTVChannels)
    {
        _allFavourTVChannels = [NSMutableArray array];
        _allFavourTVChannels = [SQLManager getAllChannelForFavoritedForType:@"TV" deviceID:[self.deviceid intValue]];
        if(_allFavourTVChannels == nil || _allFavourTVChannels.count == 0)
        {
            self.tvLogoCollectionView.backgroundColor = [UIColor lightGrayColor];
        }
    }
    return _allFavourTVChannels;
}
-(void)setRoomID:(int)roomID
{
    _roomID = roomID;
    if(roomID){
        self.deviceid = [SQLManager deviceIDWithRoomID:self.roomID withType:@"网络电视"];
        if(self.sceneid > 0)
        {
            NSArray *tvArr = [SQLManager getDeviceIDsBySeneId:[self.sceneid intValue]];
            for(int i = 0; i <tvArr.count; i++)
            {
                NSString *typeName = [SQLManager deviceTypeNameByDeviceID:[tvArr[i] intValue]];
                if([typeName isEqualToString:@"网络电视"])
                {
                    self.deviceid = tvArr[i];
                }
            }
            
        }
        
    }
  
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"电视";
    iphoneVC.eNumber = [SQLManager getENumber:[self.deviceid intValue]];
    
    self.volumeSlider.transform = CGAffineTransformMakeRotation(M_PI/2);
    self.voiceWeakImg.transform = CGAffineTransformMakeRotation(M_PI/2);
    self.voiceStrongImg.transform = CGAffineTransformMakeRotation(M_PI/2);
    self.tvLogoCollectionView.bounces = NO;
    self.volumeSlider.continuous = NO;
    [self.volumeSlider addTarget:self action:@selector(Iphonesave:) forControlEvents:UIControlEventValueChanged];
    
    DeviceInfo *device=[DeviceInfo defaultManager];
    [device addObserver:self forKeyPath:@"volume" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
    VolumeManager *volume=[VolumeManager defaultManager];
    [volume start];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    _scene=[[SceneManager defaultManager] readSceneByID:[self.sceneid intValue]];
    if ([self.sceneid intValue]>0) {
        for(int i=0;i<[_scene.devices count];i++)
        {
            if ([[_scene.devices objectAtIndex:i] isKindOfClass:[TV class]]) {
                self.volumeSlider.value=((TV *)[_scene.devices objectAtIndex:i]).volume/100.0;
            }
        }
    }
    
    UISwipeGestureRecognizer *recognizer;
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(IphonehandleSwipeFrom:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [[self touchpad] addGestureRecognizer:recognizer];
    
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(IphonehandleSwipeFrom:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [[self touchpad] addGestureRecognizer:recognizer];
    
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(IphonehandleSwipeFrom:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionUp)];
    [[self touchpad] addGestureRecognizer:recognizer];
    
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(IphonehandleSwipeFrom:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionDown)];
    [[self touchpad] addGestureRecognizer:recognizer];
    
    SocketManager *sock=[SocketManager defaultManager];
    sock.delegate=self;
    
}

- (void)IphonehandleSwipeFrom:(UISwipeGestureRecognizer *)recognizer{
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


-(IBAction)Iphonesave:(id)sender
{
    if ([sender isEqual:self.volumeSlider]) {
        NSData *data=[[DeviceInfo defaultManager] changeVolume:self.volumeSlider.value*100 deviceID:self.deviceid];
//        self.voiceValue.text = [NSString stringWithFormat:@"%d%%",(int)self.volume.value];
        SocketManager *sock=[SocketManager defaultManager];
        [sock.socket writeData:data withTimeout:1 tag:1];
    }
    
    TV *device=[[TV alloc] init];
    [device setDeviceID:[self.deviceid intValue]];
    [device setVolume:self.volumeSlider.value*100];
    
    
    [_scene setSceneID:[self.sceneid intValue]];
    [_scene setRoomID:self.roomID];
    [_scene setMasterID:[[DeviceInfo defaultManager] masterID]];
    
    [_scene setReadonly:NO];
    
    NSArray *devices=[[SceneManager defaultManager] addDevice2Scene:_scene withDeivce:device withId:device.deviceID];
    [_scene setDevices:devices];
    
    [[SceneManager defaultManager] addScene:_scene withName:nil withImage:[UIImage imageNamed:@""]];
    
}

#pragma mark - TCP recv delegate
-(void)recv:(NSData *)data withTag:(long)tag
{
    Proto proto=protocolFromData(data);
    
    if (CFSwapInt16BigToHost(proto.masterID) != [[DeviceInfo defaultManager] masterID]) {
        return;
    }
    
    
    if (tag==0) {
        if (proto.action.state == PROTOCOL_VOLUME_UP || proto.action.state == PROTOCOL_VOLUME_DOWN || proto.action.state == PROTOCOL_MUTE) {
            self.volumeSlider.value=proto.action.RValue/100.0;
        }
    }
}

#pragma mark - Navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    if([segue.identifier isEqualToString:@"detailSegue"])
//    {
//        id theSegue = segue.destinationViewController;
//        [theSegue setValue:@"1" forKey:@"deviceid"];
//    }else{
//        TVIconController *iconVC = segue.destinationViewController;
//        iconVC.delegate = self;
//    }
//    
//}

- (IBAction)domute:(id)sender
{
    self.volumeSlider.value=0.0;
    
    NSData *data=[[DeviceInfo defaultManager] mute:self.deviceid];
    SocketManager *sock=[SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"volume"])
    {
        DeviceInfo *device=[DeviceInfo defaultManager];
        self.volumeSlider.value=[[device valueForKey:@"volume"] floatValue]*100;
        /*
         KEVolumeUtil *volumeManager=[KEVolumeUtil shareInstance];
         NSData *data=nil;
         if (volumeManager.willup) {
         data = [device volumeUp:self.deviceid];
         }else{
         data = [device volumeDown:self.deviceid];
         }
         
         SocketManager *sock=[SocketManager defaultManager];
         [sock.socket writeData:data withTimeout:1 tag:1];
         */
//        [self save:nil];
        [self Iphonesave:nil];
    }
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.allFavourTVChannels.count;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TVLogoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TVLogoCell" forIndexPath:indexPath];
    TVChannel *channel = self.allFavourTVChannels[indexPath.row];
    cell.delegate = self;
    [cell hiddenEditBtnAndDeleteBtn];
    cell.label.text = channel.channel_name;
    if (channel) {
        [cell.imgView sd_setImageWithURL:[NSURL URLWithString:channel.channel_pic] placeholderImage:[UIImage imageNamed:@"placeholder"]];
        [cell useLongPressGesture];
    }
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == self.tvLogoCollectionView) {
        TVLogoCell *cell =(TVLogoCell*)[collectionView cellForItemAtIndexPath:indexPath];
        [cell hiddenEditBtnAndDeleteBtn];
        [cell useLongPressGesture];
        
        
        int channelValue=(int)[[self.allFavourTVChannels objectAtIndex:indexPath.row] channel_number];
        NSData *data=[[DeviceInfo defaultManager] switchProgram:channelValue deviceID:self.deviceid];
        SocketManager *sock=[SocketManager defaultManager];
        [sock.socket writeData:data withTimeout:1 tag:1];
    }
   

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
    http.tag = 1;
    [http sendPost:url param:dic];
    
    
}


-(void)tvEditAction:(TVLogoCell *)cell
{
    NSIndexPath *indexPath = [self.tvLogoCollectionView indexPathForCell:cell];
    TVChannel *channel = self.allFavourTVChannels[indexPath.row];
    [iphoneVC.addBtn setBackgroundImage:cell.imgView.image forState:UIControlStateNormal];
    iphoneVC.channelName.text = channel.channel_name;
    iphoneVC.channelNumber.text = [NSString stringWithFormat:@"%ld",(long)channel.channel_number];
  
}


-(void) httpHandler:(id) responseObject tag:(int)tag
{
    if(tag == 1)
    {
        if([responseObject[@"Result"] intValue] == 0)
        {
            NSIndexPath *indexPath = [self.tvLogoCollectionView indexPathForCell:self.cell];
            TVChannel *channel = self.allFavourTVChannels[indexPath.row];
            
            //从数据库中删除数据
            BOOL isSuccess = [SQLManager deleteChannelForChannelID:channel.channel_id];
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
- (IBAction)lastBtn:(id)sender {
    SocketManager *sock = [SocketManager defaultManager];
    DeviceInfo *device=[DeviceInfo defaultManager];
    NSData *data=[device forward:self.deviceid];
    [sock.socket writeData:data withTimeout:-1 tag:1];
}
- (IBAction)nextBtn:(id)sender {
    SocketManager *sock = [SocketManager defaultManager];
    DeviceInfo *device=[DeviceInfo defaultManager];
    NSData *data=[device next:self.deviceid];
    [sock.socket writeData:data withTimeout:-1 tag:1];
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


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    iphoneVC = segue.destinationViewController;
    iphoneVC.deviceid = self.deviceid;
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
