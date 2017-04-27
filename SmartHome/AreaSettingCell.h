//
//  areaSettingCell.h
//  SmartHome
//
//  Created by 逸云科技 on 16/7/15.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AreaSettingCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *areaLabel;
@property (weak, nonatomic) IBOutlet UILabel *detialLabel;
@property (weak, nonatomic) IBOutlet UIButton *changeBtn;

@property (weak, nonatomic) IBOutlet UISwitch *exchangeSwitch;
@property (weak, nonatomic) IBOutlet UIButton *exchanggeBtn;

@end
