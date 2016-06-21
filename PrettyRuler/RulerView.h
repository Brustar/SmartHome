//
//  RulerView.h
//  RulerDemo
//
//  Created by wangwendong on 16/3/28.
//  Copyright © 2016年 sunricher. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RulerItem.h"
#import "RulerLeftTagView.h"

@protocol RulerViewDatasource;

@protocol RulerViewDelegate;

@interface RulerView : UIView<UIScrollViewDelegate>

// Ruler

/// 尺子最大值
@property (nonatomic, readonly) CGFloat maxValue;

/// 尺子最小值
@property (nonatomic, readonly) CGFloat minValue;

/// 尺子标注的字体大小
@property (strong, nonatomic, readonly) UIFont *textLabelFont;

/// 尺子标注的颜色
@property (strong, nonatomic, readonly) UIColor *textLabelColor;

/// 尺子标注离左边最长线的距离
@property (nonatomic, readonly) CGFloat textLabelLeftMargin;

/// 尺子滑动结束后的减速力度（0最大，1最小）
@property (nonatomic, readonly) CGFloat itemScrollViewDecelerationRate;

// Item
/// 画尺子的数据
@property (strong, nonatomic, readonly) RulerItemModel *itemModel;

// Left Tag

/// 左边标线的宽度
@property (nonatomic, readonly) CGFloat leftTagLineWidth;

/// 左边标线的高度
@property (nonatomic, readonly) CGFloat leftTagLineHeight;

/// 左边标线的颜色
@property (strong, nonatomic, readonly) UIColor *leftTagLineColor;

/// 左边标线离顶端的距离
@property (nonatomic, readonly) CGFloat leftTagTopMargin;

// Methods

/// 刷新视图
- (void)reloadView;

// Datasource and Delegate

@property (weak, nonatomic) id<RulerViewDatasource> datasource;
@property (weak, nonatomic) id<RulerViewDelegate> delegate;

// Value
@property (nonatomic, setter=updateCurrentValue:) CGFloat currentValue;

@end

@protocol RulerViewDatasource <NSObject>

@optional

// Item setting

- (RulerItemModel *)rulerViewRulerItemModel:(RulerView *)rulerView;

// Ruler setting

- (CGFloat)rulerViewMaxValue:(RulerView *)rulerView;

- (CGFloat)rulerViewMinValue:(RulerView *)rulerView;

- (UIFont *)rulerViewTextLabelFont:(RulerView *)rulerView;

- (UIColor *)rulerViewTextLabelColor:(RulerView *)rulerView;

- (CGFloat)rulerViewTextlabelLeftMargin:(RulerView *)rulerView;

- (CGFloat)rulerViewItemScrollViewDecelerationRate:(RulerView *)rulerView;

// Left Tag setting

- (CGFloat)rulerViewLeftTagLineWidth:(RulerView *)rulerView;

- (CGFloat)rulerViewLeftTagLineHeight:(RulerView *)rulerView;

- (UIColor *)rulerViewLeftTagLineColor:(RulerView *)rulerView;

- (CGFloat)rulerViewLeftTagTopMargin:(RulerView *)rulerView;

@end

@protocol RulerViewDelegate <NSObject>

@optional

- (void)rulerView:(RulerView *)rulerView didChangedCurrentValue:(CGFloat)currentValue;

@end
