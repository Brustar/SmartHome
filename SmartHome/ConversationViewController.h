//
//  ConversationViewController.h
//  IM Demo
//
//  Created by Brustar on 2017/3/8.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RongIMKit/RongIMKit.h>
#import "CustomNaviBarView.h"

@interface ConversationViewController : RCConversationViewController

@property (nonatomic, readonly) CustomNaviBarView *m_viewNaviBar;
@property (nonatomic, readonly) UIButton *naviRightBtn;
@property (nonatomic, assign) BOOL isShowInSplitView;//ipad版，聊天页面在splitView中展示

- (void)setNaviBarTitle:(NSString *)strTitle;


@end
