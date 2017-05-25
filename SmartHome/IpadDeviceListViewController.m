//
//  IpadDeviceListViewController.m
//  SmartHome
//
//  Created by zhaona on 2017/5/25.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "IpadDeviceListViewController.h"


@interface IpadDeviceListViewController ()<IpadDeviceTypeVCDelegate>

@end

@implementation IpadDeviceListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //配置分屏视图界面外观
    self.preferredDisplayMode = UISplitViewControllerDisplayModeAutomatic;
    //调整masterViewController的宽度，按百分比调整
    self.preferredPrimaryColumnWidthFraction = 0.25;
    UINavigationController *roomListNav = [self.childViewControllers firstObject];
    IpadDeviceTypeVC * ipadTypeVC  = [roomListNav.childViewControllers firstObject];
     ipadTypeVC.roomID = self.roomID;
     ipadTypeVC.delegate = self;
    self.presentsWithGesture = NO;
}
-(void)IpadDeviceType:(IpadDeviceTypeVC *)centerListVC selected:(NSInteger)row
{
    switch (row) {
        case 0:{
           self.DevicesArr = [SQLManager getDeviceIDsBySeneId:self.sceneID];
            break;
        }
        case 1:{
             self.DevicesArr = [SQLManager getDeviceIDsBySeneId:self.sceneID];
            break;
        }
        case 2:{
          self.DevicesArr = [SQLManager getDeviceIDsBySeneId:self.sceneID];
            break;
        }
        case 3:{
             self.DevicesArr = [SQLManager getDeviceIDsBySeneId:self.sceneID];
            break;
        }
        case 4:{
             self.DevicesArr = [SQLManager getDeviceIDsBySeneId:self.sceneID];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
