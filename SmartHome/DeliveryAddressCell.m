//
//  DeliveryAddressCell.m
//  SmartHome
//
//  Created by KobeBryant on 2017/4/29.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "DeliveryAddressCell.h"

@implementation DeliveryAddressCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)selectBtnClicked:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(onSelectBtnClicked:)]) {
        [_delegate onSelectBtnClicked:sender];
    }
}

- (IBAction)deleteBtnClicked:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(onDeleteBtnClicked:)]) {
        [_delegate onDeleteBtnClicked:sender];
    }
}

- (IBAction)editBtnClicked:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(onEditBtnClicked:)]) {
        [_delegate onEditBtnClicked:sender];
    }
}

- (void)setAddress:(Address *)info {
    self.nameLabel.text = info.userName;
    self.phoneLabel.text = info.phoneNum;
    self.addressLabel.text = [NSString stringWithFormat:@"%@%@%@%@%@", info.province, info.city, info.region, info.street, info.addressDetail];
    if (info.isDefault) {
        [self.selectBtn setImage:[UIImage imageNamed:@"icon_choose_prd"] forState:UIControlStateSelected];
        self.selectBtn.selected = YES;
        self.selectTitleLabel.text = @"默认地址";
        self.selectTitleLabel.textColor = [UIColor redColor];
    }else {
        [self.selectBtn setImage:[UIImage imageNamed:@"icon_choose_nol"] forState:UIControlStateNormal];
        self.selectBtn.selected = NO;
        self.selectTitleLabel.text = @"设为默认";
        self.selectTitleLabel.textColor = [UIColor whiteColor];
    }
}
@end
