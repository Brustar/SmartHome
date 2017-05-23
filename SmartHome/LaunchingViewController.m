//
//  LaunchingViewController.m
//  SmartHome
//
//  Created by KobeBryant on 2017/5/10.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "LaunchingViewController.h"

@interface LaunchingViewController ()

@end

@implementation LaunchingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupAnimationViewForLaunching];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupAnimationViewForLaunching {
    // 设定位置和大小
    CGRect frame = CGRectMake(0,0,UI_SCREEN_WIDTH, UI_SCREEN_HEIGHT);
    // 读取gif图片数据
    NSString *launchAnimation = @"launchingAnimation";
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        launchAnimation = @"iPadLaunchAnimation";
    }
    NSData *gif = [NSData dataWithContentsOfFile: [[NSBundle mainBundle] pathForResource:launchAnimation ofType:@"gif"]];
    // view生成
    UIWebView *webView = [[UIWebView alloc] initWithFrame:frame];
    webView.userInteractionEnabled = NO;//用户不可交互
    [webView loadData:gif MIMEType:@"image/gif" textEncodingName:nil baseURL:nil];
    webView.scalesPageToFit = YES;
    webView.tag = 20171;
    [self.view addSubview:webView];
}

@end
