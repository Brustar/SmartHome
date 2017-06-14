//
//  IpadDeviceListViewController.m
//  SmartHome
//
//  Created by zhaona on 2017/5/25.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "IpadDeviceListViewController.h"
#import "IpadSceneDetailVC.h"


@interface IpadDeviceListViewController ()<IpadDeviceTypeVCDelegate,NowMusicControllerDelegate>
@property (nonatomic,assign) NSInteger htypeID;
@property (nonatomic,strong) IpadDeviceTypeVC * leftVC;
@property (nonatomic,strong) IpadSceneDetailVC * rightVC;
@property (nonatomic,strong) UIButton * naviRightBtn;


@end

@implementation IpadDeviceListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // 初始化分割视图控制器
    UISplitViewController *splitViewController = [[UISplitViewController alloc] init];
    
    //初始化左边视图控制器
    UIStoryboard * SceneStoryBoard = [UIStoryboard storyboardWithName:@"Scene-iPad" bundle:nil];
    self.leftVC= [SceneStoryBoard instantiateViewControllerWithIdentifier:@"IpadDeviceTypeVC"];
    
    self.leftVC.delegate = self;
    //初始化右边视图控制器
    self.rightVC = [SceneStoryBoard instantiateViewControllerWithIdentifier:@"IpadSceneDetailVC"];
    
    // 设置分割面板的 2 个视图控制器
    splitViewController.viewControllers = @[self.leftVC, self.rightVC];
    
    // 添加到窗口
    [self addChildViewController:splitViewController];
    //配置分屏视图界面外观
    splitViewController.preferredDisplayMode = UISplitViewControllerDisplayModeAutomatic;
    //调整masterViewController的宽度，按百分比调整
    splitViewController.preferredPrimaryColumnWidthFraction = 0.25;
    
    [self.view addSubview:splitViewController.view];
    
    [self setupNaviBar];
}

- (void)setupNaviBar {
    
    NSString * roomName =[SQLManager getRoomNameByRoomID:self.roomID];
    self.title = [SQLManager getSceneName:self.sceneID];
    [self setNaviBarTitle:[NSString stringWithFormat:@"%@-%@",roomName,self.title]]; //设置标题
    
    _naviRightBtn = [CustomNaviBarView createNormalNaviBarBtnByTitle:@"保存" target:self action:@selector(rightBtnClicked:)];
    
    [self setNaviBarRightBtn:_naviRightBtn];
}

- (void)rightBtnClicked:(UIButton *)btn {
   
}


-(void)IpadDeviceType:(IpadDeviceTypeVC *)centerListVC selected:(NSInteger)row
{
     self.DevicesArr = [SQLManager getDeviceIDsBySeneId:self.sceneID];
     self.devices = [NSMutableArray array];
    
    
    switch (row) {
        case 0:{
            
            for(int i = 0; i < self.DevicesArr.count; i++){
                
                NSString *deviceTypeName = [SQLManager getSubTypeNameByDeviceID:[self.DevicesArr[i] intValue]];
                if ([deviceTypeName isEqualToString:@"灯光"]) {
                    [self.devices addObject:self.DevicesArr[i]];
                }
            }
            
             [self.rightVC refreshData:self.devices];
             self.leftVC.DevicesArr = self.devices;

            break;
        }
        case 1:{

            for(int i = 0; i < self.DevicesArr.count; i++){
                
                NSString *deviceTypeName = [SQLManager getSubTypeNameByDeviceID:[self.DevicesArr[i] intValue]];
                if ([deviceTypeName isEqualToString:@"影音"]) {
                    [self.devices addObject:self.DevicesArr[i]];
                }
            }
            [self.rightVC refreshData:self.devices];
            self.leftVC.DevicesArr = self.devices;
            break;
        }
        case 2:{

            for(int i = 0; i < self.DevicesArr.count; i++){
                
                NSString *deviceTypeName = [SQLManager getSubTypeNameByDeviceID:[self.DevicesArr[i] intValue]];
                if ([deviceTypeName isEqualToString:@"环境"]) {
                    [self.devices addObject:self.DevicesArr[i]];
                }
            }
             [self.rightVC refreshData:self.devices];
             self.leftVC.DevicesArr = self.devices;
            break;
        }
        case 3:{

            for(int i = 0; i < self.DevicesArr.count; i++){
                
                NSString *deviceTypeName = [SQLManager getSubTypeNameByDeviceID:[self.DevicesArr[i] intValue]];
                if ([deviceTypeName isEqualToString:@"窗帘"]) {
                    [self.devices addObject:self.DevicesArr[i]];
                }
            }
               [self.rightVC refreshData:self.devices];
               self.leftVC.DevicesArr = self.devices;
            break;
        }
        case 4:{
            for(int i = 0; i < self.DevicesArr.count; i++){
                
                NSString *deviceTypeName = [SQLManager getSubTypeNameByDeviceID:[self.DevicesArr[i] intValue]];
                if ([deviceTypeName isEqualToString:@"智能单品"]) {
                    [self.devices addObject:self.DevicesArr[i]];
                }
            }
             [self.rightVC refreshData:self.devices];
             self.leftVC.DevicesArr = self.devices;
            break;
        }
        case 5:{
            for(int i = 0; i < self.DevicesArr.count; i++){
                
                NSString *deviceTypeName = [SQLManager getSubTypeNameByDeviceID:[self.DevicesArr[i] intValue]];
                if ([deviceTypeName isEqualToString:@"安防"]) {
                    [self.devices addObject:self.DevicesArr[i]];
                }
            }
            [self.rightVC refreshData:self.devices];
             self.leftVC.DevicesArr = self.devices;
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
