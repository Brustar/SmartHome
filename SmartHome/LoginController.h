//
//  LoginController.h
//  SmartHome
//
//  Created by Brustar on 16/11/29.
//  Copyright © 2016年 Brustar. All rights reserved.
//
#import "HttpManager.h"
#import "AppDelegate.h"
@interface LoginController : UIViewController<HttpDelegate>
@property (nonatomic,strong) NSMutableArray * home_room_infoArr;
@property (nonatomic,strong) NSString *UserTypeStr;
@property (nonatomic,strong) NSMutableArray * room_user_listArr;

@end
