//
//  RegistSecondStepViewController.h
//  SmartHome
//
//  Created by KobeBryant on 2017/3/24.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AFNetworking.h>
#import "HttpManager.h"
#import "MBProgressHUD+NJ.h"
#import "NSString+RegMatch.h"
#import "CryptoManager.h"
#import "WebManager.h"
#import "IOManager.h"

@interface RegistSecondStepViewController : UIViewController<HttpDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *phoneNumLabel;
@property (weak, nonatomic) IBOutlet UITextField *checkCodeTextField;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *pwdTextField;
@property (weak, nonatomic) IBOutlet UITextField *pwd2TextField;
@property (weak, nonatomic) IBOutlet UIImageView *tipImageView;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (nonatomic, strong) NSString *phoneNum;//手机号码

@property (nonatomic,assign) int cType;
@property (nonatomic,strong) NSNumber  *masterID;
@property (nonatomic,strong) NSString *userType;

@property (nonatomic,strong) dispatch_source_t _timer;
@property (weak, nonatomic) IBOutlet UIButton *checkCodeBtn;

- (IBAction)checkCodeBtnClicked:(id)sender;
- (IBAction)nextStepBtnClicked:(id)sender;

@end
