//
//  LoginController.m
//  SmartHome
//
//  Created by Brustar on 16/6/29.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "LoginController.h"
#import "MBProgressHUD+NJ.h"
#import "WebManager.h"
#import "NSString+RegMatch.h"
#import "SocketManager.h"
#import "SceneController.h"
#import "QRCodeReaderDelegate.h"
#import "QRCodeReader.h"
#import "QRCodeReaderViewController.h"
#import "RegisterPhoneNumController.h"
#import "MSGController.h"
#import "ProfileFaultsViewController.h"
#import "ServiceRecordViewController.h"
#import "RegisterDetailController.h"
#import "ECloudTabBarController.h"
#import "SQLManager.h"
#import "FMDatabase.h"
#import "DeviceInfo.h"
#import "PackManager.h"
#import "CryptoManager.h"
#import "SunCount.h"
#import <CoreLocation/CoreLocation.h>

@class SystemInfomationController;
@interface LoginController ()<QRCodeReaderDelegate,UITableViewDelegate,UITableViewDataSource,CLLocationManagerDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *user;
@property (weak, nonatomic) IBOutlet UITextField *pwd;
@property (weak, nonatomic) IBOutlet UIView *coverView;
@property (weak, nonatomic) IBOutlet UIView *registerView;
@property(nonatomic,assign) NSInteger userType;
@property(nonatomic,assign) NSInteger UserType;//判断是否为主人 
@property(nonatomic,strong) NSString *masterId;
@property(nonatomic,strong) NSString *role;
@property(nonatomic,strong) NSMutableArray *hostIDS;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,assign) int vEquipmentsLast;
@property (nonatomic,assign) int vRoomLast;
@property (nonatomic,assign) int vSceneLast;
@property (nonatomic,assign) int vTVChannelLast;
@property (nonatomic,assign) int vFMChannellLast;
@property (nonatomic,assign) int vClientlLast;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthConstraint;

@property (nonatomic,strong) NSArray *antronomicalTimes;
@property (strong,nonatomic) CLLocationManager *lm;
@end

@implementation LoginController
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
    
    self.user.delegate = self;
    self.pwd.delegate = self;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        self.widthConstraint.constant = [[UIScreen mainScreen] bounds].size.width *0.8;

    }else{
        self.widthConstraint.constant = 400;
    }
    
    self.tableView.tableFooterView = [UIView new];
    self.user.text = [[NSUserDefaults  standardUserDefaults] objectForKey:@"Account"];
    self.userType = [[[NSUserDefaults standardUserDefaults] objectForKey:@"Type"] intValue];
    self.pwd.text = [[[NSUserDefaults standardUserDefaults] objectForKey:@"Password"] decryptWithDes:DES_KEY];
    self.UserType =[[[NSUserDefaults standardUserDefaults] objectForKey:@"UserType"] intValue];
    if ([CLLocationManager locationServicesEnabled]) {
        self.lm = [[CLLocationManager alloc]init];
        self.lm.delegate = self;
        [self.lm requestWhenInUseAuthorization];
        
        // 最小距离
        self.lm.distanceFilter=kCLDistanceFilterNone;
        [self.lm startUpdatingLocation];
    }else{
        NSLog(@"定位服务不可用");
    }

    
 UIBarButtonItem *editItem = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(clickEditBtn:)];
    self.navigationItem.leftBarButtonItem = editItem;
   
}
-(void)clickEditBtn:(UIBarButtonItem *)bbi
{
    [self dismissViewControllerAnimated:YES completion:nil];

}
-(void)setAntronomicalTimes:(NSArray *)antronomicalTimes
{
    _antronomicalTimes = antronomicalTimes;
    //NSString *url = [NSString stringWithFormat:@"%@UpdateAstronomicalClock.aspx",[IOManager httpAddr]];
//    NSDictionary *dic = @{@"Dawn":self.antronomicalTimes[0],@"SunRise":self.antronomicalTimes[1],@"Sunset":self.antronomicalTimes[2],@"Dusk":self.antronomicalTimes[3]};
//    HttpManager *http = [HttpManager defaultManager];
//    http.tag = 10;
//    [http sendPost:url param:dic];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)login:(id)sender
{
    if ([self.user.text isEqualToString:@""])
    {
        [MBProgressHUD showError:@"请输入用户名或手机号"];
        return;
    }
    
    if ([self.pwd.text isEqualToString:@""])
    {
        [MBProgressHUD showError:@"请输入密码"];
        return;
    }
    
    NSString *url = [NSString stringWithFormat:@"%@login/login.aspx",[IOManager httpAddr]];
    
    self.userType = 1;
    if([self.user.text isMobileNumber])
    {
        self.userType = 2;
    }
//    if([self.UserTypeStr isEqualToString:@"客人"])
//    {
//        self.UserType = 2;
//    }else self.UserType = 1;
    
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
    
    NSDictionary *dict = @{@"account":self.user.text,@"logintype":[NSNumber numberWithInteger:self.userType],@"password":[self.pwd.text md5],@"pushtoken":pushToken,@"devicetype":@(clientType),@"devicetype":[NSNumber numberWithInteger:self.userType]};
    NSLog(@"%@ === login params ===: ", dict);
    [IOManager writeUserdefault:self.user.text forKey:@"Account"];
    [IOManager writeUserdefault:[NSNumber numberWithInteger:self.userType] forKey:@"Type"];
    [IOManager writeUserdefault:[self.pwd.text encryptWithDes:DES_KEY] forKey:@"Password"];
//    [IOManager writeUserdefault:[NSNumber numberWithInteger:self.UserType] forKey:@"UserType"];
    HttpManager *http=[HttpManager defaultManager];
    http.delegate=self;
    http.tag = 1;
    [http sendPost:url param:dict];
    
}
//获取设备配置信息
- (void)sendRequestForGettingConfigInfos:(NSString *)str withTag:(int)tag;
{
    NSString *url = [NSString stringWithFormat:@"%@%@",[IOManager httpAddr],str];
    
    //天文时钟
    NSString *dawnStr = self.antronomicalTimes[0];//黎明
    NSString *sunriseStr = self.antronomicalTimes[1];//日出
    NSString *sunsetStr = self.antronomicalTimes[2];//日落
    NSString *duskStr = self.antronomicalTimes[3];//黄昏
    
    NSDictionary *dic = @{
                          @"token":[UD objectForKey:@"AuthorToken"],
                          @"dawn":dawnStr,
                          @"sunrise":sunriseStr,
                          @"sunset":sunsetStr,
                          @"dusk":duskStr
                          };
    
    if ([UD objectForKey:@"room_version"]) {
        
        dic = @{
                @"token":[UD objectForKey:@"AuthorToken"],
                @"room_ver":[UD objectForKey:@"room_version"],
                @"equipment_ver":[UD objectForKey:@"equipment_version"],
                @"scence_ver":[UD objectForKey:@"scence_version"],
                @"tv_ver":[UD objectForKey:@"tv_version"],
                @"fm_ver":[UD objectForKey:@"fm_version"],
                @"dawn":dawnStr,
                @"sunrise":sunriseStr,
                @"sunset":sunsetStr,
                @"dusk":duskStr
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
                NSString *sql = [NSString stringWithFormat:@"insert into Rooms values(%d,'%@',null,null,null,null,null,'%@',%d,null,'%ld')",[roomDic[@"room_id"] intValue],roomDic[@"room_name"],roomDic[@"room_image_url"],[roomDic[@"ibeacon"] intValue],[DeviceInfo defaultManager].masterID];
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
                NSString *sql = [NSString stringWithFormat:@"insert into Scenes values(%d,'%@','%@','%@',%d,%d,'%@',%d,null,'%ld')",sId,sName,rName,urlImage,room_id,sType,sNumber,isFavorite,[DeviceInfo defaultManager].masterID];
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
//    if (![[NSUserDefaults standardUserDefaults] valueForKey:@"isFirst"]) {
//       
//        [[NSUserDefaults standardUserDefaults] setValue:@"YES" forKey:@"isFirst"];
//         [array writeToFile:filePath atomically:YES];
//    }else{
//       
//    }
}

#pragma - mark http delegate
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
            //写房间配置信息到sql
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
                [self performSegueWithIdentifier:@"goToIphoneScene" sender:self];
            }else{
                [self goToViewController];
            }
        }else{
            [MBProgressHUD showError:responseObject[@"msg"]];
        }
    }
}

