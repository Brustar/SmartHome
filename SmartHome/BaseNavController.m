//
//  BaseNavController.m
//
//  Created by kobe on 17/3/15.
//  Copyright © 2017年 Ecloud. All rights reserved.
//

#import "BaseNavController.h"

@interface BaseNavController ()

@end

@implementation BaseNavController

- (void)viewDidLoad {
    [super viewDidLoad];

//    [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"navBg3"]
//                            forBarPosition:UIBarPositionAny
//                                barMetrics:UIBarMetricsDefault];
    self.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    self.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationBar.barTintColor = [UIColor colorWithRed:44/255.0 green:185/255.0 blue:176/255.0 alpha:1];

}

















- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end
