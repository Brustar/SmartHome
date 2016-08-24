//
//  RulerView.m
//  RulerDemo
//
//  Created by wangwendong on 16/3/28.
//  Copyright © 2016年 sunricher. All rights reserved.
//

#import "RulerView.h"

@interface RulerView() 

@property (strong, nonatomic) UIScrollView *itemScrollView;

@property (strong, nonatomic) RulerLeftTagView *leftTagView;

@property (strong, nonatomic) NSLayoutConstraint *leftTagViewWidth;
@property (strong, nonatomic) NSLayoutConstraint *leftTagViewTop;

@property (strong, nonatomic) UIView *header;
@property (strong, nonatomic) UIView *footer;

@property (strong, nonatomic) NSMutableArray *itemsArray;

@property (nonatomic) CGFloat maxY;
@property (nonatomic) CGFloat perYsValue;

@end

@implementation RulerView

- (instancetype)init {
    self = [super init];
    
    if (self) {
        [self setupWithInit];
    }
    
    return self;
}

- (void)awakeFromNib {
    [self setupWithInit];
}

- (void)layoutSubviews {
    CGFloat footerHeight = CGRectGetHeight(self.bounds) - _leftTagTopMargin;
    CGFloat itemsHeight = _itemModel.itemNumberOfRows * _itemModel.itemHeight;
    _footer.frame = CGRectMake(0, _leftTagTopMargin + itemsHeight, 1, footerHeight);
    
    _itemScrollView.contentSize = CGSizeMake(_itemModel.itemWidth, _itemModel.itemHeight * _itemModel.itemNumberOfRows + _leftTagTopMargin + footerHeight);
}

- (void)setDatasource:(id<RulerViewDatasource>)datasource {
    if (!datasource) {
        return;
    }
    
    _datasource = datasource;
    
    [self reloadView];
}

- (void)reloadView {
    
    if (!_datasource) {
        return;
    }
    
    // Items setting
    
    if ([_datasource respondsToSelector:@selector(rulerViewRulerItemModel:)]) {
        _itemModel = [_datasource rulerViewRulerItemModel:self];
    }
    
    // Ruler setting
    
    if ([_datasource respondsToSelector:@selector(rulerViewMaxValue:)]) {
        _maxValue = [_datasource rulerViewMaxValue:self];
    }
    
    if ([_datasource respondsToSelector:@selector(rulerViewMinValue:)]) {
        _minValue = [_datasource rulerViewMinValue:self];
    }
    
    if (_minValue >= _maxValue) {
        _maxValue = _minValue + 1;
    }
    
    // Left Tag setting
    if ([_datasource respondsToSelector:@selector(rulerViewLeftTagLineWidth:)]) {
        _leftTagLineWidth = [_datasource rulerViewLeftTagLineWidth:self];
    }
    
    if ([_datasource respondsToSelector:@selector(rulerViewLeftTagLineHeight:)]) {
        _leftTagLineHeight = [_datasource rulerViewLeftTagLineHeight:self];
    }
    
    if ([_datasource respondsToSelector:@selector(rulerViewLeftTagLineColor:)]) {
        _leftTagLineColor = [_datasource rulerViewLeftTagLineColor:self];
    }
    
    if ([_datasource respondsToSelector:@selector(rulerViewLeftTagTopMargin:)]) {
        _leftTagTopMargin = [_datasource rulerViewLeftTagTopMargin:self];
    }
    
    if (_leftTagViewTop) {
        _leftTagViewTop.constant = _leftTagTopMargin;
        
        [_leftTagView layoutIfNeeded];
    }
    
    if (_leftTagViewWidth) {
        _leftTagViewWidth.constant = _leftTagLineWidth;
        
        [_leftTagView layoutIfNeeded];
    }
    
    if (_leftTagView) {
        [_leftTagView updateWithTagLineWidth:_leftTagLineWidth tagLineHeight:_leftTagLineHeight tagLineColor:_leftTagLineColor];
    }
    
    [self setupItemsView];
}

