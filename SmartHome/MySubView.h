//
//  MySubView.h
//  SmartHome
//
//  Created by zhaona on 2017/2/9.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CGLine.h"

@interface MySubView : UIView

//线条宽度
@property (nonatomic,assign) int lineWidth;
//线条颜色
@property (nonatomic,strong) UIColor *lineColor;
//需要绘制多少条线的数组
@property (nonatomic,strong)NSMutableArray *lineArr;

@end