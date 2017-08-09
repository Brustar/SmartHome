//
//  IpadTVCell.h
//  SmartHome
//
//  Created by zhaona on 2017/6/1.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol IpadTVCellDelegate;

@interface IpadTVCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *TVNameLabel;
@property (weak, nonatomic) IBOutlet UISlider *TVSlider;
@property (weak, nonatomic) IBOutlet UIButton *TVSwitchBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *TVConstraint;
@property (weak, nonatomic) IBOutlet UIButton *AddTvDeviceBtn;
@property(nonatomic, strong)NSString * deviceid;
@property (nonatomic,weak) NSString *sceneid;
@property (weak, nonatomic) IBOutlet UIView *IRContainerView;

@property (weak, nonatomic) IBOutlet UIButton *channelReduceBtn;

@property (weak, nonatomic) IBOutlet UIButton *channelAddBtn;

//房间id
@property (nonatomic,assign) int roomID;
@property (strong, nonatomic) Scene *scene;
@property (nonatomic, assign) id<IpadTVCellDelegate>delegate;
-(void) query:(NSString *)deviceid;
-(void)initWithFrame;

@end


@protocol IpadTVCellDelegate <NSObject>

@optional
- (void)onTVSwitchBtnClicked:(UIButton *)btn;
- (void)onTVSliderValueChanged:(UISlider *)slider;

@end
