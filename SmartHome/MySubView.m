//
//  MySubView.m
//  SmartHome
//
//  Created by zhaona on 2017/2/9.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "MySubView.h"

@implementation MySubView
- (void)drawRect:(CGRect)rect {
    //绘制直线
    CGContextRef context = UIGraphicsGetCurrentContext();
    //设置线的宽度
    CGContextSetLineWidth(context, self.lineWidth);
    //设置线条颜色
    CGContextSetStrokeColorWithColor(context, self.lineColor.CGColor);
    //画直线
    [self drawLine:context];
}

-(void)drawLine:(CGContextRef )context{
    //====用数组的方式绘制多条直线
    if (self.lineArr == nil) {
        return;
    }
    for (int i=0; i<self.lineArr.count; i++) {
        NSValue *value = self.lineArr[i];
        CGLine line;
        [value getValue:&line];
        //确定起始点
        CGContextMoveToPoint(context, line.startPoint.x, line.startPoint.y);
        //添加一条直线
        CGContextAddLineToPoint(context, line.endPoint.x, line.endPoint.y);
        
        //绘图
        CGContextStrokePath(context);
    }
    
}

@end
