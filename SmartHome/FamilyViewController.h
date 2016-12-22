//
//  FamilyViewController.h
//  SmartHome
//
//  Created by KobeBryant on 2016/12/21.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FamilyViewController : UIViewController
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
@end
