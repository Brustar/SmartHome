//
//  UIImageView+Badge.m
//  SmartHome
//
//  Created by Brustar on 2017/4/13.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "UIImageView+Badge.h"

@implementation UIImageView (Badge)

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

@end
