//
//  IphoneRoomView.m
//  SmartHome
//
//  Created by 逸云科技 on 16/9/20.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "IphoneRoomView.h"

@interface IphoneRoomView ()
@property (nonatomic,strong) NSMutableArray *btns;
@property (nonatomic, weak) UIButton *selectedButton;
@property (nonatomic, assign) int selectedButtonCount;
@end
@implementation IphoneRoomView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

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
        self.sv = [[UIScrollView alloc] init];
        [self addSubview:self.sv];
        self.sv.bounces = NO;
    }
    return self;
}
- (void)setDataArray:(NSArray *)dataArray {
    _dataArray = dataArray;
    
    int buttonCount = (int)self.btns.count;
    
    for (int i = 0; i < dataArray.count; i++) {
        UIButton *button;
        if (i < buttonCount) {
            button = self.btns[i];
        } else {
            button = [[UIButton alloc] init];
            [button addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
            [button setTitleColor:[UIColor redColor] forState:UIControlStateDisabled];
            [self.btns addObject:button];
            [self.sv addSubview:button];
        }
        
        button.enabled = YES;
        button.tag = i;
        
        NSString *title = dataArray[i];
        
        [button setTitle:title forState:UIControlStateNormal];
        
        button.hidden = NO;
    }
    
    for (int i = (int)self.dataArray.count; i < self.btns.count; i++) {
        UIButton *button = self.btns[i];
        button.hidden = YES;
    }
    
    [self setViewFrame];
}

- (void)setSelectButton:(int)index {
    UIButton *button = self.btns[index];
    button.enabled = NO;
    
    CGPoint point = CGPointMake(button.frame.origin.x, 0);
    
    self.selectedButton = button;
    
    [self.sv setContentOffset:point animated:YES];
}


-(void)clickButton:(UIButton *)btn
{
    self.selectedButton.enabled = YES;
    
    btn.enabled = NO;
    
    self.selectedButton = btn;
    
    if ([self.delegate respondsToSelector:@selector(iphoneRoomView:didSelectButton:)]) {
        [self.delegate iphoneRoomView:self didSelectButton:(int)btn.tag];
    }
}
- (void)setViewFrame {
    CGFloat scrollW = 0;
    
    CGFloat buttonH = self.frame.size.height;
    CGFloat buttonY = 0;
    
    NSMutableDictionary *attr = [NSMutableDictionary dictionary];
    attr[NSFontAttributeName] = [UIFont systemFontOfSize:35];
    
    
    for (int i = 0; i < self.dataArray.count; i++) {
        NSString *title = self.dataArray[i];
        
        scrollW += [title sizeWithAttributes:attr].width;
    }
    
    CGFloat buttonW = 0;
    BOOL isButtonWSet = true;
    
    if (scrollW < self.frame.size.width) {
        buttonW = self.frame.size.width / self.dataArray.count;
        isButtonWSet = false;
    }
    
    scrollW = 0;
    
    for (int i = 0; i < self.dataArray.count; i++) {
        UIButton *button = self.btns[i];
        
        NSString *title = self.dataArray[i];
        
        if (isButtonWSet) {
            buttonW = [title sizeWithAttributes:attr].width;
        }
        
        CGFloat buttonX = scrollW;
        
        button.frame = CGRectMake(buttonX, buttonY, buttonW, buttonH);
        [button setBackgroundColor:[UIColor lightGrayColor]];
        
        scrollW += buttonW;
    }
    
    self.sv.frame = self.bounds;
    self.sv.contentSize = CGSizeMake(scrollW, self.frame.size.height);
}



- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.dataArray.count < 1) {
        return;
    }
    
    [self setViewFrame];
}

@end
