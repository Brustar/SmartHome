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
#import "IOManager.h"
#import "MBProgressHUD+NJ.h"

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

@end

@implementation RegisterDetailController 

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"注册";
    self.phoneNumber.text = self.phoneStr;
    if([self.userType isEqualToString:@"客人"])
    {
        self.cType = 0;
    }else self.cType = 1;
    self.passWord.delegate = self;
}

#pragma  mark - 手机验证码
- (IBAction)sendAuothCode:(id)sender {
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
    dispatch_resume(self._timer);

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
   
    NSString *deviceToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"smartToken"];
    if(self.MasterID == nil)
    {
        self.MasterID = @"";
    }
   
    NSDictionary *dict = @{@"QRCode":self.MasterID,@"UserName":self.userName.text,@"Password":[self.passWord.text md5],@"UserTellNumber":self.phoneStr,@"UserType":[NSNumber numberWithInt:self.cType],@"pushtoken":deviceToken};
    NSString *url = [NSString stringWithFormat:@"%@UserRegist.aspx",[IOManager httpAddr]];
   
    
    HttpManager *http=[HttpManager defaultManager];
    http.delegate=self;
    [http sendPost:url param:dict];
    
    
  
}
-(void)httpHandler:(id)responseObject
{
    if([responseObject[@"Result"] intValue] == 0)
    {
        [[NSUserDefaults standardUserDefaults] setObject:responseObject[@"AuthorToken"] forKey:@"token"];
        [[NSUserDefaults standardUserDefaults] setObject:self.userName.text forKey:@"userName"];
        [[NSUserDefaults standardUserDefaults]  setObject:self.passWord.text forKey:@"password"];
        [[NSUserDefaults standardUserDefaults] setObject:self.phoneNumber.text forKey:@"UserTellNumber"];
        [[NSUserDefaults standardUserDefaults] setObject:responseObject[@"UserID"] forKey:@"UserID"];
       
        [self performSegueWithIdentifier:@"finishedSegue" sender:self];
        
       
    }else{
        [MBProgressHUD showError:responseObject[@"Msg"]];
        
    }
}




- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if(![self.passWord.text isMatchedByRegex:@"^(?![^a-z]+$)(?![^A-Z]+$)(?!\\D+$).{8,15}$"])
    {
        [MBProgressHUD showError:@"密码必须是由大小写、数字组成且不少于8位数"];
    }
}
//加载到服务协议h5界面
- (IBAction)serviceAgreement:(id)sender {
    [WebManager show:@""];
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
