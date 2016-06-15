//
//  TVController.m
//  SmartHome
//
//  Created by Brustar on 16/6/7.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "TVController.h"
#import "DetailViewController.h"
#import "TV.h"
#import "SceneManager.h"
#import "tvBrandView.h"
#import "TVChannel.h"
#import "tvBrandView.h"

@interface TVController ()<UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UISlider *volume;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tvBrandViewHight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tvBrandViewWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollewContentViewWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *secondViewLeftFromContenView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *thirdViewLeftFromContenView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageController;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic,assign) int channelViewCount;
@property (strong, nonatomic) IBOutletCollection(tvBrandView) NSArray *tvViews;



- (IBAction)mute:(id)sender;
@end

@implementation TVController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"电视";
    self.volume.continuous = NO;
    [self.volume addTarget:self action:@selector(save:) forControlEvents:UIControlEventValueChanged];
    
    
    self.beacon=[[IBeacon alloc] init];
    [self.beacon addObserver:self forKeyPath:@"volume" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
    VolumeManager *volume=[VolumeManager defaultManager];
    [volume start:self.beacon];
    
    [self setChannel];
    [self setUpConstraint];
    
}
-(void)setChannel
{
    NSArray *channels = [TVChannel getAllChannelForFavoritedForType:@"TV"];
    NSRange range;
    long count = channels.count;
    int index = 0;
    while (count > 0) {
        if(count >= 4)
        {
            range.length = 4;
        }else {
            range.length = count;
        }
        count -= range.length;
        range.location = 0;
        tvBrandView *tvView = self.tvViews[index++];
        tvView.channelArr= [channels subarrayWithRange:range];
    }
    self.channelViewCount = index;
    
}
-(void)setUpConstraint
{
    self.tvBrandViewWidth.constant = self.view.frame.size.width *0.3;
    self.scrollewContentViewWidth.constant = self.tvBrandViewWidth.constant * self.channelViewCount;
    self.tvBrandViewHight.constant = self.tvBrandViewWidth.constant;
    self.secondViewLeftFromContenView.constant = self.tvBrandViewWidth.constant;
    self.thirdViewLeftFromContenView.constant = self.tvBrandViewWidth.constant *2;
}
-(void)updateViewConstraints{
    [super updateViewConstraints];
    
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)detail:(id)sender {
    DetailViewController *detailVC = [[DetailViewController alloc]init];
    detailVC.deviceID = 3;

    [self.navigationController pushViewController:detailVC animated:YES];
}

-(IBAction)save:(id)sender
{
    TV *device=[[TV alloc] init];
    [device setDeviceID:3];
    [device setVolume:self.volume.value*100];
    
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)mute:(id)sender {
    self.volume.value=0.0;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"volume"])
    {
        self.volume.value=[[self.beacon valueForKey:@"volume"] floatValue];
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint point = self.scrollView.contentOffset;
    
    self.pageController.currentPage = round(point.x/self.scrollView.bounds.size.width);
}



@end
