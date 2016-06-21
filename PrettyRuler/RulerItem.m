//
//  RulerItem.m
//  RulerDemo
//
//  Created by wangwendong on 16/3/28.
//  Copyright © 2016年 sunricher. All rights reserved.
//

#import "RulerItem.h"

@interface RulerItem ()

@property (strong, nonatomic) RulerItemModel *itemModel;

@property (nonatomic) RulerItemStyle itemStyle;

@end

@implementation RulerItem

- (instancetype)initWithRulerItemModel:(RulerItemModel *)itemModel style:(RulerItemStyle)style {
    self = [super init];
    
    if (self) {
        if (itemModel) {
            _itemModel = itemModel;
        } else {
            _itemModel = [[RulerItemModel alloc] init];
        }
        
        self.layer.masksToBounds = NO;
        self.backgroundColor = [UIColor clearColor];
        
        _itemStyle = style;
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect {
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(ctx, _itemModel.itemLineHeight);
    CGContextSetLineCap(ctx, kCGLineCapSquare);
    CGContextSetStrokeColorWithColor(ctx, _itemModel.itemLineColor.CGColor);
    
    CGFloat perHeight = round(_itemModel.itemHeight / 10.f);
    
    CGFloat diff = round(_itemModel.itemLineHeight / 2.f);
    
    if (_itemStyle == RulerItemStyleStandard) {
         const CGPoint points[] = {CGPointMake(0, diff), CGPointMake(_itemModel.itemMaxLineWidth, diff),
            CGPointMake(0, perHeight + diff), CGPointMake(_itemModel.itemMinLineWidth, perHeight + diff),
            CGPointMake(0, perHeight * 2 + diff), CGPointMake(_itemModel.itemMinLineWidth, perHeight * 2 + diff),
            CGPointMake(0, perHeight * 3 + diff), CGPointMake(_itemModel.itemMinLineWidth, perHeight * 3 + diff),
            CGPointMake(0, perHeight * 4 + diff), CGPointMake(_itemModel.itemMinLineWidth, perHeight * 4 + diff),
            CGPointMake(0, perHeight * 5 + diff), CGPointMake(_itemModel.itemMiddleLineWidth, perHeight * 5 + diff),
            CGPointMake(0, perHeight * 6 + diff), CGPointMake(_itemModel.itemMinLineWidth, perHeight * 6 + diff),
            CGPointMake(0, perHeight * 7 + diff), CGPointMake(_itemModel.itemMinLineWidth, perHeight * 7 + diff),
            CGPointMake(0, perHeight * 8 + diff), CGPointMake(_itemModel.itemMinLineWidth, perHeight * 8 + diff),
            CGPointMake(0, perHeight * 9 + diff), CGPointMake(_itemModel.itemMinLineWidth, perHeight * 9 + diff),
        };
        
        CGContextStrokeLineSegments(ctx, points, 20);
    } else if (_itemStyle == RulerItemStyleSingleLine) {
        const CGPoint points[] = {CGPointMake(0, diff), CGPointMake(_itemModel.itemMaxLineWidth, diff)};
        
        CGContextStrokeLineSegments(ctx, points, 2);
    }
}

- (void)reloadItemByItemModel:(RulerItemModel *)itemModel {
    if (!itemModel) {
        return;
    }
    
    _itemModel = itemModel;
    
    [self setNeedsDisplay];
}

@end
