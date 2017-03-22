//
//  CYPhotoCell.m
//  自定义流水布局
//
//  Created by 葛聪颖 on 15/11/13.
//  Copyright © 2015年 聪颖不聪颖. All rights reserved.
//

#import "CYPhotoCell.h"
#import "SceneManager.h"

@interface CYPhotoCell()<UIGestureRecognizerDelegate>

@property(nonatomic,strong)UILongPressGestureRecognizer *lgPress;
@end

@implementation CYPhotoCell

- (IBAction)powerBtnAction:(id)sender {
    NSLog(@"power btn");
}
-(void)useLongPressGesture
{
    self.lgPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleLongPress:)];
    self.lgPress.delegate = self;
    [self addGestureRecognizer:self.lgPress];
}
- (IBAction)seleteSendPowBtn:(id)sender {
    self.seleteSendPowBtn.selected = !self.seleteSendPowBtn.selected;
    if (self.seleteSendPowBtn.selected) {
        [self.seleteSendPowBtn setBackgroundImage:[UIImage imageNamed:@"closeScene"] forState:UIControlStateSelected];
        [[SceneManager defaultManager] startScene:self.sceneID];
    }else{
        [self.seleteSendPowBtn setBackgroundImage:[UIImage imageNamed:@"startScene"] forState:UIControlStateNormal];
        [[SceneManager defaultManager] poweroffAllDevice:self.sceneID];
    }
    
}
- (void)awakeFromNib {
    self.imageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.imageView.layer.borderWidth = 10;
}
- (void)setSceneInfo:(Scene *)info {
     self.sceneStatus = info.status;
    [self.imageView sd_setImageWithURL:[NSURL URLWithString: info.picName] placeholderImage:[UIImage imageNamed:@"PL"]];

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
