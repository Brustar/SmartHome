//
//  Light.h
//  SmartHome
//
//  Created by Brustar on 16/5/23.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "Device.h"

@interface Light : Device

//颜色
@property (nonatomic) NSArray *color;
//亮度
@property (nonatomic) int brightness;

@end
