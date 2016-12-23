//
//  ECloudTabBar.h
//  SmartHome
//
//  Created by 逸云科技 on 16/7/21.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECloudButton.h"
@protocol ECloudTabBarDelegate <NSObject>

- (void)tabBarDidSelectButtonWithType:(NSInteger)type subType:(NSInteger)subType;

@end

@interface ECloudTabBar : UIView
@property (nonatomic, strong) ECloudButton *selectButton;
@property (nonatomic,weak) id<ECloudTabBarDelegate>delegate;

- (void)selectTabBarWithType:(NSInteger)type subType:(NSInteger)subType;
@end
