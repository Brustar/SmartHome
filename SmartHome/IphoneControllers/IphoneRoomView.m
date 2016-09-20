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
@end
@implementation IphoneRoomView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.sv = [[UIScrollView alloc]initWithFrame:frame];
        [self addSubview:self.sv];
        
    }
    return self;
}
-(void)addButtonsInScrollView:(int)count
{
    CGFloat widthBtn;
    if(count > 4)
    {
        widthBtn = self.sv.frame.size.width / 4.0;
    }else{
        widthBtn = self.sv.frame.size.width / count;
    }

    for(int i = 0 ; i < count; i++)
    {
        UIButton *button;
        if(i < self.btns.count)
        {
            button = self.btns[i];
        }else{
            button = [[UIButton alloc]initWithFrame:CGRectMake(widthBtn * i, 0, widthBtn, self.sv.frame.size.height)];
            [self.btns addObject:button];
        }
        [button addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.sv addSubview:button];
        

    }
    self.sv.contentSize = CGSizeMake(widthBtn * count, self.sv.bounds.size.height);
}
-(void)clickButton:(UIButton *)btn
{
    
}
@end
