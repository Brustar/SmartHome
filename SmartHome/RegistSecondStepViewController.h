//
//  RegistSecondStepViewController.h
//  SmartHome
//
//  Created by KobeBryant on 2017/3/24.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFNetworking.h"
#import "HttpManager.h"
#import "MBProgressHUD+NJ.h"
#import "NSString+RegMatch.h"
#import "CryptoManager.h"
#import "WebManager.h"
#import "IOManager.h"
#import "CustomViewController.h"

@interface RegistSecondStepViewController : CustomViewController<HttpDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *phoneNumLabel;
@property (weak, nonatomic) IBOutlet UITextField *checkCodeTextField;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *pwdTextField;
@property (weak, nonatomic) IBOutlet UITextField *pwd2TextField;
@property (weak, nonatomic) IBOutlet UIImageView *tipImageView;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (nonatomic, strong) NSString *phoneNum;//手机号码
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *phoneNumLabelLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *phoneNumLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *line1Trailing;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *line1Leading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *line2Trailing;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *line2Leading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *line3Trailing;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *line3Leading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *line4Trailing;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *line4Leading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *line5Trailing;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *line5Leading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *line6Trailing;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *line6Leading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *checkCodeFieldLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *checkCodeFieldWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *checkCodeBtnTrailing;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameIconLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pwdIconLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pwd2IconLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameTextFieldLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameTextFieldWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pwdTextFieldLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pwdTextFieldWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pwd2TextFieldLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pwd2TextFieldWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tipIconLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tipLabelLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nextBtnTrailing;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nextBtnLeading;

@property (nonatomic,assign) int cType;
@property (nonatomic,strong) NSString  *masterID;
@property (nonatomic,strong) NSString *userType;

@property (nonatomic,strong) dispatch_source_t _timer;
@property (weak, nonatomic) IBOutlet UIButton *checkCodeBtn;

- (IBAction)checkCodeBtnClicked:(id)sender;
- (IBAction)nextStepBtnClicked:(id)sender;

@end
