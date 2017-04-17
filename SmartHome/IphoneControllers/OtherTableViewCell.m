
//
//  OtherTableViewCell.m
//  SmartHome
//
//  Created by zhaona on 2017/3/23.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "OtherTableViewCell.h"

@implementation OtherTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self.OtherSwitchBtn setBackgroundImage:[UIImage imageNamed:@"dvd_btn_switch_off"] forState:UIControlStateNormal];
    [self.OtherSwitchBtn setBackgroundImage:[UIImage imageNamed:@"dvd_btn_switch_on"] forState:UIControlStateSelected];
}

- (IBAction)OtherSwitchBtn:(id)sender {
    self.OtherSwitchBtn.selected = !self.OtherSwitchBtn.selected;
    if (self.OtherSwitchBtn.selected) {
        [self.OtherSwitchBtn setBackgroundImage:[UIImage imageNamed:@"dvd_btn_switch_off"] forState:UIControlStateNormal];
    }else{
        
        [self.OtherSwitchBtn setBackgroundImage:[UIImage imageNamed:@"dvd_btn_switch_on"] forState:UIControlStateSelected];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
