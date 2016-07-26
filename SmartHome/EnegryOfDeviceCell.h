//
//  EnegryOfDeviceCell.h
//  SmartHome
//
//  Created by 逸云科技 on 16/7/20.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EnegryOfDeviceCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *deviceName;
@property (weak, nonatomic) IBOutlet UILabel *energyOfDevice;
@property (weak, nonatomic) IBOutlet UIImageView *imgView;

@end
