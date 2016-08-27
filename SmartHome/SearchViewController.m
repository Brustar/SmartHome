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

@interface SearchViewController ()<UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
//搜索到的设备类别
@property (nonatomic,strong) NSArray *deviceTypes;
//某个类别的下的设备
@property (nonatomic,strong) NSArray *devices;
@property (nonatomic,strong) NSArray *deviceInfos;
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
   
    NSDictionary *dict = @{@"AuthorToken":[[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"],@"InputName":searchBar.text};
    NSString *url = [NSString stringWithFormat:@"%@Search.aspx",[IOManager httpAddr]];
    HttpManager *http=[HttpManager defaultManager];
    http.delegate=self;
    http.tag = 1;
    [http sendPost:url param:dict];
    
}
-(void) httpHandler:(id) responseObject tag:(int)tag
{
    if(tag == 1)
    {
        if([responseObject[@"Result"]intValue] == 0)
        {
            //解析搜索返回来的信息
            self.deviceInfos = responseObject[@"messageInfo"];
            
        }else {
            [MBProgressHUD showError:responseObject[@"Msg"]];
        }
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.deviceInfos.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(!cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"cell"];
        
    }
    NSDictionary *dic = self.deviceInfos[indexPath.row];
    cell.textLabel.text = dic[@"eName"];
    cell.detailTextLabel.text = dic[@"rName"];
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   NSDictionary *dic = self.deviceInfos[indexPath.row];
    int eId = [dic[@"eId"] intValue];
    NSString *typeName = [DeviceManager deviceTypeNameByDeviceID:eId];
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    if([typeName isEqualToString:@"电视"])
    {
        TVController *tVC = [storyBoard instantiateViewControllerWithIdentifier:@"TVController"];
        //传递房间ID
        tVC.roomID = [dic[@"rId"] intValue];
        [self.navigationController pushViewController:tVC animated:YES];
        
    }else if([typeName isEqualToString:@"灯光"])
    {
        LightController *ligthVC = [storyBoard instantiateViewControllerWithIdentifier:@"LightController"];
        ligthVC.roomID = [dic[@"rId"] intValue];
        [self.navigationController pushViewController:ligthVC animated:YES];
        
    }else if([typeName isEqualToString:@"窗帘"])
    {
        CurtainController *curtainVC = [storyBoard instantiateViewControllerWithIdentifier:@"CurtainController"];
        curtainVC.roomID = [dic[@"rId"] intValue];
        [self.navigationController pushViewController:curtainVC animated:YES];
        
        
        
    }else if([typeName isEqualToString:@"DVD"])
    {
        
        DVDController *dvdVC = [storyBoard instantiateViewControllerWithIdentifier:@"DVDController"];
        dvdVC.roomID = [dic[@"rId"] intValue];
        [self.navigationController pushViewController:dvdVC animated:YES];
        
    }else if([typeName isEqualToString:@"FM"])
    {
        FMController *fmVC = [storyBoard instantiateViewControllerWithIdentifier:@"FMController"];
        fmVC.roomID = [dic[@"rId"] intValue];
        [self.navigationController pushViewController:fmVC animated:YES];
        
        
    }else if([typeName isEqualToString:@"机顶盒"]){
        NetvController *netVC = [storyBoard instantiateViewControllerWithIdentifier:@"NetvController"];
        netVC.roomID = [dic[@"rId"] intValue];
        [self.navigationController pushViewController:netVC animated:YES];
        
    }else{
        PluginViewController *pluginVC = [storyBoard instantiateViewControllerWithIdentifier:@"PluginViewController"];
        pluginVC.roomID = [dic[@"rId"] intValue];
         [self.navigationController pushViewController:pluginVC animated:YES];
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
