//
//  AreaSubSettingViewController.m
//  SmartHome
//
//  Created by zhaona on 2017/1/5.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "AreaSubSettingViewController.h"
#import "HttpManager.h"
#import "MBProgressHUD+NJ.h"
#import "IOManager.h"
#import "AreaSettingCell.h"

@interface AreaSubSettingViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) AreaSettingCell *cell;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (nonatomic,strong) NSMutableArray * areasArr;
@property (nonatomic,strong) NSMutableArray * recoredIDs;
@property (nonatomic,strong) NSMutableArray *opens;
@property (nonatomic,assign) int usertype;



@end

@implementation AreaSubSettingViewController
-(NSMutableArray *)areasArr
{
    if(!_areasArr)
    {
        _areasArr = [NSMutableArray array];
    }
    return _areasArr;
}
-(NSMutableArray *)recoredIDs
{
    if(!_recoredIDs)
    {
        _recoredIDs = [NSMutableArray array];
    }
    return _recoredIDs;
}
-(NSMutableArray *)opens
{
    if(!_opens)
    {
        _opens = [NSMutableArray array];
    }
    return _opens;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self setNaviBarTitle:@"权限设置"];
    self.tableView.tableHeaderView = self.headerView;
    NSString *url = [NSString stringWithFormat:@"%@Cloud/room_authority.aspx",[IOManager httpAddr]];
    self.userName.text = self.userNameTitle;
    [self creatUI];
    UIView *view = [[UIView alloc] init];
    [view setBackgroundColor:[UIColor clearColor]];
    self.tableView.tableFooterView = view;
    [self sendRequest:url withTag:2];
    /*
    DeviceInfo *device = [DeviceInfo defaultManager];
    if ([device.db isEqualToString:SMART_DB]) {
        [self sendRequest:url withTag:2];
    }else {
        NSDictionary *plistDict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"hostUserList" ofType:@"plist"]];
        NSArray *arr = plistDict[@"host_user_list"];
        if ([arr isKindOfClass:[NSArray class]]) {
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
                        [self.recoredIDs addObject:info[@"roomuser_id"]];
                    }
                    
                }
            }
        }
        [self.tableView reloadData];
    }
    */
    
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
    if(tag == 2)
    {
        if([responseObject[@"result"] intValue] == 0)
        {
            [self.areasArr removeAllObjects];
            [self.opens removeAllObjects];
            //            NSDictionary *dic = responseObject[@"host_user_list"];
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
                        [self.recoredIDs addObject:info[@"roomuser_id"]];
                    }
                    
                }
            }
            [self.tableView reloadData];
            
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
            self.cell.detialLabel.text = @"普通用户";
            if ([self.userName.text isEqualToString:[UD objectForKey:@"UserName"]]) { //如果是自己
                [UD setObject:@(2) forKey:@"UserType"];
                self.usertype = 2;
                [UD synchronize];
            }
            
        }else{
            [MBProgressHUD showError:responseObject[@"Msg"]];
            
        }
        
    }else if(tag == 5)
    {
        if([responseObject[@"Result"] intValue] == 0)
        {
            [MBProgressHUD showSuccess:@"成功转化为主人"];
            self.cell.detialLabel.text = @"主人";
            if ([self.userName.text isEqualToString:[UD objectForKey:@"UserName"]]) { //如果是自己
                [UD setObject:@(1) forKey:@"UserType"];
                self.usertype = 1;
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
-(void)creatUI
{
    if([self.detailTextName isEqualToString:@"主人"])
    {
        [self.identityType setTitle:@"转化为普通身份" forState:UIControlStateNormal];
    }else
    {
        [self.identityType setTitle:@"转化为主人身份" forState:UIControlStateNormal];
        
    }
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.areasArr.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.cell = [tableView dequeueReusableCellWithIdentifier:@"areaSettingCell" forIndexPath:indexPath];
    self.cell.backgroundColor = [UIColor clearColor];
    self.cell.exchangeSwitch.tag = [self.recoredIDs[indexPath.row] integerValue];
    self.cell.exchanggeBtn.tag = [self.recoredIDs[indexPath.row] integerValue];
    [self.cell.exchanggeBtn addTarget:self action:@selector(switchChange:) forControlEvents:UIControlEventTouchUpInside];
    [self.cell.exchangeSwitch addTarget:self action:@selector(switchChange:) forControlEvents:UIControlEventValueChanged];
    self.cell.areaLabel.text = self.areasArr[indexPath.row];
//    self.cell.detialLabel.text = @" ";
    //cell的点击颜色
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 2, self.view.bounds.size.width, 40)];
    view.backgroundColor = [UIColor clearColor];
    self.cell.selectedBackgroundView = view;
    NSNumber *num = self.opens[indexPath.row];
    self.cell.exchanggeBtn.selected = !self.cell.exchanggeBtn.selected;
    if([num intValue] == 1)
    {
       self.cell.exchangeSwitch.on = YES;
        self.cell.exchanggeBtn.selected = YES;
        [self.cell.exchanggeBtn setBackgroundImage:[UIImage imageNamed:@"dvd_btn_switch_on"] forState:UIControlStateNormal];
        
    }else {
        self.cell.exchangeSwitch.on = NO;
        self.cell.exchanggeBtn.selected = NO;
         [self.cell.exchanggeBtn setBackgroundImage:[UIImage imageNamed:@"dvd_btn_switch_off"] forState:UIControlStateNormal];
//        cell.hidden = YES;
    }
    return self.cell;
    
}
-(void)switchChange:(UIButton *)sender
{
    //注册用户
    UIButton *exchangeBtn = sender;
    exchangeBtn.selected = !exchangeBtn.selected;
    NSInteger recoredID = exchangeBtn.tag;
    if(exchangeBtn.selected)
    {
        [exchangeBtn setBackgroundImage:[UIImage imageNamed:@"dvd_btn_switch_on"] forState:UIControlStateNormal];
        [self settingAccessIsOpen:[NSNumber numberWithInt:1] tag:6 withRecoredID:recoredID];
    }else{
        
        [exchangeBtn setBackgroundImage:[UIImage imageNamed:@"dvd_btn_switch_off"] forState:UIControlStateNormal];
        [self settingAccessIsOpen:[NSNumber numberWithInt:0] tag:7 withRecoredID:recoredID];
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
            [self deleteOrChangeManagerType:2  userID:_usrID withTag:4 usertype:[NSNumber numberWithInt:2]];//转化为普通用户
            sender.titleLabel.text = @"转化为主人身份";
            
        }else{
            [self deleteOrChangeManagerType:2  userID:_usrID withTag:5 usertype:[NSNumber numberWithInt:1]];//转化为主人
            sender.titleLabel.text= @"转化为普通身份";
        }
        [alertVC dismissViewControllerAnimated:YES completion:nil];
    }];
    [alertVC addAction:cancelAction];
    [alertVC addAction:sureAction];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
