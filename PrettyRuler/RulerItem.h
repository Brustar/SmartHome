//
//  RulerItem.h
//  RulerDemo
//
//  Created by wangwendong on 16/3/28.
//  Copyright © 2016年 sunricher. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RulerItemModel.h"

typedef NS_ENUM(NSInteger, RulerItemStyle) {
    RulerItemStyleStandard,
    RulerItemStyleSingleLine
};

@interface RulerItem : UIView

- (instancetype)initWithRulerItemModel:(RulerItemModel *)itemModel style:(RulerItemStyle)style;

- (void)reloadItemByItemModel:(RulerItemModel *)itemModel;

@end
