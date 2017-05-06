//
//  LoginViewController.m
//  SmartHome
//
//  Created by KobeBryant on 2017/3/21.
//  Copyright © 2017年 ECloud. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

@synthesize userType;
@synthesize UserType;

-(NSMutableArray *)hostIDS
{
    if(!_hostIDS)
    {
        _hostIDS = [NSMutableArray array];
    }
    return _hostIDS;
}

- (NSMutableArray *)homeNameArray {
    if(!_homeNameArray)
    {
        _homeNameArray = [NSMutableArray array];
    }
    return _homeNameArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addNotifications];
   [self.nameTextField setValue:[UIColor grayColor] forKeyPath:@"_placeholderLabel.textColor"];
    
    [self.pwdTextField setValue:[UIColor grayColor] forKeyPath:@"_placeholderLabel.textColor"];
    
    self.nameTextField.delegate = self;
    self.pwdTextField.delegate = self;
    
    self.nameTextField.text = [[NSUserDefaults  standardUserDefaults] objectForKey:@"Account"];
    userType = [[UD objectForKey:@"Type"] intValue];
    self.pwdTextField.text = [[[NSUserDefaults standardUserDefaults] objectForKey:@"Password"] decryptWithDes:DES_KEY];
    UserType =[[UD objectForKey:@"UserType"] intValue];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    //判断滑动图是否出现过，第一次调用时“isScrollViewAppear” 这个key 对应的值是nil，会进入if中
    if (![@"YES" isEqualToString:[userDefaults objectForKey:@"isScrollViewAppear"]]) {
        
        [self showScrollView];//显示滑动图
    }

}

#pragma mark - 滑动图

-(void) showScrollView{
    
    UIScrollView *_scrollView = [[UIScrollView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    //设置UIScrollView 的显示内容的尺寸，有n张图要显示，就设置 屏幕宽度*n ，这里假设要显示4张图
    _scrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width * 4, [UIScreen mainScreen].bounds.size.height);
    
    _scrollView.tag = 101;
    
    //设置翻页效果，不允许反弹，不显示水平滑动条，设置代理为自己
    _scrollView.pagingEnabled = YES;
    _scrollView.bounces = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.delegate = self;
    
    //在UIScrollView 上加入 UIImageView
    for (int i = 0 ; i < 4; i ++) {
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width * i , 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        
        //将要加载的图片放入imageView 中
        //UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%d",i+1]];
        UIImage *image = [UIImage imageNamed:@"IMG_3892.jpg"];
        imageView.image = image;
        [_scrollView addSubview:imageView];
    }
    
    //初始化 UIPageControl 和 _scrollView 显示在 同一个页面中
    UIPageControl *pageConteol = [[UIPageControl alloc] initWithFrame:CGRectMake((UI_SCREEN_WIDTH-50)/2, self.view.frame.size.height - 60, 50, 40)];
    pageConteol.numberOfPages = 4;//设置pageConteol 的page 和 _scrollView 上的图片一样多
    pageConteol.tag = 201;
    
    [self.view addSubview:_scrollView];
    [self.view addSubview: pageConteol];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    // 记录scrollView 的当前位置，因为已经设置了分页效果，所以：位置/屏幕大小 = 第几页
    int current = scrollView.contentOffset.x/[UIScreen mainScreen].bounds.size.width;
    
    //根据scrollView 的位置对page 的当前页赋值
    UIPageControl *page = (UIPageControl *)[self.view viewWithTag:201];
    page.currentPage = current;
    
    //当显示到最后一页时，让滑动图消失
    if (page.currentPage == 3) {
        
        //调用方法，使滑动图消失
        [self scrollViewDisappear];
    }
}

-(void)scrollViewDisappear{
    
    //拿到 view 中的 UIScrollView 和 UIPageControl
    UIScrollView *scrollView = (UIScrollView *)[self.view viewWithTag:101];
    UIPageControl *page = (UIPageControl *)[self.view viewWithTag:201];
    
    //设置滑动图消失的动画效果图
    [UIView animateWithDuration:3.0f animations:^{
        
        scrollView.center = CGPointMake(self.view.frame.size.width/2, 1.5 * self.view.frame.size.height);
        
    } completion:^(BOOL finished) {
        
        [scrollView removeFromSuperview];
        [page removeFromSuperview];
    }];
    
    //将滑动图启动过的信息保存到 NSUserDefaults 中，使得第二次不运行滑动图
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@"YES" forKey:@"isScrollViewAppear"];
}

- (void)addNotifications {
    [NC addObserver:self selector:@selector(registSuccessNotification:) name:@"registSuccess" object:nil];
}

