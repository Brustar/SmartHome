//
//  UserInfoViewController.m
//  SmartHome
//
//  Created by KobeBryant on 2017/4/25.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "UserInfoViewController.h"
#import "ChangeNameViewController.h"
#import "CryptoManager.h"
#import "ChangePassWordVC.h"

@interface UserInfoViewController ()<UITextFieldDelegate>

@property (nonatomic,strong) NSArray * TitleArray;
@property (nonatomic,strong) NSArray * DetialArray;
@property (nonatomic,strong) NSString * powerStr;
@property (nonatomic,strong) UITextField *userNameTextField;

@end

@implementation UserInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNaviBarTitle:@"个人信息"];

    self.TitleArray = @[@"VIP会员",@"服务商城",@"我的订单",@"购物车",@"昵称",@"电话",@"逸云密码"];
    self.DetialArray = @[@"/ui/Vip.aspx?user_id=%d",@"/ui/GoodsList.aspx?user_id=%d",@"/ui/OrderQuery.aspx?user_id=%d",@"/ui/Cart.aspx?user_id=%d"];
    if (ON_IPAD) {
        [self adjustNaviBarFrameForSplitView];
        [self adjustTitleFrameForSplitView];
        [self setNaviBarLeftBtn:nil];
    }
    
    [self.userinfoTableView setTableHeaderView:[self setupTableHeader]];

    [self getUserInfoFromDB];
    [self fetchUserInfo];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self addNotifications];
    if (ON_IPAD) {
        self.UserinfoLeadingConstraint.constant = 20;
        self.UserinfoTrailingConstraint.constant = 20;
    }

    [self.userinfoTableView reloadData];
}

- (UIView *)setupTableHeader {
    
    CGFloat width = UI_SCREEN_WIDTH;
    if (ON_IPAD) {
        width = UI_SCREEN_WIDTH*3/4;
    }
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 330)];
    view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
    
    UIImageView *headBg = [[UIImageView alloc] initWithFrame:CGRectMake((width-160)/2, (330-160)/2-20, 160, 160)];
    headBg.image = [UIImage imageNamed:@"head_bg"];
    [view addSubview:headBg];
    
    _headerBtn = [[UIButton alloc] initWithFrame:CGRectMake((width-110)/2, (330-110)/2-27, 110, 110)];
    [_headerBtn addTarget:self action:@selector(headerBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:_headerBtn];
    
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(headBg.frame)+40, width, 20)];
    _nameLabel.font = [UIFont systemFontOfSize:16];
    _nameLabel.textColor = [UIColor lightGrayColor];
    _nameLabel.textAlignment = NSTextAlignmentCenter;
    [view addSubview:_nameLabel];
    
    return view;
}

- (void)addNotifications {
   
    [NC addObserver:self selector:@selector(refreshNickName:) name:@"refreshNickName" object:nil];
}
-(void)refreshNickName:(NSNotification *)fication
{
    NSString * nickName = fication.object;
    _userInfomation.nickName = nickName;
    [self refreshUI];
    
}
- (void)refreshUI {
    
    NSInteger userType = [[UD objectForKey:@"UserType"] integerValue];
    if (userType == 1) {
        _userTypeStr = @"主人";
    }else {
        _userTypeStr = @"客人";
    }
    self.nameLabel.text = [NSString stringWithFormat:@"-- %@, %@身份 --", _userInfomation.nickName, _userTypeStr];
    [self.headerBtn sd_setImageWithURL:[NSURL URLWithString:_info.headImgURL] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"portrait"]];
    self.headerBtn.layer.cornerRadius = self.headerBtn.frame.size.width/2;
    self.headerBtn.layer.masksToBounds = YES;
    self.userinfoTableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
    self.userinfoTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.userinfoTableView reloadData];
}

