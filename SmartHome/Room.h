//
//  Room.h
//  SmartHome
//
//  Created by 逸云科技 on 16/8/8.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Room : NSObject
@property (nonatomic,assign) int rId;
@property (nonatomic,strong) NSString *rName;
@property (nonatomic,strong) NSString *imgUrl;



+(instancetype)roomWithDict:(NSDictionary *)dict;
@end
