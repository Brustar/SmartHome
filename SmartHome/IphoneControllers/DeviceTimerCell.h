//
//  DeviceTimerCell.h
//  SmartHome
//
//  Created by KobeBryant on 2017/2/27.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DeviceTimerInfo.h"

@protocol DeviceTimerCellDelegate;

@interface DeviceTimerCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *deviceName;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *repeatLabel;
@property (weak, nonatomic) IBOutlet UIButton *deviceTimeBtn;
@property (nonatomic, assign) id<DeviceTimerCellDelegate>delegate;

- (IBAction)deviceTimerBtnClicked:(id)sender;

- (void)setInfo:(DeviceTimerInfo *)info;

@end


@protocol DeviceTimerCellDelegate <NSObject>

@optional
- (void)onDeviceTimerBtnClicked:(UIButton *)sender;

@end
