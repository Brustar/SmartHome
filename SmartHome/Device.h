//
//  Device.h
//  SmartHome
//
//  Created by 逸云科技 on 16/8/5.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Device : NSObject

@property (nonatomic,assign) NSInteger eId;
@property (nonatomic,strong) NSString *eNumber;
@property (nonatomic,strong) NSString *eName;
@property (nonatomic,strong) NSString *hTypeId;
@property (nonatomic,strong) NSString *typeName;
@property (nonatomic,assign) NSInteger subTypeId;
@property (nonatomic,strong) NSString *subTypeName;

+ (instancetype)deviceWithDict:(NSDictionary *)dict;
@end
