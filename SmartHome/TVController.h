//
//  TVController.h
//  SmartHome
//
//  Created by Brustar on 16/6/7.
//  Copyright © 2016年 Brustar. All rights reserved.
//
#import "public.h"

@interface TVController : UIViewController

@property (nonatomic,weak) NSString *sceneid;
@property (nonatomic,strong) NSString *deviceid;
@property (strong, nonatomic) IBeacon *beacon;


@end
