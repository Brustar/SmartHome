//
//  AccessSettingController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/7/15.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "AccessSettingController.h"
#import "AreaSettingCell.h"
#import "IOManager.h"
#import "HttpManager.h"
#import "MBProgressHUD+NJ.h"
#import "AreaSubSettingViewController.h"

@interface AccessSettingController ()<UITableViewDelegate,UITableViewDataSource,HttpDelegate>
@property (weak, nonatomic) IBOutlet UITableView *userTableView;
@property (nonatomic,strong) NSMutableArray *userArr;
@property (nonatomic,strong) NSMutableArray *managerType;
@property (nonatomic,strong) NSMutableArray *userIDArr;
@property (nonatomic,strong) NSNumber  *usrID;
//eareTabelView属性
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UIButton *identityType;
@property (weak, nonatomic) IBOutlet UIView *headView;
@property (nonatomic,strong) NSMutableArray *areasArr;
@property (nonatomic,strong) NSMutableArray *opens;
@property (nonatomic,strong) NSMutableArray *recoredIDs;
@property (nonatomic,strong) NSNumber *recoredId;
@property (nonatomic,strong) AreaSettingCell *cell;
@property (nonatomic,strong) NSIndexPath *selectedIndexPath;
@property (nonatomic,assign) int usertype;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableviewTrailingConstraint;//右边距离
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableviewLeadingConstraint;//左边距离

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *view1TrailingConstraint;//右边距离
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *view1LeadingConstraint;//左边距离
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewTopConstraint;//顶部的距离
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *view1TopConstraint;

@end

@implementation AccessSettingController

-(NSMutableArray *)userArr
{
    if(!_userArr)
    {
        _userArr = [NSMutableArray array];
       
        
    }
    return _userArr;
}
-(NSMutableArray *)managerType{
    if(!_managerType)
    {
        _managerType = [NSMutableArray array];
        
    }
    return _managerType;
}
-(NSMutableArray *)areasArr
{
    if(!_areasArr)
    {
        _areasArr = [NSMutableArray array];
    }
    return _areasArr;
}
-(NSMutableArray *)userIDArr
{
    if(!_userIDArr)
    {
        _userIDArr = [NSMutableArray array];
        
    }
    return _userIDArr;
}
-(NSMutableArray *)opens
{
    if(!_opens)
    {
        _opens = [NSMutableArray array];
    }
    return _opens;
}
-(NSMutableArray *)recoredIDs
{
    if(!_recoredIDs)
    {
        _recoredIDs = [NSMutableArray array];
    }
    return _recoredIDs;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.userArr removeAllObjects];
    [self.managerType removeAllObjects];
    [self.userIDArr removeAllObjects];
    if (ON_IPAD) {
        self.tableviewTrailingConstraint.constant = 20;
        self.tableviewLeadingConstraint.constant = 20;
        self.tableViewTopConstraint.constant = 80;
        self.view1TrailingConstraint.constant = 20;
        self.view1LeadingConstraint.constant = 20;
        self.view1TopConstraint.constant = 80;
    }
    
    NSString *url = [NSString stringWithFormat:@"%@Cloud/user_listall.aspx",[IOManager httpAddr]];
    [self sendRequest:url withTag:1];
    [self.userTableView reloadData];

    [LoadMaskHelper showMaskWithType:AccessControl onView:self.tabBarController.view delay:0.5 delegate:self];
}


