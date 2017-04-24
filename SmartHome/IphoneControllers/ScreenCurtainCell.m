//
//  ScreenCurtainCell.m
//  SmartHome
//
//  Created by zhaona on 2017/4/11.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "ScreenCurtainCell.h"

@implementation ScreenCurtainCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
   
}
- (IBAction)ScreenCurtainBtn:(id)sender {
    self.ScreenCurtainBtn.selected = !self.ScreenCurtainBtn.selected;
    if (self.ScreenCurtainBtn.selected) {
        [self.ScreenCurtainBtn setBackgroundImage:[UIImage imageNamed:@"dvd_btn_switch_off"] forState:UIControlStateNormal];
    }else{
        
        [self.ScreenCurtainBtn setBackgroundImage:[UIImage imageNamed:@"dvd_btn_switch_on"] forState:UIControlStateSelected];
    }
}

- (IBAction)AddScreenCurtainBtn:(id)sender {
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
