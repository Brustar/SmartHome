//
//  AddDeviceCell.m
//  SmartHome
//
//  Created by zhaona on 2017/4/11.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "AddDeviceCell.h"
#import "SQLManager.h"
#import "Light.h"
#import "SocketManager.h"
#import "SceneManager.h"

@implementation AddDeviceCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    if (ON_IPAD) {
        self.addBtnHeight.constant = 40;
        self.AddBtnWidth.constant = 40;
        self.AddDeviceBtnTrailing.constant = 30;
        self.addDeviceBtnLeading.constant = 40;
        self.label.textColor = [UIColor whiteColor];
        self.label.font = [UIFont systemFontOfSize:17];
        self.line1.hidden = NO;
        self.line2.hidden = NO;
    }else{
        self.line1.hidden = YES;
        self.line2.hidden = YES;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
