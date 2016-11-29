//
//  RealScene.m
//  SmartHome
//
//  Created by Brustar on 16/5/25.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "RealScene.h"

#import "Room.h"
#import "PackManager.h"
#import "SocketManager.h"
#import "SQLManager.h"

@interface RealScene ()<UITableViewDelegate, UITableViewDataSource,TcpRecvDelegate>
@property (strong, nonatomic) IBOutlet UIView *dataView;
@property (weak, nonatomic) IBOutlet UITableView *roomTable;
@property (strong, nonatomic) IBOutlet UILabel *tempValue;
@property (strong, nonatomic) IBOutlet UILabel *wetValue;
@property (strong, nonatomic) IBOutlet UILabel *pmValue;
@property (strong, nonatomic) IBOutlet UILabel *noiseValue;

//温度
@property (weak, nonatomic) IBOutlet UILabel *tempLabel;
//湿度
@property (weak, nonatomic) IBOutlet UILabel *wetLabel;
//pm2.5
@property (weak, nonatomic) IBOutlet UILabel *pmLabel;
//噪音
@property (weak, nonatomic) IBOutlet UILabel *noiseLabel;


@property (nonatomic,strong) NSArray *rooms;
@end

@implementation RealScene

-(NSArray *)rooms
{
    if(!_rooms)
    {
        _rooms = [SQLManager getAllRoomsInfo];
    }
    return _rooms;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.roomTable.hidden = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    // Do any additional setup after loading the view.
    self.realimg = [[TouchImage alloc] initWithFrame:CGRectMake(0, 40, UI_SCREEN_WIDTH, UI_SCREEN_HEIGHT-40)];
    self.realimg.delegate = self;
    self.realimg.powerOn = YES;
    self.realimg.userInteractionEnabled = YES;
    self.realimg.viewFrom = REAL_IMAGE;
    [self.view addSubview:self.realimg];
    
    //self.dataView.frame = CGRectMake((UI_SCREEN_WIDTH-400)/2, UI_SCREEN_HEIGHT-100-40, 400, 100);
    self.dataView.layer.cornerRadius = 8.0;
    self.dataView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
    self.dataView.layer.masksToBounds = YES;
    [self.view bringSubviewToFront:self.dataView];
    
    SocketManager *sock = [SocketManager defaultManager];
    sock.delegate = self;
    
    NSData *data = [[SceneManager defaultManager] getRealSceneData];
    [sock.socket writeData:data withTimeout:1 tag:1];
    NSLog(@"TCP请求Data:%@", data);
    
    [self sendRequestForGettingSceneConfig:@"cloud/GetSceneConfig.aspx" withTag:1];
}

//获取实景配置
- (void)sendRequestForGettingSceneConfig:(NSString *)str withTag:(int)tag;
{
    NSString *url = [NSString stringWithFormat:@"%@%@",[IOManager httpAddr],str];
    
    NSDictionary *dic = @{
                           @"AuthorToken" : [[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"],
                           
                           @"Optype" : @(2)
                         };
    HttpManager *http = [HttpManager defaultManager];
    http.delegate = self;
    http.tag = tag;
    [http sendPost:url param:dic];
    NSLog(@"Request URL:%@", url);
}

#pragma mark - Http callback
- (void)httpHandler:(id)responseObject tag:(int)tag
{
    if ([responseObject isKindOfClass:[NSDictionary class]]) {
        NSLog(@"responseObject:%@", responseObject);
        if ([responseObject[@"Result"] integerValue] == 0) {
            NSDictionary *infoDict = responseObject[@"info"];
            if ([infoDict isKindOfClass:[NSDictionary class]]) {
                NSString *plistURL = infoDict[@"plist_path"];
                if (plistURL.length >0) {
                    //下载plist
                    [self downloadPlist:plistURL];
                }
            }
        }
    }
}

//下载场景plist文件到本地
-(void)downloadPlist:(NSString *)plistURL
{
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:plistURL]];
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        
        //下载进度
        NSLog(@"%@",downloadProgress);
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        //下载到哪个文件夹
        NSString *path = [[IOManager realScenePath] stringByAppendingPathComponent:response.suggestedFilename];
    
        return [NSURL fileURLWithPath:path];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        NSLog(@"下载完成了 %@",filePath);
        
        NSString *plistFilePath = [[filePath absoluteString] substringFromIndex:7];
        //保存到UD
        [UD setObject:plistFilePath forKey:@"Real_Scene_PlistFile"];
        [UD synchronize];
        NSDictionary *plistDic = [NSDictionary dictionaryWithContentsOfFile:plistFilePath];
        NSLog(@"plistFilePath: %@", plistFilePath);
        NSLog(@"realScenePlistDict: %@", plistDic);
        [self showRoomNameAndBackgroundImgWithFilePath:plistFilePath];
    }];
    
    [task resume];
}

