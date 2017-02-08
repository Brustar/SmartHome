//
//  ForgotViewController.m
//  SmartHome
//
//  Created by zhaona on 2017/2/7.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "ForgotViewController.h"

@interface ForgotViewController ()

@end

@implementation ForgotViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"逸云科技";
    [super viewDidLoad];
    
//    NSString *urlString = @"/user/update_pwd.aspx";
    NSString * urlString = [[IOManager httpAddr] stringByAppendingString:@"/user/update_pwd.aspx"];
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
