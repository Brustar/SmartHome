//
//  TVTableViewCell.m
//  SmartHome
//
//  Created by zhaona on 2017/3/23.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "TVTableViewCell.h"

@implementation TVTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.TVSwitch.onImage = [UIImage imageNamed:@"dvd_btn_switch_on"];
    self.TVSwitch.offImage = [UIImage imageNamed:@"dvd_btn_switch_off"];
    self.TVSwitch.tintColor = [UIColor redColor];
    self.TVSwitch.thumbTintColor = [UIColor blackColor];
//    [self.TVSlider setThumbImage:[UIImage imageNamed:@"lv_btn_adjust_normal"] forState:UIControlStateNormal];
        UIImage *leftTrack = [UIImage imageNamed:@"lv_line_light_on"];
        [self.TVSlider setMinimumTrackImage:leftTrack forState:UIControlStateNormal];
//        UIImage *rightTrack = [UIImage imageNamed:@"Slider2"];
        [self.TVSlider setThumbImage:[UIImage imageNamed:@"lv_btn_adjust_normal"] forState:UIControlStateNormal];
//        [self.TVSlider setMaximumTrackImage:rightTrack forState:UIControlStateNormal];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
