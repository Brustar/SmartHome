//
//  AccessSettingController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/7/15.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "AccessSettingController.h"
#import "areaSettingCell.h"
#import "IOManager.h"
#import "HttpManager.h"
#import "MBProgressHUD+NJ.h"
#import "AreaSubSettingViewController.h"

@interface AccessSettingController ()<UITableViewDelegate,UITableViewDataSource,HttpDelegate>
@property (weak, nonatomic) IBOutlet UITableView *userTableView;
@property (nonatomic,strong) NSMutableArray *userArr;
@property (nonatomic,strong) NSMutableArray *managerType;
@property (weak, nonatomic) IBOutlet UITableView *areaTableView;//权限设备的TableView
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
@property (nonatomic,strong) UITableViewCell *cell;
@property (nonatomic,strong) NSIndexPath *selectedIndexPath;
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
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"权限控制";
    self.automaticallyAdjustsScrollViewInsets = NO;
    UIBarButtonItem *returnItem = [[UIBarButtonItem alloc]initWithTitle:@"设置" style:UIBarButtonItemStylePlain target:self action:@selector(clickRetunBtn:)];
    self.navigationItem.leftBarButtonItem = returnItem;
    self.areaTableView.tableHeaderView = self.headView;
    self.areaTableView.hidden = YES;
    NSString *url = [NSString stringWithFormat:@"%@Cloud/user_listall.aspx",[IOManager httpAddr]];
    [self sendRequest:url withTag:1];
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

    }else if(tag == 2)
    {
        if([responseObject[@"result"] intValue] == 0)
        {
            [self.areasArr removeAllObjects];
            [self.opens removeAllObjects];
            NSArray *arr =responseObject[@"host_user_list"];
            for(NSDictionary *messageList in arr)
            {
                NSNumber *userID = messageList[@"userid"];
                if(self.usrID == userID)
                {
                    NSArray *inforList = messageList[@"room_user_list"];
                    for(NSDictionary *info  in inforList)
                    {
                        [self.areasArr addObject:info[@"room_name"]];
                        [self.opens addObject:info[@"isopen"]];
                        [self.recoredIDs addObject:info[@"room_id"]];
                    }
                   
                }
            }
           [self.areaTableView reloadData];

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
    }else if(tag == 4)
    {
        if([responseObject[@"result"] intValue] == 0)
        {
            [MBProgressHUD showSuccess:@"成功转化为普通身份"];
            self.cell.detailTextLabel.text = @"普通用户";
            if ([self.userName.text isEqualToString:[UD objectForKey:@"UserName"]]) { //如果是自己
                [UD setObject:@(2) forKey:@"UserType"];
                [UD synchronize];
            }
            
          
        }else{
            [MBProgressHUD showError:responseObject[@"Msg"]];
            
        }

    }else if(tag == 5)
    {
        if([responseObject[@"Result"] intValue] == 0)
        {
            [MBProgressHUD showSuccess:@"成功转化为主人身份"];
            self.cell.detailTextLabel.text = @"主人";
            if ([self.userName.text isEqualToString:[UD objectForKey:@"UserName"]]) { //如果是自己
                [UD setObject:@(1) forKey:@"UserType"];
                [UD synchronize];
            }
            
        }else{
            [MBProgressHUD showError:responseObject[@"Msg"]];
        }
    }else if(tag == 6 || tag == 7)
    {
        if([responseObject[@"Result"] intValue] == 0)
        {
            [MBProgressHUD showSuccess:@"设置权限成功"];
        }else{
            [MBProgressHUD showError:responseObject[@"Msg"]];
        }

    }
    
}
#pragma mark - UITableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if(tableView == self.areaTableView)
    {
        return self.areasArr.count;
    }
    return self.userArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == self.userTableView){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"accessSettingCell" forIndexPath:indexPath];
        cell.textLabel.text = self.userArr[indexPath.row];
        NSNumber *type = self.managerType[indexPath.row];
        if([type intValue] ==1)
        {
            cell.detailTextLabel.text = @"主人";
        }else {
            cell.detailTextLabel.text = @"普通用户";
        }
        return cell;


    }
    AreaSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"areaSettingCell" forIndexPath:indexPath];
    
    cell.exchangeSwitch.tag = [self.recoredIDs[indexPath.row] integerValue];
    [cell.exchangeSwitch addTarget:self action:@selector(switchChange:) forControlEvents:UIControlEventValueChanged];
    cell.areaLabel.text = self.areasArr[indexPath.row];
    NSNumber *num = self.opens[indexPath.row];
    if([num intValue] == 1)
    {
        cell.exchangeSwitch.on = YES;
    }else {
        cell.exchangeSwitch.on = NO;
    }
    return cell;
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(tableView == self.userTableView)
    {
//        UIStoryboard * storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//        AreaSubSettingViewController *AreaSubVC = [storyBoard instantiateViewControllerWithIdentifier:@"AccessSubSettingVC"];
//        [self.navigationController pushViewController:AreaSubVC animated:YES];
//        AreaSubVC.usrID = self.userIDArr[indexPath.row];
        
        self.usrID = self.userIDArr[indexPath.row];
//         NSString *url = [NSString stringWithFormat:@"%@Cloud/room_authority.aspx",[IOManager httpAddr]];
        self.recoredIDs = nil;
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        self.cell = cell;
        self.selectedIndexPath = indexPath;
        self.userName.text = cell.textLabel.text;
        
        if ([self.userName.text isEqualToString:[UD objectForKey:@"UserName"]] && [[UD objectForKey:@"UserType"] integerValue] == 2) {
            [MBProgressHUD showError:@"你是普通用户，无权限操作"];
            self.areaTableView.hidden = YES;
            return;
            
        }else if ([self.userName.text isEqualToString:[UD objectForKey:@"UserName"]] && [[UD objectForKey:@"UserType"] integerValue] == 1) {
            self.areaTableView.hidden = YES;
            return;
        }
        
        //只有点击他人时，才显示权限列表，看自己的权限列表没意义
//        [self sendRequest:url withTag:2];
//        self.areaTableView.hidden = NO;
                UIStoryboard * storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                AreaSubSettingViewController *AreaSubVC = [storyBoard instantiateViewControllerWithIdentifier:@"AccessSubSettingVC"];
                [self.navigationController pushViewController:AreaSubVC animated:YES];
                AreaSubVC.usrID = self.userIDArr[indexPath.row];
        if([cell.detailTextLabel.text isEqualToString:@"主人"])
        {
            [self.identityType setTitle:@"转化为普通身份" forState:UIControlStateNormal];
        }else
        {
            [self.identityType setTitle:@"转化为主人身份" forState:UIControlStateNormal];

        }
    }
    
}
-(void)switchChange:(UISwitch *)sender
{
    UISwitch *exchangeSwitch = sender;

    NSInteger recoredID = exchangeSwitch.tag;
    if(sender.isOn)
    {
        [self settingAccessIsOpen:[NSNumber numberWithInt:1] tag:6 withRecoredID:recoredID];
    }else{
        [self settingAccessIsOpen:[NSNumber numberWithInt:2] tag:7 withRecoredID:recoredID];
    }
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
    if(tableView == self.userTableView)
    {
        return 50;
    }
    return 44;
}
-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(tableView == self.userTableView)
    {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if([cell.detailTextLabel.text isEqualToString:@"主人"]) {
            if ([cell.textLabel.text isEqualToString:[UD objectForKey:@"UserName"]]) {
                return NO;
            }else {
                return YES;
            }
            
        }else if ([cell.detailTextLabel.text isEqualToString:@"普通用户"]) {
            if ([cell.textLabel.text isEqualToString:[UD objectForKey:@"UserName"]]) {
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
        
        //删除用户
        [self deleteOrChangeManagerType:1 userID:_usrID withTag:3];
        
        
        [self.managerType removeObjectAtIndex:indexPath.row];
        [self.userArr removeObjectAtIndex:indexPath.row];
        [self.userTableView reloadData];
        [alertVC dismissViewControllerAnimated:YES completion:nil];
    }];
    [alertVC addAction:cancelAction];
    [alertVC addAction:sureAction];

    
}
//删除或改变用户权限请求
-(void)deleteOrChangeManagerType:(NSInteger)type userID:(NSNumber *)userID withTag:(int)tag
{
    NSString *url = [NSString stringWithFormat:@"%@Login/user_edit.aspx",[IOManager httpAddr]];
    NSString *auothorToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"];
    if (auothorToken) {
        NSDictionary *dict = @{
                               @"token": auothorToken,
                               @"optype": @(type),
                               @"opuserid": userID
                              };
        
        HttpManager *http=[HttpManager defaultManager];
        http.delegate = self;
        http.tag = tag;
        [http sendPost:url param:dict];
    }
}

