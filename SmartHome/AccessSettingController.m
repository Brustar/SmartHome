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
@interface AccessSettingController ()<UITableViewDelegate,UITableViewDataSource,HttpDelegate>
@property (weak, nonatomic) IBOutlet UITableView *userTableView;
@property (nonatomic,strong) NSMutableArray *userArr;
@property (nonatomic,strong) NSMutableArray *managerType;
@property (weak, nonatomic) IBOutlet UITableView *areaTableView;
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
    NSString *url = [NSString stringWithFormat:@"%@GetAllUserInfo.aspx",[IOManager httpAddr]];
    [self sendRequest:url withTag:1];
}
-(void)sendRequest:(NSString *)url withTag:(int)i
{
    
    NSString *auothorToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"];
    NSDictionary *dict = @{@"AuthorToken":auothorToken};
    HttpManager *http=[HttpManager defaultManager];
    http.delegate = self;
    http.tag = i;
    [http sendPost:url param:dict];

}
-(void)httpHandler:(id)responseObject tag:(int)tag
{
    if(tag == 1)
    {
        if([responseObject[@"Result"] intValue]==0)
        {
            NSDictionary *dic = responseObject[@"messageInfo"];
            NSArray *arr = dic[@"userList"];
            for(NSDictionary *userDetail in arr)
            {
                NSString *userName = userDetail[@"userName"];
                NSString *userType = userDetail[@"userType"];
                NSString *userID = userDetail[@"userId"];
                [self.userArr addObject:userName];
                [self.managerType addObject:userType];
                [self.userIDArr addObject:userID];
            }
            [self.userTableView reloadData];
        }else{
            [MBProgressHUD showError:responseObject[@"Msg"]];
        }

    }else if(tag == 2)
    {
        if([responseObject[@"Result"] intValue] == 0)
        {
            [self.areasArr removeAllObjects];
            [self.opens removeAllObjects];
            NSDictionary *dic = responseObject[@"messageInfo"];
            NSArray *arr = dic[@"userMessageList"];
            for(NSDictionary *messageList in arr)
            {
                NSNumber *userID = messageList[@"userId"];
                if(self.usrID == userID)
                {
                    NSArray *inforList = messageList[@"userMessageInfoList"];
                    for(NSDictionary *info  in inforList)
                    {
                        [self.areasArr addObject:info[@"roomName"]];
                        [self.opens addObject:info[@"isOpen"]];
                        [self.recoredIDs addObject:info[@"recordId"]];
                    }
                   
                }
            }
           [self.areaTableView reloadData];

        }else{
            [MBProgressHUD showError:responseObject[@"Msg"]];
        }

    }else if(tag == 3)
    {
        if([responseObject[@"Result"] intValue] == 0)
        {
            [MBProgressHUD showSuccess:@"删除成功"];
        }else{
            [MBProgressHUD showError:responseObject[@"Msg"]];

        }
    }else if(tag == 4)
    {
        if([responseObject[@"Result"] intValue] == 0)
        {
            [MBProgressHUD showSuccess:@"成功转化为普通身份"];
            self.cell.detailTextLabel.text = @"普通用户";
          
        }else{
            [MBProgressHUD showError:responseObject[@"Msg"]];
            
        }

    }else if(tag == 5)
    {
        if([responseObject[@"Result"] intValue] == 0)
        {
            [MBProgressHUD showSuccess:@"成功转化为主人身份"];
            self.cell.detailTextLabel.text = @"管理员";
            
            
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
            cell.detailTextLabel.text = @"管理员";
        }else {
            cell.detailTextLabel.text = @"普通用户";
        }
        return cell;


    }
    areaSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"areaSettingCell" forIndexPath:indexPath];
    self.recoredId = self.recoredIDs[indexPath.row];
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
        self.usrID = self.userIDArr[indexPath.row];
         NSString *url = [NSString stringWithFormat:@"%@GetUserAccessInfo.aspx",[IOManager httpAddr]];
        [self sendRequest:url withTag:2];
        self.areaTableView.hidden = NO;
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        self.cell = cell;
        self.selectedIndexPath = indexPath;
        self.userName.text = cell.textLabel.text;
        if([cell.detailTextLabel.text isEqualToString:@"管理员"])
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
    if(sender.isOn)
    {
        [self settingAccessIsOpen:[NSNumber numberWithInt:1] tag:6];
    }else{
        [self settingAccessIsOpen:[NSNumber numberWithInt:2] tag:7];
    }
}
//设置用户权限请求
-(void)settingAccessIsOpen:(NSNumber *)openNum tag:(int)tag;
{
    NSString *url = [NSString stringWithFormat:@"%@UserAccessSetting.aspx",[IOManager httpAddr]];
    NSString *authorToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"];
    NSDictionary *dict = @{@"AuthorToken":authorToken,@"RecordID":self.recoredId,@"isOpen":openNum};
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
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    if(tableView == self.userTableView)
    {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if([cell.detailTextLabel.text isEqualToString:@"管理员"]){
            return YES;
        }else {
            return NO;
        }
        
    }
    return NO;
}
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
   
    return UITableViewCellEditingStyleDelete;
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"确定删除吗？" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController: alertVC animated:YES completion:nil];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [alertVC dismissViewControllerAnimated:YES completion:nil];
    }];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //
        [self deleteOrChangeManagerType:1 withTag:3];
        
        
        [self.managerType removeObjectAtIndex:indexPath.row];
        [self.userArr removeObjectAtIndex:indexPath.row];
        [self.userTableView reloadData];
        [alertVC dismissViewControllerAnimated:YES completion:nil];
    }];
    [alertVC addAction:cancelAction];
    [alertVC addAction:sureAction];

    
    
}
//删除或改变用户权限请求
-(void)deleteOrChangeManagerType:(NSInteger)type withTag:(int)tag
{
    NSString *url = [NSString stringWithFormat:@"%@UserEdit.aspx",[IOManager httpAddr]];
    NSString *auothorToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"];
    
    NSDictionary *dict = @{@"AuthorToken":auothorToken,@"OType":[NSNumber numberWithInteger:type]};
    HttpManager *http=[HttpManager defaultManager];
    http.delegate = self;
    http.tag = tag;
    [http sendPost:url param:dict];

}

//点击转换身份按钮
- (IBAction)changeIdentityType:(UIButton *)sender {
    NSString *str = sender.titleLabel.text;
    NSString *type = [str substringFromIndex:4];
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"确定转化为%@",type]message:nil preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController: alertVC animated:YES completion:nil];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [alertVC dismissViewControllerAnimated:YES completion:nil];
    }];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //执行转化身份操作
        if([type isEqualToString:@"普通身份"])
        {
            [self deleteOrChangeManagerType:3 withTag:4];
            sender.titleLabel.text = @"转化为主人身份";
        }else{
            [self deleteOrChangeManagerType:2 withTag:5];
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
