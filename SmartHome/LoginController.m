//
//  LoginController.m
//  SmartHome
//
//  Created by Brustar on 16/6/29.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "LoginController.h"
#import "IOManager.h"
#import "CryptoManager.h"
#import "MBProgressHUD+NJ.h"
#import "WebManager.h"
#import "RegexKitLite.h"
<<<<<<< HEAD
#import "SocketManager.h"

@interface LoginController ()
=======
#import "QRCodeReaderDelegate.h"
#import "QRCodeReader.h"
#import "QRCodeReaderViewController.h"
#import "RegisterPhoneNumController.h"
#import "MSGController.h"
#import "ProfieFaultsViewController.h"
#import "ServiceRecordViewController.h"
@interface LoginController ()<QRCodeReaderDelegate>
>>>>>>> b958762ce3b4c53dc4a50d424ed9705aeeb9cbec
@property (weak, nonatomic) IBOutlet UITextField *user;
@property (weak, nonatomic) IBOutlet UITextField *pwd;
@property (weak, nonatomic) IBOutlet UIView *coverView;
@property (weak, nonatomic) IBOutlet UIView *registerView;

@property(nonatomic,strong) NSString *userType;
@property(nonatomic,strong) NSString *masterId;
@property(nonatomic,strong) NSString *role;
@end

@implementation LoginController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)login:(id)sender
{
    if ([self.user.text isEqualToString:@""])
    {
        [MBProgressHUD showError:@"请输入用户名或手机号"];
        return;
    }
    
    if ([self.pwd.text isEqualToString:@""])
    {
        [MBProgressHUD showError:@"请输入密码"];
        return;
    }
    
    NSString *url = [NSString stringWithFormat:@"%@UserLogin.aspx",[IOManager httpAddr]];
    
    int type = 1;
    if([self isMobileNumber:self.user.text])
    {
        type = 2;
    }
    NSDictionary *dict = @{@"Account":self.user.text,@"Type":[NSNumber numberWithInt:type],@"Password":[self.pwd.text md5]};
    [[NSUserDefaults standardUserDefaults] setObject:self.user.text forKey:@"Account"];
    HttpManager *http=[HttpManager defaultManager];
    http.delegate=self;
    [http sendPost:url param:dict];
    
}

-(void) httpHandler:(id) responseObject
{
<<<<<<< HEAD
    if ([responseObject[@"Result"] intValue]==1) {
        [[NSUserDefaults standardUserDefaults] setObject:responseObject[@"AuthorToken"] forKey:@"token"];
        [[SocketManager defaultManager] connectAfterLogined];
=======
    if ([responseObject[@"Result"] intValue]==0) {
        [[NSUserDefaults standardUserDefaults] setObject:responseObject[@"AuthorToken"] forKey:@"AuthorToken"];
        [[NSUserDefaults standardUserDefaults] setObject:responseObject[@"UserID"] forKey:@"UserID"];
        
>>>>>>> b958762ce3b4c53dc4a50d424ed9705aeeb9cbec
    }
    [MBProgressHUD showError:responseObject[@"Msg"]];
}


- (BOOL)isMobileNumber:(NSString *)mobileNum
{
    NSString *regex=@"^1[3|4|5|7|8]\\d{9}$";
    return [mobileNum isMatchedByRegex:regex];
}

- (IBAction)forgotPWD:(id)sender
{
    [WebManager show:@"http://3g.cn"];
}

//注册
- (IBAction)registerAccount:(id)sender {
    self.coverView.hidden = NO;
    self.registerView.hidden = NO;
}

- (IBAction)cancelRegister:(id)sender {
    self.coverView.hidden = YES;
    self.registerView.hidden = YES;
}
- (IBAction)scanCodeForRegistering:(id)sender {
    if ([QRCodeReader supportsMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]]) {
        static QRCodeReaderViewController *vc = nil;
        static dispatch_once_t onceToken;
        
        dispatch_once(&onceToken, ^{
            QRCodeReader *reader = [QRCodeReader readerWithMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
            vc = [QRCodeReaderViewController readerWithCancelButtonTitle:@"取消" codeReader:reader startScanningAtLoad:YES showSwitchCameraButton:YES showTorchButton:YES];
            vc.modalPresentationStyle = UIModalPresentationFormSheet;
        });
        vc.delegate = self;
        
        [vc setCompletionWithBlock:^(NSString *resultAsString) {
            NSLog(@"Completion with result: %@", resultAsString);
        }];
        
        [self presentViewController:vc animated:YES completion:NULL];
    }
    else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"标题" message:@"不能打开摄像头，请确认授权使用摄像头" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:okAction];
    }
    
}


- (void)reader:(QRCodeReaderViewController *)reader didScanResult:(NSString *)result
{
        NSArray* list = [result componentsSeparatedByString:@"@"];
        if([list count] > 1)
        {
            self.masterId = list[0];
            //[reg setValue:self.masterId forKey:@"masterStr"];
            
            if ([@"1" isEqualToString:list[1]]) {
                self.role=@"主人";
            }else{
                self.role=@"客人";
            }
            //[reg setValue:role forKey:@"suerTypeStr"];
        }
        else
        {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"非法的二维码" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
            [alert addAction:okAction];
        }
        
    
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    RegisterPhoneNumController *reg = segue.destinationViewController;
    reg.masterStr = self.masterId;
    reg.suerTypeStr = self.role;
}
- (void)readerDidCancel:(QRCodeReaderViewController *)reader
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}






@end
