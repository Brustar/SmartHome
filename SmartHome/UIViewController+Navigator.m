//
//  UIViewController+Navigator.m
//  SmartHome
//
//  Created by Brustar on 2017/5/8.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "UIViewController+Navigator.h"
#import "IphoneDeviceListController.h"
#import "SQLManager.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@implementation UIViewController (Navigator)

-(void)popToDevice
{
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:[IphoneDeviceListController class]]) {
            [self.navigationController popToViewController:vc animated:YES];
        }
    }
}


-(void)initMenuContainer:(UIStackView *)menuContainer andArray:(NSArray *)menus andID:(NSString *)deviceid
{
    for(Device *device in menus)
    {
        if ([deviceid isEqualToString:@""]) {
            [self jumpUI:device.hTypeId];
            return;
        }
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.contentMode = UIViewContentModeScaleAspectFit;
        
        [btn setBackgroundImage:[UIImage imageNamed:@"light_bar"] forState:UIControlStateNormal];
        if ([deviceid intValue] == device.eID) {
            [btn setBackgroundImage:[UIImage imageNamed:@"light_bar_pressed"] forState:UIControlStateNormal];
        }
        [btn setTitle:device.typeName forState:UIControlStateNormal];
        if (([UIScreen mainScreen].bounds.size.height == 568.0)) {
            btn.titleLabel.font = [UIFont systemFontOfSize: 11.0];
        }else{
            btn.titleLabel.font = [UIFont systemFontOfSize: 13.0];
        }
        [[btn rac_signalForControlEvents:UIControlEventTouchUpInside]
         subscribeNext:^(id x) {
             [self jumpUI:device.hTypeId];
         }];
        [menuContainer addArrangedSubview:btn];
        [menuContainer layoutIfNeeded];
    }
}

-(void) jumpUI:(NSInteger)uid
{
    [self.navigationController pushViewController:[DeviceInfo calcController:uid] animated:NO];
}

@end
