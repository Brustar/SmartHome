//
//  RulerItemModel.h
//  RulerDemo
//
//  Created by wangwendong on 16/3/28.
//  Copyright © 2016年 sunricher. All rights reserved.
//

#import <UIKit/UIKit.h>

/// 尺子标注 Label 的宽度
#define RulerViewItemLabelWidth 50.f

@interface RulerItemModel : NSObject

/// 尺子线的颜色
@property (strong, nonatomic) UIColor *itemLineColor;

/// 尺子最长线的宽
@property (nonatomic) CGFloat itemMaxLineWidth;

/// 尺子最短线的宽
@property (nonatomic) CGFloat itemMinLineWidth;

/// 尺子中间线的宽
@property (nonatomic) CGFloat itemMiddleLineWidth;

/// 尺子线的高度
@property (nonatomic) CGFloat itemLineHeight;

/// 尺子大格个数
@property (nonatomic) NSUInteger itemNumberOfRows;

/// 尺子一大格的高度
@property (nonatomic) CGFloat itemHeight;

/// 尺子一大格的宽度（一般等于尺子最长线的宽即可）
@property (nonatomic) CGFloat itemWidth;

@end
