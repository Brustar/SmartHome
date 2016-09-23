//
//  IphoneTVController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/9/23.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "IphoneTVController.h"
#import "IphoneRoomView.h"
#import "ChannelManager.h"
#import "TVChannel.h"

@interface IphoneTVController ()
@property (weak, nonatomic) IBOutlet UISlider *volumeSlider;
@property (weak, nonatomic) IBOutlet UIButton *lastBtn;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;
@property (weak, nonatomic) IBOutlet IphoneRoomView *channelView;
@property (nonatomic,strong) NSMutableArray *allFavourTVChannels;

@end

@implementation IphoneTVController

-(NSMutableArray*)allFavourTVChannels
{
    if(!_allFavourTVChannels)
    {
        _allFavourTVChannels = [NSMutableArray array];
        _allFavourTVChannels = [ChannelManager getAllChannelForFavoritedForType:@"TV" deviceID:[self.deviceid intValue]];
        if(_allFavourTVChannels == nil || _allFavourTVChannels.count == 0)
        {
            
        }
    }
    return _allFavourTVChannels;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.volumeSlider.transform = CGAffineTransformMakeRotation(M_PI/2);
    [self setUpChannelView];
}

-(void)setUpChannelView
{
    NSMutableArray *channelImg = [NSMutableArray array];
    for(TVChannel *channel in self.allFavourTVChannels)
    {
        NSString *imgUrl = channel.channel_pic;
        [channelImg addObject:imgUrl];
        
    }
    self.channelView.dataArray = channelImg;
    
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
