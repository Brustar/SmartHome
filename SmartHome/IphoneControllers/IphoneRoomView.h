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

- (void)iphoneRoomView:(UIView *)view didSelectButton:(int)index;

@end
@interface IphoneRoomView : UIView
@property (nonatomic,strong) UIScrollView *sv;


@property (nonatomic, strong) NSArray *dataArray;


- (void)setSelectButton:(int)index;


@property (nonatomic, weak) id<IphoneRoomViewDelegate> delegate;
;
@end
