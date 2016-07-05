//
//  RegisterPhoneNumController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/7/4.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "RegisterPhoneNumController.h"
#import "RegisterDetailController.h"
#import "DialogManager.h"
#import "RegexKitLite.h"

@interface RegisterPhoneNumController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewTopLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIView *usderAndMasterView;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumTextField;

@end

@implementation RegisterPhoneNumController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"注册";
    self.UserTypeLb.text = self.suerTypeStr;
    self.MasterIDLb.text = self.masterStr;
    //直接注册时隐藏身份和主机ID
    if(self.suerTypeStr == nil|| self.masterStr == nil)
    {
        self.usderAndMasterView.hidden = YES;
        self.viewTopLeadingConstraint.constant = 80;
        
    }

    
}

- (IBAction)clickNextBtn:(id)sender {
    
    if([self.phoneNumTextField.text isEqualToString:@""])
    {
        [DialogManager showMessage:@"请输入手机号"];
        return;
    }
    if(![self isMobileNumber:self.phoneNumTextField.text])
    {
        [DialogManager showMessage:@"请输入合法的手机号码"];
        return;
    }
    RegisterDetailController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"registerDetail"];
    
    [vc setValue:self.phoneNumTextField.text forKey:@"phoneStr"];
    [vc  setValue:self.masterStr forKey:@"MasterID"];
    [vc  setValue:self.suerTypeStr forKey:@"userType"];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark -判断手机号是否合法
- (BOOL)isMobileNumber:(NSString *)mobileNum
{
    NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
    /**
     10         * 中国移动：China Mobile
     11         * 134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     12         */
    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$";
    /**
     15         * 中国联通：China Unicom
     16         * 130,131,132,152,155,156,185,186
     17         */
    NSString * CU = @"^1(3[0-2]|5[256]|8[56])\\d{8}$";
    /**
     20         * 中国电信：China Telecom
     21         * 133,1349,153,180,189
     22         */
    NSString * CT = @"^1((33|53|8[09]|77)[0-9]|349)\\d{7}$";
    /**
     25         * 大陆地区固话及小灵通
     26         * 区号：010,020,021,022,023,024,025,027,028,029
     27         * 号码：七位或八位
     28         */
    // NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    
    if (([regextestmobile evaluateWithObject:mobileNum] == YES)
        || ([regextestcm evaluateWithObject:mobileNum] == YES)
        || ([regextestct evaluateWithObject:mobileNum] == YES)
        || ([regextestcu evaluateWithObject:mobileNum] == YES))
    {
        return YES;
    }
    else
    {
        return NO;
    }
}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
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