- (void)removeNotifications {
    [NC removeObserver:self];
}

- (void)registSuccessNotification:(NSNotification *)noti {
    NSString *phoneNum = (NSString *)noti.object;
    _nameTextField.text = phoneNum;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [self removeNotifications];
}

- (IBAction)forgetPwdBtnClicked:(id)sender {
    [WebManager show:[[IOManager httpAddr] stringByAppendingString:@"/user/update_pwd.aspx"]];
}

- (IBAction)tryBtnClicked:(id)sender {
    
    AVPlayer *player = [[AVPlayer alloc] initWithURL:[[NSBundle mainBundle] URLForResource:@"demo.mov" withExtension:nil]];
    
    _avPlayerVC = [[AVPlayerViewController alloc] init];
    _avPlayerVC.player = player;
    _avPlayerVC.view.frame = self.view.bounds;
    [self.navigationController pushViewController:_avPlayerVC animated:YES];
    
    player.externalPlaybackVideoGravity = AVLayerVideoGravityResizeAspectFill;//这个属性和图片填充试图的属性类似，也可以设置为自适应试图大小。
     [player play];
}

- (void)gotoIPhoneMainViewController {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.mainTabBarController = [[BaseTabBarController alloc] init];
    LeftViewController *leftVC = [[LeftViewController alloc] init];
    appDelegate.LeftSlideVC = [[LeftSlideViewController alloc] initWithLeftView:leftVC andMainView:appDelegate.mainTabBarController];
    appDelegate.window.rootViewController = appDelegate.LeftSlideVC;
}

- (IBAction)loginBtnClicked:(id)sender {
    
    if ([self.nameTextField.text isEqualToString:@""])
    {
        [MBProgressHUD showError:@"请输入家庭名称或手机号"];
        return;
    }
    
    if ([self.pwdTextField.text isEqualToString:@""])
    {
        [MBProgressHUD showError:@"请输入家庭钥匙"];
        return;
    }
    
    NSString *url = [NSString stringWithFormat:@"%@login/login.aspx",[IOManager httpAddr]];
    
    userType = 1;//用户名登录
    if([self.nameTextField.text isMobileNumber])
    {
        userType = 2;//手机号登录
    }
    
    DeviceInfo *info=[DeviceInfo defaultManager];
    NSString *pushToken;
    if(info.pushToken)
    {
        pushToken = info.pushToken;
    }else{
        pushToken = @"777";
    }
    
    //手机终端类型：1，手机 2，iPad
    NSInteger clientType = 1;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        clientType = 2;
    }
    
    //判断是不是同一个用户，是同一个用户，传缓存的hostid, 不是同一个用户，传hostid为0
    NSInteger currentHostId = 0;//当前的hostId
    _isTheSameUser = NO;//是否是同一个用户标识
    NSString *account = [UD objectForKey:@"Account"];
    if ([account isEqualToString:self.nameTextField.text]) {//同一个用户
        _isTheSameUser = YES;
    }
    
    if (_isTheSameUser) {
        currentHostId = [[UD objectForKey:@"HostID"] integerValue];
    }
    
    NSDictionary *dict = @{
                           @"account":self.nameTextField.text,
                           @"logintype":@(userType),
                           @"password":[self.pwdTextField.text md5],
                           @"pushtoken":pushToken,
                           @"devicetype":@(clientType),
                           @"hostid":@(currentHostId)
                           };
    NSLog(@"%@ === login params ===: ", dict);
    
    
    HttpManager *http=[HttpManager defaultManager];
    http.delegate=self;
    http.tag = 1;
    [http sendPost:url param:dict];
}

- (IBAction)registBtnClicked:(id)sender {
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"扫描二维码注册", @"体验账号注册", nil];
    [sheet showInView:self.view];
}

#pragma mark - UIActionSheet Delegate 
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *btnTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([btnTitle isEqualToString:@"扫描二维码注册"]) {
        
        
        if ([QRCodeReader supportsMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]]) {
            static QRCodeReaderViewController *vc = nil;
            static dispatch_once_t onceToken;
            
            dispatch_once(&onceToken, ^{
                QRCodeReader *reader = [QRCodeReader readerWithMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
                vc = [QRCodeReaderViewController readerWithCancelButtonTitle:@"取消" codeReader:reader startScanningAtLoad:YES showSwitchCameraButton:YES showTorchButton:YES];
                vc.modalPresentationStyle = UIModalPresentationFormSheet;
            });
            vc.delegate = self;
            
            [vc setCompletionWithBlock:^(NSString *resultAsString) {
                NSLog(@"Completion with result: %@", resultAsString);
            }];
            
            [self presentViewController:vc animated:YES completion:NULL];
        }
        else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"标题" message:@"不能打开摄像头，请确认授权使用摄像头" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
            [alert addAction:okAction];
        }
        
    }else if ([btnTitle isEqualToString:@"体验账号注册"]) {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
        UIViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"registFirstStepForPhoneVC"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)writeQRCodeStringToFile:(NSString *)string{
    NSArray *paths;
    NSString  *arrayPath;
paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                            NSUserDomainMask, YES);//搜索沙盒路径下的document文件夹。
arrayPath = [[paths objectAtIndex:0]
             stringByAppendingPathComponent:@"QRCodeString.plist"];//在此文件夹下创建文件，相当于你的xxx.txt

