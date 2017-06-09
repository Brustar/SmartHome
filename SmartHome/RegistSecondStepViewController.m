//
//  RegistSecondStepViewController.m
//  SmartHome
//
//  Created by KobeBryant on 2017/3/24.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "RegistSecondStepViewController.h"

@interface RegistSecondStepViewController ()

@end

@implementation RegistSecondStepViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.checkCodeTextField setValue:[UIColor grayColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.nameTextField setValue:[UIColor grayColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.pwdTextField setValue:[UIColor grayColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.pwd2TextField setValue:[UIColor grayColor] forKeyPath:@"_placeholderLabel.textColor"];
    
    self.phoneNumLabel.text = self.phoneNum;
    
    self.tipLabel.hidden = YES;
    self.tipImageView.hidden = YES;
    
    if([self.userType isEqualToString:@"客人"])
    {
        self.cType = 2;
    }else  {
        self.cType = 1;
    }
    self.pwdTextField.delegate = self;
    self.pwd2TextField.delegate = self;
    [self setNaviBarTitle:@"注册"];
    
    [self adjustIpadUI];
}

- (void)adjustIpadUI {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        
        self.line1Leading.constant = 260;
        self.line1Trailing.constant = 260;
        self.line2Leading.constant = self.line1Leading.constant;
        self.line2Trailing.constant = self.line1Trailing.constant;
        self.line3Leading.constant = self.line1Leading.constant;
        self.line3Trailing.constant = self.line1Trailing.constant;
        self.line4Leading.constant = self.line1Leading.constant;
        self.line4Trailing.constant = self.line1Trailing.constant;
        self.line5Leading.constant = self.line1Leading.constant;
        self.line5Trailing.constant = self.line1Trailing.constant;
        self.line6Leading.constant = self.line1Leading.constant;
        self.line6Trailing.constant = self.line1Trailing.constant;
        self.phoneNumLabelLeading.constant = self.line1Leading.constant + 30;
        self.phoneNumLeading.constant = self.phoneNumLabelLeading.constant + 80;
        self.checkCodeFieldLeading.constant = self.phoneNumLabelLeading.constant;
        self.checkCodeFieldWidth.constant = 200;
        self.checkCodeBtnTrailing.constant = self.line1Trailing.constant;
        self.nameIconLeading.constant = self.phoneNumLabelLeading.constant;
        self.pwdIconLeading.constant = self.nameIconLeading.constant;
        self.pwd2IconLeading.constant = self.pwdIconLeading.constant;
        self.nameTextFieldLeading.constant = self.nameIconLeading.constant + 40;
        self.nameTextFieldWidth.constant = 300;
        self.pwdTextFieldLeading.constant = self.nameTextFieldLeading.constant;
        self.pwdTextFieldWidth.constant = self.nameTextFieldWidth.constant;
        self.pwd2TextFieldLeading.constant = self.pwdTextFieldLeading.constant;
        self.pwd2TextFieldWidth.constant = self.pwdTextFieldWidth.constant;
        self.tipIconLeading.constant = self.pwd2IconLeading.constant;
        self.tipLabelLeading.constant = self.tipIconLeading.constant + 30;
        self.nextBtnTrailing.constant = self.line1Trailing.constant + 90;
        self.nextBtnLeading.constant = self.line1Leading.constant + 90;
    }
}

#pragma  mark - 手机验证码

