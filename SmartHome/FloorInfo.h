//
//  FloorInfo.h
//  SmartHome
//  楼层信息
//  Created by KobeBryant on 2017/11/20.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FloorInfo : NSObject

@property(nonatomic, assign) NSInteger floor;
@property(nonatomic, strong) NSString *plistPath;
@property(nonatomic, strong) NSString *imgPath;

@end