NSArray *array = [NSArray arrayWithObjects:
                  string, nil];//将你的数据放入数组中

[array writeToFile:arrayPath atomically:YES];//将数组中的数据写入document下xxx.txt。

    
}

#pragma mark - QRCode Delegate
- (void)readerDidCancel:(QRCodeReaderViewController *)reader
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)reader:(QRCodeReaderViewController *)reader didScanResult:(NSString *)result
{
    result=[result decryptWithDes:DES_KEY];
    
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    UIViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"registFirstStepVC"];
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        //result 格式： hostid @ hostname @ userType
        NSArray* list = [result componentsSeparatedByString:@"@"];
        if([list count] > 2)
        {
            self.masterId = list[0];
            self.hostName = list[1];
            [vc setValue:self.masterId forKey:@"masterStr"];
            [vc setValue:self.hostName forKey:@"hostName"];
            
            
            if ([@"1" isEqualToString:list[2]]) {
                self.role=@"主人";
            }else{
                self.role=@"客人";
            }
            [vc setValue:self.role forKey:@"suerTypeStr"];
        }
        
        
        /*if([list count] > 1)
        {
            self.masterId = list[0];
            [vc setValue:@([self.masterId intValue]) forKey:@"masterStr"];
            if ([@"1" isEqualToString:list[1]]) {
                self.role=@"主人";
            }else{
                self.role=@"客人";
            }
            [vc setValue:self.role forKey:@"suerTypeStr"];
        }*/
        
        
        else
        {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"非法的二维码" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
            [alert addAction:okAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }];
    [self.navigationController pushViewController:vc animated:YES];
    
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [UIView animateWithDuration:0.2 animations:^(){
        
        self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y-130, self.view.frame.size.width, self.view.frame.size.height);
        
        
    } completion:^(BOOL finished){
        
        
    }];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [UIView animateWithDuration:0.2 animations:^(){
        
        self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y+130, self.view.frame.size.width, self.view.frame.size.height);
        
        
    } completion:^(BOOL finished){
        
        
    }];
}

//获取设备配置信息
- (void)sendRequestForGettingConfigInfos:(NSString *)str withTag:(int)tag;
{
    NSString *url = [NSString stringWithFormat:@"%@%@",[IOManager httpAddr],str];
    NSString *md5Json = [IOManager md5JsonByScenes:[NSString stringWithFormat:@"%ld",[DeviceInfo defaultManager].masterID]];
    NSDictionary *dic = @{
                          @"token":[UD objectForKey:@"AuthorToken"],
                          @"md5Json":md5Json
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
                @"md5Json":md5Json
                };
        }
        HttpManager *http = [HttpManager defaultManager];
        http.delegate = self;
        http.tag = tag;
        [http sendPost:url param:dic];
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


-(void) writeChatListConfigDataToSQL:(NSArray *)users
{
    if(users.count == 0 || users == nil)
    {
        return;
    }
    [SQLManager writeChats:users];
}

