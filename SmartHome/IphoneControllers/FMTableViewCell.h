//
//  FMTableViewCell.h
//  SmartHome
//
//  Created by zhaona on 2017/4/17.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FMTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *FMNameLabel;
@property (weak, nonatomic) IBOutlet UISlider *FMSlider;//音量
@property (weak, nonatomic) IBOutlet UISlider *FMChannelSlider;//调节频道
@property (weak, nonatomic) IBOutlet UILabel *FMChannelLabel;
@property (weak, nonatomic) IBOutlet UIButton *AddFmBtn;

@end
