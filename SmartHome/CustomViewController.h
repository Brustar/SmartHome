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

- (void)bringNaviBarToTopmost;

- (void)hideNaviBar:(BOOL)bIsHide;
- (void)setNaviBarTitle:(NSString *)strTitle;
- (void)setNaviBarLeftBtn:(UIButton *)btn;
- (void)setNaviBarRightBtn:(UIButton *)btn;

- (void)naviBarAddCoverView:(UIView *)view;
- (void)naviBarAddCoverViewOnTitleView:(UIView *)view;
- (void)naviBarRemoveCoverView:(UIView *)view;


@end
