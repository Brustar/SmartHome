//
//  tvBrandView.m
//  SmartHome
//
//  Created by 逸云科技 on 16/6/13.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "tvBrandView.h"
#import "TVChannel.h"
@interface tvBrandView()
@property (strong, nonatomic) IBOutlet UIView *view;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *channelBtns;

@end

@implementation tvBrandView


- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"tvBrandView" owner:self options:nil];
        [self addSubview:self.view];
    }
    return self;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    self.view.frame = self.bounds;
}

-(void)setChannelArr:(NSArray *)channelArr
{
    _channelArr = channelArr;
    NSArray *channels = [TVChannel getAllChannelForFavoritedForType:@"TV"];
    int i = 0;
    for( i = 0; i < self.channelArr.count; i++)
    {
        UIButton *btn = self.channelBtns[i];
        TVChannel *channel = channels[i];
        [btn setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@",channel.channel_name]] forState:UIControlStateNormal];
        btn.hidden = NO;
    }
    for(;i < self.channelBtns.count; i++)
    {
        UIButton *btn = self.channelBtns[i];
        btn.hidden = YES;
    }

}




@end
