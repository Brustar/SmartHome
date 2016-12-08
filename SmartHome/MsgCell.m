//
//  MsgCell.m
//  SmartHome
//
//  Created by 逸云科技 on 16/7/16.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "MsgCell.h"

@implementation MsgCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
   self.unreadcountImage.layer.cornerRadius = self.unreadcountImage.bounds.size.width/2; //圆角半径
    self.unreadcountImage.layer.masksToBounds = YES; //圆角
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
