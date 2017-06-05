//
//  DemoVideoPlayerViewController.m
//  SmartHome
//
//  Created by KobeBryant on 2017/6/1.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "DemoVideoPlayerViewController.h"
#import <AVKit/AVPlayerViewController.h>
#import <AVFoundation/AVFoundation.h>


@interface DemoVideoPlayerViewController ()

@property (nonatomic, strong) AVPlayerViewController *avPlayerVC;

@end

@implementation DemoVideoPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initPlayer];
}

- (void)initPlayer {
    [self setNaviBarTitle:@"演示"];
    AVPlayer *player = [[AVPlayer alloc] initWithURL:[[NSBundle mainBundle] URLForResource:@"demo.mp4" withExtension:nil]];
    
    _avPlayerVC = [[AVPlayerViewController alloc] init];
    _avPlayerVC.player = player;
    _avPlayerVC.view.frame = CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height-64);
    player.externalPlaybackVideoGravity = AVLayerVideoGravityResizeAspectFill;//这个属性和图片填充试图的属性类似，也可以设置为自适应试图大小。
    [self.view addSubview:_avPlayerVC.view];
    [player play];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