- (void)showRoomNameAndBackgroundImgWithFilePath:(NSString *)filePath {
    NSDictionary *plistDic = [NSDictionary dictionaryWithContentsOfFile:filePath];
    NSArray *rooms = plistDic[@"rects"];
    if ([rooms isKindOfClass:[NSArray class]] && rooms.count >0) {
        NSDictionary *room = rooms[0];
        if ([room isKindOfClass:[NSDictionary class]]) {
            NSNumber *roomID = room[@"roomID"];
            if (roomID) {
                NSString *roomName = [SQLManager getRoomNameByRoomID:roomID.intValue];
                NSLog(@"实景房间名：%@", roomName);
            }
            
            NSString *bgImgURL = room[@"image"];
            
            if (self.realimg.powerOn) {
                if (bgImgURL.length >0) {
                    NSLog(@"roomBgImgURL: %@", bgImgURL);
                    [self.realimg sd_setImageWithURL:[NSURL URLWithString:bgImgURL] placeholderImage:[UIImage imageNamed:@"xxx.png"] options:SDWebImageRetryFailed];
                }
            }
            
        }
    }
}


#pragma mark - TCP recv delegate
- (void)recv:(NSData *)data withTag:(long)tag
{
    
    NSLog(@"TCP收到的data:%@", data);
    
    NSString *result = [NSString stringWithFormat:@"0x%@",[UD objectForKey:@"HostID"]];
    
    Proto proto = protocolFromData(data);
    
    if (CFSwapInt16BigToHost(proto.masterID) != strtoul([result UTF8String],0,16)) {
        return;
    }
    
    if (tag==0) {
        if (proto.action.state==0x6A) {
            self.tempValue.text = [NSString stringWithFormat:@"%d°C",proto.action.RValue];
        }
        if (proto.action.state==0x8A) {
            NSString *valueString = [NSString stringWithFormat:@"%d %%",proto.action.RValue];
            self.wetValue.text = valueString;
        }
        if (proto.action.state==0x7F) {
            NSString *valueString = [NSString stringWithFormat:@"%d ug/m³",proto.action.RValue];
            self.pmValue.text = valueString;
        }
        if (proto.action.state==0x7E) {
            NSString *valueString = [NSString stringWithFormat:@"%d db",proto.action.RValue];
            self.noiseValue.text = valueString;
        }
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.rooms.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(!cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    Room *room = self.rooms[indexPath.row];
    cell.textLabel.text = room.rName;
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - TouchImageDelegate
- (void)openDeviceWithDeviceID:(NSString *)deviceID {
    SocketManager *sock = [SocketManager defaultManager];
    NSData *data = [[DeviceInfo defaultManager] open:deviceID];
    [sock.socket writeData:data withTimeout:1 tag:1];
}

- (void)closeDeviceWithDeviceID:(NSString *)deviceID {
    SocketManager *sock = [SocketManager defaultManager];
    NSData *data = [[DeviceInfo defaultManager] close:deviceID];
    [sock.socket writeData:data withTimeout:1 tag:1];
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

@end
