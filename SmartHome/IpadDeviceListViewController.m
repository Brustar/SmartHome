//
//  IpadDeviceListViewController.m
//  SmartHome
//
//  Created by zhaona on 2017/5/25.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "IpadDeviceListViewController.h"
#import "IpadSceneDetailVC.h"


@interface IpadDeviceListViewController ()<IpadDeviceTypeVCDelegate>
@property (nonatomic,assign) NSInteger htypeID;

@end

@implementation IpadDeviceListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //配置分屏视图界面外观
    self.preferredDisplayMode = UISplitViewControllerDisplayModeAutomatic;
    //调整masterViewController的宽度，按百分比调整
    self.preferredPrimaryColumnWidthFraction = 0.25;
    IpadDeviceTypeVC * ipadTypeVC  = [self.childViewControllers firstObject];
    ipadTypeVC.roomID = self.roomID;
    ipadTypeVC.delegate = self;
    ipadTypeVC.sceneID = self.sceneID;
    self.presentsWithGesture = NO;
}
-(void)IpadDeviceType:(IpadDeviceTypeVC *)centerListVC selected:(NSInteger)row
{
     self.DevicesArr = [SQLManager getDeviceIDsBySeneId:self.sceneID];
    
    for(int i = 0; i < self.DevicesArr.count; i++){
        
         _htypeID = [SQLManager deviceHtypeIDByDeviceID:[self.DevicesArr[i] intValue]];
    }
    UIStoryboard * SceneIpadStoryBoard = [UIStoryboard storyboardWithName:@"Scene-iPad" bundle:nil];
    IpadSceneDetailVC * ipadSceneDetailVC = [SceneIpadStoryBoard instantiateViewControllerWithIdentifier:@"IpadSceneDetailVC"];
    
    switch (row) {
        case 0:{
             self.devices = [SQLManager getDevicesIDWithRoomID:self.roomID SubTypeName:@"灯光"];
            ipadSceneDetailVC.deviceIdArr = self.devices;
            
            [self showDetailViewController:ipadSceneDetailVC sender:self];

            break;
        }
        case 1:{
              self.devices = [SQLManager getDevicesIDWithRoomID:self.roomID SubTypeName:@"影音"];
            ipadSceneDetailVC.deviceIdArr = self.devices;
            [self showDetailViewController:ipadSceneDetailVC sender:self];
            break;
        }
        case 2:{
            self.devices = [SQLManager getDevicesIDWithRoomID:self.roomID SubTypeName:@"环境"];
            ipadSceneDetailVC.deviceIdArr = self.devices;
            [self showDetailViewController:ipadSceneDetailVC sender:self];
            break;
        }
        case 3:{
              self.devices = [SQLManager getDevicesIDWithRoomID:self.roomID SubTypeName:@"窗帘"];
            ipadSceneDetailVC.deviceIdArr = self.devices;
            [self showDetailViewController:ipadSceneDetailVC sender:self];
            break;
        }
        case 4:{
              self.devices = [SQLManager getDevicesIDWithRoomID:self.roomID SubTypeName:@"智能单品"];
            ipadSceneDetailVC.deviceIdArr = self.devices;
            [self showDetailViewController:ipadSceneDetailVC sender:self];
            break;
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
