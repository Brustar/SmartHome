//
//  UserInfo.h
//  SmartHome
//
//  Created by KobeBryant on 2017/4/25.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserInfo : NSObject

@property(nonatomic, assign) NSInteger userID;
@property(nonatomic, strong) NSString *userName;
@property(nonatomic, strong) NSString *nickName;
@property(nonatomic, strong) NSString *phoneNum;
@property(nonatomic, strong) NSString *headImgURL;
@property(nonatomic, strong) NSString *vip;
@property(nonatomic, assign) NSInteger age;
@property(nonatomic, assign) NSInteger sex;
@property(nonatomic, assign) NSInteger userType;
@property(nonatomic, strong) NSString *signature;
@property(nonatomic, strong) NSString *endDate;//VIP会员到期时间


@end
