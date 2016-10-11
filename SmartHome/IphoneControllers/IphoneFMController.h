//
//  IphoneFMController.h
//  SmartHome
//
//  Created by 逸云科技 on 16/9/24.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IphoneFMController : UIViewController
@property (nonatomic,weak) NSString *sceneid;
@property (nonatomic,weak) NSString *deviceid;
@property (nonatomic,assign) int roomID;
@property (strong, nonatomic) Scene *scene;
@property (nonatomic,assign) BOOL isAddDevice;
@end
