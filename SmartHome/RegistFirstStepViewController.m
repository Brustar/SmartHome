//
//  RegistFirstStepViewController.m
//  SmartHome
//
//  Created by KobeBryant on 2017/3/22.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "RegistFirstStepViewController.h"

@interface RegistFirstStepViewController ()

@end

@implementation RegistFirstStepViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNaviBarTitle:@"注册"];
    _countryCodeArray = @[@"中国(+86)",@"中国台湾(+886)",@"中国香港(+852)",@"中国澳门(+851)"];
    [self.countryCodeTableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    self.countryCodeTableView.hidden = YES;
    
    self.authLabel.text = self.suerTypeStr;
    self.homeLabel.text = [NSString stringWithFormat:@"%@",[NSNumber numberWithInt:self.masterStr]];
    [self.phoneNumTextField setValue:[UIColor grayColor] forKeyPath:@"_placeholderLabel.textColor"];
    
    self.countryCode = @"86";//默认国家码
    
}

- (void)backBtnAction:(UIButton *)btn {
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

- (IBAction)pullButtonClicked:(id)sender {
    if (self.countryCodeTableView.hidden) {
        self.countryCodeTableView.hidden = NO;
    }else {
        self.countryCodeTableView.hidden = YES;
    }
}

- (IBAction)nextStepBtnClicked:(id)sender {
    
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

#pragma mark - TableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _countryCodeArray.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"countryCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.textLabel.text = [_countryCodeArray objectAtIndex:indexPath.row];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.countryCodeLabel.text = [_countryCodeArray objectAtIndex:indexPath.row];
    if (indexPath.row == 0) {
        self.countryCode = @"86";
    }else if (indexPath.row == 1) {
        self.countryCode = @"886";
    }else if (indexPath.row == 2) {
        self.countryCode = @"852";
    }else if (indexPath.row == 3) {
        self.countryCode = @"851";
    }
    
    tableView.hidden = YES;
}

//验证手机号是否已注册
- (void)checkPhoneNumberIsExist {
    
    
    NSDictionary *dict = @{@"mobile":self.phoneNumTextField.text,
                           @"optype":@(1)
                           };
    
    NSString *url = [NSString stringWithFormat:@"%@login/send_code.aspx",[IOManager httpAddr]];
    HttpManager *http = [HttpManager defaultManager];
    http.tag = 1;
    http.delegate = self;
    [http sendPost:url param:dict];
    
    //        [self performSegueWithIdentifier:@"registerDetaiSegue" sender:self];
}

- (void)httpHandler:(id)responseObject tag:(int)tag
{
    if([responseObject[@"result"] intValue] == 0) { //手机号未注册，进行“下一步”操作，进入下一页面
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
        UIViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"registSecondStepVC"];
        NSString *phoneNumber = [NSString stringWithFormat:@"%@", self.phoneNumTextField.text];
        [vc setValue:phoneNumber forKey:@"phoneNum"];
        NSNumber *masterID = [NSNumber numberWithInteger:self.homeLabel.text.integerValue];
        [vc setValue:masterID forKey:@"masterID"];
        
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        [MBProgressHUD showError:responseObject[@"msg"]];
    }
}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

//加载到服务协议h5界面
- (IBAction)serviceAgreement:(id)sender {
    [WebManager show:@"http://115.28.151.85:8082/article.aspx?articleid=1"];
    
    [self performSegueWithIdentifier:@"webViewManger" sender:self];
}

@end
