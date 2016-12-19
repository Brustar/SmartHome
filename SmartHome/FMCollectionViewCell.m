//
//  FMCollectionViewCell.m
//  SmartHome
//
//  Created by 逸云科技 on 16/6/15.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "FMCollectionViewCell.h"


@interface FMCollectionViewCell ()<UIGestureRecognizerDelegate>
@property (nonatomic,strong) UILongPressGestureRecognizer *longPrss;
@end
@implementation FMCollectionViewCell


-(void)useLongPressGesture
{
    self.longPrss = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleLongPressGester:)];
    self.longPrss.delegate = self;
    [self addGestureRecognizer:self.longPrss];
}
- (IBAction)doDeleteFm:(id)sender {
    
    [self.delegate FmDeleteAction:self];
}
- (IBAction)doEditFm:(id)sender {
    [self.delegate FmEditAction:self];
}
-(void)handleLongPressGester:(UILongPressGestureRecognizer *)gestureRecognizer
{
    self.deleteBtn.hidden = YES;
    self.editBtn.hidden = YES;
}
-(void)hiddenBtns
{
    self.editBtn.hidden = YES;
    self.deleteBtn.hidden = YES;
}
-(void)unUseLongPressGesture
{
    if(self.longPrss != nil)
    {
        [self.longPrss removeTarget:self action:@selector(handleLongPressGester:)];
    }
   

}
-(void)dealloc
{
    [self unUseLongPressGesture];
}
@end
