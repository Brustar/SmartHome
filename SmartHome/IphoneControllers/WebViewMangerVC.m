//
//  WebViewMangerVC.m
//  SmartHome
//
//  Created by zhaona on 2017/2/4.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "WebViewMangerVC.h"

@interface WebViewMangerVC ()

@end

@implementation WebViewMangerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    self.navigationController.navigationBarHidden = NO;
    self.title = @"逸云科技";
    [super viewDidLoad];
    
    NSString *urlString = @"http://115.28.151.85:8082/article.aspx?articleid=1";
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
}
- (IBAction)goBack:(id)sender {
    
    
    [self dismissViewControllerAnimated:YES completion:nil];
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
