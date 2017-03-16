//
//  LayerUtil.m
//  SmartHome
//
//  Created by Brustar on 2017/3/15.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "LayerUtil.h"

@implementation LayerUtil


+(void) createRing:(CGFloat)radius pos:(CGPoint)pos colors:(NSArray *)colors container:(UIView *)view
{
    long size = colors.count;
    
    for (int i=0; i<size; i++) {
        CAShapeLayer *ringLine =  [CAShapeLayer layer];
        CGMutablePathRef solidPath =  CGPathCreateMutable();
        ringLine.lineWidth = 2.0f ;
        
        ringLine.fillColor = [UIColor clearColor].CGColor;
        
        ringLine.strokeColor = ((UIColor *)colors[i]).CGColor;
        CGFloat start = i * M_PI * 2/size;
        CGFloat end = start + M_PI * 2/size;
        //0 顺时针
        CGPathAddArc(solidPath, nil,pos.x,pos.y,radius-ringLine.lineWidth,start,end,0);
        
        ringLine.path = solidPath;
        CGPathRelease(solidPath);
        [view.layer addSublayer:ringLine];
    }
}

@end
