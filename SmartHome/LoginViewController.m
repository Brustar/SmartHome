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

- (void)viewDidLoad {
    [super viewDidLoad];
   [self.nameTextField setValue:[UIColor grayColor] forKeyPath:@"_placeholderLabel.textColor"];
    
    [self.pwdTextField setValue:[UIColor grayColor] forKeyPath:@"_placeholderLabel.textColor"];
    
    self.nameTextField.delegate = self;
    self.pwdTextField.delegate = self;
    
    self.nameTextField.text = [[NSUserDefaults  standardUserDefaults] objectForKey:@"Account"];
    userType = [[UD objectForKey:@"Type"] intValue];
    self.pwdTextField.text = [[[NSUserDefaults standardUserDefaults] objectForKey:@"Password"] decryptWithDes:DES_KEY];
    UserType =[[UD objectForKey:@"UserType"] intValue];
    
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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
    
    userType = 1;
    if([self.nameTextField.text isMobileNumber])
    {
        userType = 2;
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
    
    NSDictionary *dict = @{@"account":self.nameTextField.text,@"logintype":[NSNumber numberWithInteger:userType],@"password":[self.pwdTextField.text md5],@"pushtoken":pushToken,@"devicetype":@(clientType),@"devicetype":[NSNumber numberWithInteger:userType]};
    NSLog(@"%@ === login params ===: ", dict);
    [IOManager writeUserdefault:self.nameTextField.text forKey:@"Account"];
    [IOManager writeUserdefault:[NSNumber numberWithInteger:self.userType] forKey:@"Type"];
    [IOManager writeUserdefault:[self.pwdTextField.text encryptWithDes:DES_KEY] forKey:@"Password"];
    
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
        
        NSArray* list = [result componentsSeparatedByString:@"@"];
        if([list count] > 1)
        {
            self.masterId = list[0];
            [vc setValue:self.masterId forKey:@"masterStr"];
            if ([@"1" isEqualToString:list[1]]) {
                self.role=@"主人";
            }else{
                self.role=@"客人";
            }
            [vc setValue:self.role forKey:@"suerTypeStr"];
        }
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
                @"md5Json":md5Json,
                @"fm_ver":[UD objectForKey:@"fm_version"]
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
    FMDatabase *db = [SQLManager connetdb];
    if([db open])
    {
        NSString *delsql=@"delete from Devices";
        [db executeUpdate:delsql];
        for(NSDictionary *room in rooms)
        {
            NSInteger rId = [room[@"room_id"] integerValue];
            NSArray *equipmentList = room[@"equipment_list"];
            if(equipmentList.count ==0 || equipmentList == nil)
            {
                continue;
            }
            for(NSDictionary *equip in equipmentList)
            {
                NSString *sql = [NSString stringWithFormat:@"insert into Devices values(%d,'%@',%@,%@,%@,%@,%@,%@,%@,'%@',%@,%@,%@,%@,%ld,'%@','%@',%@,'%@','%@','%ld','%@','%@')",[equip[@"equipment_id"] intValue],equip[@"name"],NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,(long)rId,equip[@"number"],equip[@"htype_id"],equip[@"subtype_id"],equip[@"type_name"],equip[@"subtype_name"],[[DeviceInfo defaultManager] masterID],equip[@"imgurl"],equip[@"cameraurl"]]; //cameraurl
                
                BOOL result = [db executeUpdate:sql];
                if(result)
                {
                    NSLog(@"insert 成功");
                }else{
                    NSLog(@"insert 失败");
                }
                
            }
            
        }
        
    }
    [db close];
}

//写房间配置信息到SQL
-(void)writeRoomsConfigDataToSQL:(NSDictionary *)responseObject
{
    NSArray *roomList = responseObject[@"roomlist"];
    if(roomList.count == 0 || roomList == nil)
    {
        return;
    }
    FMDatabase *db = [SQLManager connetdb];
    if([db open])
    {
        NSString *delsql=@"delete from Rooms";
        [db executeUpdate:delsql];
        for(NSDictionary *roomDic in roomList)
        {
            if(roomDic)
            {
                NSString *sql = [NSString stringWithFormat:@"insert into Rooms values(%d,'%@',null,null,null,null,null,'%@',%d,null,'%ld',%d)",[roomDic[@"room_id"] intValue],roomDic[@"room_name"],roomDic[@"room_image_url"],[roomDic[@"ibeacon"] intValue],[DeviceInfo defaultManager].masterID,[roomDic[@"isaccess"] intValue]];
                BOOL result = [db executeUpdate:sql];
                if(result)
                {
                    NSLog(@"insert 成功");
                }else{
                    NSLog(@"insert 失败");
                }
                
            }
        }
    }
    [db close];
}

//写场景配置信息到SQL
-(void)writeScensConfigDataToSQL:(NSArray *)rooms
{
    if(rooms.count == 0 || rooms == nil)
    {
        return;
    }
    FMDatabase *db = [SQLManager connetdb];
    if([db open])
    {
        NSString *delsql=@"delete from Scenes";
        [db executeUpdate:delsql];
        for (NSDictionary *room in rooms) {
            NSString *rName = room[@"room_name"];
            int room_id = [room[@"room_id"] intValue];
            NSArray *sceneList = room[@"scene_list"];
            
            for(NSDictionary *sceneInfoDic in sceneList)
            {
                int sId = [sceneInfoDic[@"scence_id"] intValue];
                NSString *sName = sceneInfoDic[@"name"];
                int isFavorite = [sceneInfoDic[@"isstore"] intValue];//是否收藏，1:已收藏 2: 未收藏
                int sType = [sceneInfoDic[@"type"] intValue];
                NSString *sNumber = sceneInfoDic[@"snumber"];
                NSString *urlImage = sceneInfoDic[@"image_url"];
                if(sceneInfoDic[@"plist_url"])
                {
                    NSString *urlPlist = sceneInfoDic[@"plist_url"];
                    [self downloadPlsit:urlPlist];
                }
                NSString *sql = [NSString stringWithFormat:@"insert into Scenes values(%d,'%@','%@','%@',%d,%d,'%@',%d,null,'%ld', %d)",sId,sName,rName,urlImage,room_id,sType,sNumber,isFavorite,[DeviceInfo defaultManager].masterID, 0];
                BOOL result = [db executeUpdate:sql];
                if(result)
                {
                    NSLog(@"insert 场景信息 成功");
                }else{
                    NSLog(@"insert 场景信息 失败");
                }
            }
        }
    }
    
    [db close];
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
    FMDatabase *db = [SQLManager connetdb];
    if([db open])
    {
        for(NSDictionary *dicInfo in responseObject)
        {
            int eqId = [dicInfo[@"eqid"] intValue];
            NSString *eqNumber = dicInfo[@"eqnumber"];
            NSString *key = [NSString stringWithFormat:@"store_%@_list",parent];
            NSArray *channelList = dicInfo[key];
            if(channelList == nil || channelList .count == 0 )
            {
                return;
            }
            
            for(NSDictionary *channel in channelList)
            {
                NSString *sql = [NSString stringWithFormat:@"insert into Channels values(%d,%d,%d,%d,'%@','%@','%@',%d,'%@','%ld')",[channel[@"channel_id"] intValue],eqId,0,[channel[@"channel_number"] intValue],channel[@"channel_name"],channel[@"image_url"],parent,1,eqNumber,[DeviceInfo defaultManager].masterID];
                BOOL result = [db executeUpdate:sql];
                if(result)
                {
                    NSLog(@"insert 成功");
                }else{
                    NSLog(@"insert 失败");
                }
                
            }
            
        }
    }
    [db close];
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
    
    NSString *filePath = [docDir stringByAppendingPathComponent:@"testFile.txt"];
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
    FMDatabase *db = [SQLManager connetdb];
    if([db open])
    {
        NSString *delsql=@"delete from chats";
        [db executeUpdate:delsql];
        int i=0;
        for (NSDictionary *user in users) {
            
            NSString *nickname = user[@"nickname"];
            NSString *portrait = user[@"portrait"];
            NSString *username = user[@"username"];
            int user_id = [user[@"user_id"] intValue];
            
            NSString *sql = [NSString stringWithFormat:@"insert into chats values(%d,'%@','%@','%@',%d)",i++,nickname,portrait,username,user_id];
            BOOL result = [db executeUpdate:sql];
            if(result)
            {
                NSLog(@"insert 聊天信息 成功");
            }else{
                NSLog(@"insert 聊天信息 失败");
            }
            
        }
        [IOManager writeUserdefault:@(i) forKey:@"familyNum"];
    }
    
    [db close];
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
            [IOManager writeUserdefault:responseObject[@"token"] forKey:@"AuthorToken"];
            [IOManager writeUserdefault:responseObject[@"username"] forKey:@"UserName"];
            [IOManager writeUserdefault:responseObject[@"userid"] forKey:@"UserID"];
            [IOManager writeUserdefault:responseObject[@"usertype"] forKey:@"UserType"];
            [IOManager writeUserdefault:responseObject[@"vip"] forKey:@"vip"];
            NSArray *hostList = responseObject[@"hostlist"];
            
            for(NSDictionary *hostID in hostList)
            {
                [self.hostIDS addObject:hostID[@"hostid"]];
            }
            
            [IOManager writeUserdefault:self.hostIDS forKey:@"HostIDS"];
            if ([self.hostIDS count]>0) {
                int mid = [self.hostIDS[0] intValue];
                //切换帐号后，版本号归零
                if (mid != [[UD objectForKey:@"HostID"] intValue]) {
                    [UD removeObjectForKey:@"room_version"];
                    [UD removeObjectForKey:@"equipment_version"];
                    [UD removeObjectForKey:@"scence_version"];
                    [UD removeObjectForKey:@"tv_version"];
                    [UD removeObjectForKey:@"fm_version"];
                }
                
                [IOManager writeUserdefault:@(mid) forKey:@"HostID"];
                info.masterID = mid;
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
    }else if(tag == 2){
        if ([responseObject[@"result"] intValue]==0)
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
