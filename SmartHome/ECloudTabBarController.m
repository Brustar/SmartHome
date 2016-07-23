//
//  ECloudTabBarController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/7/21.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "ECloudTabBarController.h"
#import "ECloudTabBar.h"
#import "ScenseController.h"
@interface ECloudTabBarController ()<ECloudTabBarDelegate>

@end

@implementation ECloudTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    ECloudTabBar *tabBar = [[ECloudTabBar alloc] init];
    tabBar.delegate = self;
    tabBar.frame = self.tabBar.bounds;
    
    [self.tabBar addSubview:tabBar];
    //[self setValue:tabBar forKey:@"tabBar"];
}

- (void)tabBarDidSelectButtonWithType:(NSInteger)type subType:(NSInteger)subType
{
    NSLog(@"%ld  %ld", type, subType);
    
    self.selectedIndex = type;
    if(self.selectedIndex == 0)
    {
        NSString *str = [NSString stringWithFormat:@"%ld", subType];
        NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:str, @"subType", nil];
        
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center postNotificationName:@"subtype" object:nil userInfo:dict];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}



@end
