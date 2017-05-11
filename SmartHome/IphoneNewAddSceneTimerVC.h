//
//  IphoneNewAddSceneTimerVC.h
//  SmartHome
//
//  Created by zhaona on 2017/4/10.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomViewController.h"

@interface IphoneNewAddSceneTimerVC : CustomViewController
@property (weak, nonatomic) IBOutlet UILabel *RepetitionLable;//显示重复日期的label
@property (weak, nonatomic) IBOutlet UIView *DrawView;//画自定义滑杆的视图
@property (weak, nonatomic) IBOutlet UILabel *starTimeLabel;//开始时间
@property (weak, nonatomic) IBOutlet UILabel *endTimeLabel;//结束时间
@property (nonatomic, strong) NSString *naviTitle;
@property (nonatomic, strong) NSMutableArray *weekArray;

@end
