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
#import "CustomViewController.h"
#import "DeviceListTimeVC.h"
#import "IphoneEditSceneController.h"
#import "DeviceTimingViewController.h"
#import "SceneManager.h"
#import "IphoneSaveNewSceneController.h"
#import "IpadDeviceListViewController.h"

@interface AddIpadSceneVC ()<IpadAddDeviceVCDelegate>

@property (nonatomic,strong)CustomViewController * customViewVC;
@property (nonatomic,strong)UIButton * rightBtn;
@property (nonatomic,strong)IpadAddDeviceVC * leftVC;
@property (nonatomic,strong)IpadAddDeviceTypeVC * rightVC;
@property (nonatomic,strong) NSArray * viewControllerArrs;

@end

@implementation AddIpadSceneVC

- (void)viewDidLoad {
    [super viewDidLoad];

  
    // 初始化分割视图控制器
    UISplitViewController *splitViewController = [[UISplitViewController alloc] init];
    
    //初始化左边视图控制器
    UIStoryboard * SceneStoryBoard = [UIStoryboard storyboardWithName:@"Scene-iPad" bundle:nil];
     self.leftVC= [SceneStoryBoard instantiateViewControllerWithIdentifier:@"IpadAddDeviceVC"];

    self.leftVC.delegate = self;
    self.leftVC.roomID = self.roomID;
    //初始化右边视图控制器
    self.rightVC = [SceneStoryBoard instantiateViewControllerWithIdentifier:@"IpadAddDeviceTypeVC"];
    self.rightVC.roomID = self.roomID;
    self.rightVC.sceneID = self.sceneID;
    self.rightVC.scene  = _scene;
    // 设置分割面板的 2 个视图控制器
    splitViewController.viewControllers = @[self.leftVC, self.rightVC];
    
    // 添加到窗口
    [self addChildViewController:splitViewController];
    //配置分屏视图界面外观
    splitViewController.preferredDisplayMode = UISplitViewControllerDisplayModeAutomatic;
    //调整masterViewController的宽度，按百分比调整
    splitViewController.preferredPrimaryColumnWidthFraction = 0.25;
    
    [self.view addSubview:splitViewController.view];
//    _scene = [[Scene alloc] init];
    [self setupNaviBar];
    
}

- (void)setupNaviBar {
    
    [self setNaviBarTitle:@"添加场景"]; //设置标题

    _naviRightBtn = [CustomNaviBarView createNormalNaviBarBtnByTitle:@"保存" target:self action:@selector(rightBtnClicked:)];
   
    [self setNaviBarRightBtn:_naviRightBtn];
}

- (void)rightBtnClicked:(UIButton *)btn {
   
    _viewControllerArrs =self.navigationController.viewControllers;
    NSInteger vcCount = _viewControllerArrs.count;
    UIViewController * lastVC = _viewControllerArrs[vcCount -2];
    UIStoryboard * iphoneStoryBoard = [UIStoryboard storyboardWithName:@"iPhone" bundle:nil];
    UIStoryboard * SceneStoryBoard = [UIStoryboard storyboardWithName:@"Scene" bundle:nil];
    DeviceListTimeVC * deviceListVC = [iphoneStoryBoard instantiateViewControllerWithIdentifier:@"iPhoneDeviceListTimeVC"];
    
    IpadDeviceListViewController * ipadDeviceListVC = [[IpadDeviceListViewController alloc] init];
    
    if ([lastVC isKindOfClass:[deviceListVC class]]) {
        DeviceTimingViewController * deviceTimingVC = [SceneStoryBoard instantiateViewControllerWithIdentifier:@"DeviceTimingViewController"];
        [self.navigationController pushViewController:deviceTimingVC animated:YES];
        
    }else if ([lastVC isKindOfClass:[ipadDeviceListVC class]]) {
        
        //场景ID不变
        NSString *sceneFile = [NSString stringWithFormat:@"%@_%d.plist",SCENE_FILE_NAME,self.sceneID];
        NSString *scenePath=[[IOManager scenesPath] stringByAppendingPathComponent:sceneFile];
        NSDictionary *plistDic = [NSDictionary dictionaryWithContentsOfFile:scenePath];
        
        _scene = [[Scene alloc]init];
        [_scene setValuesForKeysWithDictionary:plistDic];
        _scene.roomID = self.roomID;
        _scene.sceneID = self.sceneID;
        
        [[SceneManager defaultManager] editScene:_scene];
        
    }else{
//        if (_scene.devices.count != 0) {
        
            IphoneSaveNewSceneController * iphoneSaveNewScene = [iphoneStoryBoard instantiateViewControllerWithIdentifier:@"IphoneSaveNewSceneController"];
            iphoneSaveNewScene.roomId = self.roomID;
            [self.navigationController pushViewController:iphoneSaveNewScene animated:YES];
//        }

//        else{
//            [MBProgressHUD showSuccess:@"请先选择设备"];
//            
//        }
    
    }
    
}
-(void)IpadAddDeviceVC:(IpadAddDeviceVC *)centerListVC selected:(NSInteger)row
{

     self.rightVC.roomID = self.roomID;
     self.rightVC.sceneID = self.sceneID;
    
    switch (row) {
        case 0:{
            
            self.devices = [SQLManager getDevicesIDWithRoomID:self.roomID SubTypeName:@"灯光"];

            [self.rightVC refreshData:self.devices];

            break;
        }
        case 1:{
            self.devices = [SQLManager getDevicesIDWithRoomID:self.roomID SubTypeName:@"影音"];
            
             [self.rightVC refreshData:self.devices];
            
            break;
        }
        case 2:{
            self.devices = [SQLManager getDevicesIDWithRoomID:self.roomID SubTypeName:@"环境"];
            
               [self.rightVC refreshData:self.devices];
            
            break;
        }
        case 3:{
            self.devices = [SQLManager getDevicesIDWithRoomID:self.roomID SubTypeName:@"窗帘"];
            
               [self.rightVC refreshData:self.devices];
            
            break;
        }
        case 4:{
            self.devices = [SQLManager getDevicesIDWithRoomID:self.roomID SubTypeName:@"智能单品"];
            
               [self.rightVC refreshData:self.devices];
            
            break;
        }
        case 5:{
            
            self.devices = [SQLManager getDevicesIDWithRoomID:self.roomID SubTypeName:@"安防"];
            
               [self.rightVC refreshData:self.devices];
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