//点击转换身份按钮
- (IBAction)changeIdentityType:(UIButton *)sender {
    
    if ([self.userName.text isEqualToString:[UD objectForKey:@"UserName"]] && [[UD objectForKey:@"UserType"] integerValue] == 2) {
        [MBProgressHUD showError:@"你是普通用户，无权限操作"];
        //return;
    }
    
    NSString *str = sender.titleLabel.text;
    NSString *type = [str substringFromIndex:3];
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"确定转化为%@",type]message:nil preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController: alertVC animated:YES completion:nil];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [alertVC dismissViewControllerAnimated:YES completion:nil];
    }];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //执行转化身份操作
        if([str containsString:@"普通身份"])
        {
            [self deleteOrChangeManagerType:3  userID:_usrID withTag:4];//转化为普通用户
            sender.titleLabel.text = @"转化为主人身份";
        }else{
            [self deleteOrChangeManagerType:2  userID:_usrID withTag:5];//转化为主人
            sender.titleLabel.text= @"转化为普通身份";
        }
        [alertVC dismissViewControllerAnimated:YES completion:nil];
    }];
    [alertVC addAction:cancelAction];
    [alertVC addAction:sureAction];
    
}

- (IBAction)clickRetunBtn:(id)sender {
    //[self.view removeFromSuperview];
    [self.navigationController popViewControllerAnimated:NO];
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
