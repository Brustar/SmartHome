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

@interface RegistFirstStepForPhoneViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, HttpDelegate, UITextFieldDelegate,UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *countryCodeLabel;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumTextField;
@property (weak, nonatomic) IBOutlet UITableView *countryCodeTableView;

@property(nonatomic, strong) NSArray *countryCodeArray;
@property (nonatomic,strong) NSString *suerTypeStr;
@property (nonatomic, strong) NSString *countryCode;//国家码


- (IBAction)pullButtonClicked:(id)sender;
- (IBAction)nextStepBtnClicked:(id)sender;

@end
