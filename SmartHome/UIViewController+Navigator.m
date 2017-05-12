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
    NSString *targetName=@"";
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Devices" bundle:nil];
    
    switch (uid) {
        case DVDtype:
            targetName = @"DVDController";
            break;
        case TVtype:
            targetName = @"TVController";
            break;
        case FM:
            targetName = @"FMController";
            break;
        case amplifier:
            targetName = @"AmplifierController";
            break;
        case projector:
            targetName = @"ProjectorController";
            break;
        case screen:
            targetName = @"ScreenController";
            break;
        case bgmusic:
            targetName = @"BgMusicController";
            break;
            
        case plugin:
            targetName = @"PluginController";
            break;
        case windowOpener:
            targetName = @"WindowSlidingController";
            break;
        case flowering:
            targetName = @"FloweringController";
            break;
        case feeding:
            targetName = @"FeedingController";
            break;
        
        case Wetting:
            targetName = @"WettingController";
            break;
        default:
            break;
    }
    UIViewController *target = [storyboard instantiateViewControllerWithIdentifier:targetName];
    [self.navigationController pushViewController:target animated:NO];
}

@end
