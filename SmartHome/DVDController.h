#import "CustomViewController.h"
//
//  DVDController.h
//  SmartHome
//
//  Created by Brustar on 16/6/7.
//  Copyright © 2016年 Brustar. All rights reserved.
//

@interface DVDController : CustomViewController

@property (nonatomic,weak) NSString *sceneid;
@property (nonatomic,weak) NSString *deviceid;
@property (nonatomic,assign) int roomID;

@property (nonatomic,assign) BOOL isAddDevice;
@end
