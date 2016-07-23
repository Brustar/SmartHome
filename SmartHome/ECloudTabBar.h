//
//  ECloudTabBar.h
//  SmartHome
//
//  Created by 逸云科技 on 16/7/21.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ECloudTabBarDelegate <NSObject>

- (void)tabBarDidSelectButtonWithType:(NSInteger)type subType:(NSInteger)subType;


@end

@interface ECloudTabBar : UIView

@property (nonatomic,weak) id<ECloudTabBarDelegate>delegate;
@end
