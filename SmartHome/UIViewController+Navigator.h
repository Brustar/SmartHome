//
//  UIViewController+Navigator.h
//  SmartHome
//
//  Created by Brustar on 2017/5/8.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Navigator)

-(void)popToDevice;

-(void)initMenuContainer:(UIStackView *)menuContainer andArray:(NSArray *)menus andID:(NSString *)deviceid;

@end
