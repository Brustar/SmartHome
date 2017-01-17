//
//  EnenCell.h
//  SmartHome
//
//  Created by zhaona on 2017/1/5.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EnenCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *weekLabel;

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *ViewLabel;
@property (weak, nonatomic) IBOutlet UILabel *ViewSubViewLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *subViewLayout;

@property (weak, nonatomic) IBOutlet UIView *timeViewLabel;
@property (weak, nonatomic) IBOutlet UILabel *energyLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *SubViewConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *subViewWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *subViewX;

@end
