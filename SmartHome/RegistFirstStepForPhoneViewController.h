//
//  RegistFirstStepForPhoneViewController.h
//  SmartHome
//
//  Created by KobeBryant on 2017/4/7.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HttpManager.h"
#import "MBProgressHUD+NJ.h"
#import "NSString+RegMatch.h"
#import "WebManager.h"
#import "CustomViewController.h"

@interface RegistFirstStepForPhoneViewController : CustomViewController<UITableViewDelegate, UITableViewDataSource, HttpDelegate, UITextFieldDelegate,UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *countryCodeLabel;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumTextField;
@property (weak, nonatomic) IBOutlet UITableView *countryCodeTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *line1Trailing;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *line1Leading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *line2Trailing;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *line2Leading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *line3Trailing;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *line3Leading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *countryCodeLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *phoneNumLabelLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *phoneNumTextFieldLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *phoneNumTextFieldWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pullBtnTrailing;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *countryCodeTableTrailing;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *countryCodeTableLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nextBtnTrailing;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nextBtnLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *protocolBtnLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tips1Leading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tips2Leading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tips3Leading;

@property(nonatomic, strong) NSArray *countryCodeArray;
@property (nonatomic,strong) NSString *suerTypeStr;
@property (nonatomic, strong) NSString *countryCode;//国家码
@property (nonatomic, strong) NSString *masterStr;//主机码


- (IBAction)pullButtonClicked:(id)sender;
- (IBAction)nextStepBtnClicked:(id)sender;
- (IBAction)protocolBtnClicked:(id)sender;

@end
