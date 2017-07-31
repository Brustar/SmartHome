//
//  CYPhotoCell.h
//  自定义流水布局
//
//  Created by 葛聪颖 on 15/11/13.
//  Copyright © 2015年 聪颖不聪颖. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"

@class CYPhotoCell;

@protocol CYPhotoCellDelegate <NSObject>

@optional

-(void)sceneDeleteAction:(CYPhotoCell *)cell;
-(void)powerBtnAction:(UIButton *)sender sceneStatus:(int)status;
-(void)refreshTableView:(CYPhotoCell *)cell;
- (void)onTimingBtnClicked:(UIButton *)sender sceneID:(int)sceneID;

@end

@interface CYPhotoCell : UICollectionViewCell
/** 图片名 */
@property (nonatomic, copy) NSString *imageName;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic,assign) int sceneID;
@property (nonatomic,assign) int roomID;
@property (weak, nonatomic) IBOutlet UIButton *powerBtn;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property (weak, nonatomic) IBOutlet UIButton *seleteSendPowBtn;
@property (weak, nonatomic) IBOutlet UILabel *SceneName;
@property (nonatomic, assign) int roomIndex;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *PowerBtnCenterContraint;//定时按钮隐藏改变的约束

@property (nonatomic,weak) id<CYPhotoCellDelegate> delegate;

@property (nonatomic, assign) int sceneStatus;//场景状态
@property (nonatomic, assign) int isplan;//是否有定时
@property (nonatomic, assign) int sType;//是否系统场景
@property (nonatomic, assign) int isactive;//是否启动定时
@property (weak, nonatomic) IBOutlet UIImageView *subImageView;
@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *SceneNameTopConstraint;
//- (void)setSceneInfo:(Scene *)info;
@end
