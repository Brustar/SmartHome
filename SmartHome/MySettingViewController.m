//
//  MySettingViewController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/7/12.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "MySettingViewController.h"
#import "AccessSettingController.h"
#import "SystemSettingViewController.h"
#import "SystemInfomationController.h"
#import "AboutUsController.h"
#import "HttpManager.h"
#import "MBProgressHUD+NJ.h"
#import "AppDelegate.h"
#import "SocketManager.h"
//#import "WelcomeController.h"
#import "PushSettingController.h"
#import "SystemSettingViewController.h"
#import "SystemInfomationController.h"
#import "AccessSettingController.h"
#import "AboutUsController.h"
#import "DeviceListTimeVC.h"
#import "IphoneSceneController.h"

@interface MySettingViewController ()<UITableViewDelegate,UITableViewDataSource,UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSArray *titleArr;
@property (nonatomic,strong) AccessSettingController *accessVC;
@property (nonatomic,strong) SystemSettingViewController *sySetVC;
@property (nonatomic,strong) SystemInfomationController *inforVC;
@property (nonatomic,strong) AboutUsController *aboutVC;
@property (nonatomic,strong) NSMutableArray *userArr;
@property (nonatomic,strong) NSMutableArray *managerType;
@property (nonatomic,strong) NSMutableArray *userIDArr;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewTopConstraint;//顶部的距离
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewLeadingConstraint;//左边的距离
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewTainlingConstraint;//右边的距离
@property (nonatomic,assign) BOOL Seccess;

@end

@implementation MySettingViewController
-(NSMutableArray *)userArr
{
    if(!_userArr)
    {
        _userArr = [NSMutableArray array];
        
        
    }
    return _userArr;
}
-(NSMutableArray *)managerType{
    if(!_managerType)
    {
        _managerType = [NSMutableArray array];
        
    }
    return _managerType;
}
-(NSMutableArray *)userIDArr
{
    if(!_userIDArr)
    {
        _userIDArr = [NSMutableArray array];
    }
    return _userIDArr;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (ON_IPAD) {
        
        self.tableViewTopConstraint.constant = 60;
        self.tableViewLeadingConstraint.constant = 20;
        self.tableViewTainlingConstraint.constant = 20;
    }

    [LoadMaskHelper showMaskWithType:SettingView onView:self.tabBarController.view delay:0.5 delegate:self];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView.tableFooterView = [UIView new];
    NSString *url = [NSString stringWithFormat:@"%@Cloud/user_listall.aspx",[IOManager httpAddr]];
    [self sendRequest:url withTag:2];
    [self setupNaviBar];

}

-(void)sendRequest:(NSString *)url withTag:(int)i
{
    NSString *auothorToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"];
    if (auothorToken) {
        NSDictionary *dict = @{@"token":auothorToken,@"optype":[NSNumber numberWithInteger:0]};
        HttpManager *http=[HttpManager defaultManager];
        http.delegate = self;
        http.tag = 2;
        [http sendPost:url param:dict];
    }
    
}
- (void)setupNaviBar {
    
    [self setNaviBarTitle:@"设置"]; //设置标题
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self adjustNaviBarFrameForSplitView];
        [self adjustTitleFrameForSplitView];
        [self setNaviBarLeftBtn:nil];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        if ([[IOManager getUserDefaultForKey:@"UserType"] integerValue] == 2) { //是普通用户，不显示“权限控制”
            return 6;
        }
            return 7;//是主人，显示“权限控制”
    }else{
        if([[IOManager getUserDefaultForKey:@"UserType"] integerValue] == 2) { //2代表普通用户，如果是普通用户，不显示“权限控制”
            return 6;
        }else {
            return 7;//是主人，显示“权限控制”
        }
    }
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   
    if ([[IOManager getUserDefaultForKey:@"UserType"] integerValue] == 2) { //普通用户，不显示“权限控制”选项
        if(section == 2)  // 系统设置，系统信息
        {
            return 2;
        }
    
    }else {
        if (section == 4) { // 系统设置，系统信息
            return 2;
        }
    }
    
    if (section == 3) {  //场景快捷键，定时器，地址管理
        return 3;
    }
    
    return 1;
}

