//
//  EnenCell.m
//  SmartHome
//
//  Created by zhaona on 2017/1/5.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "EnenCell.h"

@implementation EnenCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.subView.layer.masksToBounds = YES;
    self.subView.layer.cornerRadius = 5;
  
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
