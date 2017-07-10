//
//  CustomViewController.h
//  SmartHome
//
//  Created by KobeBryant on 2017/4/11.
//  Copyright © 2017年 ECloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomNaviBarView.h"

@interface CustomViewController : UIViewController

@property (nonatomic, readonly) CustomNaviBarView * m_viewNaviBar;

- (void)bringNaviBarToTopmost;
- (void)naviToDevice;

- (void)hideNaviBar:(BOOL)bIsHide;
- (void)setNaviBarTitle:(NSString *)strTitle;
- (void)setNaviBarLeftBtn:(UIButton *)btn;
- (void)setNaviBarRightBtn:(UIButton *)btn;
- (void)setNaviBarRightBtnForSplitView:(UIButton *)btn;
- (void)setNaviMiddletBtn:(UIButton *)btn;
- (void)naviBarAddCoverView:(UIView *)view;
- (void)naviBarAddCoverViewOnTitleView:(UIView *)view;
- (void)naviBarRemoveCoverView:(UIView *)view;
- (void)adjustNaviBarFrameForSplitView;
- (void)showNetStateView;
- (void)showMassegeLabel;
- (void)setNetState:(int)state;
- (void)adjustTitleFrameForSplitView;
@end