- (void)updateCurrentValue:(CGFloat)currentValue {
    if (currentValue <= _maxValue && currentValue >= _minValue) {
        _currentValue = currentValue;
        
        CGFloat scrollY = (_currentValue - _minValue) / _perYsValue;
        
        [_itemScrollView setContentOffset:CGPointMake(0, scrollY) animated:YES];
        
        if ([_delegate respondsToSelector:@selector(rulerView:didChangedCurrentValue:)]) {
            //[_delegate rulerView:self didChangedCurrentValue:_maxValue+_minValue-_currentValue];
        }
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    NSLog(@"did scroll");
    
    //[self valueAtScrollPoint:scrollView.contentOffset];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//    NSLog(@"did end decelerating");
    
    //[self valueAtScrollPoint:scrollView.contentOffset];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
//    NSLog(@"did end dragging");
    
    [self valueAtScrollPoint:scrollView.contentOffset];
}

#pragma mark - ------- Private -------
- (void)setupWithInit {
    _itemModel = [[RulerItemModel alloc] init];
    
    _maxValue = 100;
    _minValue = 0;
    
    _currentValue = 0;
    
    _textLabelFont = [UIFont systemFontOfSize:14.f];
    _textLabelColor = [UIColor grayColor];
    _textLabelLeftMargin = 8;
    _itemScrollViewDecelerationRate = 0.1;

    _leftTagLineWidth = 40;
    _leftTagLineHeight = 2;
    _leftTagLineColor = [UIColor redColor];
    _leftTagTopMargin = 50;
    
    [self setupSubviews];
}

- (void)setupSubviews {
    // Left Tag View
    [self setupLeftTagView];
    
    // Item Scroll View
    [self setupItemScrollView];
    
    // Items View
    [self setupItemsView];
}

- (void)setupLeftTagView {
    if (!_leftTagView) {
        _leftTagView = [[RulerLeftTagView alloc] initWithTagLineWidth:_leftTagLineWidth tagLineHeight:_leftTagLineHeight tagLineColor:[UIColor redColor]];
    }
    
    [self addSubview:_leftTagView];
    
    _leftTagView.translatesAutoresizingMaskIntoConstraints = NO;
    
    // Left Tag View Constraints
    NSLayoutConstraint *leftTagViewLeft = [NSLayoutConstraint constraintWithItem:_leftTagView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
    _leftTagViewTop = [NSLayoutConstraint constraintWithItem:_leftTagView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:_leftTagTopMargin];
    _leftTagViewWidth = [NSLayoutConstraint constraintWithItem:_leftTagView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1 constant:_leftTagLineWidth];
    NSLayoutConstraint *leftTagViewBottom = [NSLayoutConstraint constraintWithItem:_leftTagView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    
    [self addConstraints:@[leftTagViewLeft, _leftTagViewTop, _leftTagViewWidth, leftTagViewBottom]];
}

- (void)setupItemScrollView {
    // Item Scroll View
    if (!_itemScrollView) {
        _itemScrollView = [[UIScrollView alloc] init];
    }
    
    _itemScrollView.showsVerticalScrollIndicator = NO;
    _itemScrollView.showsHorizontalScrollIndicator = NO;
    
    _itemScrollView.delegate = self;
    
    [self addSubview:_itemScrollView];
    
    _itemScrollView.translatesAutoresizingMaskIntoConstraints = NO;
    
    // Item Scroll View Constraints
    NSLayoutConstraint *itemScrollViewLeft = [NSLayoutConstraint constraintWithItem:_itemScrollView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_leftTagView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    NSLayoutConstraint *itemScrollViewTop = [NSLayoutConstraint constraintWithItem:_itemScrollView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    NSLayoutConstraint *itemScrollViewRight = [NSLayoutConstraint constraintWithItem:_itemScrollView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:0];
    NSLayoutConstraint *itemScrollViewBottom = [NSLayoutConstraint constraintWithItem:_itemScrollView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    
    [self addConstraints:@[itemScrollViewLeft, itemScrollViewTop, itemScrollViewRight, itemScrollViewBottom]];
}

- (void)setupItemsView {
    if (!_itemScrollView) {
        [self setupItemScrollView];
    }
    
    if (!_itemsArray) {
        _itemsArray = [NSMutableArray array];
    }
    
    // Remove last items
    for (UIView *item in _itemScrollView.subviews) {
        [item removeFromSuperview];
    }
    
    [_itemsArray removeAllObjects];
    
    _itemScrollView.decelerationRate = _itemScrollViewDecelerationRate;
    
    // Add items
    if (_itemModel.itemNumberOfRows < 1) {
        return;
    }
    
    // Add header
    _header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, _leftTagTopMargin)];
    _header.backgroundColor = [UIColor clearColor];
    [_itemScrollView addSubview:_header];
    
    // Add footer
    _footer = [[UIView alloc] init];
    _footer.backgroundColor = [UIColor clearColor];
    [_itemScrollView addSubview:_footer];
    
    CGFloat perItemValue = [self perItemValue];
    
    CGFloat textFontSize = _textLabelFont.pointSize;
    CGFloat textLabelHeight = textFontSize;
    
    for (int i = 0; i < _itemModel.itemNumberOfRows + 1; i++) {
        CGFloat yPosition = i * _itemModel.itemHeight + _leftTagTopMargin;
        
        NSInteger itemValue = round(perItemValue) * i + _minValue;
        NSString *labelText = [NSString stringWithFormat:@"%2.0f", _maxValue + _minValue - (int)itemValue];
        
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(_itemModel.itemMaxLineWidth + _textLabelLeftMargin, yPosition - round(textFontSize / 2.f), RulerViewItemLabelWidth, textLabelHeight)];
        textLabel.font = _textLabelFont;
        textLabel.textColor = _textLabelColor;
        textLabel.text = labelText;
        
        [_itemScrollView addSubview:textLabel];
        
        RulerItem *item = [[RulerItem alloc] initWithRulerItemModel:_itemModel style:RulerItemStyleStandard];
        
        if (i == _itemModel.itemNumberOfRows) {
            item = [[RulerItem alloc] initWithRulerItemModel:_itemModel style:RulerItemStyleSingleLine];
        }
        
        item.frame = CGRectMake(0, yPosition, _itemModel.itemWidth, _itemModel.itemHeight);
        
        [_itemScrollView addSubview:item];
        
        [_itemsArray addObject:item];
    }
    
    // Caculate maxY and perYsValue
    _maxY = _itemModel.itemNumberOfRows * _itemModel.itemHeight;
    _perYsValue = (_maxValue - _minValue) / _maxY;
    
    // Current value
    _currentValue = _minValue;
}

- (CGFloat)perItemValue {
    CGFloat value = 0;
    
    CGFloat diff = _maxValue - _minValue;
    
    if (_itemModel.itemNumberOfRows > 1) {
        value = diff / _itemModel.itemNumberOfRows;
    }
    
    return value;
}

- (CGFloat)valueAtScrollPoint:(CGPoint)scrollPoint {
    CGFloat value = 0;
    
    CGFloat y = scrollPoint.y;
    
    if (y < 0) {
        value = _minValue;
    } else if (y > _maxY) {
        value = _maxValue;
    } else {
        value = y * _perYsValue + _minValue;
    }
    
//    NSLog(@"y %.2f max %.2f", value, _maxY);
    
    _currentValue = _maxValue + _minValue - value;
    
    if ([_delegate respondsToSelector:@selector(rulerView:didChangedCurrentValue:)]) {
        [_delegate rulerView:self didChangedCurrentValue:_currentValue];
    }
    
    return value;
}

@end
