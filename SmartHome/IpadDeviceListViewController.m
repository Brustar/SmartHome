//
//  IpadDeviceListViewController.m
//  SmartHome
//
//  Created by zhaona on 2017/5/25.
//  Copyright © 2017年 Brustar. All rights reserved.
//ipad的场景详情的 SplitViewController

#import "IpadDeviceListViewController.h"
#import "IpadSceneDetailVC.h"
#import "IphoneNewAddSceneTimerVC.h"
#import "SceneManager.h"
#import "IphoneSaveNewSceneController.h"


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
    self.rightVC.roomID = self.roomID;
    
    
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [LoadMaskHelper showMaskWithType:SceneDetail onView:self.tabBarController.view delay:0.5 delegate:self];
}

- (void)setupNaviBar {
    
    NSString * roomName =[SQLManager getRoomNameByRoomID:self.roomID];
    self.title = [SQLManager getSceneName:self.sceneID];
    [self setNaviBarTitle:[NSString stringWithFormat:@"%@-%@",roomName,self.title]]; //设置标题
    _naviRightBtn = [CustomNaviBarView createNormalNaviBarBtnByTitle:@"保存" target:self action:@selector(rightBtnClicked:)];
    
    [self setNaviBarRightBtn:_naviRightBtn];
}

- (void)rightBtnClicked:(UIButton *)btn {
   
    //     [self performSegueWithIdentifier:@"storeNewScene" sender:self];
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"请选择" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *saveAction = [UIAlertAction actionWithTitle:@"保存" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //场景ID不变
        Scene *scene = [[SceneManager defaultManager] readSceneByID:self.sceneID];
        NSMutableArray *ds = [[scene devices] mutableCopy];
        
        NSArray *devices = [[SceneManager defaultManager] readSceneByID:0].devices;
        
        for (int j=(int)devices.count-1; j>=0; j--) {
            for(int i = (int)ds.count-1;i>=0;i--){
                if ([[ds objectAtIndex:i] class] == [[devices objectAtIndex:j] class] && [[ds objectAtIndex:i] deviceID] == [[devices objectAtIndex:j] deviceID] ) {
                    [ds removeObjectAtIndex:i];
                }
            }
        }
        
        NSArray *temp = [ds arrayByAddingObjectsFromArray:devices];
        
        scene.devices = temp;
        
        [[SceneManager defaultManager] editScene:scene];
    }];
    
    //判断场景的　stype
    int stype = [SQLManager getReadOnly:self.sceneID];
    if (stype == 0) { // 自定义场景
        [alertVC addAction:saveAction];
    }
    
    
    UIAlertAction *saveNewAction = [UIAlertAction actionWithTitle:@"另存为新场景" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //另存为场景，新的场景ID
        
//        [self performSegueWithIdentifier:@"storeNewScene" sender:self];
        UIStoryboard * iphoneStoryBoard = [UIStoryboard storyboardWithName:@"iPhone" bundle:nil];
        IphoneSaveNewSceneController * iphoneSaveNewSceneVC = [iphoneStoryBoard instantiateViewControllerWithIdentifier:@"IphoneSaveNewSceneController"];
        iphoneSaveNewSceneVC.roomId = self.roomID;
        [self.navigationController pushViewController:iphoneSaveNewSceneVC animated:YES];
        
    }];
    [alertVC addAction:saveNewAction];
    
    UIAlertAction *editAction = [UIAlertAction actionWithTitle:@"编辑定时" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //重新编辑场景的定时
        
        UIStoryboard * sceneStoryBoard = [UIStoryboard storyboardWithName:@"Scene" bundle:nil];
        IphoneNewAddSceneTimerVC * newTimerVC = [sceneStoryBoard instantiateViewControllerWithIdentifier:@"IphoneNewAddSceneTimerVC"];
        NSString *sceneFile = [NSString stringWithFormat:@"%@_%d.plist",SCENE_FILE_NAME,self.sceneID];
        NSString *scenePath=[[IOManager scenesPath] stringByAppendingPathComponent:sceneFile];
        NSDictionary *plistDic = [NSDictionary dictionaryWithContentsOfFile:scenePath];
        NSArray * schedules = plistDic[@"schedules"];
        Scene * scene = [[Scene alloc] init];
        scene.schedules = schedules;
        if (scene.schedules.count > 0) {
            for(NSDictionary *dict in schedules)
            {
                NSString *startTime = dict[@"startTime"];
                NSString *endTime = dict[@"endTime"];
                NSArray * weekDays = dict[@"weekDays"];
                NSMutableString *strSelete = [NSMutableString string];
                for (int i = 0; i < weekDays.count; i++) {
                    if ([weekDays[i] intValue]== 0) {
                        [strSelete appendString:@"周日、"];
                    }if ([weekDays[i] intValue]== 1) {
                        [strSelete appendString:@"周一、"];
                    }if ([weekDays[i] intValue]== 2) {
                        [strSelete appendString:@"周二、"];
                    }if ([weekDays[i] intValue]== 3) {
                        [strSelete appendString:@"周三、"];
                    }if ([weekDays[i] intValue]== 4) {
                        [strSelete appendString:@"周四、"];
                    }if ([weekDays[i] intValue]== 5) {
                        [strSelete appendString:@"周五、"];
                    }if ([weekDays[i] intValue]== 6) {
                        [strSelete appendString:@"周六、"];
                    }
                    
                }
                newTimerVC.startTimeStr = startTime;
                newTimerVC.endTimeStr = endTime;
                newTimerVC.repeatitionStr =[NSString stringWithFormat:@"%@",strSelete];
                if ([newTimerVC.repeatitionStr isEqualToString:@"周一、周二、周三、周四、周五、"]) {
                    newTimerVC.repeatitionStr = @"工作日";
                }if ([newTimerVC.repeatitionStr isEqualToString:@"周日、周六、"]) {
                    newTimerVC.repeatitionStr = @"周末";
                }if ([newTimerVC.repeatitionStr isEqualToString:@"周日、周一、周二、周三、周四、周五、周六、"]) {
                    newTimerVC.repeatitionStr = @"每天";
                }
            }
            
        }
        
        newTimerVC.sceneID = self.sceneID;
        newTimerVC.roomid = self.roomID;
        
        [self.navigationController pushViewController:newTimerVC animated:YES];
        
        
    }];
    [alertVC addAction:editAction];
    //    UIAlertAction *favScene = [UIAlertAction actionWithTitle:@"收藏场景" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    //
    //
    //        [self favorScene];
    //
    //    }];
    //    [alertVC addAction:favScene];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [alertVC dismissViewControllerAnimated:YES completion:nil];
    }];
    [alertVC addAction:cancelAction];
    [[DeviceInfo defaultManager] setEditingScene:NO];
    [self presentViewController:alertVC animated:YES completion:nil];
}


-(void)IpadDeviceType:(IpadDeviceTypeVC *)centerListVC selected:(NSInteger)row
{
     self.DevicesArr = [SQLManager getDeviceIDsBySeneId:self.sceneID];
     self.devices = [NSMutableArray array];
     self.leftVC.roomID = self.roomID;
     self.leftVC.sceneID = self.sceneID;
     self.rightVC.sceneID = self.sceneID;
    
    
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

#pragma mark - SingleMaskViewDelegate
- (void)onNextButtonClicked:(UIButton *)btn pageType:(PageTye)pageType {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)onSkipButtonClicked:(UIButton *)btn pageType:(PageTye)pageType {
    [UD setObject:@"haveShownMask" forKey:ShowMaskViewSceneAdd];
    [UD synchronize];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    [NC postNotificationName:@"TabbarPanelClickedNotificationHome" object:nil];
}

- (void)onTransparentBtnClicked:(UIButton *)btn {
    
}

@end
