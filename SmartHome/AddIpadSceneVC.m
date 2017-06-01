//
//  AddIpadSceneVC.m
//  SmartHome
//
//  Created by zhaona on 2017/6/1.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "AddIpadSceneVC.h"
#import "IpadAddDeviceVC.h"
#import "SQLManager.h"
#import "IpadAddDeviceTypeVC.h"

@interface AddIpadSceneVC ()<IpadAddDeviceVCDelegate>

@end

@implementation AddIpadSceneVC

- (void)viewDidLoad {
    [super viewDidLoad];

    //配置分屏视图界面外观
    self.preferredDisplayMode = UISplitViewControllerDisplayModeAutomatic;
    //调整masterViewController的宽度，按百分比调整
    self.preferredPrimaryColumnWidthFraction = 0.25;
    IpadAddDeviceVC * ipadDeviceVC  = [self.childViewControllers firstObject];
    ipadDeviceVC.roomID = self.roomID;
    ipadDeviceVC.delegate = self;
    ipadDeviceVC.sceneID = self.sceneID;
    self.presentsWithGesture = NO;
    
}
-(void)IpadAddDeviceVC:(IpadAddDeviceVC *)centerListVC selected:(NSInteger)row
{
    UIStoryboard * SceneIpadStoryBoard = [UIStoryboard storyboardWithName:@"Scene-iPad" bundle:nil];
    IpadAddDeviceTypeVC * ipadAddDeviceTypeVC = [SceneIpadStoryBoard instantiateViewControllerWithIdentifier:@"IpadAddDeviceTypeVC"];
    
    switch (row) {
        case 0:{
            
            self.devices = [SQLManager getDevicesIDWithRoomID:self.roomID SubTypeName:@"灯光"];
            ipadAddDeviceTypeVC.deviceIdArr = self.devices;
            
            [self showDetailViewController:ipadAddDeviceTypeVC sender:self];
            break;
        }
        case 1:{
            self.devices = [SQLManager getDevicesIDWithRoomID:self.roomID SubTypeName:@"影音"];
            ipadAddDeviceTypeVC.deviceIdArr = self.devices;
            
            [self showDetailViewController:ipadAddDeviceTypeVC sender:self];
            
            break;
        }
        case 2:{
            self.devices = [SQLManager getDevicesIDWithRoomID:self.roomID SubTypeName:@"环境"];
            ipadAddDeviceTypeVC.deviceIdArr = self.devices;
            
            [self showDetailViewController:ipadAddDeviceTypeVC sender:self];
            
            break;
        }
        case 3:{
            self.devices = [SQLManager getDevicesIDWithRoomID:self.roomID SubTypeName:@"窗帘"];
            ipadAddDeviceTypeVC.deviceIdArr = self.devices;
            
            [self showDetailViewController:ipadAddDeviceTypeVC sender:self];
            
            break;
        }
        case 4:{
            self.devices = [SQLManager getDevicesIDWithRoomID:self.roomID SubTypeName:@"智能单品"];
            ipadAddDeviceTypeVC.deviceIdArr = self.devices;
            
            [self showDetailViewController:ipadAddDeviceTypeVC sender:self];
            
            break;
        }
        case 5:{
            
            self.devices = [SQLManager getDevicesIDWithRoomID:self.roomID SubTypeName:@"安防"];
            ipadAddDeviceTypeVC.deviceIdArr = self.devices;
            
            [self showDetailViewController:ipadAddDeviceTypeVC sender:self];
        }
            
        default:
            break;
            
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
