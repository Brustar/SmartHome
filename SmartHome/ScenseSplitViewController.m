//
//  ScenseSplitViewController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/7/22.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "ScenseSplitViewController.h"
#import "RoomListController.h"
#import "DeviceListController.h"

@interface ScenseSplitViewController () <RoomListControllerDelegate,UISplitViewControllerDelegate>

@end
@implementation ScenseSplitViewController


-(void)viewDidLoad
{
    [super viewDidLoad];
    
    
   
   
    UINavigationController *roomListNav = [self.childViewControllers firstObject];
    RoomListController *roomListVC  = [roomListNav.childViewControllers firstObject];
    roomListVC.delegate = self;
    self.presentsWithGesture = NO;
}
-(void)RoomListControllerDelegate:(RoomListController *)roomListCV SelectedRoom:(NSInteger)RoomID
{
    UINavigationController *deviceList = [self.childViewControllers lastObject];
    DeviceListController *deviceVC = [deviceList.childViewControllers firstObject];
    deviceVC.roomid = RoomID;
    [deviceList popToRootViewControllerAnimated:YES];
}

@end
