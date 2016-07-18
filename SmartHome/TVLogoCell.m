//
//  TVLogoCell.m
//  SmartHome
//
//  Created by 逸云科技 on 16/7/14.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "TVLogoCell.h"


@interface TVLogoCell () <UIGestureRecognizerDelegate>
@property (nonatomic,strong) UILongPressGestureRecognizer *lgPress;
@end

@implementation TVLogoCell

-(void)useLongPressGesture
{
    self.lgPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleLongPress:)];
    self.lgPress.delegate = self;
    [self addGestureRecognizer:self.lgPress];
}

- (IBAction)doDeleteBtn:(id)sender {
    [self.delegate tvDeleteAction:self];
}
- (IBAction)doEditBtn:(id)sender {
    [self.delegate tvEditAction:self];
}

-(void)handleLongPress:(UILongPressGestureRecognizer *)lgr
{
    self.editBtn.hidden = NO;
    self.deleteBtn.hidden = NO;
}
-(void)hiddenEditBtnAndDeleteBtn
{
    self.editBtn.hidden = YES;
    self.deleteBtn.hidden =YES;
}
-(void)unUseLongPressGesture
{
    if(self.lgPress != nil)
    {
        [self.lgPress removeTarget:self action:@selector(handleLongPress:)];
    }
}
-(void)dealloc{
    [self unUseLongPressGesture];
}

@end
