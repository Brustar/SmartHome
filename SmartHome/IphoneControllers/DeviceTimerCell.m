//
//  DeviceTimerCell.m
//  SmartHome
//
//  Created by KobeBryant on 2017/2/27.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "DeviceTimerCell.h"

@implementation DeviceTimerCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setInfo:(DeviceTimerInfo *)info {
    if (info) {
        self.deviceName.text = info.deviceName;
        self.timeLabel.text = [NSString stringWithFormat:@"%@-%@", info.startTime, info.endTime];
        self.repeatLabel.text = info.repetition;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
