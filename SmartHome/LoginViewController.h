//
//  LoginViewController.h
//  SmartHome
//
//  Created by KobeBryant on 2017/3/21.
//  Copyright © 2017年 ECloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "HttpManager.h"
#import "MBProgressHUD+NJ.h"
#import "WebManager.h"
#import "NSString+RegMatch.h"
#import "SocketManager.h"
#import "SceneController.h"
#import "QRCodeReaderDelegate.h"
#import "QRCodeReader.h"
#import "QRCodeReaderViewController.h"
#import "RegisterPhoneNumController.h"
#import "MSGController.h"
#import "ProfileFaultsViewController.h"
#import "ServiceRecordViewController.h"
#import "RegisterDetailController.h"
#import "ECloudTabBarController.h"
#import "SQLManager.h"
#import "FMDatabase.h"
#import "DeviceInfo.h"
#import "PackManager.h"
#import "CryptoManager.h"
#import "SunCount.h"
#import <CoreLocation/CoreLocation.h>

@interface LoginViewController : UIViewController<QRCodeReaderDelegate, CLLocationManagerDelegate, UITextFieldDelegate, HttpDelegate,UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *pwdTextField;

@property (nonatomic,strong) NSMutableArray * home_room_infoArr;
@property (nonatomic,strong) NSString *UserTypeStr;
@property (nonatomic,strong) NSMutableArray * room_user_listArr;

@property(nonatomic,assign) NSInteger userType;
@property(nonatomic,assign) NSInteger UserType;//判断是否为主人
@property(nonatomic,strong) NSString *masterId;
@property(nonatomic,strong) NSString *role;
@property(nonatomic,strong) NSMutableArray *hostIDS;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,assign) int vEquipmentsLast;
@property (nonatomic,assign) int vRoomLast;
@property (nonatomic,assign) int vSceneLast;
@property (nonatomic,assign) int vTVChannelLast;
@property (nonatomic,assign) int vFMChannellLast;
@property (nonatomic,assign) int vClientlLast;

@property (nonatomic,strong) NSArray *antronomicalTimes;
@property (strong,nonatomic) CLLocationManager *lm;

- (IBAction)forgetPwdBtnClicked:(id)sender;
- (IBAction)tryBtnClicked:(id)sender;
- (IBAction)loginBtnClicked:(id)sender;
- (IBAction)registBtnClicked:(id)sender;

@end
