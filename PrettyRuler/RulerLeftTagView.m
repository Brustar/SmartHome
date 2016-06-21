//
//  RulerLeftTagView.m
//  RulerDemo
//
//  Created by wangwendong on 16/3/28.
//  Copyright © 2016年 sunricher. All rights reserved.
//

#import "RulerLeftTagView.h"

@interface RulerLeftTagView ()

@property (nonatomic) CGFloat tagLineWidth;
@property (nonatomic) CGFloat tagLineHeight;
@property (strong, nonatomic) UIColor *tagLineColor;

@property (strong, nonatomic) UIImageView *arrowImageView;

@end

@implementation RulerLeftTagView

- (instancetype)initWithTagLineWidth:(CGFloat)tagLineWidth tagLineHeight:(CGFloat)tagLineHeight tagLineColor:(UIColor *)tagLineColor {
    self = [super init];
    
    if (self) {
        _tagLineWidth = tagLineWidth;
        _tagLineHeight = tagLineHeight;
        _tagLineColor = tagLineColor;
        
        self.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect {

    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(ctx, _tagLineColor.CGColor);
    CGContextSetLineCap(ctx, kCGLineCapSquare);
    CGContextSetLineWidth(ctx, _tagLineHeight);
    
    CGFloat topLineDiffY = round(_tagLineHeight / 2.f);
    
    CGPoint topLinePoints[] = {
        CGPointMake(0, topLineDiffY),
        CGPointMake(CGRectGetWidth(self.bounds), topLineDiffY)
    };
    
    CGContextStrokeLineSegments(ctx, topLinePoints, 2);
    
    if (!_arrowImageView) {
        _arrowImageView = [[UIImageView alloc] init];
        _arrowImageView.image = [UIImage imageNamed:@"arrow_img.png"];
        _arrowImageView.contentMode = UIViewContentModeScaleAspectFit;
        
        [self addSubview:_arrowImageView];
    }
    
    _arrowImageView.frame = CGRectMake(0, _tagLineHeight, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) - _tagLineHeight);
}

- (void)updateWithTagLineWidth:(CGFloat)tagLineWidth tagLineHeight:(CGFloat)tagLineHeight tagLineColor:(UIColor *)tagLineColor {
    _tagLineWidth = tagLineWidth;
    _tagLineHeight = tagLineHeight;
    _tagLineColor = tagLineColor;
    
    [self setNeedsDisplay];
}

@end
