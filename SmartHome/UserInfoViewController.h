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

@interface UserInfoViewController : CustomViewController<UITableViewDelegate, UITableViewDataSource, HttpDelegate>
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *headerBtn;
@property (weak, nonatomic) IBOutlet UITableView *userinfoTableView;
@property (nonatomic, strong) UserInfo *userInfomation;
@property (nonatomic, strong) NSString *userTypeStr;
- (IBAction)headerBtnClicked:(id)sender;

@end
