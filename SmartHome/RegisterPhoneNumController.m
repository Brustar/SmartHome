//
//  RegisterPhoneNumController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/7/4.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "RegisterPhoneNumController.h"
#import "RegisterDetailController.h"
#import "MBProgressHUD+NJ.h"
#import "NSString+RegMatch.h"
#import "WebManager.h"
#import "VerifyCodeView.h"

@interface RegisterPhoneNumController ()<UITextFieldDelegate,UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewTopLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIView *usderAndMasterView;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumTextField;
@property (weak, nonatomic) IBOutlet UITextField *imgeVerifyField;
@property (weak, nonatomic) IBOutlet VerifyCodeView *imgVerifyView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewWidthConstraint;

@property (weak, nonatomic) IBOutlet UIButton *DissmissBtn;

@end

@implementation RegisterPhoneNumController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"注册";
    self.UserTypeLb.text = self.suerTypeStr;
    self.MasterIDLb.text = self.masterStr;
    self.imgeVerifyField.delegate = self;
    //直接注册时隐藏身份和主机ID
    if(self.suerTypeStr == nil|| self.masterStr == nil)
    {
        self.usderAndMasterView.hidden = YES;
        self.viewTopLeadingConstraint.constant = 80;
        
    }
    self.viewWidthConstraint.constant = [[UIScreen mainScreen] bounds].size.width * 0.8;
    
    UIBarButtonItem *editItem = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(clickEditBtn:)];
    self.navigationItem.leftBarButtonItem = editItem;
    
}
-(void)clickEditBtn:(UIBarButtonItem *)bbi
{
    [self dismissViewControllerAnimated:YES completion:nil];

}
- (IBAction)DissmissBtn:(id)sender {
    
    
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

//验证手机号是否已注册
- (void)checkPhoneNumberIsExist {
    NSDictionary *dict = @{@"TellNumber":self.phoneNumTextField.text};
    NSString *url = [NSString stringWithFormat:@"%@AuthTellNumber.aspx",[IOManager httpAddr]];
    NSLog(@"request URL:%@", url);
    HttpManager *http = [HttpManager defaultManager];
    http.tag = 1;
    http.delegate = self;
    [http sendPost:url param:dict];
}

- (void)httpHandler:(id)responseObject tag:(int)tag
{
    if([responseObject[@"Result"] intValue] == 0) { //手机号未注册，进行“下一步”操作，进入下一页面
        [self performSegueWithIdentifier:@"registerDetaiSegue" sender:self];
    }else if([responseObject[@"Result"] intValue] == 1){ //手机号已注册，提示用户“手机号已注册”
        [MBProgressHUD showError:responseObject[@"Msg"]];
    }
}

- (IBAction)clickNextBtn:(id)sender {
    
    if([self.phoneNumTextField.text isEqualToString:@""])
    {
        [MBProgressHUD showError:@"请输入手机号"];
        return;
    }
    if(![self.phoneNumTextField.text isMobileNumber])
    {
        [MBProgressHUD showError:@"请输入合法的手机号码"];
        return;
    }
    
    //手机号格式验证通过后，开始请求http接口验证手机号是否已注册
    [self checkPhoneNumberIsExist];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    RegisterDetailController *vc = segue.destinationViewController;
    vc.MasterID = self.masterStr;
    vc.phoneStr = self.phoneNumTextField.text;
    vc.userType = self.suerTypeStr;
    
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   
}
//加载到服务协议h5界面
- (IBAction)serviceAgreement:(id)sender {
    [WebManager show:@""];
}
#pragma mark UITextField代理
- (void)textFieldDidEndEditing:(UITextField *)textField;
{
    
        if (![self.imgeVerifyField.text isEqualToString:self.imgVerifyView.authCodeStr])
        {
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"验证码错误，请重新输入" message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
            [alertVC addAction:action];
            [self presentViewController:alertVC animated:YES completion:nil];
        }
        
}






@end
