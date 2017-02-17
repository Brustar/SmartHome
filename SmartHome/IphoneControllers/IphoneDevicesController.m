//
//  IphoneDevicesController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/9/26.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "IphoneDevicesController.h"
#import "SQLManager.h"
#import "IphoneDeviceListController.h"
#import "LightController.h"
#import "CurtainController.h"
#import "IphoneTVController.h"
#import "IphoneDVDController.h"
#import "IphoneNetTvController.h"
#import "FMController.h"
#import "IphoneAirController.h"
#import "PluginViewController.h"
#import "CameraController.h"
#import "GuardController.h"
#import "ScreenCurtainController.h"
#import "ProjectController.h"
#import "IphoneRoomView.h"
#import "MBProgressHUD+NJ.h"
#import "AmplifierController.h"
#import "WindowSlidingController.h"
#import "BgMusicController.h"
#import "IphoneSceneAirVC.h"
#import "IPhoneSceneDVDVC.h"
#import "IPhoneTVVC.h"
#import "IPhoneNetVV.h"


@interface IphoneDevicesController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSArray *deviceTypes;
@end

@implementation IphoneDevicesController

-(void)setRoomId:(int)roomId
{
    _roomId = roomId;
//    if (_roomId) {
//       self.deviceTypes = [SQLManager deviceSubTypeByRoomId:_roomId];
//    }else{
//        self.deviceTypes = [SQLManager getAllDevices];
//    }
    self.deviceTypes = [SQLManager deviceSubTypeByRoomId:_roomId];
  
    
    self.automaticallyAdjustsScrollViewInsets = NO;
   // self.tableViewHight.constant = self.deviceTypes.count * self.tableView.rowHeight;
    if(self.isViewLoaded)
    {
        
        [self.tableView reloadData];
    }
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIView *view = [[UIView alloc] init];
    [view setBackgroundColor:[UIColor clearColor]];
    self.tableView.tableFooterView = view;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.deviceTypes.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(!cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = self.deviceTypes[indexPath.row];

    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *typeName = self.deviceTypes[indexPath.row];
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIStoryboard *iphoneBoard  = [UIStoryboard storyboardWithName:@"iPhone" bundle:nil];
    if([typeName isEqualToString:@"网络电视"])
    {
//        IphoneTVController *tVC = [iphoneBoard instantiateViewControllerWithIdentifier:@"IphoneTVController"];
        IPhoneTVVC * tVC = [iphoneBoard instantiateViewControllerWithIdentifier:@"IPhoneTVVC"];
        tVC.roomID = self.roomId;
        tVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneId];
        tVC.isAddDevice = YES;
        [self.navigationController pushViewController:tVC animated:YES];
        
        
        
    }else if([typeName isEqualToString:@"灯光"])
    {
        LightController *ligthVC = [storyBoard instantiateViewControllerWithIdentifier:@"LightController"];
        ligthVC.roomID = self.roomId;
        ligthVC.showLightView = NO;
        ligthVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneId];
        ligthVC.isAddDevice = YES;
        [self.navigationController pushViewController:ligthVC animated:YES];
        
    }else if([typeName isEqualToString:@"窗帘"])
    {
        CurtainController *curtainVC = [storyBoard instantiateViewControllerWithIdentifier:@"CurtainController"];
        curtainVC.roomID = self.roomId;
        curtainVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneId];
        curtainVC.isAddDevice = YES;
         [self.navigationController pushViewController:curtainVC animated:YES];
        
        
    }else if([typeName isEqualToString:@"DVD"])
    {
        
//        IphoneDVDController *dvdVC = [iphoneBoard instantiateViewControllerWithIdentifier:@"IphoneDVDController"];
        IPhoneSceneDVDVC * dvdVC = [iphoneBoard instantiateViewControllerWithIdentifier:@"IPhoneSceneDVDVC"];
        dvdVC.roomID = self.roomId;
        dvdVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneId];
        dvdVC.isAddDevice = YES;
         [self.navigationController pushViewController:dvdVC animated:YES];
        
        
    }else if([typeName isEqualToString:@"FM"])
    {
        FMController *fmVC = [iphoneBoard instantiateViewControllerWithIdentifier:@"IphoneFMController"];
        fmVC.roomID = self.roomId;
        fmVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneId];
        fmVC.isAddDevice = YES;
         [self.navigationController pushViewController:fmVC animated:YES];
    }else if([typeName isEqualToString:@"空调"])
    {
        IphoneAirController *airVC = [iphoneBoard instantiateViewControllerWithIdentifier:@"IphoneAirController"];
//        IphoneSceneAirVC * airVC = [iphoneBoard instantiateViewControllerWithIdentifier:@"IphoneSceneAirVC"];
        airVC.roomID = self.roomId;
        airVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneId];
        airVC.isAddDevice = YES;
        [self.navigationController pushViewController:airVC animated:YES];
        
    }else if([typeName isEqualToString:@"机顶盒"]){
//        IphoneNetTvController *netVC = [iphoneBoard instantiateViewControllerWithIdentifier:@"IphoneNetTvController"];
        IPhoneNetVV * netVC = [iphoneBoard instantiateViewControllerWithIdentifier:@"IPhoneNetVV"];
        netVC.roomID = self.roomId;
        netVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneId];
        
         [self.navigationController pushViewController:netVC animated:YES];
        
    }else if([typeName isEqualToString:@"摄像头"]){
        CameraController *camerVC = [storyBoard instantiateViewControllerWithIdentifier:@"CameraController"];
        camerVC.roomID = self.roomId;
        camerVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneId];
        camerVC.isAddDevice = YES;
       [self.navigationController pushViewController:camerVC animated:YES];
        
    }else if([typeName isEqualToString:@"智能门锁"]){
        GuardController *guardVC = [storyBoard instantiateViewControllerWithIdentifier:@"GuardController"];
        guardVC.roomID = self.roomId;
        guardVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneId];
        guardVC.isAddDevice = YES;
        [self.navigationController pushViewController:guardVC animated:YES];
        
        
    }else if([typeName isEqualToString:@"幕布"]){
        ScreenCurtainController *screenCurtainVC = [storyBoard instantiateViewControllerWithIdentifier:@"ScreenCurtainController"];
        screenCurtainVC.roomID = self.roomId;
        screenCurtainVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneId];
        screenCurtainVC.isAddDevice = YES;
        [self.navigationController pushViewController:screenCurtainVC animated:YES];
        
        
    }else if([typeName isEqualToString:@"投影"])
    {
        ProjectController *projectVC = [storyBoard instantiateViewControllerWithIdentifier:@"ProjectController"];
        projectVC.roomID = self.roomId;
        projectVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneId];
        projectVC.isAddDevice = YES;
       [self.navigationController pushViewController:projectVC animated:YES];
        
    }else if([typeName isEqualToString:@"功放"]){
        AmplifierController *amplifierVC = [storyBoard instantiateViewControllerWithIdentifier:@"AmplifierController"];
        amplifierVC.roomID = self.roomId;
        amplifierVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneId];
        amplifierVC.isAddDevice = YES;
       [self.navigationController pushViewController:amplifierVC animated:YES];
        
    }else if([typeName isEqualToString:@"智能推窗器"])
    {
        WindowSlidingController *windowSlidVC = [storyBoard instantiateViewControllerWithIdentifier:@"WindowSlidingController"];
        windowSlidVC.roomID = self.roomId;
        windowSlidVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneId];
        windowSlidVC.isAddDevice = YES;
        [self.navigationController pushViewController:windowSlidVC animated:YES];
    }else if([typeName isEqualToString:@"背景音乐"]){
        BgMusicController *bgMusicVC = [storyBoard instantiateViewControllerWithIdentifier:@"BgMusicController"];
        bgMusicVC.roomID = self.roomId;
        bgMusicVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneId];
        bgMusicVC.isAddDevice = YES;
       [self.navigationController pushViewController:bgMusicVC animated:YES];
        
    }else {
        PluginViewController *pluginVC = [storyBoard instantiateViewControllerWithIdentifier:@"PluginViewController"];
        pluginVC.roomID = self.roomId;
        pluginVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneId];
        pluginVC.isAddDevice = YES;
       [self.navigationController pushViewController:pluginVC animated:YES];
    }
    

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
