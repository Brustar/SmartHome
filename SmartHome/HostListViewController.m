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
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self adjustNaviBarFrameForSplitView];
        [self adjustTitleFrameForSplitView];
        [self setNaviBarLeftBtn:nil];
    }
    _selectedHost = [[UD objectForKey:@"HostID"] stringValue];
    _hostArray = [NSMutableArray array];
    _homeNameArray = [NSMutableArray array];
    
    NSArray *array = [UD objectForKey:@"HostIDS"];
    if ([array isKindOfClass:[NSArray class]] && array.count >0) {
        [_hostArray addObjectsFromArray:array];
    }
    
   // if (_hostArray.count < 2) {
        [self.okBtn setEnabled:NO];
        [self.okBtn setBackgroundImage:[UIImage imageNamed:@"disable_btn"] forState:UIControlStateDisabled];
        [self.okBtn setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    //}else {
    //    [self.okBtn setEnabled:YES];
    //    [self.okBtn setBackgroundImage:[UIImage imageNamed:@"family_done"] forState:UIControlStateNormal];
    //    [self.okBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //}
    
    NSArray *homeArray = [UD objectForKey:@"HomeNameList"];
    if ([homeArray isKindOfClass:[NSArray class]] && homeArray.count >0) {
        [_homeNameArray addObjectsFromArray:homeArray];
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
    
    HostListCell *cell =  [[HostListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"hostsCell"];
    
    NSString *host = nil;
    if (indexPath.row < _hostArray.count) {
        host = [_hostArray[indexPath.row] stringValue];
    
        if ([_selectedHost isEqualToString:host]) {
            UIImageView *selectView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 16, 12)];
            selectView.image = [UIImage imageNamed:@"family_select"];
            cell.accessoryView = selectView;
        }else {
            cell.accessoryView = nil;
        }
        
    }
    
    if (indexPath.row < _homeNameArray.count) {
        NSString *homeName = _homeNameArray[indexPath.row];
        cell.textLabel.text = homeName;
    }
    
    
    cell.textLabel.textColor = [UIColor whiteColor];
    
    cell.backgroundColor = [UIColor colorWithRed:30.0/255.0 green:29.0/255.0 blue:34.0/255.0 alpha:1];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedHost = [_hostArray[indexPath.row] stringValue];
    [_hostTableView reloadData];
    
    NSString *currentHost = [[UD objectForKey:@"HostID"] stringValue];
    if (_selectedHost.length >0 && ![currentHost isEqualToString:_selectedHost]) {
        [self.okBtn setEnabled:YES];
        [self.okBtn setBackgroundImage:[UIImage imageNamed:@"family_done"] forState:UIControlStateNormal];
        [self.okBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }else {
        [self.okBtn setEnabled:NO];
        [self.okBtn setBackgroundImage:[UIImage imageNamed:@"disable_btn"] forState:UIControlStateDisabled];
        [self.okBtn setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    }
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
    [http sendPost:url param:dict];
}

- (void)writeChatListConfigDataToSQL:(NSArray *)users
{
    if(users.count == 0 || users == nil)
    {
        return;
    }
    [SQLManager writeChats:users];
}

#pragma - mark http delegate
- (void)httpHandler:(id) responseObject tag:(int)tag
{
    if(tag == 1)
    {
        if ([responseObject[@"result"] intValue] == 0)
        {
            //切换主机后，版本号归零
            
                [UD removeObjectForKey:@"room_version"];
                [UD removeObjectForKey:@"equipment_version"];
                [UD removeObjectForKey:@"scence_version"];
                [UD removeObjectForKey:@"tv_version"];
                [UD removeObjectForKey:@"fm_version"];
            
            
            //更新token
            [IOManager writeUserdefault:responseObject[@"token"] forKey:@"AuthorToken"];
            
            //更新主机类型（0:Creston   1:C4）
            [IOManager writeUserdefault:responseObject[@"hosttype"] forKey:@"HostType"];
            
            //更新家庭名
            [IOManager writeUserdefault:responseObject[@"homename"] forKey:@"homename"];
            
            //更新UD的@"HostID"， 更新DeviceInfo的 masterID
            [IOManager writeUserdefault:@([_selectedHost integerValue] )forKey:@"HostID"];
            DeviceInfo *info = [DeviceInfo defaultManager];
            info.masterID = [_selectedHost integerValue];
            
            //更新主机用户列表
            [self writeChatListConfigDataToSQL:responseObject[@"userlist"]];
            
            //请求配置信息
            [self sendRequestForGettingConfigInfos:@"Cloud/load_config_data.aspx" withTag:2];
            
            
        }else {
            [MBProgressHUD showError:@"切换失败"];
        }
        
    }else if(tag == 2) {
        if ([responseObject[@"result"] intValue] == 0)
        {
            NSDictionary *versioninfo=responseObject[@"version_info"];
            //执久化配置版本号
            [versioninfo enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                [IOManager writeUserdefault:obj forKey:key];
            }];
            
            //写房间配置信息到sql
            [self writeRoomsConfigDataToSQL:responseObject[@"home_room_info"]];
            //写场景配置信息到sql
            [self writeScensConfigDataToSQL:responseObject[@"room_scence_list"]];
            //写设备配置信息到sql
            [self writDevicesConfigDatesToSQL:responseObject[@"room_equipment_list"]];
            //写TV频道信息到sql
            [self writeChannelsConfigDataToSQL:responseObject[@"tv_store_list"] withParent:@"tv"];
            
            //写FM频道信息到sql
            [self writeChannelsConfigDataToSQL:responseObject[@"fm_store_list"] withParent:@"fm"];
            [self gainHome_room_infoDataTo:responseObject[@"home_room_info"]];
            
            [MBProgressHUD showSuccess:@"切换成功"];
            
            [self.okBtn setEnabled:NO];
            [self.okBtn setBackgroundImage:[UIImage imageNamed:@"disable_btn"] forState:UIControlStateDisabled];
            [self.okBtn setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
            
            //发通知刷新设备首页，场景首页,app首页
            [NC postNotificationName:@"ChangeHostRefreshUINotification" object:nil];
            
        }else{
            [MBProgressHUD showError:@"切换失败"];
        }
    }
}

//写设备配置信息到sql
-(void)writDevicesConfigDatesToSQL:(NSArray *)rooms
{
    if(rooms.count ==0 || rooms == nil)
    {
        return;
    }
    [SQLManager writeDevices:rooms];
}

//写房间配置信息到SQL
-(void)writeRoomsConfigDataToSQL:(NSDictionary *)responseObject
{
    NSArray *roomList = responseObject[@"roomlist"];
    if(roomList.count == 0 || roomList == nil)
    {
        return;
    }
    
    [SQLManager writeRooms:roomList]; 
}

//写场景配置信息到SQL
-(void)writeScensConfigDataToSQL:(NSArray *)rooms
{
    if(rooms.count == 0 || rooms == nil)
    {
        return;
    }
    NSArray *plists = [SQLManager writeScenes:rooms];
    for (NSString *s in plists) {
        [self downloadPlsit:s];
    }
}

//下载场景plist文件到本地
-(void)downloadPlsit:(NSString *)urlPlist

{
    AFHTTPSessionManager *session=[AFHTTPSessionManager manager];
    
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:urlPlist]];
    NSURLSessionDownloadTask *task=[session downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        
        //下载进度
        NSLog(@"%@",downloadProgress);
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            //self.pro.progress=downloadProgress.fractionCompleted;
            
        }];
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        //下载到哪个文件夹
        NSString *path = [[IOManager scenesPath] stringByAppendingPathComponent:response.suggestedFilename];
        
        
        return [NSURL fileURLWithPath:path];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        NSLog(@"下载完成了 %@",filePath);
    }];
    [task resume];
    
}
//写电视频道配置信息到SQL
-(void)writeChannelsConfigDataToSQL:(NSArray *)responseObject withParent:(NSString *)parent
{
    [SQLManager writeChannels:responseObject parent:parent];
}

