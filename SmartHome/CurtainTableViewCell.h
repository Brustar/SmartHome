//
//  CurtainTableViewCell.h
//  SmartHome
//
//  Created by 逸云科技 on 16/6/2.
//  Copyright © 2016年 Brustar. All rights reserved.
//

@protocol CurtainTableViewCellDelegate;

@interface CurtainTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UIButton *close;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
@property (weak, nonatomic) IBOutlet UIButton *open;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *supImageViewHeight;

@property (nonatomic,assign) int roomID;
@property (weak,nonatomic) NSString *deviceid;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *curtainContraint;
@property (weak, nonatomic) IBOutlet UIButton *AddcurtainBtn;
@property (strong, nonatomic) Scene *scene;
@property (nonatomic,weak) NSString *sceneid;
@property (nonatomic, assign) id<CurtainTableViewCellDelegate>delegate;
-(void) query:(NSString *)deviceid delegate:(id)delegate;

@end


@protocol CurtainTableViewCellDelegate <NSObject>

@optional
- (void)onCurtainOpenBtnClicked:(UIButton *)btn deviceID:(int)deviceID;
- (void)onCurtainSliderBtnValueChanged:(UISlider *)slider deviceID:(int)deviceID;

@end
