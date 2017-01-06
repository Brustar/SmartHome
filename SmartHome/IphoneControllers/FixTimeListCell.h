//
//  FixTimeListCell.h
//  SmartHome
//
//  Created by zhaona on 2016/12/29.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FixTimeListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *sceneNameLabel;//场景名字
@property (weak, nonatomic) IBOutlet UILabel *sceneTimeLabel;//定时时间
@property (weak, nonatomic) IBOutlet UILabel *repetitionLabel;//重复日期
@end