- (void)getUserInfoFromDB {
    
    int userID = [[UD objectForKey:@"UserID"] intValue];
    _userInfomation = [SQLManager getUserInfo:userID];
    
    [self refreshUI];
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
            
            _info = [[UserInfo alloc] init];
            _info.nickName = responseObject[@"nickname"];
            _info.headImgURL = responseObject[@"portrait"];
            _info.phoneNum = responseObject[@"phone"];
            _info.vip = responseObject[@"vip"];
            _info.endDate = responseObject[@"end_date"];
//            _userInfomation = info;
            
            [self refreshUI];
        }
    }if (tag == 2) {
       
                if([responseObject[@"result"] intValue]==0)
                {
                    UIStoryboard * MyInfoStoryBoard = [UIStoryboard storyboardWithName:@"MyInfo" bundle:nil];
                    ChangePassWordVC * changePassWordVC = [MyInfoStoryBoard instantiateViewControllerWithIdentifier:@"ChangePassWordVC"];
                    changePassWordVC.nameStr = _userInfomation.nickName;
                    
                    [self.navigationController pushViewController:changePassWordVC animated:YES];
                    
                }else{
                    
//                    [MBProgressHUD showError:@"原密码输入错误"];
                    
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"密码输入错误，请重新输入" preferredStyle:UIAlertControllerStyleAlert];
                    
                    // 添加按钮
                    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                        
                        [self passoward];
                    }]];
                    
                    [self presentViewController:alert animated:YES completion:nil];
                }
           }
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.TitleArray.count;
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
   
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UI_SCREEN_WIDTH, 8.0)];
    footer.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UI_SCREEN_WIDTH, 0.5)];
    line.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"login_line"]];
    [footer addSubview:line];
    
    return footer;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return 8.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"userinfoCell";
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundView = nil;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.backgroundColor = [UIColor colorWithRed:30.0/255.0 green:29.0/255.0 blue:34.0/255.0 alpha:1];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    cell.textLabel.text = self.TitleArray[indexPath.section];
    if (indexPath.section == 0) {
        if ([_info.vip isEqualToString:@"1"]) {
            cell.imageView.image = [UIImage imageNamed:@"VIP_icon"];
            UILabel *vipLabel = [[UILabel alloc] initWithFrame:CGRectMake(4, -2, 20, 15)];
            vipLabel.textAlignment = NSTextAlignmentCenter;
            vipLabel.textColor = [UIColor whiteColor];
            vipLabel.font = [UIFont boldSystemFontOfSize:11];
            vipLabel.backgroundColor = [UIColor clearColor];
            vipLabel.text = @"VIP";
            [cell.imageView addSubview:vipLabel];
            
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
            UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 12, 140, 20)];
            dateLabel.textAlignment = NSTextAlignmentRight;
            dateLabel.textColor = [UIColor lightGrayColor];
            dateLabel.font = [UIFont systemFontOfSize:15];
            dateLabel.backgroundColor = [UIColor clearColor];
            dateLabel.text = [NSString stringWithFormat:@"%@ 到期", _info.endDate];
            [view addSubview:dateLabel];
            
            UIButton *chargeBtn = [[UIButton alloc] initWithFrame:CGRectMake(160, 11, 40, 22)];
            [chargeBtn addTarget:self action:@selector(chargeBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            chargeBtn.backgroundColor = [UIColor redColor];
            chargeBtn.layer.cornerRadius = 4.0;
            chargeBtn.layer.masksToBounds = YES;
            [chargeBtn setTitle:@"续费" forState:UIControlStateNormal];
            [chargeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            chargeBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
            [view addSubview:chargeBtn];
            
            cell.accessoryView = view;
            
        }else {
            cell.imageView.image = nil;
            cell.accessoryView = nil;
        }
    }if (indexPath.section == 4) {
        cell.detailTextLabel.text = _userInfomation.nickName;
    }if (indexPath.section == 5) {
         cell.detailTextLabel.text = _info.phoneNum;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    int userID = [[UD objectForKey:@"UserID"] intValue];
    
    if (indexPath.section == 0 || indexPath.section == 1 || indexPath.section == 2 || indexPath.section == 3) {
        //VIP会员
        WebManager *web = [[WebManager alloc] initWithUrl:[[IOManager httpAddr] stringByAppendingString:[NSString stringWithFormat:self.DetialArray[indexPath.section], userID]] title:self.TitleArray[indexPath.section]];
        web.isShowInSplitView = YES;
        [self.navigationController pushViewController:web animated:YES];
    }
    else if (indexPath.section == 4){
        UIStoryboard * MyInfoStoryBoard = [UIStoryboard storyboardWithName:@"MyInfo" bundle:nil];
        ChangeNameViewController * changeNameVC = [MyInfoStoryBoard instantiateViewControllerWithIdentifier:@"ChangeNameViewController"];
        
        [self.navigationController pushViewController:changeNameVC animated:YES];
        
    }else if (indexPath.section == 6){
        
               [self passoward];
        
    }
}
-(void)sendRequest
{
    NSString *url = [NSString stringWithFormat:@"%@Cloud/user_info.aspx",[IOManager httpAddr]];
    NSString *auothorToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"];
    if (auothorToken) {
        NSDictionary *dict = @{@"token":auothorToken,@"optype":[NSNumber numberWithInteger:3],@"originalPsw":[_userNameTextField.text md5]};
        HttpManager *http=[HttpManager defaultManager];
        http.delegate = self;
        http.tag = 2;
        [http sendPost:url param:dict];
    }
}

-(void)passoward
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"验证原密码" message:@"为保障你的数据安全，修改密码前请输入原密码" preferredStyle:UIAlertControllerStyleAlert];
    
    //增加取消按钮；
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil]];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请输入原密码";
        textField.secureTextEntry = YES;
    }];
    //增加确定按钮；
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //获取第1个输入框；
       _userNameTextField = alertController.textFields.firstObject;
        
