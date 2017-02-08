//
//  IphoneFamilyViewController.h
//  SmartHome
//
//  Created by 逸云科技 on 2016/11/11.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IphoneFamilyViewController : UIViewController
@property(nonatomic, strong)NSString *nest_access_token;
@property(nonatomic, strong)NSString *nest_user;
@property(nonatomic, strong)NSString *nest_user_id;
@property(nonatomic, strong)NSString *nest_transport_url;
@property(nonatomic, strong)NSString *nest_status_req_url;
@property(nonatomic, strong)NSDictionary *nest_status_req_header;
@property(nonatomic, strong)NSMutableArray *nest_devices_arr;
@property(nonatomic, strong)NSMutableArray *nest_curr_temperature_arr;
@property(nonatomic, strong)NSMutableArray *nest_curr_humidity_arr;
@property(nonatomic, strong)NSMutableArray *nest_en_room_name_arr;
@property(nonatomic, strong)NSString * deviceid;

@end
