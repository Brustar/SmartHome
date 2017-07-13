//
//  ChangeNameViewController.m
//  SmartHome
//
//  Created by zhaona on 2017/6/23.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "ChangeNameViewController.h"
#import "MBProgressHUD+NJ.h"
#import "HttpManager.h"
#import "SQLManager.h"
#import "CryptoManager.h"

@interface ChangeNameViewController ()

@property (nonatomic, readonly) UIButton *naviRightBtn;


@property (weak, nonatomic) IBOutlet UITextField *changeNameTextField;

@end

@implementation ChangeNameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setNaviBarTitle:@"更改名称"];
    _naviRightBtn = [CustomNaviBarView createNormalNaviBarBtnByTitle:@"保存" target:self action:@selector(rightBtnClicked:)];
    [self.changeNameTextField addTarget:self action:@selector(endediting) forControlEvents:UIControlEventEditingDidEnd];
    [self setNaviBarRightBtn:_naviRightBtn];
    if (ON_IPAD) {
        [self adjustNaviBarFrameForSplitView];
        [self adjustTitleFrameForSplitView];
        [self setNaviBarRightBtnForSplitView:_naviRightBtn];
    }
}
-(void)endediting

{
    
    if (self.changeNameTextField.text.length == 0) {
        _naviRightBtn.enabled = NO;
        [_naviRightBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    }else{
        _naviRightBtn.enabled = YES;
    }
    NSLog(@"停止编辑");
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    int userID = [[UD objectForKey:@"UserID"] intValue];
    _userInfomation = [SQLManager getUserInfo:userID];
    self.changeNameTextField.text = [NSString stringWithFormat:@"%@",_userInfomation.nickName];
    
}

- (BOOL)becomeFirstResponder

{
    [super becomeFirstResponder];
    
    return [self.changeNameTextField becomeFirstResponder];
    
}
-(void)sendRequest
{
    NSString *url = [NSString stringWithFormat:@"%@Cloud/user_info.aspx",[IOManager httpAddr]];
    NSString *auothorToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"];
    if (auothorToken) {
        NSDictionary *dict = @{@"token":auothorToken,@"optype":[NSNumber numberWithInteger:1],@"nickname":[self.changeNameTextField.text encodeBase]};
        NSLog(@"%@",self.changeNameTextField.text);
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
                NSInteger userID = [[UD objectForKey:@"UserID"] integerValue];
                BOOL   succeed = [SQLManager updateUserNickNameByID:(int)userID nickName:self.changeNameTextField.text];//更新User表
                BOOL succeed_chats = [SQLManager updateChatsPortraitByID:(int)userID nickname:self.changeNameTextField.text];//更新chats表
                if (succeed && succeed_chats) {
                [MBProgressHUD showSuccess:@"更新昵称成功"];
                [NC postNotificationName:@"refreshNickName" object:self.changeNameTextField.text];
                    
                   }
            [MBProgressHUD showSuccess:@"保存成功"];
           
        }else{
            [MBProgressHUD showError:responseObject[@"保存失败"]];
        }
        
    }
   
}
-(void)rightBtnClicked:(UIButton *)bbt
{
    
    NSString *isDemo = [UD objectForKey:IsDemo];
    if ([isDemo isEqualToString:@"YES"]) {
        [MBProgressHUD showSuccess:@"真实用户才可以修改成功"];
    }else{
         [self sendRequest];
    }
    [self.navigationController popViewControllerAnimated:YES];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
