//
//  CustomSliderViewController.h
//  SmartHome
//
//  Created by KobeBryant on 2017/10/17.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SocketManager.h"
#import "SQLManager.h"

@interface CustomSliderViewController : UIViewController
@property (weak, nonatomic) IBOutlet UISlider *lightSlider;
@property(nonatomic, copy)  NSString *deviceid;

@end
