//
//  DVDTableViewCell.h
//  SmartHome
//
//  Created by zhaona on 2017/3/23.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DVDTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *DVDNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *YLImageView;
@property (weak, nonatomic) IBOutlet UISlider *DVDSlider;
@property (weak, nonatomic) IBOutlet UIButton *DVDSwitchBtn;

@end
