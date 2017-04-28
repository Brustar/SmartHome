//
//  SystemCell.h
//  SmartHome
//
//  Created by 逸云科技 on 16/7/18.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SystemCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *title;

@property (weak, nonatomic) IBOutlet UISwitch *turnSwitch;

@property (weak, nonatomic) IBOutlet UIButton *sysyTemSwitchBtn;

@end
