//
//  DeviceType.h
//  SmartHome
//
//  Created by 逸云科技 on 16/8/12.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceType : NSObject
//
@property (nonatomic,assign) int hTypeId;
@property (nonatomic,strong) NSString *typeName;
@property (nonatomic,strong) NSArray *types;

@end
