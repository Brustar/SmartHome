//
//  ScenseCell.m
//  SmartHome
//
//  Created by 逸云科技 on 16/7/20.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "SceneCell.h"
#import "SceneManager.h"

@interface SceneCell ()<UIGestureRecognizerDelegate>
@property(nonatomic,strong)UILongPressGestureRecognizer *lgPress;

@end
@implementation SceneCell

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

- (void)setSceneInfo:(Scene *)info {
    self.scenseName.text = info.sceneName;
    self.sceneStatus = info.status;
    [self.imgView sd_setImageWithURL:[NSURL URLWithString: info.picName] placeholderImage:[UIImage imageNamed:@"PL"]];
    if (self.sceneStatus == 0) {
        [self.powerBtn setBackgroundImage:[UIImage imageNamed:@"startScene"] forState:UIControlStateNormal];
    }else if (self.sceneStatus == 1) {
        [self.powerBtn setBackgroundImage:[UIImage imageNamed:@"closeScene"] forState:UIControlStateNormal];
    }
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
