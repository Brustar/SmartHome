//
//  AireTableViewCell.h
//  SmartHome
//
//  Created by zhaona on 2017/3/22.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AireTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *deviceNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *temperatureLabel;
@property (weak, nonatomic) IBOutlet UISlider *AireSlider;
@property (weak, nonatomic) IBOutlet UIButton *AireSwitchBtn;
@property (nonatomic,assign) int roomID;
@property(nonatomic,strong) NSString * sceneID;
//硬件id
@property (weak,nonatomic) NSString *deviceid;
@end
