//
//  IpadSceneCell.m
//  SmartHome
//
//  Created by zhaona on 2017/5/22.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "IpadSceneCell.h"
#import "SceneManager.h"
#import "Scene.h"
#import "SQLManager.h"

@implementation IpadSceneCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
}
//删除
- (IBAction)doDeleteBtn:(id)sender {
    
    self.deleteBtn.selected = !self.deleteBtn.selected;
    if (self.deleteBtn.selected) {
        [self.deleteBtn setBackgroundImage:[UIImage imageNamed:@"delete_white"] forState:UIControlStateSelected];
    }else{
        [self.deleteBtn setBackgroundImage:[UIImage imageNamed:@"delete_white"] forState:UIControlStateSelected];
    }
    if (_delegate && [_delegate respondsToSelector:@selector(sceneDeleteAction:)]) {
        [self.delegate sceneDeleteAction:self];
    }
}

//开关 
- (IBAction)powerBtn:(id)sender {
    
    if (self.sceneStatus == 0) { //点击前，场景是关闭状态，需打开场景
        [self.powerBtn setBackgroundImage:[UIImage imageNamed:@"close_red"] forState:UIControlStateSelected];
        [[SceneManager defaultManager] startScene:self.sceneID];//打开场景
        [SQLManager updateSceneStatus:1 sceneID:self.sceneID];//更新数据库
    }else if (self.sceneStatus == 1) { //点击前，场景是打开状态，需关闭场景
        [self.powerBtn setBackgroundImage:[UIImage imageNamed:@"close_white"] forState:UIControlStateNormal];
        [[SceneManager defaultManager] poweroffAllDevice:self.sceneID];//关闭场景
        [SQLManager updateSceneStatus:0 sceneID:self.sceneID];//更新数据库
    }
    
    
    NSLog(@"power");
    
}
//定时
- (IBAction)timingBtn:(id)sender {
    
    self.seleteSendPowBtn.selected = !self.seleteSendPowBtn.selected;
    
    if (self.seleteSendPowBtn.selected) {
        
        [self.seleteSendPowBtn setBackgroundImage:[UIImage imageNamed:@"alarm clock2"] forState:UIControlStateSelected];
    }else{
        [self.seleteSendPowBtn setBackgroundImage:[UIImage imageNamed:@"alarm clock1"] forState:UIControlStateNormal];
    }
}

@end
