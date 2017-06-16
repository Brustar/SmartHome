//
//  BjMusicTableViewCell.h
//  SmartHome
//
//  Created by zhaona on 2017/4/12.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BjMusicTableViewCellDelegate;

@interface BjMusicTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *BjMusicNameLb;
@property (weak, nonatomic) IBOutlet UISlider *BjSlider;
@property (weak, nonatomic) IBOutlet UIButton *BjPowerButton;
@property (weak, nonatomic) IBOutlet UIButton *AddBjmusicBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *BJmusicConstraint;
@property(nonatomic, strong)NSString * deviceid;
@property (nonatomic,weak) NSString *sceneid;
//房间id
@property (nonatomic,assign) int roomID;
@property (strong, nonatomic) Scene *scene;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *BjmusicHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bdIconLeadingConstraint;//音量小距离左边的距离
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bgIconTadilingConst;//音量小距离右边的距离

@property (nonatomic, assign) id<BjMusicTableViewCellDelegate>delegate;
-(void) query:(NSString *)deviceid;

@end


@protocol BjMusicTableViewCellDelegate <NSObject>

@optional
- (void)onBjPowerButtonClicked:(UIButton *)btn;
- (void)onBjSliderValueChanged:(UISlider *)slider;

@end
