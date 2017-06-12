//
//  CustomNaviBarView.h
//  SmartHome
//
//  Created by KobeBryant on 2017/4/11.
//  Copyright © 2017年 ECloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Utilities.h"

@interface CustomNaviBarView : UIView

@property (nonatomic, weak) UIViewController *m_viewCtrlParent;
@property (nonatomic, readonly) BOOL m_bIsCurrStateMiniMode;

+ (CGRect)rightBtnFrameForSplitView;
+ (CGRect)rightBtnFrame;
+ (CGSize)barBtnSize;
+ (CGSize)barSizeForSplitView;
+ (CGSize)barSize;
+ (CGRect)titleViewFrame;
+ (CGRect)titleViewFrameForSplitView;

// 创建一个导航条按钮：使用默认的按钮图片。
+ (UIButton *)createNormalNaviBarBtnByTitle:(NSString *)strTitle target:(id)target action:(SEL)action;

// 创建一个带标题和图片的按钮
+ (UIButton *)createNormalNaviBarBtnByTitle:(NSString *)strTitle imgNormal:(NSString *)strImg imgHighlight:(NSString *)strImgHighlight target:(id)target action:(SEL)action;

// 创建一个导航条按钮：自定义按钮图片。
+ (UIButton *)createImgNaviBarBtnByImgNormal:(NSString *)strImg imgHighlight:(NSString *)strImgHighlight target:(id)target action:(SEL)action;
+ (UIButton *)createImgNaviBarBtnByImgNormal:(NSString *)strImg imgHighlight:(NSString *)strImgHighlight imgSelected:(NSString *)strImgSelected target:(id)target action:(SEL)action;

// 用自定义的按钮和标题替换默认内容
- (void)setBackBtn:(UIButton *)btn;
- (void)setLeftBtn:(UIButton *)btn;
- (void)setRightBtn:(UIButton *)btn;
- (void)setRightBtnForSplitView:(UIButton *)btn;
- (void)setMiddleBtn:(UIButton *)btn;
- (void)setTitle:(NSString *)strTitle;

// 在导航条上覆盖一层自定义视图。比如：输入搜索关键字时，覆盖一个输入框在上面。
- (void)showCoverView:(UIView *)view;
- (void)showCoverView:(UIView *)view animation:(BOOL)bIsAnimation;
- (void)showCoverViewOnTitleView:(UIView *)view;
- (void)hideCoverView:(UIView *)view;

//显示网络状态视图
- (void)showNetStateView;
//设置网络状态
- (void)setNetState:(int)state;
- (void)adjustTitleFrameForSplitView;

@end
