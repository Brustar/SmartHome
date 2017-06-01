//
//  IpadSceneCell.h
//  SmartHome
//
//  Created by zhaona on 2017/5/22.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"

@class IpadSceneCell;

@protocol IpadSceneCellDelegate <NSObject>

//@optional

-(void)sceneDeleteAction:(IpadSceneCell *)cell;
-(void)powerBtnAction:(UIButton *)sender sceneStatus:(int)status;
-(void)refreshTableView:(IpadSceneCell *)cell;

@end

@interface IpadSceneCell : UICollectionViewCell
/** 图片名 */
@property (nonatomic, copy) NSString *imageName;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic,assign) int sceneID;
@property (weak, nonatomic) IBOutlet UIButton *powerBtn;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property (weak, nonatomic) IBOutlet UIButton *seleteSendPowBtn;
@property (weak, nonatomic) IBOutlet UILabel *SceneName;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *PowerBtnCenterContraint;//定时按钮隐藏改变的约束
@property (weak, nonatomic) IBOutlet UIView *partternBtnView;

@property (nonatomic,weak) id<IpadSceneCellDelegate> delegate;

@property (nonatomic, assign) int sceneStatus;//场景状态
@property (weak, nonatomic) IBOutlet UIImageView *subImageView;
@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *SceneNameTopConstraint;



@end
