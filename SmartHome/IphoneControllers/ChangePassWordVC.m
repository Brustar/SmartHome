//
//  ChangePassWordVC.m
//  SmartHome
//
//  Created by zhaona on 2017/6/23.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "ChangePassWordVC.h"
#import "MBProgressHUD+NJ.h"
#import "HttpManager.h"
#import "CryptoManager.h"
#import "NSString+RegMatch.h"

@interface ChangePassWordVC ()

@property (weak, nonatomic) IBOutlet UILabel *NameLabel;//自己的用户名
@property (weak, nonatomic) IBOutlet UITextField *passWordField;//密码
@property (weak, nonatomic) IBOutlet UITextField *confirmedPsd;//再次确认
@property (nonatomic, readonly) UIButton *naviRightBtn;


@end

@implementation ChangePassWordVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setNaviBarTitle:@"设置新密码"];
    _naviRightBtn = [CustomNaviBarView createNormalNaviBarBtnByTitle:@"保存" target:self action:@selector(rightBtnClicked:)];
     _naviRightBtn.enabled = NO;
     [_naviRightBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
     [self.confirmedPsd addTarget:self action:@selector(confirmedPsdEndediting) forControlEvents:UIControlEventEditingDidEnd];
     [self.passWordField addTarget:self action:@selector(endediting) forControlEvents:UIControlEventEditingDidEnd];

    [self setNaviBarRightBtn:_naviRightBtn];
    if (ON_IPAD) {
        [self adjustNaviBarFrameForSplitView];
        [self adjustTitleFrameForSplitView];
        [self setNaviBarRightBtnForSplitView:_naviRightBtn];
    }
    self.NameLabel.text = self.nameStr;
    [self.passWordField setValue:[UIColor grayColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.confirmedPsd setValue:[UIColor grayColor] forKeyPath:@"_placeholderLabel.textColor"];
   
}
-(void)endediting
{
    if(![self.passWordField.text isPassword])
    {
        [MBProgressHUD showError:@"密码应该是6-8位字符"];
        _naviRightBtn.enabled = NO;
        [_naviRightBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
        return;
    }else{
         _naviRightBtn.enabled = YES;
    }
    
}
-(void)confirmedPsdEndediting
{
   if (![self.passWordField.text isEqualToString:self.confirmedPsd.text])
    {
        [MBProgressHUD showError:@"两次密码不匹配"];
        _naviRightBtn.enabled = NO;
        [_naviRightBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
        return;
    }else{
        _naviRightBtn.enabled = YES;
    }
    
}
-(void)sendRequest
{
    NSString *url = [NSString stringWithFormat:@"%@Cloud/user_info.aspx",[IOManager httpAddr]];
    NSString *auothorToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"];
    if (auothorToken) {
        NSDictionary *dict = @{@"token":auothorToken,@"optype":[NSNumber numberWithInteger:4],@"psw":[self.passWordField.text md5],@"psw2":[self.confirmedPsd.text md5]};
        HttpManager *http=[HttpManager defaultManager];
        http.delegate = self;
        http.tag = 1;
        [http sendPost:url param:dict];
    }
}

-(void)httpHandler:(id)responseObject tag:(int)tag
{
    if(tag == 1)
    {
        if([responseObject[@"result"] intValue]==0)
        {
            [MBProgressHUD showSuccess:@"修改密码成功"];
            
        }else{
            [MBProgressHUD showError:responseObject[@"修改密码失败"]];
        }
        
    }
    
}
-(void)rightBtnClicked:(UIButton *)bbt
{
   
    NSString *isDemo = [UD objectForKey:IsDemo];
    if ([isDemo isEqualToString:@"YES"]) {
        [MBProgressHUD showSuccess:@"真实用户才可以修改成功"];
        
    }else{
        if(![self.passWordField.text isPassword])
        {
            [MBProgressHUD showError:@"密码应该是6-8位字符"];
            _naviRightBtn.enabled = NO;
            [_naviRightBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
            return;
        }if (![self.passWordField.text isEqualToString:self.confirmedPsd.text])
        {
            [MBProgressHUD showError:@"两次密码不匹配"];
            _naviRightBtn.enabled = NO;
            [_naviRightBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
            return;
        }else{
             [self sendRequest];
        }
        
    }
    
     [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
