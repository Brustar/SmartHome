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
#import "DialogManager.h"

@interface RegisterDetailController ()
@property (weak, nonatomic) IBOutlet UITextField *authorNum;
@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *passWord;
@property (weak, nonatomic) IBOutlet UITextField *pwdAgain;
@property (nonatomic,assign) int cType;

@property (weak, nonatomic) IBOutlet UIButton *auothCodeBtn;

@property (nonatomic,strong) dispatch_source_t _timer;

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
}

#pragma  mark - 手机验证码
- (IBAction)sendAuothCode:(id)sender {
    __block int timeout=30; //倒计时时间
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
        [DialogManager showMessage:@"信息不能为空"];
        return;
    }
    
    if(![self.passWord.text isEqualToString:self.pwdAgain.text])
    {
        [DialogManager showMessage:@"两次密码不匹配"];
        return;
    }
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    NSString *deviceToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"smartToken"];
    NSDictionary *dict = @{@"QRCode":self.MasterID,@"CName":self.userName.text,@"CPassword":[self.passWord.text md5],@"CTellNumber":self.phoneStr,@"CType":[NSNumber numberWithInt:self.cType],@"AuthorCode":self.authorNum.text,@"pushtoken":deviceToken};
    NSString *url = [NSString stringWithFormat:@"%@reg",[IOManager httpAddr]];
    [mgr POST:url parameters:dict progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"success:%@",responseObject);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"failure:%@",error);
    }];

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
