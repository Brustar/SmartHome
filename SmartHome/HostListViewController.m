//
//  HostListViewController.m
//  SmartHome
//
//  Created by KobeBryant on 2017/5/3.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "HostListViewController.h"

@interface HostListViewController ()

@end

@implementation HostListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNaviBarTitle:@"切换家庭账号"];
    _selectedHost = [[UD objectForKey:@"HostID"] stringValue];
    _hostArray = [NSMutableArray array];
    NSArray *array = [UD objectForKey:@"HostIDS"];
    if ([array isKindOfClass:[NSArray class]] && array.count >0) {
        [_hostArray addObjectsFromArray:array];
    }
    
    _hostTableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
    _hostTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_hostTableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _hostArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    HostListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"hostsCell"];
    if(!cell)
    {
        cell = [[HostListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"hostsCell"];
    }
    
     NSString *host = [_hostArray[indexPath.row] stringValue];
     cell.textLabel.text = host;
     cell.textLabel.textColor = [UIColor whiteColor];
    
    if ([_selectedHost isEqualToString:host]) {
        UIImageView *selectView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 16, 12)];
        selectView.image = [UIImage imageNamed:@"family_select"];
        cell.accessoryView = selectView;
    }else {
        cell.accessoryView = nil;
    }
    
    cell.backgroundColor = [UIColor colorWithRed:30.0/255.0 green:29.0/255.0 blue:34.0/255.0 alpha:1];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedHost = [_hostArray[indexPath.row] stringValue];
    [_hostTableView reloadData];
}

-(void)loginHost
{
    NSString *url = [NSString stringWithFormat:@"%@login/login_host.aspx",[IOManager httpAddr]];
    
    NSDictionary *dict = @{
                           @"token":[UD objectForKey:@"AuthorToken"],
                           @"hostid":_selectedHost
                           };
    
    
    HttpManager *http = [HttpManager defaultManager];
    http.delegate = self;
    http.tag = 1;
    [http sendGet:url param:dict];
}


#pragma - mark http delegate
- (void)httpHandler:(id) responseObject tag:(int)tag
{
    if(tag == 1)
    {
        if ([responseObject[@"result"] intValue] == 0)
        {
            //更新token
            [IOManager writeUserdefault:responseObject[@"token"] forKey:@"AuthorToken"];
            
            //更新本地的hostID变量
            [IOManager writeUserdefault:@([_selectedHost integerValue] )forKey:@"HostID"];
            
            [MBProgressHUD showSuccess:@"切换成功"];
            
        }else {
            [MBProgressHUD showError:@"切换失败"];
        }
        
    }
}

- (IBAction)OkBtnClicked:(id)sender {
    NSString *currentHost = [[UD objectForKey:@"HostID"] stringValue];
    if (_selectedHost.length >0 && ![currentHost isEqualToString:_selectedHost]) {
        [self loginHost];
    }
}
@end