- (void)viewDidLoad {
    [super viewDidLoad];
  
    [self setNaviBarTitle:@"权限控制"];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self adjustNaviBarFrameForSplitView];
        [self adjustTitleFrameForSplitView];
    }
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.userTableView.tableFooterView = [UIView new];
   
}
-(void)sendRequest:(NSString *)url withTag:(int)i
{
    
    NSString *auothorToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"];
    if (auothorToken) {
        NSDictionary *dict = @{@"token":auothorToken,@"optype":[NSNumber numberWithInteger:0]};
        HttpManager *http=[HttpManager defaultManager];
        http.delegate = self;
        http.tag = i;
        [http sendPost:url param:dict];
    }

}
-(void)httpHandler:(id)responseObject tag:(int)tag
{
    if(tag == 1)
    {
        if([responseObject[@"result"] intValue]==0)
        {
//            NSDictionary *dic = responseObject[@"messageInfo"];
            NSArray *arr = responseObject[@"user_list"];
            for(NSDictionary *userDetail in arr)
            {
                NSString *userName = userDetail[@"username"];
                NSString *userType = userDetail[@"usertype"];
                NSString *userID = userDetail[@"user_id"];
                [self.userArr addObject:userName];
                [self.managerType addObject:userType];
                [self.userIDArr addObject:userID];
               
//    [IOManager writeUserdefault:userDetail[@"usertype"] forKey:@"UserType"];
            }
                        [self.userTableView reloadData];
        }else{
            [MBProgressHUD showError:responseObject[@"Msg"]];
        }

    }else if(tag == 3)
    {
        if([responseObject[@"result"] intValue] == 0)
        {
            [MBProgressHUD showSuccess:@"删除成功"];
        }else{
            [MBProgressHUD showError:responseObject[@"Msg"]];

        }
    }
    
}
-(void)viewDidLayoutSubviews {
    
    if ([self.userTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.userTableView setSeparatorInset:UIEdgeInsetsZero];
        
    }
    if ([self.userTableView respondsToSelector:@selector(setLayoutMargins:)])  {
        [self.userTableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPat{
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]){
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
}
#pragma mark - UITableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return self.userArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
        AreaSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"accessSettingCell" forIndexPath:indexPath];
        cell.backgroundColor = [UIColor colorWithRed:29/255.0 green:30/255.0 blue:34/255.0 alpha:1];
        cell.areaLabel.text = self.userArr[indexPath.row];
        NSNumber *type = self.managerType[indexPath.row];
        cell.changeBtn.userInteractionEnabled = NO;
        UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 50)];
        view.backgroundColor = [UIColor clearColor];
        
        cell.selectedBackgroundView = view;
        if([type intValue] ==1)
        {
            cell.detialLabel.text = @"主人";
        }else {
            cell.detialLabel.text = @"普通用户";
        }
    
     return cell;
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
        self.usrID = self.userIDArr[indexPath.row];
//         NSString *url = [NSString stringWithFormat:@"%@Cloud/room_authority.aspx",[IOManager httpAddr]];
//        self.recoredIDs = nil;
        AreaSettingCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        self.cell = cell;
        self.selectedIndexPath = indexPath;
        
        self.userName.text = cell.areaLabel.text;
        
        if ([self.userName.text isEqualToString:[UD objectForKey:@"UserName"]] && [[UD objectForKey:@"UserType"] integerValue] == 2) {
            [MBProgressHUD showError:@"你是普通用户，无权限操作"];
           
            return;
            
        }else if ([self.userName.text isEqualToString:[UD objectForKey:@"UserName"]] && [[UD objectForKey:@"UserType"] integerValue] == 1) {
            
            return;
        }
        
        //只有点击他人时，才显示权限列表，看自己的权限列表没意义
//        [self sendRequest:url withTag:2];
//        self.areaTableView.hidden = NO;
                UIStoryboard * storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                AreaSubSettingViewController *AreaSubVC = [storyBoard instantiateViewControllerWithIdentifier:@"AccessSubSettingVC"];
                [self.navigationController pushViewController:AreaSubVC animated:YES];
                AreaSubVC.usrID = self.userIDArr[indexPath.row];
                AreaSubVC.userNameTitle = cell.areaLabel.text;
                 AreaSubVC.identityType = self.identityType;
                AreaSubVC.detailTextName = cell.detialLabel.text;

    
}

