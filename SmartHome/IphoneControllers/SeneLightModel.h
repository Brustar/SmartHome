//
//  SeneLightModel.h
//  SmartHome
//
//  Created by zhaona on 2017/5/15.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger ,SENE_LIGHTS_MODEL) {
    SENE_LIGHTS_MODEL_SOFT  = 0,
    SENE_LIGHTS_MODEL_NORMAL,
    SENE_LIGHTS_MODEL_BRIGHT,
    SENE_LIGHTS_MODEL_CUSTOMER
    
};


@interface SeneLightModel : NSObject

@property (nonatomic,copy) NSString *ID;//
@property (nonatomic,assign)float   value;//灯的亮度
@property (nonatomic,copy) NSString *color;//

@property (nonatomic,assign) int sene_light_model;

@end
