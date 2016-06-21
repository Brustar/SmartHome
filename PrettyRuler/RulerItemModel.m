//
//  RulerItemModel.m
//  RulerDemo
//
//  Created by wangwendong on 16/3/28.
//  Copyright © 2016年 sunricher. All rights reserved.
//

#import "RulerItemModel.h"

@implementation RulerItemModel

- (instancetype)init {
    self = [super init];
    
    if (self) {
        _itemLineColor = [UIColor blackColor];
        _itemMaxLineWidth = 20;
        _itemMinLineWidth = 10;
        _itemMiddleLineWidth = 15;
        _itemLineHeight = 1;
        _itemNumberOfRows = 20;
        _itemHeight = 40;
        _itemWidth = _itemMaxLineWidth;
    }
    
    return self;
}

- (void)setItemMaxLineWidth:(CGFloat)itemMaxLineWidth {
    _itemMaxLineWidth = itemMaxLineWidth;
    
    _itemWidth = _itemMaxLineWidth;
}

@end
