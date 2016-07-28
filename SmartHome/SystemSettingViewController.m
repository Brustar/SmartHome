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
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"使用习惯";
    self.automaticallyAdjustsScrollViewInsets = NO;
    UIBarButtonItem *returnItem = [[UIBarButtonItem alloc]initWithTitle:@"设置" style:UIBarButtonItemStylePlain target:self action:@selector(clickRetunBtn:)];
    self.navigationItem.leftBarButtonItem = returnItem;

    // Do any additional setup after loading the view.
    //self.titles = @[@"开启向导",@"开启每日提示",@"开启智能过滤",@"全部场景静音"];
    self.tableView.tableFooterView = [UIView new];
    [self sendRequest];
}
-(void)sendRequest
{
    NSString *url = [NSString stringWithFormat:@"%@GetUserHabit.aspx",[IOManager httpAddr]];
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
            NSString *names = userDetail[@"name"];
            NSString *isOpens = userDetail[@"IsOpen"];
            [self.habits addObject:names];
            [self.opens addObject:isOpens];
        }
        [self.tableView reloadData];
    }else{
        [MBProgressHUD showError:responseObject[@"Msg"]];
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
    NSString *str = self.opens[indexPath.row];
    if([str isEqualToString:@"1"])
    {
        cell.turnSwitch.on = YES;
    }else{
        cell.turnSwitch.on = NO;
    }
    return cell;
    
}
- (IBAction)clickRetunBtn:(id)sender {
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
