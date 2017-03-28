//
//  TVTableViewCell.h
//  SmartHome
//
//  Created by zhaona on 2017/3/22.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TVTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *TVNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *TVIconeImageView;
@property (weak, nonatomic) IBOutlet UISlider *TVSlider;
@property (weak, nonatomic) IBOutlet UIButton *TVSwitchBtn;

@end
