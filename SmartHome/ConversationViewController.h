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

@end
