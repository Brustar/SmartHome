//
//  RoomDetailViewController.m
//  SmartHome
//
//  Created by KobeBryant on 2017/1/5.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "RoomDetailViewController.h"

@interface RoomDetailViewController ()

@end

@implementation RoomDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initDataSource];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.deviceTypeTableView.backgroundColor = [UIColor colorWithRed:55/255.0 green:73/255.0 blue:91/255.0 alpha:1];
    self.deviceSubTypeTableView.backgroundColor = [UIColor colorWithRed:55/255.0 green:73/255.0 blue:91/255.0 alpha:1];
    self.view.backgroundColor = [UIColor colorWithRed:55/255.0 green:73/255.0 blue:91/255.0 alpha:1];
    [self.deviceTypeTableView reloadData];
    [self.deviceSubTypeTableView reloadData];
    
    //默认选中第一行
    NSIndexPath *ip=[NSIndexPath indexPathForRow:0 inSection:0];
    
    if ([self.deviceSubTypeTableView.delegate respondsToSelector:@selector(tableView:willSelectRowAtIndexPath:)]) {
        [self.deviceSubTypeTableView.delegate tableView:self.deviceSubTypeTableView willSelectRowAtIndexPath:ip];
    }
    
    [self.deviceSubTypeTableView selectRowAtIndexPath:ip animated:YES scrollPosition:UITableViewScrollPositionNone];
    
    if ([self.deviceSubTypeTableView.delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
        [self.deviceSubTypeTableView.delegate tableView:self.deviceSubTypeTableView didSelectRowAtIndexPath:ip];
    }
    
    
    //房间名
    self.navigationItem.title = [SQLManager getRoomNameByRoomID:self.roomID];
    
}

