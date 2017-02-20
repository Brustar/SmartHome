//
//  ScenseCell.h
//  SmartHome
//
//  Created by 逸云科技 on 16/7/20.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"

@class SceneCell;
@protocol SceneCellDelegate <NSObject>

@optional

-(void)sceneDeleteAction:(SceneCell *)cell;
- (void)powerBtnAction:(UIButton *)sender sceneStatus:(int)status;

@end


@interface SceneCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *scenseName;
@property (weak, nonatomic) IBOutlet UIButton *powerBtn;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property (nonatomic,assign) int sceneID;
@property (nonatomic,weak) id<SceneCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton *seleteSendPowBtn;
@property (nonatomic, assign) int sceneStatus;//场景状态


- (IBAction)powerBtnAction:(UIButton *)sender;

- (void)setSceneInfo:(Scene *)info;


-(void)useLongPressGesture;
-(void)unUseLongPressGesture;

@end
