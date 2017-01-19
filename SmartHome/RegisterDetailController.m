//
//  RegisterDetailController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/7/4.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "RegisterDetailController.h"
#import <AFNetworking.h>
#import "CryptoManager.h"
#import "MBProgressHUD+NJ.h"
#import "IOManager.h"
#import "WebManager.h"
#import "NSString+RegMatch.h"
#import "LoginController.h"

@interface RegisterDetailController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *authorNum;
@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *passWord;//密码
@property (weak, nonatomic) IBOutlet UITextField *pwdAgain;//确认密码
@property (weak, nonatomic) IBOutlet UIButton *auothCodeBtn;//获取验证码

@property (nonatomic,strong) dispatch_source_t _timer;

@property (weak, nonatomic) IBOutlet UIView *coverView;
@property (weak, nonatomic) IBOutlet UIView *regSuccessView;
@property (weak, nonatomic) IBOutlet UIButton *goHomeBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIButton *DisMissBtn;

@end

@implementation RegisterDetailController 

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"注册";
    self.checkPwdImageView.hidden = YES;
    self.passWoardImageView.hidden = YES;
    
    self.viewWidthConstraint.constant = [[UIScreen mainScreen] bounds].size.width * 0.8;
    
    self.phoneNumber.text = self.phoneStr;
    if([self.userType isEqualToString:@"客人"])
    {
        self.cType = 2;
    }else self.cType = 1;
    self.passWord.delegate = self;
    self.pwdAgain.delegate = self;
     self.auothCodeBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
}

- (IBAction)DisMissBtn:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma  mark - 手机验证码
- (IBAction)sendAuothCode:(id)sender {
    if (![self.phoneNumber.text isEqualToString:@""]) {
        if(![self.phoneNumber.text isMobileNumber]){
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"系统提示" message:@"电话号码不正确" preferredStyle:UIAlertControllerStyleAlert];
            [self presentViewController: alertVC animated:YES completion:nil];
        }else{
            __block int timeout=59; //倒计时时间
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            self._timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
            dispatch_source_set_timer(self._timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
            dispatch_source_set_event_handler(self._timer, ^{
                if(timeout<=0){ //倒计时结束，关闭
                    dispatch_source_cancel(self._timer);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.auothCodeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
                        self.auothCodeBtn.userInteractionEnabled = YES;
                    });
                }else{
                 
                    int seconds = timeout % 60;
                    NSString *strTime = [NSString stringWithFormat:@" %.2d", seconds];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [UIView beginAnimations:nil context:nil];
                        [UIView setAnimationDuration:1];
                        [self.auothCodeBtn setTitle:[NSString stringWithFormat:@"重新获取(%@) ",strTime] forState:UIControlStateNormal];
                        [UIView commitAnimations];
                        self.auothCodeBtn.userInteractionEnabled = NO;
                    });
                    timeout--;
                }
            });
        dispatch_resume(self._timer);}
        //点击验证码发送请求
        NSDictionary *dict = @{@"mobile":self.phoneStr};
        HttpManager *http = [HttpManager defaultManager];
        http.delegate = self;
        http.tag =1;
        NSString *url = [NSString stringWithFormat:@"%@login/send_code.aspx",[IOManager httpAddr]];
        [http sendPost:url param:dict];
    }
    
}
- (IBAction)clickRegisterBtn:(id)sender {
    if([self.authorNum.text isEqualToString:@""]|| [self.userName.text isEqualToString:@""]||[self.passWord.text isEqualToString:@""])
    {
        [MBProgressHUD showError:@"信息不能为空"];
        return;
    }
    
    if(![self.passWord.text isEqualToString:self.pwdAgain.text])
    {
        [MBProgressHUD showError:@"两次密码不匹配"];
        return;
    }
    
    if(![self.passWord.text isPassword])
    {
        [MBProgressHUD showError:@"密码应该是6-8位字符"];
        return;
    }
   
    //发送注册请求
    DeviceInfo *info=[DeviceInfo defaultManager];
    
    //手机终端类型：1，手机 2，iPad
    NSInteger clientType = 1;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        clientType = 2;
    }
    
    NSDictionary *dict = @{
                           @"hostid":@(self.MasterID),
                           @"username":self.userName.text,
                           @"password":[self.passWord.text md5],
                           @"mobile":self.phoneStr,
                           @"usertype":[NSNumber numberWithInt:self.cType],
                           @"authcode":self.authorNum.text,
                           @"pushtoken":info.pushToken,
                           @"devicetype":@(clientType)
                           };
    NSString *url = [NSString stringWithFormat:@"%@login/regist.aspx",[IOManager httpAddr]];
    HttpManager *http=[HttpManager defaultManager];
    http.tag = 2;
    http.delegate=self;
    [http sendPost:url param:dict];
  
}
-(void)httpHandler:(id)responseObject tag:(int)tag
{
    if(tag == 1)
    {
        if([responseObject[@"result"] intValue] == 0)
        {
            [MBProgressHUD showSuccess:@"验证码发送成功"];
        }else {
            [MBProgressHUD showError:@"验证码发送失败"];
//            [MBProgressHUD showError:responseObject[@"msg"]];
        }
    }else if(tag == 2){
        if([responseObject[@"result"] intValue] == 0)
        {
            [IOManager writeUserdefault:responseObject[@"token"] forKey:@"AuthorToken"];
            self.coverView.hidden = YES;
            self.regSuccessView.hidden = YES;
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            LoginController *tvc = [storyBoard instantiateViewControllerWithIdentifier:@"LoginController"];
            [self.navigationController pushViewController:tvc animated:YES];
            [MBProgressHUD showError:@"恭喜注册成功"];
            
        }else{
            [MBProgressHUD showError:responseObject[@"msg"]];
        }
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == self.passWord) {
        if(![self.passWord.text isPassword])
        {
            self.checkPwdImageView.hidden = YES;
            [MBProgressHUD showError:@"密码应该是6-8位字符"];
        }else {
            self.checkPwdImageView.hidden = NO;
        }
    }else if (textField == self.pwdAgain) {
        if(![self.passWord.text isPassword])
        {
            self.passWoardImageView.hidden = YES;
            [MBProgressHUD showError:@"密码应该是6-8位字符"];
        }else if(![self.passWord.text isEqualToString:self.pwdAgain.text])
        {
            self.passWoardImageView.hidden = YES;
            [MBProgressHUD showError:@"两次密码不匹配"];
            
        }else {
            self.passWoardImageView.hidden = NO;
        }
    }
}
//加载到服务协议h5界面
- (IBAction)serviceAgreement:(id)sender {
    [WebManager show:@"http://115.28.151.85:8082/article.aspx?articleid=1"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
