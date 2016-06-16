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

@interface FMController ()<UICollectionViewDelegate,UICollectionViewDataSource,UIScrollViewDelegate,TXHRrettyRulerDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollerContentViewWidth;
@property (nonatomic,strong) NSArray *allFavouriteChannels;
//@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (weak, nonatomic) IBOutlet UILabel *numberOfChannel;
@property (weak, nonatomic) IBOutlet UIView *fmView;

@end

@implementation FMController

-(NSArray *)allFavouriteChannels
{
    if(!_allFavouriteChannels)
    {
        _allFavouriteChannels = [TVChannel getAllChannelForFavoritedForType:@"FM"];
        
    }
    return _allFavouriteChannels;
}
- (void)viewDidLoad {
    [super viewDidLoad];
//    long  count = self.allFavouriteChannels.count;
//    self.pageControl.numberOfPages = count % 4 == 0 ? count / 4 :count /4 + 1;
    
    [self setRuleForFMChannel];
    self.volume.continuous = NO;
    [self.volume addTarget:self action:@selector(save:) forControlEvents:UIControlEventValueChanged];
    
    
    self.beacon=[[IBeacon alloc] init];
    [self.beacon addObserver:self forKeyPath:@"volume" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
    VolumeManager *volume=[VolumeManager defaultManager];
    [volume start:self.beacon];
    // Do any additional setup after loading the view.
    if ([self.sceneid intValue]>0) {
        
        Scene *scene=[[SceneManager defaultManager] readSceneByID:[self.sceneid intValue]];
        for(int i=0;i<[scene.devices count];i++)
        {
            if ([[scene.devices objectAtIndex:i] isKindOfClass:[Radio class]]) {
                self.volume.value=((Radio*)[scene.devices objectAtIndex:i]).rvolume/100.0;
                self.numberOfChannel.text=  [NSString stringWithFormat:@"%f", ((Radio*)[scene.devices objectAtIndex:i]).channel];
            }
        }
    }
}

-(void)setRuleForFMChannel
{
    TXHRrettyRuler *ruler = [[TXHRrettyRuler alloc] initWithFrame:CGRectMake(20, 150, self.fmView.bounds.size.width - 20 * 2, 150)];
    ruler.rulerDeletate = self;
    [ruler showRulerScrollViewWithCount:205 average:[NSNumber numberWithFloat:0.1] currentValue:16.5f smallMode:YES];
    [self.fmView addSubview:ruler];

}
- (void)txhRrettyRuler:(TXHRulerScrollView *)rulerScrollView {
    self.numberOfChannel.text = [NSString stringWithFormat:@" %.1f",rulerScrollView.rulerValue];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionDelegate

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.allFavouriteChannels.count;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FMCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"collectionCell" forIndexPath:indexPath];
    TVChannel *channel = self.allFavouriteChannels[indexPath.row];
    [cell.numberBtn setTitle:[NSString stringWithFormat:@"%d",channel.channel_id] forState:UIControlStateNormal];
    [cell.nameBtn setTitle:[NSString stringWithFormat:@"%@",channel.channel_name] forState:UIControlStateNormal];
    return cell;
}


-(IBAction)save:(id)sender
{
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

-(void)dealloc
{
    [self.beacon removeObserver:self forKeyPath:@"volume" context:nil];
}

//-(void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    CGPoint point = [self.collectionView contentOffset];
//    self.pageControl.currentPage =round(point.x /self.collectionView.bounds.size.width);
//    
//}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
