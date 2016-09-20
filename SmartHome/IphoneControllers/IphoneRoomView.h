//
//  IphoneRoomView.h
//  SmartHome
//
//  Created by 逸云科技 on 16/9/20.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IphoneRoomView;
@protocol IphoneRoomViewDelegate <NSObject>



@end
@interface IphoneRoomView : UIView
@property (nonnull,strong) UIScrollView *sv;
-(void)addButtonsInScrollView:(int)count;
@end
