//
//  LoginViewController.h
//  SmartHome
//
//  Created by KobeBryant on 2017/3/21.
//  Copyright © 2017年 ECloud. All rights reserved.
//

#import <AVKit/AVKit.h>
#import "AppDelegate.h"
#import "HttpManager.h"
#import "MBProgressHUD+NJ.h"
#import "WebManager.h"
#import "NSString+RegMatch.h"
#import "SocketManager.h"
//#import "SceneController.h"
#import "QRCodeReaderDelegate.h"
#import "QRCodeReader.h"
#import "QRCodeReaderViewController.h"
//#import "RegisterPhoneNumController.h"
#import "MSGController.h"
#import "ProfileFaultsViewController.h"
#import "ServiceRecordViewController.h"
//#import "RegisterDetailController.h"

#import "SQLManager.h"
#import "FMDatabase.h"
#import "DeviceInfo.h"
#import "PackManager.h"
#import "CryptoManager.h"
#import "DemoVideoPlayerViewController.h"

@interface LoginViewController : UIViewController<QRCodeReaderDelegate, UITextFieldDelegate, HttpDelegate,UIActionSheetDelegate, AVPlayerViewControllerDelegate, UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *pwdTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *loginBtnTrailing;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *loginBtnLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *loginBtnBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *registBtnTrailing;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *registBtnLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *registBtnBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *line1Trailing;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *line1Leading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *line1Top;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *line2Trailing;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *line2Leading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *line2Top;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *line3Trailing;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *line3Leading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *line3Top;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameIconLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pwdIconLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameTextFieldLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameTextFieldWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pwdTextFieldLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pwdTextFieldWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *forgetBtnLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tryBtnTrailing;

@property (nonatomic,strong) NSMutableArray * home_room_infoArr;
@property (nonatomic,strong) NSString *UserTypeStr;
@property (nonatomic,strong) NSMutableArray * room_user_listArr;
@property (nonatomic, assign) BOOL isTheSameUser;//判断是不是同一个用户登录
@property(nonatomic,assign) NSInteger userType;
@property(nonatomic,assign) NSInteger UserType;//判断是否为主人
@property(nonatomic,strong) NSString *masterId;
@property (nonatomic, strong) NSString *hostName;//主机名称（家庭名称）
@property(nonatomic,strong) NSString *role;
@property(nonatomic,strong) NSMutableArray *hostIDS;//主机Id列表
@property(nonatomic, strong) NSMutableArray *homeNameArray;//家庭名称列表
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,assign) int vEquipmentsLast;
@property (nonatomic,assign) int vRoomLast;
@property (nonatomic,assign) int vSceneLast;
@property (nonatomic,assign) int vTVChannelLast;
@property (nonatomic,assign) int vFMChannellLast;
@property (nonatomic,assign) int vClientlLast;
@property (nonatomic,strong)NSMutableArray * remind_listArr;
@property (nonatomic, strong) AVPlayerViewController *avPlayerVC;
@property (nonatomic,strong)  NSMutableArray * titleArray;
@property (nonatomic,strong)  NSMutableArray * detailArray;


- (IBAction)forgetPwdBtnClicked:(id)sender;
- (IBAction)tryBtnClicked:(id)sender;
- (IBAction)loginBtnClicked:(id)sender;
- (IBAction)registBtnClicked:(id)sender;

@end
