//
//  SystemSettingViewController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/7/18.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "SystemSettingViewController.h"
#import "SystemCell.h"
#import "HttpManager.h"
#import "MBProgressHUD+NJ.h"
@interface SystemSettingViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong)NSArray *titles;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *habits;
@property (nonatomic,strong) NSMutableArray *opens;
@property (nonatomic,strong) NSMutableArray *recordIDs;
@property (nonatomic,strong) NSNumber *recordID;
@end

@implementation SystemSettingViewController

-(NSMutableArray *)habits
{
    if(!_habits)
    {
        _habits = [NSMutableArray array];
        
    }
    return _habits;
}
-(NSMutableArray *)opens
{
    if(!_opens)
    {
        _opens = [NSMutableArray array];
    }
    return _opens;
}
-(NSMutableArray *)recordIDs
{
    if(!_recordIDs)
    {
        _recordIDs = [NSMutableArray array];
    }
    return _recordIDs;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNaviBarTitle:@"系统设置"];
    self.automaticallyAdjustsScrollViewInsets = NO;

    self.tableView.tableFooterView = [UIView new];
    [self sendRequest];

    self.tableView.allowsSelection = NO;

    
}
-(void)sendRequest
{
    NSString *url = [NSString stringWithFormat:@"%@Cloud/user_habit.aspx",[IOManager httpAddr]];
    NSString *auothorToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"];
    if (auothorToken) {
        NSDictionary *dict = @{@"token":auothorToken,@"optype":[NSNumber numberWithInteger:0]};
    HttpManager *http=[HttpManager defaultManager];
    http.delegate = self;
    http.tag = 1;
    [http sendPost:url param:dict];
    }
}
-(void)httpHandler:(id)responseObject tag:(int)tag
{
    if(tag == 1)
    {
        if([responseObject[@"result"] intValue]==0)
        {
//            NSDictionary *messageInfo = responseObject[@"user_habit_list"];
            NSArray *listMsg = responseObject[@"user_habit_list"];
            for(NSDictionary *userDetail in listMsg)
            {
    
                [self.habits addObject:userDetail[@"hobit_name"]];
                [self.opens addObject:userDetail[@"isopen"]];
                [self.recordIDs addObject:userDetail[@"userhabit_id"]];
            }
            [self.tableView reloadData];
        }else{
            [MBProgressHUD showError:responseObject[@"Msg"]];
        }

    }else if(tag == 2 || tag == 3)
    {
         if([responseObject[@"result"] intValue]==0)
         {
             [MBProgressHUD showSuccess:@"设置成功"];
         }else{
             [MBProgressHUD showError:responseObject[@"Msg"]];
         }
    }
}
-(void)viewDidLayoutSubviews {
    
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
        
    }
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)])  {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
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
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.habits.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SystemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.title.text = self.habits[indexPath.row];
    cell.backgroundColor = [UIColor colorWithRed:29/255.0 green:30/255.0 blue:34/255.0 alpha:1];
    NSNumber *openNum = self.opens[indexPath.row];
    cell.sysyTemSwitchBtn.selected = !cell.sysyTemSwitchBtn.selected;
    if([openNum intValue] == 1)
    {
        cell.turnSwitch.on = YES;
        cell.sysyTemSwitchBtn.selected = YES;
        [cell.sysyTemSwitchBtn setBackgroundImage:[UIImage imageNamed:@"dvd_btn_switch_on"] forState:UIControlStateNormal];
    }else{
        cell.turnSwitch.on = NO;
        cell.sysyTemSwitchBtn.selected = NO;
        [cell.sysyTemSwitchBtn setBackgroundImage:[UIImage imageNamed:@"dvd_btn_switch_off"] forState:UIControlStateNormal];
    }
    cell.sysyTemSwitchBtn.tag = [self.recordIDs[indexPath.row] integerValue];
    cell.turnSwitch.tag = [self.recordIDs[indexPath.row] integerValue];
    [cell.turnSwitch addTarget:self action:@selector(changSwithchValue:) forControlEvents:UIControlEventValueChanged];
    [cell.sysyTemSwitchBtn addTarget:self action:@selector(changSwithchValue:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
    
}

-(void)changSwithchValue:(UIButton *)sender
{
    sender.selected = !sender.selected;
    
    if(sender.selected)
    {
        [sender setBackgroundImage:[UIImage imageNamed:@"dvd_btn_switch_on"] forState:UIControlStateNormal];
        [self sendRequsetForChangSwitch:[NSNumber numberWithInt:1] withTag:2 andSwitch:sender];
    }else{
        [sender setBackgroundImage:[UIImage imageNamed:@"dvd_btn_switch_off"] forState:UIControlStateNormal];
        [self sendRequsetForChangSwitch:[NSNumber numberWithInt:2] withTag:3 andSwitch:sender];
    }
}
-(void)sendRequsetForChangSwitch:(NSNumber *)num withTag:(int)tag andSwitch:(UIButton *)sender
{
    NSString *url = [NSString stringWithFormat:@"%@Cloud/user_habit.aspx",[IOManager httpAddr]];
    NSString *auothorToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"];
    NSNumber *recordID = [NSNumber numberWithInteger:sender.tag];
    if (auothorToken) {
    NSDictionary *dict = @{@"token":auothorToken,@"isopen":num,@"userhabit_id":recordID,@"optype":[NSNumber numberWithInteger:1]};
    HttpManager *http=[HttpManager defaultManager];
    http.delegate = self;
    http.tag = tag;
    [http sendPost:url param:dict];
    }
}
//- (IBAction)clickRetunBtn:(id)sender {
//    [self.navigationController popViewControllerAnimated:NO];
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
