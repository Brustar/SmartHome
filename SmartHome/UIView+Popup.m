//
//  UIView+Popup.m
//  SmartHome
//
//  Created by Brustar on 2017/4/26.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "UIView+Popup.h"
#import <PopupKit/PopupView.h>

@implementation UIView (Popup)

-(void) show
{
    // Show in popup
    PopupViewLayout layout = PopupViewLayoutMake(PopupViewHorizontalLayoutCenter,PopupViewVerticalLayoutCenter);
    
    PopupView* popup = [PopupView popupViewWithContentView:self
                                                  showType:PopupViewShowTypeBounceInFromTop
                                               dismissType:PopupViewDismissTypeBounceOutToBottom
                                                  maskType:PopupViewMaskTypeDimmed
                            shouldDismissOnBackgroundTouch:YES shouldDismissOnContentTouch:NO];
    [popup showWithLayout:layout];
}

-(void) dismiss
{
    [self dismissPresentingPopup];
}

@end
