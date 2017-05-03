//
//  Address.h
//  SmartHome
//
//  Created by KobeBryant on 2017/4/29.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Address : NSObject
@property(nonatomic, strong) NSString *userName;
@property(nonatomic, strong) NSString *phoneNum;
@property(nonatomic, assign) NSInteger addressID;
@property(nonatomic, strong) NSString *province;
@property(nonatomic, strong) NSString *city;
@property(nonatomic, strong) NSString *region;
@property(nonatomic, strong) NSString *street;
@property(nonatomic, strong) NSString *addressDetail;
@property(nonatomic, assign) BOOL isDefault;

@end
