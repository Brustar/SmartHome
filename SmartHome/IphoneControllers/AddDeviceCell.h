//
//  AddDeviceCell.h
//  SmartHome
//
//  Created by zhaona on 2017/4/11.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddDeviceCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *AddDeviceBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addDeviceBtnLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *AddDeviceBtnTrailing;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *AddBtnWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addBtnHeight;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIView *line1;
@property (weak, nonatomic) IBOutlet UIView *line2;

@end
