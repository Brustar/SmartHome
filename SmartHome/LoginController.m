//
//  LoginController.m
//  SmartHome
//
//  Created by Brustar on 16/6/29.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "LoginController.h"
#import <AFNetworking.h>
#import "IOManager.h"
#import "CryptoManager.h"
#import "MBProgressHUD+NJ.h"
#import "WebManager.h"

@interface LoginController ()
@property (weak, nonatomic) IBOutlet UITextField *user;
@property (weak, nonatomic) IBOutlet UITextField *pwd;

@end

@implementation LoginController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    NSString *url = [NSString stringWithFormat:@"%@login",[IOManager httpAddr]];
    // GET
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    // 将数据作为参数传入
    NSDictionary *dict = @{@"username":self.user.text,@"pwd":[self.pwd.text md5]};
    [MBProgressHUD showMessage:@"请稍候..."];
    [mgr POST:url parameters:dict progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        [MBProgressHUD hideHUD];
        NSLog(@"success:%@",responseObject);
        if ([responseObject[@"Result"] intValue]==1) {
            [[NSUserDefaults standardUserDefaults] setObject:responseObject[@"AuthorToken"] forKey:@"token"];
        }
        [MBProgressHUD showSuccess:responseObject[@"Msg"]];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [MBProgressHUD hideHUD];
        NSLog(@"failure:%@",error);
        [MBProgressHUD showError:@"网络错误"];
    }];
}

- (IBAction)forgotPWD:(id)sender
{
    [WebManager show:@"http://3g.cn"];
}


@end