#pragma mark -  http delegate
-(void) httpHandler:(id) responseObject tag:(int)tag
{
    DeviceInfo *info=[DeviceInfo defaultManager];
    if ([responseObject[@"result"] intValue]==0)
    {
        info.db=SMART_DB;
    }
    
    if(tag == 1)
    {
        if ([responseObject[@"result"] intValue]==0) {
            
            //登录成功，才缓存用户账号，密码，登录类型
            [IOManager writeUserdefault:self.nameTextField.text forKey:@"Account"];
            [IOManager writeUserdefault:[NSNumber numberWithInteger:self.userType] forKey:@"Type"];
            [IOManager writeUserdefault:[self.pwdTextField.text encryptWithDes:DES_KEY] forKey:@"Password"];
            
            [IOManager writeUserdefault:responseObject[@"token"] forKey:@"AuthorToken"];
            [IOManager writeUserdefault:responseObject[@"username"] forKey:@"UserName"];
            [IOManager writeUserdefault:responseObject[@"userid"] forKey:@"UserID"];
            [IOManager writeUserdefault:responseObject[@"usertype"] forKey:@"UserType"];
            [IOManager writeUserdefault:responseObject[@"vip"] forKey:@"vip"];
            
            //保存登录用户信息
            
            UserInfo *userInfo = [[UserInfo alloc] init];
            userInfo.userID = [responseObject[@"userid"] integerValue];
            userInfo.userName = responseObject[@"username"];
            userInfo.nickName = responseObject[@"nickname"];
            userInfo.userType = [responseObject[@"usertype"] integerValue]; //1:主人  2:客人
            userInfo.vip = responseObject[@"vip"];
            userInfo.headImgURL = responseObject[@"portrait"];
            userInfo.age = 30;
            userInfo.sex = 1;
            userInfo.signature = @"";
            userInfo.phoneNum = @"";
            
           BOOL succeed = [SQLManager insertOrReplaceUser:userInfo];// 登录用户基本信息入库
            if (succeed) {
                NSLog(@"登录用户基本信息入库成功");
            }else {
                NSLog(@"登录用户基本信息入库失败");
            }
            
            NSArray *hostList = responseObject[@"hostlist"];
            
            for(NSDictionary *host in hostList)
            {
                if (host[@"hostid"]) {
                    [self.hostIDS addObject:host[@"hostid"]];
                }
                
                if (host[@"homename"]) {
                    [self.homeNameArray addObject:host[@"homename"]];
                }
            }
            
            
            //缓存HostIDS， HomeNameList
            if (self.hostIDS) {
                [IOManager writeUserdefault:self.hostIDS forKey:@"HostIDS"];
            }
            
            if (self.homeNameArray) {
                [IOManager writeUserdefault:self.homeNameArray forKey:@"HomeNameList"];
            }
            
            
            if (!_isTheSameUser) { //如果不是同一个用户, 或者是同一个用户，但卸载重装了App
                if ([self.hostIDS count] >0) {
                    int mid = [self.hostIDS[0] intValue];
                    //切换帐号后，版本号归零
                    if (mid != [[UD objectForKey:@"HostID"] intValue]) {
                        [UD removeObjectForKey:@"room_version"];
                        [UD removeObjectForKey:@"equipment_version"];
                        [UD removeObjectForKey:@"scence_version"];
                        [UD removeObjectForKey:@"tv_version"];
                        [UD removeObjectForKey:@"fm_version"];
                    }
                    
                    //更新UD的@"HostID"， 更新DeviceInfo的 masterID
                    [IOManager writeUserdefault:@(mid) forKey:@"HostID"];
                    info.masterID = mid;
                }
            }
            
            
            [IOManager writeUserdefault:responseObject[@"rctoken"] forKey:@"rctoken"];
            [IOManager writeUserdefault:responseObject[@"homename"] forKey:@"homename"];
            [self writeChatListConfigDataToSQL:responseObject[@"userList"]];
            [self sendRequestForGettingConfigInfos:@"Cloud/load_config_data.aspx" withTag:2];
            
            //直接登录主机
            //[self sendRequestToHostWithTag:2 andRow:0];
        }else{
            [MBProgressHUD showError:responseObject[@"msg"]];
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
            
            if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            {
                [self gotoIPhoneMainViewController];
            }else {
                [self goToViewController];
            }
        }else{
            [MBProgressHUD showError:responseObject[@"msg"]];
        }
    }
}

- (void)goToViewController
{
    ECloudTabBarController *ecloudVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ECloudTabBarController"];
    [self presentViewController:ecloudVC animated:YES completion:nil];
}

-(void)sendRequestToHostWithTag:(int)tag andRow:(int)row
{
    NSString *url = [NSString stringWithFormat:@"%@UserLoginHost.aspx",[IOManager httpAddr]];
    
    NSString *authorToken = [IOManager getUserDefaultForKey:@"AuthorToken"];
    NSString *hostID = self.hostIDS[row];
    
    NSDictionary *dict = nil;
    if (authorToken.length >0 && hostID.length >0) {
        
        dict = @{@"AuthorToken":authorToken,
                 @"HostID":hostID
                 
                 };
    }
    [IOManager writeUserdefault:hostID forKey:@"HostID"];
    [IOManager writeUserdefault:self.nameTextField.text forKey:@"Account"];
    
    if (dict) {
        HttpManager *http = [HttpManager defaultManager];
        http.delegate = self;
        http.tag = tag;
        [http sendPost:url param:dict];
    }else {
        NSLog(@"请求参数dict为 nil");
    }
}


@end
