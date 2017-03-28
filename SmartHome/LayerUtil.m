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
    CGFloat temp = M_PI;
    if (size == 2 || size == 3) {
        temp = M_PI/2;
    }
    
    for (int i=0; i<size; i++) {
        CAShapeLayer *ringLine =  [CAShapeLayer layer];
        CGMutablePathRef solidPath =  CGPathCreateMutable();
        ringLine.lineWidth = 2.0f ;
        
        ringLine.fillColor = [UIColor clearColor].CGColor;
        
        ringLine.strokeColor = ((UIColor *)colors[i]).CGColor;
        CGFloat start = temp + i * M_PI * 2/size;
        CGFloat end = start + M_PI * 2/size;
        
        if (i==0 && size == 3) {
            end = M_PI*3/2;
        }else if (i ==1 && size == 3) {
            start = M_PI*3/2;
            end = M_PI*4/2;
        }else if (i ==2 && size == 3) {
            start = M_PI*4/2;
            end = M_PI*5/2;
        }
        //0 顺时针
        CGPathAddArc(solidPath, nil,pos.x,pos.y,radius-ringLine.lineWidth,start,end,0);
        
        ringLine.path = solidPath;
        CGPathRelease(solidPath);
        [view.layer addSublayer:ringLine];
    }
}

@end
