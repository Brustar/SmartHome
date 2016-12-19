//
//  LoginController.h
//  SmartHome
//
//  Created by Brustar on 16/11/29.
//  Copyright © 2016年 Brustar. All rights reserved.
//
#import "HttpManager.h"
@interface LoginController : UIViewController<HttpDelegate>
@property (nonatomic,strong) NSMutableArray * home_room_infoArr;
@end