-(void)goToViewController;
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
    [IOManager writeUserdefault:self.user.text forKey:@"Account"];
    
    if (dict) {
        HttpManager *http = [HttpManager defaultManager];
        http.delegate = self;
        http.tag = tag;
        [http sendPost:url param:dict];
    }else {
        NSLog(@"请求参数dict为 nil");
    }
}

- (IBAction)forgotPWD:(id)sender
{
    
    [WebManager show:[[IOManager httpAddr] stringByAppendingString:@"/user/update_pwd.aspx"]];
}

//注册
- (IBAction)registerAccount:(id)sender {
    self.coverView.hidden = NO;
    self.registerView.hidden = NO;
}

- (IBAction)cancelRegister:(id)sender {
    self.coverView.hidden = YES;
    self.registerView.hidden = YES;
}
- (IBAction)scanCodeForRegistering:(id)sender {
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
    
}

- (void)reader:(QRCodeReaderViewController *)reader didScanResult:(NSString *)result
{
    result=[result decryptWithDes:DES_KEY];
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    RegisterPhoneNumController *registVC = [story instantiateViewControllerWithIdentifier:@"RegisterPhoneNumController"];
    [self dismissViewControllerAnimated:YES completion:^{
        
         NSArray* list = [result componentsSeparatedByString:@"@"];
            if([list count] > 1)
            {
                self.masterId = list[0];
                [registVC setValue:self.masterId forKey:@"masterStr"];
                                if ([@"1" isEqualToString:list[1]]) {
                    self.role=@"主人";
                }else{
                    self.role=@"客人";
                }
                [registVC setValue:self.role forKey:@"suerTypeStr"];
            }
            else
            {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"非法的二维码" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
                [alert addAction:okAction];
                [self presentViewController:alert animated:YES completion:nil];
            }
    }];
    [self presentViewController:registVC animated:YES completion:nil];
    
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    self.coverView.hidden = YES;
    self.registerView.hidden = YES;
    [self.view endEditing:YES];
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

#pragma  mark -UITableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.hostIDS.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(!cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = self.hostIDS[indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row =(int)indexPath.row;
    [self sendRequestToHostWithTag:3 andRow:row];
}

- (void)readerDidCancel:(QRCodeReaderViewController *)reader
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation{
    [SunCount sunrisetWithLongitude:newLocation.coordinate.longitude andLatitude:newLocation.coordinate.latitude
                        andResponse:^(SunString *str) {
                            NSLog(@"天文时钟: 黎明 %@,日出 %@,日落 %@,黄昏 %@",str.dayspring, str.sunrise,str.sunset,str.dusk);
                            self.antronomicalTimes = @[str.dayspring,str.sunrise,str.sunset,str.dusk];
                    }];
}

@end
