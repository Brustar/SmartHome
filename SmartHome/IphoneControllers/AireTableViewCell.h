//
//  AireTableViewCell.h
//  SmartHome
//
//  Created by zhaona on 2017/3/23.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AireTableViewCellDelegate;

@interface AireTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *AireNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *temperatureLabel;
@property (weak, nonatomic) IBOutlet UISlider *AireSlider;
@property (weak, nonatomic) IBOutlet UIButton *AireSwitchBtn;
//硬件id
@property (weak,nonatomic) NSString *deviceid;
@property (strong, nonatomic) Scene *scene;
@property (nonatomic,assign) int roomID;
@property (nonatomic,weak) NSString *sceneid;
@property (weak, nonatomic) IBOutlet UIButton *AddAireBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *AireConstraint;
@property (nonatomic, assign) id<AireTableViewCellDelegate>delegate;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *supImageViewHeight;


@end


@protocol AireTableViewCellDelegate <NSObject>

@optional
- (void)onAirSwitchBtnClicked:(UIButton *)btn;
- (void)onAirSliderValueChanged:(UISlider *)slider;

@end
