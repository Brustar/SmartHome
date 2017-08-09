//
//  TVTableViewCell.h
//  SmartHome
//
//  Created by zhaona on 2017/3/23.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TVTableViewCellDelegate;

@interface TVTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *TVNameLabel;
@property (weak, nonatomic) IBOutlet UISlider *TVSlider;
@property (weak, nonatomic) IBOutlet UIButton *TVSwitchBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *TVConstraint;
@property (weak, nonatomic) IBOutlet UIButton *AddTvDeviceBtn;
@property (weak, nonatomic) IBOutlet UIView *IRContainerView;

@property(nonatomic, strong)NSString * deviceid;
@property (nonatomic,weak) NSString *sceneid;
//房间id
@property (nonatomic,assign) int roomID;
@property (strong, nonatomic) Scene *scene;
@property (nonatomic, assign) id<TVTableViewCellDelegate>delegate;
-(void)initWithFrame;
-(void) query:(NSString *)deviceid;

@end


@protocol TVTableViewCellDelegate <NSObject>

@optional
- (void)onTVSwitchBtnClicked:(UIButton *)btn;
- (void)onTVSliderValueChanged:(UISlider *)slider;

@end
