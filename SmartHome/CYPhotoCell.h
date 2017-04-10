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
- (void)powerBtnAction:(UIButton *)sender sceneStatus:(int)status;

@end

@interface CYPhotoCell : UICollectionViewCell
/** 图片名 */
@property (nonatomic, copy) NSString *imageName;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic,assign) int sceneID;
@property (weak, nonatomic) IBOutlet UIButton *powerBtn;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property (nonatomic,weak) id<CYPhotoCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *sceneLabel;
@property (weak, nonatomic) IBOutlet UIButton *seleteSendPowBtn;
@property (nonatomic, assign) int sceneStatus;//场景状态
@property (weak, nonatomic) IBOutlet UIImageView *subImageView;

- (IBAction)powerBtnAction:(UIButton *)sender;

- (void)setSceneInfo:(Scene *)info;


-(void)useLongPressGesture;
-(void)unUseLongPressGesture;


@end
