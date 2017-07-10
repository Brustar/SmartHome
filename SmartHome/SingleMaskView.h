//
//  SingleMaskView.h
//
//  Created by KobeBryant on 17/6/23.
//  Copyright © 2017年 Ecloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SingleMaskViewDelegate;


@interface SingleMaskView : UIView

/**
 *  蒙版颜色(非透明区颜色，默认黑色0.5透明度)
 */
@property (nonatomic, strong) UIColor *maskColor;

@property (nonatomic, strong) UIButton *nextBtn;
@property (nonatomic, strong) UIButton *skipBtn;

@property (nonatomic, weak) id<SingleMaskViewDelegate>delegate;

@property (nonatomic, assign) PageTye pageType;

/**
 *  添加矩形透明按钮
 */
- (void)addTransparentBtn:(CGRect)rect tag:(NSInteger)tag;

/**
 *  添加矩形透明区(位置和弧度)
 */
- (void)addTransparentRect:(CGRect)rect withRadius:(CGFloat)radius;

/**
 *  添加圆形透明区
 */
- (void)addTransparentOvalRect:(CGRect)rect;

/**
 *  添加图片(图片和位置)
 */
- (void)addImage:(UIImage*)image withFrame:(CGRect)frame;



/**   在指定view上显示蒙版（过渡动画）
 *   不调用用此方法可使用 addSubview:自己添加展示
 */
- (void)showMaskViewInView:(UIView *)view;

/**
 *  销毁蒙版view(默认点击空白区自动销毁)
 */
- (void)dismissMaskView;

@end


@protocol SingleMaskViewDelegate <NSObject>

@optional
- (void)onNextButtonClicked:(UIButton *)btn pageType:(PageTye)pageType;
- (void)onSkipButtonClicked:(UIButton *)btn;
- (void)onTransparentBtnClicked:(UIButton *)btn;

@end
