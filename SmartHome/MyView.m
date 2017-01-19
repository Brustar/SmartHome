//
//  MyView.m
//  SmartHome
//
//  Created by zhaona on 2017/1/19.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "MyView.h"

@implementation MyView

- (void)drawRect:(CGRect)rect {
    //绘制直线
    CGContextRef context = UIGraphicsGetCurrentContext();
    //设置线的宽度
    CGContextSetLineWidth(context, self.lineWidth);
    //设置线条颜色
    CGContextSetStrokeColorWithColor(context, self.lineColor.CGColor);
    //画直线
    [self drawLine:context];
    //画文字
    [self drawText:context];
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
-(void)drawText:(CGContextRef)context{
    NSArray *times = @[@"12A",@"4A",@"8A",@"12P",@"4P",@"8P",@"12A"];
    //===获取字体宽度
    int fontSize = 12;
    if (self.textSize!=0) {
        fontSize = self.textSize;
    }
    NSDictionary *attrs = @{NSFontAttributeName : [UIFont boldSystemFontOfSize:fontSize]};
    CGSize size=[times[0] sizeWithAttributes:attrs];
    CGFloat textWidth = size.width;
    CGFloat totalWidth = self.bounds.size.width;
    //绘制最后一个文字
    [times[0] drawAtPoint:CGPointMake(0, 30) withAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor],NSFontAttributeName:[UIFont systemFontOfSize:fontSize]}];
    //平分宽度
    CGFloat iWidth = (totalWidth-7*textWidth)/([times count]-1);
    for (int i=1; i<times.count-1; i++) {
        CGFloat x = i*(iWidth+textWidth);
        //利用现有文字画文字
        [times[i] drawAtPoint:CGPointMake(x, 30) withAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor],NSFontAttributeName:[UIFont systemFontOfSize:fontSize]}];
    }
    
    //绘制最后一个文字
    [times[times.count-1] drawAtPoint:CGPointMake(self.bounds.size.width-textWidth, 30) withAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor],NSFontAttributeName:[UIFont systemFontOfSize:fontSize]}];
    
}

@end
