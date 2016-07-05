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
        [MBProgressHUD showError:@"请输入手机号"];
        return;
    }
    if(![self isMobileNumber:self.phoneNumTextField.text])
    {
        [MBProgressHUD showError:@"请输入合法的手机号码"];
        return;
    }
    RegisterDetailController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"registerDetail"];
    
    vc.MasterID = self.masterStr;
    vc.phoneStr = self.phoneNumTextField.text;
    vc.userType = self.suerTypeStr;

    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark -判断手机号是否合法
- (BOOL)isMobileNumber:(NSString *)mobileNum
{
    NSString *regex=@"^1[3|4|5|7|8]\\d{9}$";
    return [mobileNum isMatchedByRegex:regex];
}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   
}




@end
