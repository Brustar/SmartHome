//
//  ChangePassWordVC.m
//  SmartHome
//
//  Created by zhaona on 2017/6/23.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "ChangePassWordVC.h"
#import "MBProgressHUD+NJ.h"

@interface ChangePassWordVC ()

@property (weak, nonatomic) IBOutlet UILabel *NameLabel;//自己的用户名
@property (weak, nonatomic) IBOutlet UITextField *passWordField;//密码
@property (weak, nonatomic) IBOutlet UITextField *confirmedPsd;
@property (nonatomic, readonly) UIButton *naviRightBtn;


@end

@implementation ChangePassWordVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setNaviBarTitle:@"设置新密码"];
    _naviRightBtn = [CustomNaviBarView createNormalNaviBarBtnByTitle:@"保存" target:self action:@selector(rightBtnClicked:)];
    
    [self setNaviBarRightBtn:_naviRightBtn];
    if (ON_IPAD) {
        [self adjustNaviBarFrameForSplitView];
        [self adjustTitleFrameForSplitView];
        [self setNaviBarRightBtnForSplitView:_naviRightBtn];
    }
    self.NameLabel.text = self.nameStr;
    self.passWordField.placeholder = @"请设置逸云密码";
    [self.passWordField setTextColor:[UIColor redColor]];
    self.confirmedPsd.placeholder = @"请再次填入";
    [self.confirmedPsd setTextColor:[UIColor redColor]];
    
}
-(void)rightBtnClicked:(UIButton *)bbt
{
    [MBProgressHUD showSuccess:@"保存成功"];
    
    [self.navigationController popViewControllerAnimated:YES];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
