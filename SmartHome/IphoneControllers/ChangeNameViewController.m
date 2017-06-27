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
    
    [self setNaviBarRightBtn:_naviRightBtn];
    if (ON_IPAD) {
        [self adjustNaviBarFrameForSplitView];
        [self adjustTitleFrameForSplitView];
        [self setNaviBarRightBtnForSplitView:_naviRightBtn];
    }
}
-(void)sendRequest
{
    NSString *url = [NSString stringWithFormat:@"%@Cloud/user_info.aspx",[IOManager httpAddr]];
    NSString *auothorToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"];
    if (auothorToken) {
        NSDictionary *dict = @{@"token":auothorToken,@"optype":[NSNumber numberWithInteger:1],@"nickname":self.changeNameTextField.text};
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
                BOOL succeed = [SQLManager updateUserPortraitUrlByID:(int)userID url:self.changeNameTextField.text];//更新User表
                BOOL succeed_chats = [SQLManager updateChatsPortraitByID:(int)userID userName:self.changeNameTextField.text nickName:self.changeNameTextField.text];//更新chats表
                if (succeed && succeed_chats) {
                    [MBProgressHUD showSuccess:@"更新昵称成功"];
                    _userInfomation.nickName = self.changeNameTextField.text;
                    _userInfomation.userName = self.changeNameTextField.text;
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
    [self sendRequest];
    
    [self.navigationController popViewControllerAnimated:YES];

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
