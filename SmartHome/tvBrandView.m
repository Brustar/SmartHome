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
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *imageView;
@property (nonatomic,strong) UILongPressGestureRecognizer *lgr;


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
    
    int i = 0;
    for( i = 0; i < self.channelArr.count; i++)
    {
        UIImageView *img = self.imageView[i];
        TVChannel *channel = channelArr[i];
        
        img.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@",channel.channel_pic]];
        img.hidden = NO;
    }
    for(;i < self.imageView.count; i++)
    {
        UIImageView *img = self.imageView[i];
        img.hidden = YES;
    }

}

-(void)useLongPressGesture
{
    self.lgr = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleLongPressGesture:)];
    
}
-(void)handleLongPressGesture:(UILongPressGestureRecognizer *)lgr
{
    
}

@end
