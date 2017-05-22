//
//  SearchViewController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/8/15.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "SearchViewController.h"
#import "HttpManager.h"
#import "MBProgressHUD+NJ.h"
#import "TVController.h"
#import "DVDController.h"
#import "NetvController.h"
#import "LightController.h"
#import "CurtainController.h"
#import "GuardController.h"
#import "FMController.h"
#import "SQLManager.h"
#import "PluginViewController.h"
#import "FMDatabase.h"
#import "MBProgressHUD+NJ.h"
#import "AirController.h"
#import "CameraController.h"
#import "AmplifierController.h"
#import "MBProgressHUD+NJ.h"
#import "ScreenCurtainController.h"
#import "ProjectController.h"

#import "Device.h"
#import "BgMusicController.h"
#import "WindowSlidingController.h"

@interface SearchViewController ()<UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource>

//搜索到的设备类别
@property (nonatomic,strong) NSArray *deviceTypes;
//某个类别的下的设备
@property (nonatomic,strong) NSArray *devices;
@property (nonatomic,strong) NSArray *deviceInfos;
@property (nonatomic,strong) NSArray *searchResult;
@property (nonatomic,strong) NSArray * rooms;//房间
@property (nonatomic,strong) NSArray * roomIDs;
@property (nonatomic,strong) NSArray * AllDevices;

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UISearchBar *searchBar = [UISearchBar new];
    searchBar.placeholder = @"请输入搜索关键字";
    searchBar.delegate = self;
    self.navigationItem.titleView = searchBar;
    self.automaticallyAdjustsScrollViewInsets = NO;
}

#pragma mark - SearchBarDelegate
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    NSMutableArray * roomArr = [NSMutableArray array];
    NSMutableArray * roomIDArr = [NSMutableArray array];
    
    NSArray *roomList = [SQLManager getAllRoomsInfoByName:searchBar.text];
    for (NSDictionary *room in roomList) {
        [roomIDArr addObject:room[@"roomid"]];
        [roomArr addObject:room[@"roomName"]];
    }
    
    self.roomIDs = [roomIDArr copy];
    self.rooms = [roomArr copy];
    [self.tableView reloadData];
}

