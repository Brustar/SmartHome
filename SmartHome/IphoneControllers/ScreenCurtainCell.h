//
//  ScreenCurtainCell.h
//  SmartHome
//
//  Created by zhaona on 2017/4/11.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScreenCurtainCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *ScreenCurtainLabel;
@property (weak, nonatomic) IBOutlet UIButton *UPBtn;
@property (weak, nonatomic) IBOutlet UIButton *stopBtn;
@property (weak, nonatomic) IBOutlet UIButton *DownBtn;
@property (weak, nonatomic) IBOutlet UISwitch *PowerSwitch;
@property (weak, nonatomic) IBOutlet UIButton *ScreenCurtainBtn;

@end
