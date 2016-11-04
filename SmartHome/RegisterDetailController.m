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
#import "RegexKitLite.h"

@interface RegisterDetailController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *authorNum;
@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *passWord;
@property (weak, nonatomic) IBOutlet UITextField *pwdAgain;
@property (nonatomic,assign) int cType;

@property (weak, nonatomic) IBOutlet UIButton *auothCodeBtn;

@property (nonatomic,strong) dispatch_source_t _timer;

@property (weak, nonatomic) IBOutlet UIView *coverView;
@property (weak, nonatomic) IBOutlet UIView *regSuccessView;
@property (weak, nonatomic) IBOutlet UIButton *goHomeBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewWidthConstraint;

@end

@implementation RegisterDetailController 

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"注册";
    
    self.viewWidthConstraint.constant = [[UIScreen mainScreen] bounds].size.width * 0.8;
    
    self.phoneNumber.text = self.phoneStr;
    if([self.userType isEqualToString:@"客人"])
    {
        self.cType = 0;
    }else self.cType = 1;
    self.passWord.delegate = self;
    
    
}

#pragma  mark - 手机验证码
- (IBAction)sendAuothCode:(id)sender {
    if (![self.phoneNumber.text isEqualToString:@""]) {
        if(![self isMobileNumber:self.phoneNumber.text ]){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"系统提示"
                                                            message:@"电话号码不合法"
                                                           delegate:self
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil];
            //显示AlertView
            [alert show];
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
        NSDictionary *dict = @{@"TellNumber":self.phoneStr};
        HttpManager *http = [HttpManager defaultManager];
        http.delegate = self;
        http.tag =1;
        NSString *url = [NSString stringWithFormat:@"%@ObtainAuthCode.aspx",[IOManager httpAddr]];
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
    
    
        
    //发送注册请求
    DeviceInfo *info=[DeviceInfo defaultManager];
    
    if(self.MasterID == nil)
    {
        self.MasterID = @"";
    }
    
    NSDictionary *dict = @{@"HostID":self.MasterID,@"UserName":self.userName.text,@"Password":[self.passWord.text md5],@"UserTellNumber":self.phoneStr,@"UserType":[NSNumber numberWithInt:self.cType],@"AuthCode":self.authorNum.text,@"Pushtoken":info.pushToken};
    NSString *url = [NSString stringWithFormat:@"%@UserRegist.aspx",[IOManager httpAddr]];
   
    
    HttpManager *http=[HttpManager defaultManager];
    http.tag = 2;
    http.delegate=self;
    [http sendPost:url param:dict];
    
    
  
}
-(void)httpHandler:(id)responseObject tag:(int)tag
{
    if(tag == 1)
    {
        if([responseObject[@"Result"] intValue] == 0)
        {
            [MBProgressHUD showSuccess:@"验证码发送成功"];
        }else {
            [MBProgressHUD showError:responseObject[@"Msg"]];
        }
    }else if(tag == 2)
    {
        if([responseObject[@"Result"] intValue] == 0)
        {
            [IOManager writeUserdefault:responseObject[@"AuthorToken"] forKey:@"AuthorToken"];
            [IOManager writeUserdefault:self.MasterID forKey:@"HostID"];
            [IOManager writeUserdefault:responseObject[@"UserHostID"] forKey:@"UserHostID"];
            self.coverView.hidden = NO;
            self.regSuccessView.hidden = NO;
        }else{
            [MBProgressHUD showError:responseObject[@"Msg"]];
            
        }
        
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if(![self.passWord.text isMatchedByRegex:@"^\\w{6,8}$"])
    {
        [MBProgressHUD showError:@"密码应该是6-8位字符"];
    }
}
//加载到服务协议h5界面
- (IBAction)serviceAgreement:(id)sender {
    [WebManager show:@""];
}




#pragma mark -判断手机号是否合法
- (BOOL)isMobileNumber:(NSString *)mobileNum
{
    NSString *regex=@"^1[3|4|5|7|8]\\d{9}$";
    return [mobileNum isMatchedByRegex:regex];
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
