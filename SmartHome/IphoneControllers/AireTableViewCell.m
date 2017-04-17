//
//  AireTableViewCell.m
//  SmartHome
//
//  Created by zhaona on 2017/3/23.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "AireTableViewCell.h"

@implementation AireTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self.AireSlider setThumbImage:[UIImage imageNamed:@"lv_btn_adjust_normal"] forState:UIControlStateNormal];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
