//
//  IphoneTypeView.h
//  SmartHome
//
//  Created by 逸云科技 on 16/10/11.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>


@class IphoneTypeView;


@protocol IphoneTypeViewDelegate <NSObject>

- (void)iphoneTypeView:(IphoneTypeView *)typeView didSelectButton:(int)index;

@end


@interface IphoneTypeView : UIView

- (void)addItemWithTitle:(NSString *)title imageName:(NSString *)imageName;

- (void)clearItem;

- (void)setSelectButton:(int)index;

@property (nonatomic, weak) id<IphoneTypeViewDelegate> delegate;
@end
