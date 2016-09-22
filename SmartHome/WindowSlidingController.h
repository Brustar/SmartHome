//
//  WindowSlidingController.h
//  SmartHome
//
//  Created by 逸云科技 on 16/9/22.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WindowSlidingController : UIViewController
@property (nonatomic,weak) NSString *sceneid;
@property (nonatomic,weak) NSString *deviceid;
@property (nonatomic,assign) int roomID;
@property (nonatomic,assign) BOOL isAddDevice;

@property (strong, nonatomic) Scene *scene;
@end
