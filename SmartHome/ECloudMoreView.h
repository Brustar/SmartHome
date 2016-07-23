//
//  ECloudMoreView.h
//  SmartHome
//
//  Created by 逸云科技 on 16/7/21.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECloudButton.h"

@protocol ECloudMoreViewDelegate <NSObject>

- (void)moreViewDidSelectWithType:(NSInteger)type subType:(NSInteger)subType;

@end
@interface ECloudMoreView : UIView
@property (nonatomic, weak) id<ECloudMoreViewDelegate> delegate;


- (void)addItemWith:(ECloudButton *)button;

@end
