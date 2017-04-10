//
//  TabbarPanel.h
//  SmartHome
//
//  Created by KobeBryant on 2017/4/6.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TabbarPanelDelegate;

@interface TabbarPanel : UIView

@property(nonatomic, strong) UIImageView *pannelBgView;//背景
@property(nonatomic, strong) UIImageView *pannelSubBgView;//子背景
@property(nonatomic, strong) UIButton *deviceBtn;//设备按钮
@property(nonatomic, strong) UIButton *homeBtn;//home按钮
@property(nonatomic, strong) UIButton *sceneBtn;//场景按钮
@property(nonatomic, strong) UIButton *sliderBtn;//滑动按钮
@property(nonatomic, assign) id<TabbarPanelDelegate> delegate;

@end


@protocol TabbarPanelDelegate <NSObject>

@optional

- (void)onSliderBtnClicked:(UIButton *)sender;

- (void)changeViewController:(UIButton *)sender;

@end
