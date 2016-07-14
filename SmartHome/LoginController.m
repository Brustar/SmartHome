//
//  LoginController.m
//  SmartHome
//
//  Created by Brustar on 16/6/29.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "LoginController.h"
#import "IOManager.h"
#import "CryptoManager.h"
#import "MBProgressHUD+NJ.h"
#import "WebManager.h"
#import "RegexKitLite.h"
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
    
    NSString *url = [NSString stringWithFormat:@"%@UserLogin.aspx",[IOManager httpAddr]];
    
    int type = 1;
    if([self isMobileNumber:self.user.text])
    {
        type = 2;
    }
    NSDictionary *dict = @{@"Account":self.user.text,@"Type":[NSNumber numberWithInt:type],@"Password":[self.pwd.text md5]};
    [[NSUserDefaults standardUserDefaults] setObject:self.user.text forKey:@"Account"];
    HttpManager *http=[HttpManager defaultManager];
    http.delegate=self;
    [http sendPost:url param:dict];
}

-(void) httpHandler:(id) responseObject
{
    if ([responseObject[@"Result"] intValue]==0) {
        [[NSUserDefaults standardUserDefaults] setObject:responseObject[@"AuthorToken"] forKey:@"token"];
        [[NSUserDefaults standardUserDefaults] setObject:responseObject[@"UserID"] forKey:@"UserID"];
    }
    [MBProgressHUD showSuccess:responseObject[@"Msg"]];
}


- (BOOL)isMobileNumber:(NSString *)mobileNum
{
    NSString *regex=@"^1[3|4|5|7|8]\\d{9}$";
    return [mobileNum isMatchedByRegex:regex];
}

- (IBAction)forgotPWD:(id)sender
{
    [WebManager show:@"http://3g.cn"];
}


@end