//获取房间配置信息
-(void)gainHome_room_infoDataTo:(NSDictionary *)responseObject
{
    self.home_room_infoArr = [NSMutableArray array];
    NSInteger home_id  = [responseObject[@"home_id"] integerValue];
    NSString * hostbrand = responseObject[@"hostbrand"];
    NSString * host_brand_number = responseObject[@"host_brand_number"];
    NSString * homename = responseObject[@"homename"];
    if (homename == nil) {
        [self.home_room_infoArr addObject:@" "];
    }else{
        [self.home_room_infoArr addObject:homename];
    }
    if (hostbrand == nil) {
        [self.home_room_infoArr addObject:@" "];
    }else{
        [self.home_room_infoArr addObject:hostbrand];
    }
    if (host_brand_number == nil) {
        [self.home_room_infoArr addObject:@" "];
    }else{
        [self.home_room_infoArr addObject:host_brand_number];
    }
    
    [self.home_room_infoArr addObject:[NSNumber numberWithInteger:home_id]];
    
    
    NSArray  *paths  =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *docDir = [paths objectAtIndex:0];
    if(!docDir) {
        
        NSLog(@"Documents 目录未找到");
        
    }
    
    NSArray *array = [[NSArray alloc] initWithObjects:homename,[NSNumber numberWithInteger:home_id],hostbrand,host_brand_number,nil];
    
    NSString *filePath = [docDir stringByAppendingPathComponent:@"gainHome.plist"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath]==NO) {
        [array writeToFile:filePath atomically:YES];
    }
    
}

//获取设备配置信息
- (void)sendRequestForGettingConfigInfos:(NSString *)str withTag:(int)tag;
{
    NSString *url = [NSString stringWithFormat:@"%@%@",[IOManager httpAddr],str];
    NSString *md5Json = [IOManager md5JsonByScenes:[NSString stringWithFormat:@"%ld",[DeviceInfo defaultManager].masterID]];
    NSDictionary *dic = @{
                          @"token":[UD objectForKey:@"AuthorToken"],
                          @"md5Json":md5Json,
                          @"change_host":@(1)//是否是切换家庭 0:否  1:是
                          };
    
    if ([UD objectForKey:@"room_version"]) {
        dic = @{
                @"token":[UD objectForKey:@"AuthorToken"],
                @"room_ver":[UD objectForKey:@"room_version"],
                @"equipment_ver":[UD objectForKey:@"equipment_version"],
                @"scence_ver":[UD objectForKey:@"scence_version"],
                @"tv_ver":[UD objectForKey:@"tv_version"],
                @"fm_ver":[UD objectForKey:@"fm_version"],
                //@"chat_ver":[UD objectForKey:@"chat_version"],
                @"md5Json":md5Json,
                @"change_host":@(1)//是否是切换家庭 0:否  1:是
                };
    }
    HttpManager *http = [HttpManager defaultManager];
    http.delegate = self;
    http.tag = tag;
    [http sendPost:url param:dic];
}

- (IBAction)OkBtnClicked:(id)sender {
    NSString *currentHost = [[UD objectForKey:@"HostID"] stringValue];
    if (_selectedHost.length >0 && ![currentHost isEqualToString:_selectedHost]) {
        [self loginHost];
    }
}
@end