-(void)httpHandler:(id)responseObject tag:(int)tag
{
    if(tag == 1)
    {
        if([responseObject[@"result"] intValue] == 0)
        {
            [MBProgressHUD showSuccess:@"验证码发送成功"];
        }else {
            [MBProgressHUD showError:@"验证码发送失败"];
            
        }
    }else if(tag == 2){
        if([responseObject[@"result"] intValue] == 0)
        {
            [IOManager writeUserdefault:responseObject[@"token"] forKey:@"AuthorToken"];
            //进入注册成功页面
            [MBProgressHUD showSuccess:@"恭喜注册成功"];
            [NC postNotificationName:@"registSuccess" object:self.phoneNum];
            [self.navigationController popToRootViewControllerAnimated:YES];
            
            //self.coverView.hidden = NO;
            //self.regSuccessView.hidden = NO;
            
            //            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            //            LoginController *tvc = [storyBoard instantiateViewControllerWithIdentifier:@"LoginController"];
            //            [self.navigationController pushViewController:tvc animated:YES];
            //            [MBProgressHUD showError:@"恭喜注册成功"];
            
        }else{
            [MBProgressHUD showError:responseObject[@"msg"]];
        }
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == self.pwdTextField) {
        if(![self.pwdTextField.text isPassword])
        {
            self.tipLabel.text = @"密码应该是6-8位字符";
            self.tipLabel.hidden = NO;
            self.tipImageView.hidden = NO;
            
        }else {
            self.tipLabel.hidden = YES;
            self.tipImageView.hidden = YES;
        }
    }else if (textField == self.pwd2TextField) {
        if(![self.pwd2TextField.text isPassword])
        {
            self.tipLabel.text = @"密码应该是6-8位字符";
            self.tipLabel.hidden = NO;
            self.tipImageView.hidden = NO;
        }else if(![self.pwdTextField.text isEqualToString:self.pwd2TextField.text])
        {
            self.tipLabel.text = @"两个密码不一致";
            self.tipLabel.hidden = NO;
            self.tipImageView.hidden = NO;
            
        }else {
            self.tipLabel.hidden = YES;
            self.tipImageView.hidden = YES;
        }
    }
}
//加载到服务协议h5界面
- (IBAction)serviceAgreement:(id)sender {
    //    [WebManager show:@"http://115.28.151.85:8082/article.aspx?articleid=1"];
    
    [self performSegueWithIdentifier:@"webViewManger" sender:self];
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

- (IBAction)checkCodeBtnClicked:(id)sender {
    
    if (![self.phoneNum isEqualToString:@""]) {
        if(![self.phoneNum isMobileNumber]){
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
                        [self.checkCodeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
                        self.checkCodeBtn.userInteractionEnabled = YES;
                    });
                }else{
                    
                    int seconds = timeout % 60;
                    NSString *strTime = [NSString stringWithFormat:@" %.2d", seconds];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [UIView beginAnimations:nil context:nil];
                        [UIView setAnimationDuration:1];
                        [self.checkCodeBtn setTitle:[NSString stringWithFormat:@"(%@)秒 ",strTime] forState:UIControlStateNormal];
                        [UIView commitAnimations];
                        self.checkCodeBtn.userInteractionEnabled = NO;
                    });
                    timeout--;
                }
            });
            dispatch_resume(self._timer);
        }
        //点击验证码发送请求
        NSDictionary *dict = @{
                               @"mobile":self.phoneNum,
                               @"optype":@(0)
                               };
        
        HttpManager *http = [HttpManager defaultManager];
        http.delegate = self;
        http.tag =1;
        NSString *url = [NSString stringWithFormat:@"%@login/send_code.aspx",[IOManager httpAddr]];
        [http sendPost:url param:dict];
    }
}

- (IBAction)nextStepBtnClicked:(id)sender {
    
    if([self.checkCodeTextField.text isEqualToString:@""]|| [self.nameTextField.text isEqualToString:@""]||[self.pwdTextField.text isEqualToString:@""])
    {
        self.tipLabel.text = @"信息不能为空";
        self.tipLabel.hidden = NO;
        self.tipImageView.hidden = NO;
        return;
    }
    
    if(![self.pwdTextField.text isEqualToString:self.pwd2TextField.text])
    {
        self.tipLabel.text = @"两个密码不一致";
        self.tipLabel.hidden = NO;
        self.tipImageView.hidden = NO;
        return;
    }
    
    if(![self.pwdTextField.text isPassword])
    {
        self.tipLabel.text = @"密码应该是6-8位字符";
        self.tipLabel.hidden = NO;
        self.tipImageView.hidden = NO;
        return;
    }
    
    self.tipLabel.hidden = YES;
    self.tipImageView.hidden = YES;
    
    //发送注册请求
    DeviceInfo *info=[DeviceInfo defaultManager];
    
    //手机终端类型：1，手机 2，iPad
    NSInteger clientType = 1;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        clientType = 2;
    }
    
    NSDictionary *dict = @{
                           @"hostid":@([self.masterID integerValue]),
                           @"username":self.nameTextField.text,
                           @"password":[self.pwdTextField.text md5],
                           @"mobile":self.phoneNum,
                           @"usertype":@(self.cType),
                           @"authcode":self.checkCodeTextField.text,
                           @"pushtoken":info.pushToken,
                           @"devicetype":@(clientType)
                           };
    NSString *url = [NSString stringWithFormat:@"%@login/regist.aspx",[IOManager httpAddr]];
    HttpManager *http = [HttpManager defaultManager];
    http.tag = 2;
    http.delegate = self;
    [http sendPost:url param:dict];
}
@end
