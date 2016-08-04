//
//  Detail.h
//  SmartHome
//
//  Created by 逸云科技 on 16/6/1.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Detail : NSObject

@property (nonatomic,assign) NSInteger ID;


+(NSArray *)getAllDetails;
+(NSArray *)getAllDevicesWith:(NSDictionary *)responseObject;
@end
