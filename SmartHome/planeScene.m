//
//  planeScene.m
//  SmartHome
//
//  Created by Brustar on 16/5/26.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "planeScene.h"

@implementation planeScene

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    //self.planeimg=[[TouchImage alloc] initWithFrame:CGRectMake(100, 40, 625, 500)];
    self.planeimg = [[TouchImage alloc]initWithFrame:self.view.frame];
    self.planeimg.contentMode = UIViewContentModeScaleAspectFit;
    self.planeimg.image =[UIImage imageNamed:@"ecloud_2"];
    self.planeimg.userInteractionEnabled=YES;
    self.planeimg.viewFrom=PLANE_IMAGE;
    self.planeimg.delegate = self;
    [self.view addSubview:self.planeimg];
    
    [self sendRequestForGettingSceneConfig:@"cloud/GetSceneConfig.aspx" withTag:1];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
}

//获取平面配置
- (void)sendRequestForGettingSceneConfig:(NSString *)str withTag:(int)tag;
{
    NSString *url = [NSString stringWithFormat:@"%@%@",[IOManager httpAddr],str];
    
    NSDictionary *dic = @{
                          @"AuthorToken" : [[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"],
                          
                          @"Optype" : @(1)
                          };
    
    NSLog(@"request param: %@", dic);
    
    HttpManager *http = [HttpManager defaultManager];
    http.delegate = self;
    http.tag = tag;
    [http sendPost:url param:dic];
    NSLog(@"Request URL:%@", url);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        NSString *path = [[IOManager planeScenePath] stringByAppendingPathComponent:response.suggestedFilename];
        
        return [NSURL fileURLWithPath:path];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        NSLog(@"planeScenePlistFile下载完了 %@",filePath);
        
        NSString *plistFilePath = [[filePath absoluteString] substringFromIndex:7];
        //保存到UD
        [UD setObject:plistFilePath forKey:@"Plane_Scene_PlistFile"];
        [UD synchronize];
        NSDictionary *plistDic = [NSDictionary dictionaryWithContentsOfFile:plistFilePath];
        NSLog(@"planeScenePlistFilePath: %@", plistFilePath);
        NSLog(@"planeScenePlistDict: %@", plistDic);
        //[self showRoomNameAndBackgroundImgWithFilePath:plistFilePath];
    }];
    
    [task resume];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
     id theSegue = segue.destinationViewController;
     [theSegue setValue:[NSString stringWithFormat:@"%d", self.deviceID] forKey:@"deviceid"];
}


@end
