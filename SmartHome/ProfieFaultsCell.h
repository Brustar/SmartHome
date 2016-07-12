//
//  ProfieFaultsCell.h
//  SmartHome
//
//  Created by 逸云科技 on 16/7/11.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfieFaultsCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *title;

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *alertImageView;

@property (weak, nonatomic) IBOutlet UIButton *selectedBtn;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *selectBtnWidth;

@end
