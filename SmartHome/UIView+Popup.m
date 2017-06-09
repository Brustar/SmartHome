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
    
    if (ON_IPAD) {
        popup = [PopupView popupViewWithContentView:self
                                           showType:PopupViewShowTypeBounceInFromRight
                                        dismissType:PopupViewDismissTypeBounceOutToLeft
                                           maskType:PopupViewMaskTypeDimmed
                     shouldDismissOnBackgroundTouch:YES shouldDismissOnContentTouch:NO];
    }
    [popup showWithLayout:layout];
}

-(void) dismiss
{
    [self dismissPresentingPopup];
}

// Recursively travel down the view tree, increasing the indentation level for children
- (void) dumpView:(int) indent into:(NSMutableString *) outstring
{
    for (int i = 0; i < indent; i++) [outstring appendString:@"--"];
    [outstring appendFormat:@"[%2d] %@\n", indent, [[self class] description]];
    for (UIView *view in [self subviews]) [view dumpView:indent + 1 into:outstring];
}

// Start the tree recursion at level 0 with the root view
- (void) displayViews
{
    NSMutableString *outstring = [[NSMutableString alloc] init];
    [self dumpView:0 into:outstring];
    NSLog(@"%@",outstring);
}

-(void) constraintToCenter:(int)size
{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint * constraintX = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f];
    //创建y居中的约束
    NSLayoutConstraint* constraintY = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f];
    
    //创建宽度约束
    NSLayoutConstraint * constraintW = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:size];
    //创建高度约束
    NSLayoutConstraint * constraintH = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:size];
    constraintH.active=constraintX.active = constraintY.active = constraintW.active =YES;
}

@end
