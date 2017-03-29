//
//  CYPhotoCell.m
//  自定义流水布局
//
//  Created by 葛聪颖 on 15/11/13.
//  Copyright © 2015年 聪颖不聪颖. All rights reserved.
//

#import "CYPhotoCell.h"
#import "SceneManager.h"

@interface CYPhotoCell()<UIGestureRecognizerDelegate,UIActionSheetDelegate>

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
//    [self addGestureRecognizer:self.lgPress];
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
    [super awakeFromNib];
//    self.imageView.layer.borderColor = [UIColor whiteColor].CGColor;
//    self.imageView.layer.borderWidth = 10;
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
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"温馨提示 " delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"收藏场景"
                                              otherButtonTitles:@"更换图片", nil];
//    sheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
  
    
    [sheet showInView:self];
    
    NSLog(@"8980-08-");
    
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        NSLog(@"---------1----------");
        actionSheet.hidden = YES;
    }else if (buttonIndex == 1){
        NSLog(@"---------2----------");
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"温馨提示 " delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"预置台标"
                                                  otherButtonTitles:@"本地图库",@"现在拍摄", nil];
        //    sheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
        
        [sheet showInView:self];
                
    }
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
