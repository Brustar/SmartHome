//
//  DVDTableViewCell.m
//  SmartHome
//
//  Created by zhaona on 2017/3/23.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "DVDTableViewCell.h"

@implementation DVDTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
  
    [self.DVDSlider setThumbImage:[UIImage imageNamed:@"lv_btn_adjust_normal"] forState:UIControlStateNormal];
    self.DVDSlider.maximumTrackTintColor = [UIColor colorWithRed:16/255.0 green:17/255.0 blue:21/255.0 alpha:1];
    self.DVDSlider.minimumTrackTintColor = [UIColor colorWithRed:253/255.0 green:254/255.0 blue:254/255.0 alpha:1];
}
- (IBAction)DVDSwitchBtn:(id)sender {
    self.DVDSwitchBtn.selected = !self.DVDSwitchBtn.selected;
    if (self.DVDSwitchBtn.selected) {
        [self.DVDSwitchBtn setBackgroundImage:[UIImage imageNamed:@"dvd_btn_switch_off"] forState:UIControlStateNormal];
    }else{
        
        [self.DVDSwitchBtn setBackgroundImage:[UIImage imageNamed:@"dvd_btn_switch_on"] forState:UIControlStateSelected];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
