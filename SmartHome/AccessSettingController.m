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

@property (weak, nonatomic) IBOutlet UITableView *areaTableView;
//eareTabelView属性
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UIButton *identityType;
@property (weak, nonatomic) IBOutlet UIView *headView;
@property (nonatomic,strong) NSArray *areasArr;
@property (nonatomic,strong) NSMutableArray *managerType;
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
-(NSArray *)areasArr
{
    if(!_areasArr)
    {
        _areasArr = @[@"客厅",@"大主卧",@"一楼小房",@"一楼厨房",@"二楼小房",@"二楼主卧"];
    }
    return _areasArr;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"权限控制";
    self.automaticallyAdjustsScrollViewInsets = NO;
    UIBarButtonItem *returnItem = [[UIBarButtonItem alloc]initWithTitle:@"设置" style:UIBarButtonItemStylePlain target:self action:@selector(clickRetunBtn:)];
    self.navigationItem.leftBarButtonItem = returnItem;
    self.areaTableView.tableHeaderView = self.headView;
    self.areaTableView.hidden = YES;
    [self sendRequest];
}
-(void)sendRequest
{
    NSString *url = [NSString stringWithFormat:@"%@GetAllUserInfo.aspx",[IOManager httpAddr]];
    NSString *auothorToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"];
    NSString *userHostID = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserHostID"];
     NSDictionary *dict = @{@"AuthorToken":auothorToken,@"UserHostID":userHostID};
    HttpManager *http=[HttpManager defaultManager];
    http.delegate = self;
   // http.tag = 1;
    [http sendPost:url param:dict];

}
-(void)httpHandler:(id)responseObject
{
    if([responseObject[@"Result"] intValue]==0)
    {
        NSDictionary *dic = responseObject[@"HomeInfo"];
        NSArray *arr = dic[@"UserInfo"];
        for(NSDictionary *userDetail in arr)
        {
            NSString *userName = userDetail[@"UserName"];
            NSString *userType = userDetail[@"UserType"];
            [self.userArr addObject:userName];
            [self.managerType addObject:userType];
        }
        [self.userTableView reloadData];
    }else{
        [MBProgressHUD showError:responseObject[@"Msg"]];
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
    
    if(tableView == self.areaTableView)
    {
        areaSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"areaSettingCell" forIndexPath:indexPath];
        
        cell.areaLabel.text = self.areasArr[indexPath.row];
        return cell;
    }

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"accessSettingCell" forIndexPath:indexPath];
    cell.textLabel.text = self.userArr[indexPath.row];
    cell.detailTextLabel.text = self.managerType[indexPath.row];
    
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.areaTableView.hidden = NO;
    if(tableView == self.userTableView)
    {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        self.userName.text = cell.textLabel.text;
        if([cell.detailTextLabel.text isEqualToString:@"主人用户"])
        {
            [self.identityType setTitle:@"可转化为普通身份" forState:UIControlStateNormal];
        }else [self.identityType setTitle:@"可转化为主人身份" forState:UIControlStateNormal];
        
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(tableView == self.userTableView)
    {
        return 50;
    }
    return 44;
}
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    if(tableView == self.userTableView)
    {
        return YES;
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
        
        [self.managerType removeObjectAtIndex:indexPath.row];
        [self.userArr removeObjectAtIndex:indexPath.row];
        [self.userTableView reloadData];
        [alertVC dismissViewControllerAnimated:YES completion:nil];
    }];
    [alertVC addAction:cancelAction];
    [alertVC addAction:sureAction];

    
    
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
