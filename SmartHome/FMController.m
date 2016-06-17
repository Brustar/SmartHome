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
                self.numberOfChannel.text=  [NSString stringWithFormat:@"%.1f", ((Radio*)[scene.devices objectAtIndex:i]).channel];
            }
        }
    }
    
    [self setRuleForFMChannel];

}

-(void)setRuleForFMChannel
{
    CGFloat rule = [self.numberOfChannel.text floatValue];
    NSLog(@"\n\n\n\n\n rule = %f",rule);
    TXHRrettyRuler *ruler = [[TXHRrettyRuler alloc] initWithFrame:CGRectMake(20, 150, self.fmView.bounds.size.width - 20 * 2, 150)];
    ruler.rulerDelegate = self;
    [ruler showRulerScrollViewWithCount:205 average:[NSNumber numberWithFloat:0.1] currentValue:rule smallMode:YES];
    [self.fmView addSubview:ruler];

}
#warning save 进来就执行
- (void)txhRrettyRuler:(TXHRulerScrollView *)rulerScrollView {
    self.numberOfChannel.text = [NSString stringWithFormat:@" %.1f",rulerScrollView.rulerValue];
    
    [self save:nil];
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
    [cell.numberBtn setTitle:[NSString stringWithFormat:@"%ld",channel.channel_id] forState:UIControlStateNormal];
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


@end
