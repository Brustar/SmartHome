//
//  RegisterViewController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/7/4.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "RegisterViewController.h"
#import "QRCodeReaderDelegate.h"
#import "QRCodeReader.h"
#import "QRCodeReaderViewController.h"
#import "RegisterPhoneNumController.h"
#import "WebManager.h"
@interface RegisterViewController ()<QRCodeReaderDelegate>
@property(nonatomic,strong) NSString *userType;
@property(nonatomic,strong) NSString *masterId;
@property(nonatomic,strong) NSString *role;
@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"注册";
    // Do any additional setup after loading the view.
}





- (IBAction)scanCode:(id)sender {
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
     [self dismissViewControllerAnimated:YES completion:^{
      
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

    }];
    [self performSegueWithIdentifier:@"scanQCSegue" sender:self];
    
}

- (void)readerDidCancel:(QRCodeReaderViewController *)reader
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    RegisterPhoneNumController *reg = segue.destinationViewController;
    reg.masterStr = self.masterId;
    reg.suerTypeStr = self.role;
}

//加载到服务协议h5界面
- (IBAction)serviceAgreement:(id)sender {
    [WebManager show:@""];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
