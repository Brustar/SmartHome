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

@interface RegisterDetailController ()
@property (weak, nonatomic) IBOutlet UITextField *authorNum;
@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *passWord;
@property (weak, nonatomic) IBOutlet UITextField *pwdAgain;
@property (nonatomic,assign) int cType;
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

- (IBAction)clickRegisterBtn:(id)sender {
    if(![self.passWord.text isEqualToString:self.pwdAgain.text])
    {
        [MBProgressHUD showError:@"两次密码不匹配"];
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
