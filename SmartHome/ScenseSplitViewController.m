//
//  ScenseSplitViewController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/7/22.
//  Copyright © 2016年 Brustar. All rights reserved.
//
#define backGroudColour [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1]
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
-(void)showDataPicker
{

    UIDatePicker * dataPicker = [[UIDatePicker alloc] init];
    dataPicker.frame = CGRectMake(400, 260, 400,400);
    dataPicker.backgroundColor = backGroudColour;
//    dataPicker.hidden = YES;
    dataPicker.datePickerMode = UIDatePickerModeDate;
    [self.view addSubview:dataPicker];
}
@end