-(void)viewDidLayoutSubviews {
    
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
        
    }
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)])  {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPat{
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]){
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"settingCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor colorWithRed:29/255.0 green:30/255.0 blue:34/255.0 alpha:1];
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    view.backgroundColor = [UIColor clearColor];
    cell.selectedBackgroundView = view;
    NSString *title;
    switch (indexPath.section) {
        case 0:
            title = @"推送设置";
            break;
            
        case 1:
            title = @"恢复初始设置";
            break;
            
        case 2:
            
            if ([[IOManager getUserDefaultForKey:@"UserType"] integerValue] == 2) {
                if(indexPath.row == 0)
                {
                    title = @"系统设置";
                }else {
                    title = @"系统信息";
                }
            }else {
                    title = @"权限控制";
            }
            
            break;
        case 3:
                if(indexPath.row == 0)
                {
                    title = @"场景快捷键";
                }else if(indexPath.row == 1){
                    title = @"定时器";
                }else {
                    title = @"地址管理";
                }
            break;
        case 4:
        {
           if ([[IOManager getUserDefaultForKey:@"UserType"] integerValue] == 2) {
                    title = @"去评价";
           }else {
               if(indexPath.row == 0)
               {
                    title = @"系统设置";
               }else {
                    title = @"系统信息";
               }
           }
            
            break;
        }
        case 5:
            if ([[IOManager getUserDefaultForKey:@"UserType"] integerValue] == 2) {
                title = @"关于我们";
            }else {
               
                title = @"去评价";
            }
            
            break;
        case 6:
            if ([[IOManager getUserDefaultForKey:@"UserType"] integerValue] == 2) {
                title = @"退出";
            }else{
                title = @"关于我们";
            }
            
            break;
        default:
            title = @"退出";
            cell.textLabel.textColor = [UIColor redColor];
            break;
    }
    cell.textLabel.text = title;
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView * view = [UIView new];
    view.frame = CGRectMake(0, 0, self.view.bounds.size.width, 0.3);
    view.backgroundColor = [UIColor whiteColor];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.3;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * view = [UIView new];
    view.frame = CGRectMake(0, 0, self.view.bounds.size.width, 20);
    UILabel * la = [[UILabel alloc] initWithFrame:CGRectMake(0, 19.5, self.view.bounds.size.width,0.5)];
    la.backgroundColor = [UIColor whiteColor];
    
    [view addSubview:la];
    
    return view;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{

    return 20;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    view.backgroundColor = [UIColor blackColor];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self goToViewController:indexPath];
}