//
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.rooms.count;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString * str = self.rooms[section];
    
    return str;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    self.AllDevices = [SQLManager devicesByRoomId:[self.roomIDs[section] integerValue]];
    NSMutableArray * arr = [NSMutableArray array];
    for (Device * device in self.AllDevices) {
        NSString * deviceName = device.name;
        [arr addObject:deviceName];
    }
    self.searchResult = [arr copy];
    return self.searchResult.count;

}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(!cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"cell"];
        
    }
    

    NSArray * item = [SQLManager devicesByRoomId:[self.roomIDs[indexPath.section] integerValue]];
    NSMutableArray * arr = [NSMutableArray array];
    for (Device * device in item) {
        NSString * deviceName = device.name;
        [arr addObject:deviceName];
    }
    item = [arr copy];
    
    cell.textLabel.text =item[indexPath.row];
    cell.textLabel.textAlignment = NSTextAlignmentLeft;
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray * item = [SQLManager devicesByRoomId:[self.roomIDs[indexPath.section] integerValue]];
    NSMutableArray * arr = [NSMutableArray array];
    for (Device * device in item) {
        NSString * deviceName = device.name;
        [arr addObject:deviceName];
    }
    item = [arr copy];
    int eId =(int)[SQLManager deviceIDByDeviceName:item[indexPath.row]];
    NSString *typeName = [SQLManager deviceTypeNameByDeviceID:eId];
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIStoryboard *iphoneBoard  = [UIStoryboard storyboardWithName:@"iPhone" bundle:nil];
        if([typeName isEqualToString:@"网络电视"])
    {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
            /*
            IphoneTVController *tvc = [iphoneBoard instantiateViewControllerWithIdentifier:@"IphoneTVController"];
            
            tvc.deviceid = [NSString stringWithFormat:@"%d",eId];
            [self.navigationController pushViewController:tvc animated:YES];
            */
        }else{
            
            TVController *tVC = [storyBoard instantiateViewControllerWithIdentifier:@"TVController"];
            
            tVC.deviceid = [NSString stringWithFormat:@"%d",eId];
            [self.navigationController pushViewController:tVC animated:YES];
        }
        
    }else if([typeName isEqualToString:@"灯光"])
    {
        LightController *ligthVC = [storyBoard instantiateViewControllerWithIdentifier:@"LightController"];
        //ligthVC.showLightView = NO;
        ligthVC.deviceid = [NSString stringWithFormat:@"%d",eId];
        [self.navigationController pushViewController:ligthVC animated:YES];
        
    }else if([typeName isEqualToString:@"窗帘"])
    {
        CurtainController *curtainVC = [storyBoard instantiateViewControllerWithIdentifier:@"CurtainController"];
       
        curtainVC.deviceid = [NSString stringWithFormat:@"%d",eId];
        [self.navigationController pushViewController:curtainVC animated:YES];
        
    }else if([typeName isEqualToString:@"DVD"])
    {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
            /*
            IphoneDVDController * IphoneDVD = [iphoneBoard instantiateViewControllerWithIdentifier:@"IphoneDVDController"];
            IphoneDVD.deviceid = [NSString stringWithFormat:@"%d",eId];
            [self.navigationController pushViewController:IphoneDVD animated:YES];
            */
        }else{
            
            DVDController *dvdVC = [storyBoard instantiateViewControllerWithIdentifier:@"DVDController"];
            dvdVC.deviceid = [NSString stringWithFormat:@"%d",eId];
            [self.navigationController pushViewController:dvdVC animated:YES];
        }
        
        
    }else if([typeName isEqualToString:@"FM"])
    {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
            /*
            IphoneFMController *IphonefmVC = [iphoneBoard instantiateViewControllerWithIdentifier:@"IphoneFMController"];
            
            IphonefmVC.deviceid = [NSString stringWithFormat:@"%d",eId];
            [self.navigationController pushViewController:IphonefmVC animated:YES];*/
        }else{
            
            FMController *fmVC = [storyBoard instantiateViewControllerWithIdentifier:@"FMController"];
            
            fmVC.deviceid = [NSString stringWithFormat:@"%d",eId];
            [self.navigationController pushViewController:fmVC animated:YES];
        }

    }else if([typeName isEqualToString:@"机顶盒"]){
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
            /*
            IphoneNetTvController * Iphonenet = [iphoneBoard instantiateViewControllerWithIdentifier:@"IphoneNetTvController"];
            Iphonenet.deviceid = [NSString stringWithFormat:@"%d",eId];
            [self.navigationController pushViewController:Iphonenet animated:YES];
            */
        }else{
            
            NetvController *netVC = [storyBoard instantiateViewControllerWithIdentifier:@"NetvController"];
            netVC.deviceid = [NSString stringWithFormat:@"%d",eId];
            [self.navigationController pushViewController:netVC animated:YES];
        }
    }else if([typeName isEqualToString:@"空调"]){
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
            /*
            IphoneAirController *air = [iphoneBoard instantiateViewControllerWithIdentifier:@"IphoneAirController"];
            
            air.deviceid = [NSString stringWithFormat:@"%d",eId];
            [self.navigationController pushViewController:air animated:YES];
            */
        }else{
            
            AirController *airVC = [storyBoard instantiateViewControllerWithIdentifier:@"AirController"];
            airVC.deviceid = [NSString stringWithFormat:@"%d",eId];
            [self.navigationController pushViewController:airVC animated:YES];
        }
       
    }else if([typeName isEqualToString:@"摄像头"]){
        CameraController *camerVC = [storyBoard instantiateViewControllerWithIdentifier:@"CameraController"];
        camerVC.deviceid = [NSString stringWithFormat:@"%d",eId];
       
        [self.navigationController pushViewController:camerVC animated:YES];
    }else if([typeName isEqualToString:@"智能门锁"]) {
        
        GuardController *guardVC = [storyBoard instantiateViewControllerWithIdentifier:@"GuardController"];
        guardVC.deviceid = [NSString stringWithFormat:@"%d",eId];
        [self.navigationController pushViewController:guardVC animated:YES];
       
    }else if([typeName isEqualToString:@"功放"]){
        
        AmplifierController *amplifier = [storyBoard instantiateViewControllerWithIdentifier:@"AmplifierController"];
        amplifier.deviceid = [NSString stringWithFormat:@"%d",eId];
        [self.navigationController pushViewController:amplifier animated:YES];
        
    }
    else if([typeName isEqualToString:@"智能单品"]){
        PluginViewController *pluginVC = [storyBoard instantiateViewControllerWithIdentifier:@"PluginViewController"];
        
        [self.navigationController pushViewController:pluginVC animated:YES];
    
    }else if([typeName isEqualToString:@"背景音乐"]){
         BgMusicController *bgMusicVC = [storyBoard instantiateViewControllerWithIdentifier:@"BgMusicController"];
        
        [self.navigationController pushViewController:bgMusicVC animated:YES];
        
    } else if([typeName isEqualToString:@"智能推窗器"]){
         WindowSlidingController *windowSlidVC = [storyBoard instantiateViewControllerWithIdentifier:@"WindowSlidingController"];
        
        [self.navigationController pushViewController:windowSlidVC animated:YES];
        
    }else if([typeName isEqualToString:@"幕布"]){
        ScreenCurtainController *screenCurtainVC = [storyBoard instantiateViewControllerWithIdentifier:@"ScreenCurtainController"];
        screenCurtainVC.deviceid = [NSString stringWithFormat:@"%d",eId];
        [self.navigationController pushViewController:screenCurtainVC animated:YES];
        
    }else if([typeName isEqualToString:@"投影"])
    {
        ProjectController *projectVC = [storyBoard instantiateViewControllerWithIdentifier:@"ProjectController"];
        projectVC.deviceid = [NSString stringWithFormat:@"%d",eId];
        [self.navigationController pushViewController:projectVC animated:YES];
    }else{
        GuardController *guardVC = [storyBoard instantiateViewControllerWithIdentifier:@"GuardController"];
        guardVC.deviceid = [NSString stringWithFormat:@"%d",eId];
        [self.navigationController pushViewController:guardVC animated:YES];
    }

}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
