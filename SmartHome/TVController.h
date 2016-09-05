//
//  TVController.h
//  SmartHome
//
//  Created by Brustar on 16/6/7.
//  Copyright © 2016年 Brustar. All rights reserved.
//

@interface TVController : UIViewController

@property (nonatomic,weak) NSString *sceneid;
@property (nonatomic,assign) NSString *deviceid;

@property (nonatomic,assign) NSString *deviceNumber;
@property (strong, nonatomic) Scene *scene;
@property (nonatomic, retain) NSTimer *timer;
@property (nonatomic) int retChannel;
@property (nonatomic,assign) int roomID;

@end
