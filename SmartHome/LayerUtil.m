//
//  LayerUtil.m
//  SmartHome
//
//  Created by Brustar on 2017/3/15.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "LayerUtil.h"

@implementation LayerUtil


+ (void)createRing:(CGFloat)radius pos:(CGPoint)pos colors:(NSArray *)colors container:(UIView *)view
{
    CGFloat startAngle = 5/6*M_PI;
    NSInteger size = colors.count;
    
    NSArray *subLayersArray = [NSArray arrayWithArray:[view.layer sublayers]];
    for(CAShapeLayer *subLayer in subLayersArray) {
        if ([subLayer isKindOfClass:[CAShapeLayer class]] && subLayer.lineWidth == 2) {
            [subLayer removeFromSuperlayer];
        }
    }
    
    for (NSInteger i=0; i < size; i++) {
        CAShapeLayer *ringLine =  [CAShapeLayer layer];
        CGMutablePathRef solidPath =  CGPathCreateMutable();
        ringLine.lineWidth = 2.0f ;
        
        ringLine.fillColor = [UIColor clearColor].CGColor;
        
        ringLine.strokeColor = ((UIColor *)colors[i]).CGColor;
        CGFloat start = startAngle + i * M_PI * 2/size;
        CGFloat end = start + M_PI * 2/size;
        
        //0 顺时针
        CGPathAddArc(solidPath, nil,pos.x,pos.y,radius-ringLine.lineWidth,start,end,0);
        
        ringLine.path = solidPath;
        CGPathRelease(solidPath);
        [view.layer addSublayer:ringLine];
    }
}

+ (void)createRingForPM25:(CGFloat)radius pos:(CGPoint)pos colors:(NSArray *)colors pm25Value:(CGFloat)pm25Value container:(UIView *)view
{
    CGFloat startAngle = 0.7*M_PI;
    NSInteger size = colors.count;
    NSInteger pm25_parm = 100;
    CGFloat end = 0;
    
    if (pm25Value >50 && pm25Value <=90) {
        pm25_parm = 190;
    }else if (pm25Value >90 && pm25Value <=200) {
        pm25_parm = 230;
    }else if (pm25Value >200 && pm25Value <=300) {
        pm25_parm = 310;
    }else if (pm25Value >300 && pm25Value <= 400) {
        pm25_parm = 370;
    }
    
    NSArray *subLayersArray = [NSArray arrayWithArray:[view.layer sublayers]];
    for(CAShapeLayer *subLayer in subLayersArray) {
        if ([subLayer isKindOfClass:[CAShapeLayer class]] && subLayer.lineWidth == 14) {
            [subLayer removeFromSuperlayer];
        }
    }
    
    for (NSInteger i=0; i < size; i++) {
        CAShapeLayer *ringLine =  [CAShapeLayer layer];
        CGMutablePathRef solidPath =  CGPathCreateMutable();
        ringLine.lineWidth = 14.0f;
        ringLine.fillColor = [UIColor clearColor].CGColor;
        
        ringLine.strokeColor = ((UIColor *)colors[i]).CGColor;
        CGFloat start = startAngle + i * M_PI * 2/size;
        end = start + pm25Value/pm25_parm * M_PI;
        
        if (pm25Value > 400) {
            end = 9/4*M_PI;
        }
        
        //0 顺时针
        CGPathAddArc(solidPath, nil,pos.x,pos.y,radius-ringLine.lineWidth,start,end,0);
        
        ringLine.path = solidPath;
        CGPathRelease(solidPath);
        [view.layer addSublayer:ringLine];
    }
}



/*+(void) createRing:(CGFloat)radius pos:(CGPoint)pos colors:(NSArray *)colors container:(UIView *)view
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
}*/


@end
