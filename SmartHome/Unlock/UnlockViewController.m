//
//  UnlockViewController.m
//  SmartHome
//
//  Created by zhaona on 2017/12/14.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "UnlockViewController.h"
#import "UnlockView.h"
#import "NSString+RegMatch.h"
#import "CryptoManager.h"


@interface UnlockViewController ()
@property (nonatomic,strong)UIButton * btnBack;
//@property UnlockView * unlockView;
@property (weak, nonatomic) IBOutlet UITextField *pwdTextField;

@end

@implementation UnlockViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
   [self setNaviBarTitle:@"密码设置"];
    // 默认左侧显示返回按钮
    _btnBack =  [CustomNaviBarView createImgNaviBarBtnByImgNormal:@"backBtn" imgHighlight:@"backBtn" target:self action:@selector(leftBtnClicked:)];
//    self.unlockView = [[UnlockView alloc] initWithFrame:CGRectMake(50, 350, self.view.frame.size.width - 100, 45)];
    [self setNaviBarLeftBtn:_btnBack];
     self.pwdTextField.secureTextEntry = YES;
     [self.pwdTextField addTarget:self action:@selector(endediting) forControlEvents:UIControlEventEditingDidEnd];
//    [self.view addSubview:self.unlockView];
    
}
-(void)endediting
{
    if([self.pwdTextField.text isEqualToString: [[UD objectForKey:@"Password"] decryptWithDes:DES_KEY]] )
    {
        [self.navigationController popViewControllerAnimated:YES];
     
    }else{
       
    }
    
}
- (void)leftBtnClicked:(UIButton *)btn {
    
      [self.navigationController popToRootViewControllerAnimated:YES];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
