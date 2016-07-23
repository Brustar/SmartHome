//
//  ECloudMoreView.m
//  SmartHome
//
//  Created by 逸云科技 on 16/7/21.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "ECloudMoreView.h"

@interface ECloudMoreView ()
@property (nonatomic, weak) UIView *contentView;

@property (nonatomic, weak) UIButton *cover;


@end
@implementation ECloudMoreView
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        UIButton *cover = [[UIButton alloc] init];
        cover.backgroundColor = [UIColor clearColor];
        [cover addTarget:self action:@selector(coverOnClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:cover];
        self.cover = cover;
        
        UIView *contentView = [[UIView alloc] init];
        self.contentView = contentView;
        self.contentView.backgroundColor = [UIColor whiteColor];
        [self addSubview:contentView];
    }
    return self;
}


- (void)addItemWith:(ECloudButton *)button
{
    [self.contentView addSubview:button];
    button.titleLabel.font = [UIFont systemFontOfSize:17];
    [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonOnClick:) forControlEvents:UIControlEventTouchUpInside];
}


- (void)coverOnClick
{
    [self removeFromSuperview];
}


- (void)buttonOnClick:(ECloudButton *)button
{
    if ([self.delegate respondsToSelector:@selector(moreViewDidSelectWithType:subType:)]) {
        [self.delegate moreViewDidSelectWithType:button.type subType:button.subType];
    }
    
    [self coverOnClick];
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.cover.frame = self.bounds;
    
    CGFloat tabBarH = 49;
    
    CGFloat buttonW = 70;
    CGFloat buttonH = 70;
    CGFloat buttonY = 0;
    
    for (int i = 0; i < self.contentView.subviews.count; i++) {
        ECloudButton *button = self.contentView.subviews[i];
        CGFloat buttonX = i * buttonW;
        button.frame = CGRectMake(buttonX, buttonY, buttonW, buttonH);
    }
    
    
    CGFloat contentViewY = self.frame.size.height - buttonH - tabBarH;
    CGFloat contentViewW = buttonW * self.contentView.subviews.count;
    CGFloat contentViewH = buttonH;
    CGFloat contentViewX = self.frame.size.width / 11 * 7 - contentViewW / 2;
    
    self.contentView.frame = CGRectMake(contentViewX, contentViewY, contentViewW, contentViewH);
}

@end
