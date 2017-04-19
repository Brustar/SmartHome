//
//  NewColourCell.h
//  SmartHome
//
//  Created by zhaona on 2017/4/19.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewColourCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *colourNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *colourBtn;
@property (weak, nonatomic) IBOutlet UISlider *colourSlider;
@property (weak, nonatomic) IBOutlet UIImageView *supimageView;
@property (weak, nonatomic) IBOutlet UIImageView *lowImageView;
@property (weak, nonatomic) IBOutlet UIImageView *highImageView;

@end
