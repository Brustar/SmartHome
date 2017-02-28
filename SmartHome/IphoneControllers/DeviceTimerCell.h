//
//  DeviceTimerCell.h
//  SmartHome
//
//  Created by KobeBryant on 2017/2/27.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DeviceTimerInfo.h"

@interface DeviceTimerCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *deviceName;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *repeatLabel;

- (void)setInfo:(DeviceTimerInfo *)info;

@end
