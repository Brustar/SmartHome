//
//  LoadMaskHelper.h
//
//
//  Created by KobeBryant on 17/6/23.
//  Copyright © 2017年 Ecloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SingleMaskView.h"


@interface LoadMaskHelper : NSObject

/*
    使用方法： [LoadMaskHelper showMaskWithType:HomePage onView:self.view delay:0.5];
*/


/**
 *  显示蒙版  （ 页面蒙版类型 要在那个view展示 延时几秒展示）
 */
+ (void)showMaskWithType:(PageTye)pageType onView:(UIView*)view delay:(NSTimeInterval)delay delegate:(id)delegate;

/**
 *  版本升级则重置蒙版，加载新蒙版
 */
+ (void)checkAPPVersion;

@end
