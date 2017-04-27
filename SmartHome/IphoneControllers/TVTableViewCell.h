//
//  TVTableViewCell.h
//  SmartHome
//
//  Created by zhaona on 2017/3/23.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TVTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *TVNameLabel;
@property (weak, nonatomic) IBOutlet UISlider *TVSlider;
@property (weak, nonatomic) IBOutlet UISwitch *TVSwitch;
@property (weak, nonatomic) IBOutlet UIButton *TVSwitchBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *TVConstraint;
@property (weak, nonatomic) IBOutlet UIButton *AddTvDeviceBtn;
@property(nonatomic, strong)NSString * deviceid;
@property (nonatomic,weak) NSString *sceneid;
//房间id
@property (nonatomic,assign) NSInteger roomID;
@property (strong, nonatomic) Scene *scene;
@end
