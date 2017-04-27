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


@end
