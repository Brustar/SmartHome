//
//  iPadMyViewController.h
//  SmartHome
//
//  Created by KobeBryant on 2017/6/12.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LeftViewController.h"
#import "CustomViewController.h"
#import "BaseTabBarController.h"

@interface iPadMyViewController : UIViewController<LeftViewControllerDelegate>

@property(nonatomic, strong) LeftViewController *leftVC;
@property(nonatomic, strong) UINavigationController *rightVC;
@property(nonatomic, strong) CustomViewController *rootVC;
@property(nonatomic, strong) NSString *currentItem;

@end
