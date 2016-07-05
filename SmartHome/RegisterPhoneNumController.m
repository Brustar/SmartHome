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
    RegisterDetailController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"registerDetail"];
    
    [vc setValue:self.phoneNumTextField.text forKey:@"phoneStr"];
    [vc  setValue:self.masterStr forKey:@"MasterID"];
    [vc  setValue:self.suerTypeStr forKey:@"userType"];
    [self.navigationController pushViewController:vc animated:YES];
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
