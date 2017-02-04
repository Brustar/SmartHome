//
//  IphoneAirCell.h
//  SmartHome
//
//  Created by zhaona on 2017/1/23.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IphoneAirCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *deviceNameLabel;
@property (weak, nonatomic) IBOutlet UISwitch *IphoneSwitch;
@property (nonatomic,strong) NSString * deviceId;

@end
