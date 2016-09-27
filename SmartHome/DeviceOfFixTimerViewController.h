//
//  DeviceOfFixTimerViewController.h
//  SmartHome
//
//  Created by 逸云科技 on 16/9/27.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DeviceOfFixTimerViewController;
@protocol deviceOfFixTimerViewControllerDelegate <NSObject>

-(void)DeviceOfFixTimerViewController:(DeviceOfFixTimerViewController *)vc andName:(NSString *)deviceName;

@end

@interface DeviceOfFixTimerViewController : UIViewController
@property (nonatomic,weak) id<deviceOfFixTimerViewControllerDelegate> delegate;
@end
