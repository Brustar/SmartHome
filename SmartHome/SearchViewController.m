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
#import "DeviceManager.h"
#import "PluginViewController.h"
#import "FMDatabase.h"
#import "MBProgressHUD+NJ.h"
#import "AirController.h"
#import "CameraController.h"
#import "AmplifierController.h"
#import "MBProgressHUD+NJ.h"
#import "ScreenCurtainController.h"
#import "ProjectController.h"
@interface SearchViewController ()<UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource>

//搜索到的设备类别
@property (nonatomic,strong) NSArray *deviceTypes;
//某个类别的下的设备
@property (nonatomic,strong) NSArray *devices;
@property (nonatomic,strong) NSArray *deviceInfos;
@property (nonatomic,strong) NSArray *searchResult;
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
    NSArray *tables=@[@"Devices",@"Scenes"];
    NSString *dbPath = [[IOManager sqlitePath] stringByAppendingPathComponent:@"smartDB"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    NSMutableArray *result = [NSMutableArray array];
    if([db open])
    {
        for(int i = 0; i < tables.count; i++)
        {
            if(searchBar.text)
            {
                NSString *sql = [NSString stringWithFormat:@"select * from %@ where NAME like '%%%@%%'",tables[i],searchBar.text];
                FMResultSet *resultSet = [db executeQuery:sql];
                while([resultSet next])
                {
                    NSString *name = [resultSet stringForColumn:@"NAME"];
                    [result addObject:name];
                }

            }
        }
        self.searchResult = [result copy];
        [db close];
       
    }
    [self.tableView reloadData];
    
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.searchResult.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(!cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"cell"];
        
    }
    
    cell.textLabel.text = self.searchResult[indexPath.row];
    cell.textLabel.textAlignment = NSTextAlignmentLeft;
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    int eId =(int)[DeviceManager deviceIDByDeviceName:self.searchResult[indexPath.row]];
    NSString *typeName = [DeviceManager deviceTypeNameByDeviceID:eId];
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    if([typeName isEqualToString:@"网络电视"])
    {
        TVController *tVC = [storyBoard instantiateViewControllerWithIdentifier:@"TVController"];
        
        tVC.deviceid = [NSString stringWithFormat:@"%d",eId];
        [self.navigationController pushViewController:tVC animated:YES];
        
    }else if([typeName isEqualToString:@"灯光"])
    {
        LightController *ligthVC = [storyBoard instantiateViewControllerWithIdentifier:@"LightController"];
        
        ligthVC.deviceid = [NSString stringWithFormat:@"%d",eId];
        [self.navigationController pushViewController:ligthVC animated:YES];
        
    }else if([typeName isEqualToString:@"窗帘"])
    {
        CurtainController *curtainVC = [storyBoard instantiateViewControllerWithIdentifier:@"CurtainController"];
       
        curtainVC.deviceid = [NSString stringWithFormat:@"%d",eId];
        [self.navigationController pushViewController:curtainVC animated:YES];
        
        
        
    }else if([typeName isEqualToString:@"DVD"])
    {
        
        DVDController *dvdVC = [storyBoard instantiateViewControllerWithIdentifier:@"DVDController"];
       
        dvdVC.deviceid = [NSString stringWithFormat:@"%d",eId];
        [self.navigationController pushViewController:dvdVC animated:YES];
        
    }else if([typeName isEqualToString:@"FM"])
    {
        FMController *fmVC = [storyBoard instantiateViewControllerWithIdentifier:@"FMController"];
       
        fmVC.deviceid = [NSString stringWithFormat:@"%d",eId];
        [self.navigationController pushViewController:fmVC animated:YES];
        
        
    }else if([typeName isEqualToString:@"机顶盒"]){
        NetvController *netVC = [storyBoard instantiateViewControllerWithIdentifier:@"NetvController"];
        netVC.deviceid = [NSString stringWithFormat:@"%d",eId];
        [self.navigationController pushViewController:netVC animated:YES];
        
    }else if([typeName isEqualToString:@"空调"]){
        
        AirController *airVC = [storyBoard instantiateViewControllerWithIdentifier:@"AirController"];
        airVC.deviceid = [NSString stringWithFormat:@"%d",eId];
        [self.navigationController pushViewController:airVC animated:YES];
    }else if([typeName isEqualToString:@"摄像头"]){
        CameraController *camerVC = [storyBoard instantiateViewControllerWithIdentifier:@"CameraController"];
        camerVC.deviceid = [NSString stringWithFormat:@"%d",eId];
       

    }else if([typeName isEqualToString:@"智能门锁"]) {
        
        GuardController *guardVC = [storyBoard instantiateViewControllerWithIdentifier:@"GuardController"];
        guardVC.deviceid = [NSString stringWithFormat:@"%d",eId];
        [self.navigationController pushViewController:guardVC animated:YES];
       
    }else if([typeName isEqualToString:@"功放"]){
        
        AmplifierController *amplifier = [storyBoard instantiateViewControllerWithIdentifier:@"AmplifierController"];
        amplifier.deviceid = [NSString stringWithFormat:@"%d",eId];
        [self.navigationController pushViewController:amplifier animated:YES];
        
    }else if([typeName isEqualToString:@"智能单品"]){
        PluginViewController *pluginVC = [storyBoard instantiateViewControllerWithIdentifier:@"PluginViewController"];
    
        [self.navigationController pushViewController:pluginVC animated:YES];
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
        [MBProgressHUD showError:@"没有结果匹配"];
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