- (void)initDataSource {
    _deviceTypes = [NSMutableArray arrayWithArray:[SQLManager getDevicesSubTypeNamesWithRoomID:self.roomID]];//设备大类;
    
    if (_deviceTypes.count <=0) {
        [MBProgressHUD showError:@"此房间暂无设备"];
        //[self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
        for (NSString *subTypeName in _deviceTypes) {
            if (subTypeName.length >0) {
                _deviceSubTypes = [NSMutableArray arrayWithArray:[SQLManager getDeviceTypeName:self.roomID subTypeName:subTypeName]];//设备小类
                break;
            }
        }
    
}

-(void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:YES];
    
    for(int i = 0; i < self.deviceTypes.count; i++)
    {
        NSString *subTypeName = self.deviceTypes[i];
        if([subTypeName isEqualToString:@"影音"])
        {
            [self tableView:self.deviceTypeTableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            self.deviceSubTypes = [NSMutableArray arrayWithArray:[SQLManager getDeviceTypeName:self.roomID subTypeName:_deviceTypes[i]]];
            
            for(int i = 0; i < self.deviceSubTypes.count; i++)
            {
                NSString *typeName = self.deviceSubTypes[i];
                if([typeName isEqualToString:@"背景音乐"])
                {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                    [self tableView:self.deviceSubTypeTableView didSelectRowAtIndexPath:indexPath];
                }
            }
        }
    }
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //右边的根据左边选中的设备大类的设备子类数量
    if (tableView == self.deviceTypeTableView) {
        return _deviceTypes.count;
    }
    else {
        return _deviceSubTypes.count;
    }
    
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EditSceneCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EditSceneCell" forIndexPath:indexPath];
    
    if(tableView == self.deviceTypeTableView)
    {
        NSString *subType  = self.deviceTypes[indexPath.row];
        cell.label.text = subType;
        if([subType isEqualToString:@"照明"])
        {
            [cell.button setBackgroundImage:[UIImage imageNamed:@"lights"] forState:UIControlStateNormal];
        }else if([subType isEqualToString:@"环境"])
        {
            [cell.button setBackgroundImage:[UIImage imageNamed:@"environment"] forState:UIControlStateNormal];
        }else if([subType isEqualToString:@"影音"])
        {
            [cell.button setBackgroundImage:[UIImage imageNamed:@"medio"] forState:UIControlStateNormal];
        }else if ([subType isEqualToString:@"安防"]){
            [cell.button setBackgroundImage:[UIImage imageNamed:@"safe"] forState:UIControlStateNormal];
        }else{
            [cell.button setBackgroundImage:[UIImage imageNamed:@"others"] forState:UIControlStateNormal];
        }
        
    }else {
        //根据设备子类数据
        
        NSString *type  = self.deviceSubTypes[indexPath.row];
        cell.label.text = type;
        if([type isEqualToString:@"灯光"])
        {
            [cell.button setBackgroundImage:[UIImage imageNamed:@"lamp"] forState:UIControlStateNormal];
        }else if([type isEqualToString:@"窗帘"])
        {
            [cell.button setBackgroundImage:[UIImage imageNamed:@"curtainType"] forState:UIControlStateNormal];
        }else if([type isEqualToString:@"空调"])
            
        {
            [cell.button setBackgroundImage:[UIImage imageNamed:@"air"] forState:UIControlStateNormal];
        }else if ([type isEqualToString:@"FM"]){
            [cell.button setBackgroundImage:[UIImage imageNamed:@"fm"] forState:UIControlStateNormal];
        }else if([type isEqualToString:@"网络电视"]){
            [cell.button setBackgroundImage:[UIImage imageNamed:@"TV"] forState:UIControlStateNormal];
        }else if ([type isEqualToString:@"智能门锁"]){
            [cell.button setBackgroundImage:[UIImage imageNamed:@"guard"] forState:UIControlStateNormal];
        }else  if ([type isEqualToString:@"DVD"]){
            [cell.button setBackgroundImage:[UIImage imageNamed:@"DVD"] forState:UIControlStateNormal];
        }else {
            [cell.button setBackgroundImage:[UIImage imageNamed:@"safe"] forState:UIControlStateNormal];
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //DeviceInfo *device = [DeviceInfo defaultManager];
    if(tableView == self.deviceTypeTableView)
    {
        self.deviceSubTypes = [NSMutableArray arrayWithArray:[SQLManager getDeviceTypeName:self.roomID subTypeName:_deviceTypes[indexPath.row]]];
        [self.deviceSubTypeTableView reloadData];
    }
    
    if(tableView == self.deviceSubTypeTableView)
    {
        if (!self.deviceSubTypes) {
            return;
        }
        //灯光，窗帘，DVD，网络电视
        NSString *typeName = self.deviceSubTypes[indexPath.row];
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        if([typeName isEqualToString:@"网络电视"])
        {
            TVController *tVC = [storyBoard instantiateViewControllerWithIdentifier:@"TVController"];
            tVC.roomID = self.roomID;
            
            [self addViewAndVC:tVC];
            
        }else if([typeName isEqualToString:@"灯光"])
        {
            LightController *ligthVC = [storyBoard instantiateViewControllerWithIdentifier:@"LightController"];
            //ligthVC.showLightView = NO;
            ligthVC.roomID = self.roomID;
            
            //ligthVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
            [self addViewAndVC:ligthVC];
            
        }else if([typeName isEqualToString:@"窗帘"])
        {
            CurtainController *curtainVC = [storyBoard instantiateViewControllerWithIdentifier:@"CurtainController"];
            curtainVC.roomID = self.roomID;
            
            
            [self addViewAndVC:curtainVC];
            
            
        }else if([typeName isEqualToString:@"DVD"])
        {
            
            DVDController *dvdVC = [storyBoard instantiateViewControllerWithIdentifier:@"DVDController"];
            dvdVC.roomID = self.roomID;
            //dvdVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
            [self addViewAndVC:dvdVC];
            
        }else if([typeName isEqualToString:@"FM"])
        {
            FMController *fmVC = [storyBoard instantiateViewControllerWithIdentifier:@"FMController"];
            fmVC.roomID = self.roomID;
            //fmVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
            [self addViewAndVC:fmVC];
            
        }else if([typeName isEqualToString:@"空调"])
        {
            AirController *airVC = [storyBoard instantiateViewControllerWithIdentifier:@"AirController"];
            airVC.roomID = self.roomID;
            //airVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
            [self addViewAndVC:airVC];
        }else if([typeName isEqualToString:@"机顶盒"]){
//            NetvController *netVC = [storyBoard instantiateViewControllerWithIdentifier:@"NetvController"];
//            netVC.roomID = self.roomID;
//            //netVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
//            [self addViewAndVC:netVC];
            
        }else if([typeName isEqualToString:@"摄像头"]){
            CameraController *camerVC = [storyBoard instantiateViewControllerWithIdentifier:@"CameraController"];
            camerVC.roomID = self.roomID;
            //camerVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
            [self addViewAndVC:camerVC];
            
        }else if([typeName isEqualToString:@"智能门锁"]){
            GuardController *guardVC = [storyBoard instantiateViewControllerWithIdentifier:@"GuardController"];
            guardVC.roomID = self.roomID;
            //guardVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
            [self addViewAndVC:guardVC];
            
        }else if([typeName isEqualToString:@"幕布"]){
            ScreenCurtainController *screenCurtainVC = [storyBoard instantiateViewControllerWithIdentifier:@"ScreenCurtainController"];
            screenCurtainVC.roomID = self.roomID;
            //screenCurtainVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
            [self addViewAndVC:screenCurtainVC];
            
        }else if([typeName isEqualToString:@"投影"])
        {
            ProjectController *projectVC = [storyBoard instantiateViewControllerWithIdentifier:@"ProjectController"];
            projectVC.roomID = self.roomID;
            //projectVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
            [self addViewAndVC:projectVC];
        }else if([typeName isEqualToString:@"功放"]){
            AmplifierController *amplifierVC = [storyBoard instantiateViewControllerWithIdentifier:@"AmplifierController"];
            amplifierVC.roomID = self.roomID;
            //amplifierVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
            [self addViewAndVC:amplifierVC];
            
        }else if([typeName isEqualToString:@"智能推窗器"]){
            WindowSlidingController *windowSlidVC = [storyBoard instantiateViewControllerWithIdentifier:@"WindowSlidingController"];
            windowSlidVC.roomID = self.roomID;
            //windowSlidVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
            [self addViewAndVC:windowSlidVC];
            
        }else if([typeName isEqualToString:@"背景音乐"]){
            BgMusicController *bgVC = [storyBoard instantiateViewControllerWithIdentifier:@"BgMusicController"];
            bgVC.roomID = self.roomID;
           // bgVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
            [self addViewAndVC:bgVC];
            
            
        }else{
            PluginViewController *pluginVC = [storyBoard instantiateViewControllerWithIdentifier:@"PluginViewController"];
            pluginVC.roomID = self.roomID;
           // pluginVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
            [self addViewAndVC:pluginVC];
        }
    }
    
    
}

-(void )addViewAndVC:(UIViewController *)vc
{
    if (self.currentViewController != nil) {
        [self.currentViewController.view removeFromSuperview];
        [self.currentViewController removeFromParentViewController];
    }
    
    vc.view.frame = CGRectMake(100, 64, self.view.bounds.size.width - 200  , self.view.bounds.size.height);
    [self.view addSubview:vc.view];
    [self addChildViewController:vc];
    self.currentViewController = vc;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor colorWithRed:55/255.0 green:73/255.0 blue:91/255.0 alpha:1];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