- (void)goToViewController:(NSIndexPath *)indexPath
{
    UIStoryboard * MainBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIStoryboard * iphoneBoard = [UIStoryboard storyboardWithName:@"iPhone" bundle:nil];
    UIStoryboard * myInfoStoryBoard  = [UIStoryboard storyboardWithName:@"MyInfo" bundle:nil];
    
    if(indexPath.section == 0)
    {
        PushSettingController * pushVC = [MainBoard instantiateViewControllerWithIdentifier:@"PushSettingController"];
        [self.navigationController pushViewController:pushVC animated:YES];
    }
    
    else if(indexPath.section == 1) { //恢复初始设置
      //弹出二次确认对话框
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"确定恢复吗？" message:@"恢复初始设置后，自定义的场景将被删除，系统场景图片将被恢复为默认图片，场景快捷键将被移除" preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController: alertVC animated:YES completion:nil];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [alertVC dismissViewControllerAnimated:YES completion:nil];
        }];
        UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSString *isDemo = [UD objectForKey:IsDemo];
            if ([isDemo isEqualToString:@"YES"]) {
                [MBProgressHUD showSuccess:@"你无权操作，请登录后再操作"];
            }else {
                //执行恢复
                [self doResetOperation];
            }
        }];
        [alertVC addAction:cancelAction];
        [alertVC addAction:sureAction];
        
    }
    
    else if(indexPath.section == 2) {
       if ([[IOManager getUserDefaultForKey:@"UserType"] integerValue] == 2) {
           if(indexPath.row == 0)
           {
               SystemSettingViewController * systemVC = [MainBoard instantiateViewControllerWithIdentifier:@"SystemSettingViewController"];
               [self.navigationController pushViewController:systemVC animated:YES];
           }else {
               SystemInfomationController * systemInfoVC = [MainBoard instantiateViewControllerWithIdentifier:@"systemInfomationController"];
               [self.navigationController pushViewController:systemInfoVC animated:YES];
           }
       }else {
          
           if (_Seccess) {
               AccessSettingController * accessVC = [MainBoard instantiateViewControllerWithIdentifier:@"AccessSettingController"];
               [self.navigationController pushViewController:accessVC animated:YES];
           }else{
               
               [MBProgressHUD showError:@"您为普通用户， 无权限访问"];
           }
        }
        
      }
    
    else if (indexPath.section == 3) {
          if (indexPath.row == 0) {
              //场景快捷键
              SceneShortcutsViewController *vc = [myInfoStoryBoard instantiateViewControllerWithIdentifier:@"SceneShortcutsVC"];
              vc.isShowInSplitView = YES;
              [self.navigationController pushViewController:vc animated:YES];
          }else if(indexPath.row == 1){
              //定时器
              DeviceListTimeVC * deviceList = [iphoneBoard instantiateViewControllerWithIdentifier:@"iPhoneDeviceListTimeVC"];
              [self.navigationController pushViewController:deviceList animated:YES];
          }else { // 地址管理
              DeliveryAddressViewController *vc = [myInfoStoryBoard instantiateViewControllerWithIdentifier:@"DeliveryAddressVC"];
              vc.hidesBottomBarWhenPushed = YES;
              [self.navigationController pushViewController:vc animated:YES];
          }
        
     }
    
      else if(indexPath.section == 4) {
        if ([[IOManager getUserDefaultForKey:@"UserType"] integerValue] == 2) {
                [self gotoAppStoreToComment];
        }else {
            if(indexPath.row == 0)
            {
            SystemSettingViewController * systemVC = [MainBoard instantiateViewControllerWithIdentifier:@"SystemSettingViewController"];
                [self.navigationController pushViewController:systemVC animated:YES];
            }else {
         SystemInfomationController * systemInfoVC = [MainBoard instantiateViewControllerWithIdentifier:@"systemInfomationController"];
                [self.navigationController pushViewController:systemInfoVC animated:YES];
            }
        }
        
        
    }
    
      else if(indexPath.section == 5) {
        if ([[IOManager getUserDefaultForKey:@"UserType"] integerValue] == 2) {
           AboutUsController * aboutVC = [MainBoard instantiateViewControllerWithIdentifier:@"AboutUsController"];
            [self.navigationController pushViewController:aboutVC animated:YES];
        }else {
            [self gotoAppStoreToComment];
        }
    
    }
    
      else if(indexPath.section == 6) {
        if ([[IOManager getUserDefaultForKey:@"UserType"] integerValue] == 2) {
            AboutUsController * aboutVC = [MainBoard instantiateViewControllerWithIdentifier:@"AboutUsController"];
            [self.navigationController pushViewController:aboutVC animated:YES];
            //退出发送请求
            NSString *authorToken =[[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"];
            if (authorToken) {
                NSDictionary *dict = @{@"token":authorToken};
                
                NSString *url = [NSString stringWithFormat:@"%@login/logout.aspx",[IOManager httpAddr]];
                HttpManager *http=[HttpManager defaultManager];
                http.delegate=self;
                http.tag = 1;
                [http sendPost:url param:dict];
            }else{
                //跳转到欢迎页
                //self.splitViewController.preferredDisplayMode = UISplitViewControllerDisplayModePrimaryHidden;
                //[self performSegueWithIdentifier:@"goWelcomeSegue" sender:self];
                [self gotoLoginViewController];
            }

        }else{
            AboutUsController * aboutVC = [MainBoard instantiateViewControllerWithIdentifier:@"AboutUsController"];
            [self.navigationController pushViewController:aboutVC animated:YES];
        }
        
    }else {
        //退出发送请求
        NSString *authorToken =[[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"];
        if (authorToken) {
            NSDictionary *dict = @{@"token":authorToken};
        
            NSString *url = [NSString stringWithFormat:@"%@login/logout.aspx",[IOManager httpAddr]];
            HttpManager *http=[HttpManager defaultManager];
            http.delegate=self;
            http.tag = 1;
            [http sendPost:url param:dict];
        }else{
            //跳转到欢迎页
            //self.splitViewController.preferredDisplayMode = UISplitViewControllerDisplayModePrimaryHidden;
            //[self performSegueWithIdentifier:@"goWelcomeSegue" sender:self];
            [self gotoLoginViewController];
        }
    }

}
//退出登录
- (IBAction)QuitBtn:(id)sender {
        [UD removeObjectForKey:@"AuthorToken"];  [UD synchronize]; //清空token
        [[SocketManager defaultManager] cutOffSocket];//断开socket长连接
        [[RCIM sharedRCIM] logout];//IM注销
        [[UIApplication sharedApplication] unregisterForRemoteNotifications];//注销推送通知
        [self gotoLoginViewController];//跳转到登录页面
}

- (void)gotoLoginViewController {
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    UIViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"loginNavController"];//进入登录页面
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.window.rootViewController = vc;
    [appDelegate.window makeKeyAndVisible];
}

- (void)doResetOperation {
    //删除服务器端自定义场景
    [self resetSceneOfServer];
    
}

- (void)resetSceneOfServer {
    NSString *url = [NSString stringWithFormat:@"%@Cloud/factory_reset.aspx",[IOManager httpAddr]];
    NSString *authorToken = [UD objectForKey:@"AuthorToken"];
    
    if (authorToken.length >0) {
        NSDictionary *dict = @{
                               @"token":authorToken
                               };
        HttpManager *http = [HttpManager defaultManager];
        http.delegate = self;
        http.tag = 3;
        [http sendPost:url param:dict];
    }
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"goWelcomeSegue"])
    {
//        WelcomeController *welcomeVC = segue.destinationViewController;
//        welcomeVC.coverView.hidden = YES;
    }
}

