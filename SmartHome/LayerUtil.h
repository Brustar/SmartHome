//
//  LayerUtil.h
//  SmartHome
//
//  Created by Brustar on 2017/3/15.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LayerUtil : NSObject

+(void) createRing:(CGFloat)radius pos:(CGPoint)pos colors:(NSArray *)colors container:(UIView *)view;

@end
