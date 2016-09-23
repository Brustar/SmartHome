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
    self.title = @"使用习惯";
    self.automaticallyAdjustsScrollViewInsets = NO;
    UIBarButtonItem *returnItem = [[UIBarButtonItem alloc]initWithTitle:@"设置" style:UIBarButtonItemStylePlain target:self action:@selector(clickRetunBtn:)];
    self.navigationItem.leftBarButtonItem = returnItem;

    self.tableView.tableFooterView = [UIView new];
    [self sendRequest];
}
-(void)sendRequest
{
    NSString *url = [NSString stringWithFormat:@"%@GetUserHabit.aspx",[IOManager httpAddr]];
    NSString *auothorToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"];
    if (auothorToken) {
    NSDictionary *dict = @{@"AuthorToken":auothorToken};
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
        if([responseObject[@"Result"] intValue]==0)
        {
            NSDictionary *messageInfo = responseObject[@"messageInfo"];
            NSArray *listMsg = messageInfo[@"listMessage"];
            for(NSDictionary *userDetail in listMsg)
            {
    
                [self.habits addObject:userDetail[@"name"]];
                [self.opens addObject:userDetail[@"isOpen"]];
                [self.recordIDs addObject:userDetail[@"recordId"]];
            }
            [self.tableView reloadData];
        }else{
            [MBProgressHUD showError:responseObject[@"Msg"]];
        }

    }else if(tag == 2 || tag == 3)
    {
         if([responseObject[@"Result"] intValue]==0)
         {
             [MBProgressHUD showSuccess:@"设置权限成功"];
         }else{
             [MBProgressHUD showError:responseObject[@"Msg"]];
         }
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
    
    NSNumber *openNum = self.opens[indexPath.row];
    if([openNum intValue] == 1)
    {
        cell.turnSwitch.on = YES;
    }else{
        cell.turnSwitch.on = NO;
    }
    cell.turnSwitch.tag = [self.recordIDs[indexPath.row] integerValue];
    [cell.turnSwitch addTarget:self action:@selector(changSwithchValue:) forControlEvents:UIControlEventValueChanged];
    
    
    return cell;
    
}

-(void)changSwithchValue:(UISwitch*)sender
{
    if(sender.isOn)
    {
        [self sendRequsetForChangSwitch:[NSNumber numberWithInt:1] withTag:2 andSwitch:sender];
    }else{
        [self sendRequsetForChangSwitch:[NSNumber numberWithInt:2] withTag:3 andSwitch:sender];
    }
}
-(void)sendRequsetForChangSwitch:(NSNumber *)num withTag:(int)tag andSwitch:(UISwitch *)sender
{
    NSString *url = [NSString stringWithFormat:@"%@UserHobitSetting.aspx",[IOManager httpAddr]];
    NSString *auothorToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"];
    NSNumber *recordID = [NSNumber numberWithInteger:sender.tag];
    if (auothorToken) {
    NSDictionary *dict = @{@"AuthorToken":auothorToken,@"IsOpen":num,@"RecordID":recordID};
    HttpManager *http=[HttpManager defaultManager];
    http.delegate = self;
    http.tag = tag;
    [http sendPost:url param:dict];
    }
}
- (IBAction)clickRetunBtn:(id)sender {
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
