//
//  WeekdaysVC.h
//  SmartHome
//
//  Created by zhaona on 2017/1/11.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomViewController.h"

@protocol WeekdaysVCDelegate;

@interface WeekdaysVC : UIViewController

@property (nonatomic, assign) id<WeekdaysVCDelegate>delegate;

@end

@protocol WeekdaysVCDelegate <NSObject>

@optional

-(void)onWeekButtonClicked:(UIButton *)button;

@end
