//
//  AirController.h
//  SmartHome
//
//  Created by Brustar on 16/6/17.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AirController : UIViewController

@property (nonatomic,weak) NSString *sceneid;
@property (nonatomic,weak) NSString *deviceid;
@property (nonatomic,strong) NSArray *params;
@property (nonatomic) int currentIndex;
@property (nonatomic) int currentButton;

@end
