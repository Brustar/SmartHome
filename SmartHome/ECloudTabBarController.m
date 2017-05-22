//
//  ECloudTabBarController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/7/21.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "ECloudTabBarController.h"
#import "ECloudTabBar.h"
#import "SceneController.h"
#import "Room.h"

@interface ECloudTabBarController ()<ECloudTabBarDelegate>
@property (nonatomic,strong) ECloudTabBar *cloudTabBar;
@property (nonatomic,assign) NSString *ibeaconStr;
@end

@implementation ECloudTabBarController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    ECloudTabBar *tabBar = [[ECloudTabBar alloc] init];
    tabBar.delegate = self;
    tabBar.frame = self.tabBar.bounds;
    self.cloudTabBar = tabBar;
    [self.tabBar addSubview:tabBar];
    //[self setValue:tabBar forKey:@"tabBar"];
    
    
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //[self tabBarDidSelectButtonWithType:self.cloudTabBar.selectButton.type subType:self.cloudTabBar.selectButton.subType];
    NSDictionary *dict = @{
                           @"type":@(1),
                           @"subType":@(0)
                           };
    [NC postNotificationName:@"tabBar" object:nil userInfo:dict];
}


- (void)tabBarDidSelectButtonWithType:(NSInteger)type subType:(NSInteger)subType
{
    self.selectedIndex = type;
    if(type!= self.selectedIndex)
    {
        self.selectedIndex = type;
    }
    if(self.selectedIndex == 0) //场景
    {
        NSString *str = [NSString stringWithFormat:@"%d", (int)subType];
        NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:str, @"subType",nil ];
       // NSDictionary *dict = @{@"type":[NSNumber numberWithInteger:type],@"subType":[NSNumber numberWithInteger:subType]};
        
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center postNotificationName:@"subType" object:nil userInfo:dict];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end
