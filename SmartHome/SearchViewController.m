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

@interface SearchViewController ()<UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
//搜索到的设备类别
@property (nonatomic,strong) NSArray *deviceTypes;
//某个类别的下的设备
@property (nonatomic,strong) NSArray *devices;
@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UISearchBar *searchBar = [UISearchBar new];
    searchBar.placeholder = @"请输入搜索关键字";
    searchBar.delegate = self;
    self.navigationItem.titleView = searchBar;
}

#pragma mark - SearchBarDelegate
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
   
    NSDictionary *dict = @{@"AuthorToken":[[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"],@"UserID":[[NSUserDefaults standardUserDefaults] objectForKey:@"UserID"],@"InputName":searchBar.text};
    NSString *url = [NSString stringWithFormat:@"%@UserLogin.aspx",[IOManager httpAddr]];
    HttpManager *http=[HttpManager defaultManager];
    http.delegate=self;
    http.tag = 1;
    [http sendPost:url param:dict];
    
}
-(void) httpHandler:(id) responseObject tag:(int)tag
{
    if(tag == 1)
    {
        if(responseObject[@"Result"] == 0)
        {
            //解析搜索返回来的信息
        }else {
            [MBProgressHUD showError:responseObject[@"Msg"]];
        }
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.deviceTypes.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.devices.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(!cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"cell"];
        
    }
    cell.textLabel.text = self.devices[indexPath.row];
    return cell;
    
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.deviceTypes[section];
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *typeName = self.deviceTypes[indexPath.row];
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    if([typeName isEqualToString:@"电视"])
    {
        TVController *tVC = [storyBoard instantiateViewControllerWithIdentifier:@"TVController"];
        //传递设备ID和房间ID
        [self.navigationController pushViewController:tVC animated:YES];
        
    }else if([typeName isEqualToString:@"灯光"])
    {
        LightController *ligthVC = [storyBoard instantiateViewControllerWithIdentifier:@"LightController"];
        [self.navigationController pushViewController:ligthVC animated:YES];
        
    }else if([typeName isEqualToString:@"窗帘"])
    {
        CurtainController *curtainVC = [storyBoard instantiateViewControllerWithIdentifier:@"CurtainController"];
        [self.navigationController pushViewController:curtainVC animated:YES];
        
        
        
    }else if([typeName isEqualToString:@"DVD"])
    {
        
        DVDController *dvdVC = [storyBoard instantiateViewControllerWithIdentifier:@"DVDController"];
        [self.navigationController pushViewController:dvdVC animated:YES];
        
    }else if([typeName isEqualToString:@"FM"])
    {
        FMController *fmVC = [storyBoard instantiateViewControllerWithIdentifier:@"FMController"];
        [self.navigationController pushViewController:fmVC animated:YES];
        
        
    }else {
        NetvController *netVC = [storyBoard instantiateViewControllerWithIdentifier:@"NetvController"];
        [self.navigationController pushViewController:netVC animated:YES];
        
    }

}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
