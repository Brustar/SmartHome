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

@interface FMController ()<UICollectionViewDelegate,UICollectionViewDataSource,UIScrollViewDelegate,TXHRrettyRulerDelegate,UIGestureRecognizerDelegate,FMCollectionViewCellDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollerContentViewWidth;
@property (nonatomic,strong) NSMutableArray *allFavouriteChannels;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UILabel *numberOfChannel;
@property (weak, nonatomic) IBOutlet UIView *fmView;

@property (weak, nonatomic) IBOutlet UIView *coverView;

@property (weak, nonatomic) IBOutlet UITextField *channelNameEdit;
@property (weak, nonatomic) IBOutlet UITextField *channelIDEdit;

@property (weak, nonatomic) IBOutlet UIView *editView;
@property (weak, nonatomic) IBOutlet UILabel *hzLabel;
@property (weak, nonatomic) IBOutlet UIPageControl *pageController;

@end

@implementation FMController

-(NSMutableArray *)allFavouriteChannels
{
    if(!_allFavouriteChannels)
    {
        _allFavouriteChannels = [NSMutableArray array];
        _allFavouriteChannels = [TVChannel getAllChannelForFavoritedForType:@"FM"];
        
    }
    return _allFavouriteChannels;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.hzLabel.transform = CGAffineTransformMakeRotation(M_PI/2 + M_PI);
    self.collectionView.pagingEnabled = YES;
    
    self.volume.continuous = NO;
    [self.volume addTarget:self action:@selector(save:) forControlEvents:UIControlEventValueChanged];
    
    
    DeviceInfo *device=[DeviceInfo defaultManager];
    [device addObserver:self forKeyPath:@"volume" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
    VolumeManager *volume=[VolumeManager defaultManager];
    [volume start:device];
    // Do any additional setup after loading the view.
    if ([self.sceneid intValue]>0) {
        
        Scene *scene=[[SceneManager defaultManager] readSceneByID:[self.sceneid intValue]];
        for(int i=0;i<[scene.devices count];i++)
        {
            if ([[scene.devices objectAtIndex:i] isKindOfClass:[Radio class]]) {
                self.volume.value=((Radio*)[scene.devices objectAtIndex:i]).rvolume/100.0;
                self.numberOfChannel.text=  [NSString stringWithFormat:@"%.1f", ((Radio*)[scene.devices objectAtIndex:i]).channel];
            }
        }
    }
    [self setUpPageController];
    
    [self setRuleForFMChannel];
}

-(void)setRuleForFMChannel
{
    CGFloat rule = [self.numberOfChannel.text floatValue];
    NSLog(@"\n\n\n\n\n rule = %f",rule);
    TXHRrettyRuler *ruler = [[TXHRrettyRuler alloc] initWithFrame:CGRectMake(30, 150, self.fmView.bounds.size.width - 30 * 2, 150)];
    ruler.rulerDelegate = self;
    [ruler showRulerScrollViewWithCount:205 average:[NSNumber numberWithFloat:0.1] currentValue:rule smallMode:YES];
    [self.fmView addSubview:ruler];

}

//warning save 进来就执行
- (void)txhRrettyRuler:(TXHRulerScrollView *)rulerScrollView {
    self.numberOfChannel.text = [NSString stringWithFormat:@" %.1f",rulerScrollView.rulerValue];
    
    [self save:nil];
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
        //cell.backgroundColor = [UIColor lightGrayColor];
        [cell unUseLongPressGesture];
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
    [cell unUseLongPressGesture];
}


#pragma mark - -(void)unUseLongPressGesture
-(void)FmDeleteAction:(FMCollectionViewCell *)cell
{
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    TVChannel *channel = [self.allFavouriteChannels objectAtIndex: indexPath.row];
    BOOL isSuccess = [TVChannel deleteChannelForChannelID:channel.channel_id];
    if(!isSuccess)
    {
        [MBProgressHUD showError:@"删除失败，请稍后再试"];
    
        return;
    }
    
    [self.allFavouriteChannels removeObject:channel];
    [self.collectionView reloadData];
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
    BOOL isSuccess =[TVChannel upDateChannelForChannelID:[self.channelIDEdit.text intValue] andNewChannel_Name:self.channelNameEdit.text];
    if(!isSuccess)
    {
        [MBProgressHUD showError:@"编辑失败，请稍后再试"];
        
        return;
    }
    self.allFavouriteChannels = [TVChannel getAllChannelForFavoritedForType:@"FM"];
    [self cancelEdit:nil];
    [self.collectionView reloadData];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    id theSegue = segue.destinationViewController;
    [theSegue setValue:self.deviceid forKey:@"deviceid"];
}

-(IBAction)save:(id)sender
{
    NSData *data=[[DeviceInfo defaultManager] changeVolume:self.volume.value*100 deviceID:self.deviceid];
    SocketManager *sock=[SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
    [sock.socket readDataToData:[NSData dataWithBytes:"\xEA" length:1] withTimeout:1 tag:1];
    
    Radio *device=[[Radio alloc] init];
    [device setDeviceID:6];
    [device setRvolume:self.volume.value*100];
    [device setChannel:[self.numberOfChannel.text floatValue]];
    
    Scene *scene=[[Scene alloc] init];
    [scene setSceneID:2];
    [scene setRoomID:4];
    [scene setHouseID:3];
    [scene setPicID:66];
    [scene setReadonly:NO];
    
    NSArray *devices=[[SceneManager defaultManager] addDevice2Scene:scene withDeivce:device id:device.deviceID];
    [scene setDevices:devices];
    [[SceneManager defaultManager] addScenen:scene withName:@"" withPic:@""];
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
