//
//  ColourCell.h
//  SmartHome
//
//  Created by zhaona on 2017/1/24.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ColourCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *deviceName;
@property (weak, nonatomic) IBOutlet UIButton *changeColourBtn;

@property (weak, nonatomic) IBOutlet UISwitch *myswitch;


@end
