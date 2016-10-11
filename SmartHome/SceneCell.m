//
//  ScenseCell.m
//  SmartHome
//
//  Created by 逸云科技 on 16/7/20.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "SceneCell.h"

@interface SceneCell ()<UIGestureRecognizerDelegate>
@property(nonatomic,strong)UILongPressGestureRecognizer *lgPress;

@end
@implementation SceneCell

-(void)useLongPressGesture
{
    self.lgPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleLongPress:)];
    self.lgPress.delegate = self;
    [self addGestureRecognizer:self.lgPress];
}

- (IBAction)doDeleteBtn:(id)sender {
    [self.delegate sceneDeleteAction:self];
}
-(void)handleLongPress:(UILongPressGestureRecognizer *)lgr
{
    
    self.deleteBtn.hidden = NO;
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
