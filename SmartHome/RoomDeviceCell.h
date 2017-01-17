//
//  RoomDeviceCell.h
//  SmartHome
//
//  Created by 逸云科技 on 2016/11/28.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RoomDeviceCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *deviceName;
@property (weak, nonatomic) IBOutlet UISlider *deviceSlider;
@property (weak, nonatomic) IBOutlet UISwitch *deviceSwitch;
@property (weak,nonatomic) NSString *deviceid;
@property (weak, nonatomic) IBOutlet UIImageView *lowIcon;
@property (weak, nonatomic) IBOutlet UIImageView *highIcon;


@end
