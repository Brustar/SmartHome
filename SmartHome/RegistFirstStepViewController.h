//
//  RegistFirstStepViewController.h
//  SmartHome
//
//  Created by KobeBryant on 2017/3/22.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HttpManager.h"
#import "MBProgressHUD+NJ.h"
#import "NSString+RegMatch.h"
#import "WebManager.h"
#import "CustomViewController.h"

@interface RegistFirstStepViewController : CustomViewController<UITableViewDelegate, UITableViewDataSource, HttpDelegate, UITextFieldDelegate,UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *homeLabel;
@property (weak, nonatomic) IBOutlet UILabel *authLabel;
@property (weak, nonatomic) IBOutlet UILabel *countryCodeLabel;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumTextField;
@property (weak, nonatomic) IBOutlet UITableView *countryCodeTableView;
@property(nonatomic, strong) NSArray *countryCodeArray;

@property (nonatomic,strong) NSString *suerTypeStr;
@property (nonatomic,assign) int masterStr;//hostid 主机ID
@property (nonatomic, strong) NSString *hostName;//主机名

@property (nonatomic, strong) NSString *countryCode;//国家码

- (IBAction)pullButtonClicked:(id)sender;
- (IBAction)nextStepBtnClicked:(id)sender;
- (IBAction)protocolBtnClicked:(id)sender;

@end