- (void)httpHandler:(id) responseObject tag:(int)tag
{
    if(tag == 1)
    {
        if([responseObject[@"Result"] intValue] == 0)
        {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"AuthorToken"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [[SocketManager defaultManager] cutOffSocket];

            [self gotoLoginViewController];
            
            
        }else {
            [MBProgressHUD showSuccess:responseObject[@"Msg"]];
        }

    }
    if(tag == 2)
    {
        if([responseObject[@"result"] intValue]==0)
        {
            _Seccess = YES;
            NSArray *arr = responseObject[@"user_list"];
            for(NSDictionary *userDetail in arr)
            {
                NSString *userName = userDetail[@"username"];
                NSString *userType = userDetail[@"usertype"];
                NSString *userID = userDetail[@"user_id"];
                [self.userArr addObject:userName];
                [self.managerType addObject:userType];
                [self.userIDArr addObject:userID];
                
            }
      
        }else{
            
            _Seccess = NO;
            
        }
        
    }
    
    if (tag == 3) { // 恢复初始设置
        if([responseObject[@"result"] intValue] == 0)
        {
            //请求场景配置信息
            [self sendRequestForGettingConfigInfos:@"Cloud/load_config_data.aspx" withTag:4];
        }else {
            [MBProgressHUD showError:@"恢复失败，请稍后再试"];
        }
    }
    
    if (tag == 4) { // 场景配置信息
        if ([responseObject[@"result"] intValue] == 0)
        {
            NSDictionary *versioninfo = responseObject[@"version_info"];
            //执久化配置版本号
            [versioninfo enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                [IOManager writeUserdefault:obj forKey:key];
            }];
            
            //写场景配置信息到sql
            [self writeScensConfigDataToSQL:responseObject[@"room_scence_list"]];
            
            //发通知刷新设备首页，场景首页,app首页
            [NC postNotificationName:@"ChangeHostRefreshUINotification" object:nil];
            
            
            [MBProgressHUD showSuccess:@"恢复成功"];
            
        }else{
            [MBProgressHUD showError:@"恢复失败,请稍后再试"];
        }
    }
    
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
- (void)downloadPlsit:(NSString *)urlPlist
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

//获取设备配置信息
- (void)sendRequestForGettingConfigInfos:(NSString *)str withTag:(int)tag;
{
    NSString *url = [NSString stringWithFormat:@"%@%@",[IOManager httpAddr],str];
    NSString *md5Json = [IOManager md5JsonByScenes:[NSString stringWithFormat:@"%ld",[DeviceInfo defaultManager].masterID]];
    NSDictionary *dic = @{
                          @"token":[UD objectForKey:@"AuthorToken"],
                          @"md5Json":md5Json,
                          @"change_host":@(0)//是否是切换家庭 0:否  1:是
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
                @"change_host":@(0)//是否是切换家庭 0:否  1:是
                };
    }
    HttpManager *http = [HttpManager defaultManager];
    http.delegate = self;
    http.tag = tag;
    [http sendPost:url param:dic];
}

-(void)gotoAppStoreToComment
{
    NSString *str = [NSString stringWithFormat:@"https://itunes.apple.com/cn/app/yi-yun-zhi-neng-jia-ju/id1173335171?l=zh&ls=1&mt=8"];
    NSURL * url = [NSURL URLWithString:str];
    
    if ([[UIApplication sharedApplication] canOpenURL:url])
    {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    }
    else
    {
        NSLog(@"can not open");
    }
}

#pragma mark - SingleMaskViewDelegate
- (void)onNextButtonClicked:(UIButton *)btn pageType:(PageTye)pageType {
    UIStoryboard * MainBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    AccessSettingController * accessVC = [MainBoard instantiateViewControllerWithIdentifier:@"AccessSettingController"];
    [self.navigationController pushViewController:accessVC animated:YES];
}

- (void)onSkipButtonClicked:(UIButton *)btn pageType:(PageTye)pageType {
    [UD setObject:@"haveShownMask" forKey:ShowMaskViewAccessControl];
    [UD synchronize];
}

- (void)onTransparentBtnClicked:(UIButton *)btn {
    UIStoryboard * MainBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    AccessSettingController * accessVC = [MainBoard instantiateViewControllerWithIdentifier:@"AccessSettingController"];
    [self.navigationController pushViewController:accessVC animated:YES];
    
}

@end
