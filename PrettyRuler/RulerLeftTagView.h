//
//  RulerLeftTagView.h
//  RulerDemo
//
//  Created by wangwendong on 16/3/28.
//  Copyright © 2016年 sunricher. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RulerLeftTagView : UIView

- (instancetype)initWithTagLineWidth:(CGFloat)tagLineWidth tagLineHeight:(CGFloat)tagLineHeight tagLineColor:(UIColor *)tagLineColor;

- (void)updateWithTagLineWidth:(CGFloat)tagLineWidth tagLineHeight:(CGFloat)tagLineHeight tagLineColor:(UIColor *)tagLineColor;

@end
