//
//  UserInfoViewController.h
//  SmartHome
//
//  Created by KobeBryant on 2017/4/25.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "CustomViewController.h"
#import "HttpManager.h"
#import "UserInfo.h"
#import "UIButton+WebCache.h"
#import "WebManager.h"
#import "MBProgressHUD+NJ.h"
#import "UploadManager.h"
#import "SQLManager.h"

@interface UserInfoViewController : CustomViewController<UITableViewDelegate, UITableViewDataSource, HttpDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UIButton *headerBtn;
@property (weak, nonatomic) IBOutlet UITableView *userinfoTableView;
@property (nonatomic, strong)  UserInfo *userInfomation;
@property (nonatomic, strong)  UserInfo *info;
@property (nonatomic, strong) NSString *userTypeStr;
@property (nonatomic, strong) UIImage *selectedImg;//选择的头像图片
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *UserinfoTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *UserinfoLeadingConstraint;

@end