//设置用户权限请求
-(void)settingAccessIsOpen:(NSNumber *)openNum tag:(int)tag withRecoredID:(NSInteger)recordID
{
    NSString *url = [NSString stringWithFormat:@"%@Cloud/room_authority.aspx",[IOManager httpAddr]];
    NSString *authorToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"];
    NSDictionary *dict = @{@"token":authorToken,@"roomuser_id":[NSNumber numberWithInteger:recordID],@"isopen":openNum,@"optype":[NSNumber numberWithInteger:1]};
    HttpManager *http=[HttpManager defaultManager];
    http.delegate = self;
    http.tag = tag;
    [http sendPost:url param:dict];
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}
-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(tableView == self.userTableView)
    {
//        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        AreaSettingCell * cell = (AreaSettingCell *)[tableView cellForRowAtIndexPath:indexPath];
        if([cell.detialLabel.text isEqualToString:@"主人"]) {
            if ([cell.areaLabel.text isEqualToString:[UD objectForKey:@"UserName"]]) {
                return NO;
            }else {
                return YES;
            }
            
        }else if ([cell.detialLabel.text isEqualToString:@"普通用户"]) {
            if ([cell.areaLabel.text isEqualToString:[UD objectForKey:@"UserName"]]) {
                return NO;
            }else {
                return YES;
            }
        }else {
            return NO;
        }
        
    }
    return NO;
}
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(tableView == self.userTableView) {
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    //判断是不是自己
    if ([cell.textLabel.text isEqualToString:[UD objectForKey:@"UserName"]]) {
        return UITableViewCellEditingStyleNone;
    }
    self.usrID = self.userIDArr[indexPath.row];
    return UITableViewCellEditingStyleDelete;
    }
    
    return UITableViewCellEditingStyleNone;
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"确定删除吗？" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController: alertVC animated:YES completion:nil];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [alertVC dismissViewControllerAnimated:YES completion:nil];
    }];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *isDemo = [UD objectForKey:IsDemo];
        if ([isDemo isEqualToString:@"YES"]) {
            [MBProgressHUD showSuccess:@"此操作你没有权限"];
        }else{
            //删除用户
            [self deleteOrChangeManagerType:1 userID:_usrID withTag:3 usertype:[NSNumber numberWithInt:self.usertype]];
            [self.managerType removeObjectAtIndex:indexPath.row];
            [self.userArr removeObjectAtIndex:indexPath.row];
            [self.userTableView reloadData];
            [alertVC dismissViewControllerAnimated:YES completion:nil];
        }
    }];
    [alertVC addAction:cancelAction];
    [alertVC addAction:sureAction];

    
}
//删除或改变用户权限请求
-(void)deleteOrChangeManagerType:(NSInteger)type userID:(NSNumber *)userID withTag:(int)tag usertype:(NSNumber *)usertype
{
    NSString *url = [NSString stringWithFormat:@"%@Login/user_edit.aspx",[IOManager httpAddr]];
    NSString *auothorToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"];
    if (auothorToken) {
        NSDictionary *dict = @{
                               @"token": auothorToken,
                               @"optype": @(type),
                               @"opuserid": userID,
                               @"usertype":usertype
                              };
        
        HttpManager *http=[HttpManager defaultManager];
        http.delegate = self;
        http.tag = tag;
        [http sendPost:url param:dict];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - SingleMaskViewDelegate
- (void)onNextButtonClicked:(UIButton *)btn pageType:(PageTye)pageType {
    [MBProgressHUD showError:@"已经是最后一步了"];
}

- (void)onSkipButtonClicked:(UIButton *)btn pageType:(PageTye)pageType {
    [UD setObject:@"haveShownMask" forKey:ShowMaskViewHomePageChatBtn];
    [UD setObject:@"haveShownMask" forKey:ShowMaskViewHomePageEnterChat];
    [UD setObject:@"haveShownMask" forKey:ShowMaskViewHomePageEnterFamily];
    [UD setObject:@"haveShownMask" forKey:ShowMaskViewHomePageScene];
    [UD setObject:@"haveShownMask" forKey:ShowMaskViewHomePageDevice];
    [UD setObject:@"haveShownMask" forKey:ShowMaskViewHomePageCloud];
    [UD setObject:@"haveShownMask" forKey:ShowMaskViewChatView];
    [UD setObject:@"haveShownMask" forKey:ShowMaskViewFamilyHome];
    [UD setObject:@"haveShownMask" forKey:ShowMaskViewFamilyHomeDetail];
    [UD setObject:@"haveShownMask" forKey:ShowMaskViewScene];
    [UD setObject:@"haveShownMask" forKey:ShowMaskViewSceneDetail];
    [UD setObject:@"haveShownMask" forKey:ShowMaskViewDevice];
    [UD setObject:@"haveShownMask" forKey:ShowMaskViewDeviceAir];
    [UD setObject:@"haveShownMask" forKey:ShowMaskViewLeftView];
    [UD setObject:@"haveShownMask" forKey:ShowMaskViewSettingView];
    [UD setObject:@"haveShownMask" forKey:ShowMaskViewAccessControl];
    [UD setObject:@"haveShownMask" forKey:ShowMaskViewSceneAdd];
    [UD synchronize];
}

- (void)onTransparentBtnClicked:(UIButton *)btn {
//    self.usrID = self.userIDArr[1];
//    AreaSettingCell *cell = [_userTableView cellForRowAtIndexPath:[NSIndexPath indexPathWithIndex:1]];
//    self.cell = cell;
//    self.selectedIndexPath = [NSIndexPath indexPathWithIndex:1];
//    self.userName.text = cell.areaLabel.text;
//    
//    UIStoryboard * storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    AreaSubSettingViewController *AreaSubVC = [storyBoard instantiateViewControllerWithIdentifier:@"AccessSubSettingVC"];
//    [self.navigationController pushViewController:AreaSubVC animated:YES];
//    AreaSubVC.usrID = self.userIDArr[1];
//    AreaSubVC.userNameTitle = cell.areaLabel.text;
//    AreaSubVC.identityType = self.identityType;
//    AreaSubVC.detailTextName = cell.detialLabel.text;
}


@end