//        if ([userNameTextField.text isEqualToString:[[[NSUserDefaults standardUserDefaults] objectForKey:@"Password"] decryptWithDes:DES_KEY]]) {
        
            [self sendRequest];
       
        
        
    }]];
    
    [self presentViewController:alertController animated:true completion:nil];
    

}
- (void)headerBtnClicked:(id)sender {
    
    UIAlertController * alerController = [UIAlertController alertControllerWithTitle:@"更换头像" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alerController addAction:[UIAlertAction actionWithTitle:@"拍一张" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            [MBProgressHUD showError:@"无法使用系统相机"];
            return;
        }
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:picker animated:YES completion:NULL];
        
        
    }]];
    
    [alerController addAction:[UIAlertAction actionWithTitle:@"从相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [DeviceInfo defaultManager].isPhotoLibrary = YES;
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            [MBProgressHUD showError:@"无法使用系统相册"];
            return;
        }
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [picker shouldAutorotate];
        [picker supportedInterfaceOrientations];
        [self presentViewController:picker animated:YES completion:nil];
        
    }]];
    [alerController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [alerController setModalPresentationStyle:UIModalPresentationPopover];
        UIPopoverPresentationController *popPresenter = [alerController
                                                         popoverPresentationController];
        popPresenter.sourceView = self.headerBtn;
        popPresenter.sourceRect = self.headerBtn.bounds;
        [self presentViewController:alerController animated:YES completion:nil];
        
    }else {
    
       [self presentViewController:alerController animated:YES completion:nil];
        
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [DeviceInfo defaultManager].isPhotoLibrary = NO;
    self.selectedImg = info[UIImagePickerControllerEditedImage];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *str = [formatter stringFromDate:[NSDate date]];
    NSString *fileName = [NSString stringWithFormat:@"%@.png", str];
    
    //[self saveImage:self.selectedImg withName:fileName];
    
    NSString *url = [NSString stringWithFormat:@"%@Cloud/user_info.aspx",[IOManager httpAddr]];
    NSString *authorToken = [UD objectForKey:@"AuthorToken"];
    NSDictionary *dic = @{
                          @"token":authorToken,
                          @"optype":@(2),
                          @"imgfile":fileName
                          };
    
    if (self.selectedImg && url && dic && fileName) {
    
        //上传头像
        [[UploadManager defaultManager] uploadImage:self.selectedImg url:url dic:dic fileName:fileName completion:^(id responseObject) {
            
            if ([responseObject[@"result"] intValue] == 0) {
                NSString *portrait = responseObject[@"portrait"];
                if (portrait.length >0) {
                    NSInteger userID = [[UD objectForKey:@"UserID"] integerValue];
                   BOOL succeed = [SQLManager updateUserPortraitUrlByID:(int)userID url:portrait];//更新User表
                    BOOL succeed_chats = [SQLManager updateChatsPortraitByID:(int)userID url:portrait];//更新chats表
                    if (succeed && succeed_chats) {
                         [MBProgressHUD showSuccess:@"更新头像成功"];
                        [self.headerBtn sd_setImageWithURL:[NSURL URLWithString:portrait] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"portrait"]];
                        _info.headImgURL = portrait;
                        [NC postNotificationName:@"refreshPortrait" object:portrait];
                    }else {
                        [MBProgressHUD showError:@"更新头像失败"];
                    }
                }else {
                    [MBProgressHUD showError:@"更新头像失败"];
                }
                
                
            }else {
                [MBProgressHUD showError:@"更新头像失败"];
            }
            
        }];
    
   
    [picker dismissViewControllerAnimated:YES completion:nil];
 }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [DeviceInfo defaultManager].isPhotoLibrary = NO;
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)saveImage:(UIImage *)currentImage withName:(NSString *)imageName
{
    NSData *imageData = UIImageJPEGRepresentation(currentImage, 0.5);
    // 获取沙盒目录
    
    NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:imageName];
    // 将图片写入文件
    [imageData writeToFile:fullPath atomically:NO];
}

- (void)chargeBtnClicked:(UIButton *)btn {
    //VIP支付页面
    int userID = [[UD objectForKey:@"UserID"] intValue];
    WebManager *web = [[WebManager alloc] initWithUrl:[[IOManager httpAddr] stringByAppendingString:[NSString stringWithFormat:@"/ui/Vip.aspx?user_id=%d", userID]] title:@"VIP会员"];
    web.isShowInSplitView = YES;
    [self.navigationController pushViewController:web animated:YES];
}

@end
