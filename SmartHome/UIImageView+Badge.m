//
//  UIImageView+Badge.m
//  SmartHome
//
//  Created by Brustar on 2017/4/13.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "UIImageView+Badge.h"

@implementation UIImageView (Badge)

float degrees2Radians(float degrees) { return degrees * M_PI / 180; }

CGAffineTransform GetCGAffineTransformRotateAroundPoint(float centerX, float centerY ,float x ,float y ,float angle)
{
    x = x - centerX; //计算(x,y)从(0,0)为原点的坐标系变换到(CenterX ，CenterY)为原点的坐标系下的坐标
    y = y - centerY; //(0，0)坐标系的右横轴、下竖轴是正轴,(CenterX,CenterY)坐标系的正轴也一样
    
    CGAffineTransform  trans = CGAffineTransformMakeTranslation(x, y);
    trans = CGAffineTransformRotate(trans,angle);
    trans = CGAffineTransformTranslate(trans,-x, -y);
    return trans;
}

-(void)badge
{
    UIView *dot = [[UIView alloc] init];
    dot.backgroundColor = [UIColor redColor];
    
    CGRect tabFrame =self.frame;
    CGFloat x =ceilf(0.6 * tabFrame.size.width);
    CGFloat y =ceilf(0.1 * tabFrame.size.height);
    dot.frame =CGRectMake(x, y, 8,8);
    dot.layer.cornerRadius = dot.frame.size.width/2;
    [self addSubview:dot];
}

-(void) rotate:(int)degree
{
    float centerX = self.bounds.size.width/2;
    float centerY = self.bounds.size.height/2;
    float x = self.bounds.size.width/2;
    float y = 0;
    
    CGAffineTransform trans = GetCGAffineTransformRotateAroundPoint(centerX,centerY ,x ,y ,degrees2Radians(degree));
    self.transform = CGAffineTransformIdentity;
    self.transform = trans;
}

-(void) sliderRotate:(int)degree
{
    float centerX = self.bounds.size.width/2;
    float centerY = self.bounds.size.height/2;
    float x = self.bounds.size.width/2;
    float y = 20;
    
    CGAffineTransform trans = GetCGAffineTransformRotateAroundPoint(centerX,centerY ,x ,y ,degrees2Radians(degree));
    self.transform = CGAffineTransformIdentity;
    self.transform = trans;
}


@end
