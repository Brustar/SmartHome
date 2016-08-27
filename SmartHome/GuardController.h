//
//  GuardController.h
//  SmartHome
//
//  Created by Brustar on 16/6/13.
//  Copyright © 2016年 Brustar. All rights reserved.
//
@interface GuardController : UIViewController<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,weak) NSString *sceneid;
@property (nonatomic,weak) NSString *deviceid;
@property (nonatomic,assign) int roomID;
@property (nonatomic, retain) NSTimer *timer;

@end
