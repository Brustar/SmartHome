//
//  UserInfoViewController.m
//  SmartHome
//
//  Created by KobeBryant on 2017/4/25.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "UserInfoViewController.h"

@interface UserInfoViewController ()

@end

@implementation UserInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNaviBarTitle:@"个人信息"];
    [self initUI];
    [self fetchUserInfo];
}

- (void)initUI {
    NSInteger userType = [[UD objectForKey:@"UserType"] integerValue];
    if (userType == 1) {
        _userTypeStr = @"主人";
    }else {
        _userTypeStr = @"客人";
    }
    
    self.nameLabel.text = [NSString stringWithFormat:@"-- %@, %@身份 --", _userInfomation.nickName, _userTypeStr];
    
    self.headerBtn.layer.cornerRadius = self.headerBtn.frame.size.width/2;
    self.headerBtn.layer.masksToBounds = YES;
    self.userinfoTableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
    self.userinfoTableView.tableFooterView = [UIView new];
}

- (void)refreshUI {
    [self.headerBtn sd_setImageWithURL:[NSURL URLWithString:_userInfomation.headImgURL] forState:UIControlStateNormal placeholderImage:nil];
    
    self.nameLabel.text = [NSString stringWithFormat:@"-- %@, %@身份 --", _userInfomation.nickName, _userTypeStr];
    
    [self.userinfoTableView reloadData];
}

- (void)fetchUserInfo {
    
    NSInteger userID = [[UD objectForKey:@"UserID"] integerValue];
    NSString *auothorToken = [UD objectForKey:@"AuthorToken"];
    
    NSString *url = [NSString stringWithFormat:@"%@Cloud/user_info.aspx",[IOManager httpAddr]];
    
    
    if (auothorToken.length >0 ) {
        NSDictionary *dict = @{@"token":auothorToken,
                               @"user_id":@(userID),
                               @"optype":@(0)
                               };
        HttpManager *http = [HttpManager defaultManager];
        http.delegate = self;
        http.tag = 1;
        [http sendPost:url param:dict];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Http callback
- (void)httpHandler:(id)responseObject tag:(int)tag
{
    if(tag == 1) {
        if ([responseObject[@"result"] intValue] == 0) {
            
            UserInfo *info = [[UserInfo alloc] init];
            info.nickName = responseObject[@"nickname"];
            info.headImgURL = responseObject[@"portrait"];
            info.phoneNum = responseObject[@"phone"];
            _userInfomation = info;
            
            [self refreshUI];
        }
    }
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 0.5f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UI_SCREEN_WIDTH, 0.5)];
    header.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"login_line"]];
    
    return header;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
   
    if (section == 0 || section == 1 || section == 2) {
        UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UI_SCREEN_WIDTH, 8.0)];
        footer.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UI_SCREEN_WIDTH, 0.5)];
        line.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"login_line"]];
        [footer addSubview:line];
        
        return footer;
    }
    
    if (section == 4) {
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UI_SCREEN_WIDTH, 0.5)];
        line.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"login_line"]];
        
        return line;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    if (section == 0 || section == 1 || section == 2) {
        return 8.0f;
    }
    
    if (section == 4) {
        return 0.5f;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"userinfoCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    cell.backgroundView = nil;
    cell.accessoryType = UITableViewCellAccessoryNone;
    if (indexPath.section == 0 || indexPath.section == 1 || indexPath.section == 2) {
        cell.backgroundColor = [UIColor colorWithRed:30.0/255.0 green:29.0/255.0 blue:34.0/255.0 alpha:1];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.textColor = [UIColor whiteColor];
    
    if (indexPath.section == 0) {
        cell.textLabel.text = @"VIP会员";
    }else if (indexPath.section == 1) {
        cell.textLabel.text = @"购物车";
    }else if (indexPath.section == 2) {
        cell.textLabel.text = @"服务";
    }else if (indexPath.section == 3) {
        cell.textLabel.text = @"昵称";
        cell.detailTextLabel.text = _userInfomation.nickName;
    }else if (indexPath.section == 4) {
        cell.textLabel.text = @"电话";
        cell.detailTextLabel.text = _userInfomation.phoneNum;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        //VIP
    }else if (indexPath.section == 1) {
        //购物车
    }else if (indexPath.section == 2) {
        //服务
    }
}

- (IBAction)headerBtnClicked:(id)sender {
}
@end
