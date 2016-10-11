//
//  IphoneTypeView.m
//  SmartHome
//
//  Created by 逸云科技 on 16/10/11.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "IphoneTypeView.h"


#define ButtonTitleHeight  30

#define ButtonImageTitleMargin  10


@interface IphoneTypeView ()

@property (nonatomic,strong) NSMutableArray *btns;
@property (nonatomic, weak) UIButton *selectedButton;
@property (nonatomic, assign) int selectedButtonCount;
@property (nonatomic,strong) UIScrollView *scrollView;

@end


@implementation IphoneTypeView
- (NSMutableArray *)btns {
    if (_btns == nil) {
        _btns = [NSMutableArray array];
    }
    return _btns;
}


- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        self.scrollView = [[UIScrollView alloc] init];
        [self addSubview:self.scrollView];
        self.scrollView.bounces = NO;
    }
    return self;
}


- (void) clearItem {
    for (UIButton *button in self.btns) {
        [button removeFromSuperview];
        button.hidden = YES;
    }
    
    self.selectedButtonCount = 0;
}


- (void)addItemWithTitle:(NSString *)title imageName:(NSString *)imageName {
    UIButton *button = nil;
    
    if (self.selectedButtonCount < self.btns.count) {
        button = self.btns[self.selectedButtonCount];
    } else {
        button = [[UIButton alloc] init];
        [self.btns addObject:button];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor redColor] forState:UIControlStateDisabled];
        [button addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    button.hidden = NO;
    button.enabled = YES;
    
    CGFloat buttonW = [UIScreen mainScreen].bounds.size.width / 4;
    
    UIImage *image = [UIImage imageNamed:imageName];
    [button setImage:image forState:UIControlStateNormal];
    CGFloat imageViewX = (buttonW - image.size.width) / 2;
    button.imageView.frame = CGRectMake(imageViewX, 0, image.size.width, image.size.height);
    
    [button setTitle:title forState:UIControlStateNormal];
    
    button.titleLabel.frame = CGRectMake(0, ButtonImageTitleMargin + image.size.height, buttonW, ButtonTitleHeight);
    
    [self.scrollView addSubview:button];
    
    self.selectedButtonCount++;
    
    [self setViewFrame];
}



- (void)setSelectButton:(int)index {
    UIButton *button = self.btns[index];
    button.enabled = NO;
    
    CGPoint point = CGPointMake(button.frame.origin.x, 0);
    
    self.selectedButton = button;
    
    [self.scrollView setContentOffset:point animated:YES];
}


-(void)clickButton:(UIButton *)btn
{
    self.selectedButton.enabled = YES;
    
    btn.enabled = NO;
    
    self.selectedButton = btn;
    
    if ([self.delegate respondsToSelector:@selector(iphoneTypeView:didSelectButton:)]) {
        [self.delegate iphoneTypeView:self didSelectButton:(int)btn.tag];
    }
}


- (void)setViewFrame {
    UIButton *button = self.btns[0];
    CGFloat buttonH = button.imageView.image.size.height + ButtonImageTitleMargin + ButtonTitleHeight;
    CGFloat buttonY = (self.frame.size.height - buttonH) / 2;
    if (buttonY < 0 ) {
        buttonY = 0;
    }
    CGFloat buttonW = [UIScreen mainScreen].bounds.size.width / 4;
    
    for (int i = 0; i < self.selectedButtonCount; i++) {
        UIButton *button = self.btns[i];
        CGFloat buttonX = i * buttonW;
        button.frame = CGRectMake(buttonX, buttonY, buttonW, buttonH);
    }
    
    self.scrollView.frame = self.bounds;
    self.scrollView.contentSize = CGSizeMake(buttonW * self.selectedButtonCount, self.frame.size.height);
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self setViewFrame];
}


@end
