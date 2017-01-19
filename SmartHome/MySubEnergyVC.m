//
//  MySubEnergyVC.m
//  SmartHome
//
//  Created by zhaona on 2017/1/4.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "MySubEnergyVC.h"
#import "HttpManager.h"
#import "MBProgressHUD+NJ.h"
#import "MySubEnergyCell.h"
#import "ENenViewController.h"

@interface MySubEnergyVC ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic,strong) NSMutableArray * enameArr;
@property (nonatomic,strong) NSMutableArray * minute_timeArr;
@property (nonatomic,strong) NSMutableArray * eidArr;
@end

@implementation MySubEnergyVC
-(NSMutableArray *)eidArr
{
    if (!_eidArr) {
        _eidArr = [NSMutableArray array];
    }
    
    return _eidArr;
}
-(NSMutableArray *)enameArr
{
    if (!_enameArr) {
        _enameArr = [NSMutableArray array];
    }
    
    return _enameArr;
}
-(NSMutableArray *)minute_timeArr
{
    if (!_minute_timeArr) {
        _minute_timeArr = [NSMutableArray array];
    }
    
    return _minute_timeArr;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"我的能耗";
    
    DeviceInfo *device = [DeviceInfo defaultManager];
    if ([device.db isEqualToString:SMART_DB]) {
        [self sendRequestToGetEenrgy];
    }else {
        NSDictionary *plistDict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"energylist" ofType:@"plist"]];
        NSArray *arr = plistDict[@"energy_stat_list"];
        for(NSDictionary *dic in arr)
        {
            NSDictionary *energy = @{@"eid":dic[@"eid"],@"ename":dic[@"ename"],@"minute_time":dic[@"minute_time"]};
            [self.enameArr addObject:energy];
            
        }
        [self.tableView reloadData];
    }
    
    
    UIView *view = [[UIView alloc] init];
    [view setBackgroundColor:[UIColor clearColor]];
    self.tableView.tableFooterView = view;
}
-(void)sendRequestToGetEenrgy
{
    NSString *url = [NSString stringWithFormat:@"%@Cloud/energy_list.aspx",[IOManager httpAddr]];
    NSString *authorToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"];
    if (authorToken) {
        NSDictionary *dic = @{@"token":authorToken,@"optype":[NSNumber numberWithInteger:2]};
        HttpManager *http = [HttpManager defaultManager];
        http.delegate = self;
        http.tag =1;
        [http sendPost:url param:dic];
    }
}
-(void)httpHandler:(id)responseObject tag:(int)tag
{
    if(tag == 1)
    {
        if([responseObject[@"result"] intValue] == 0)
        {
            NSArray *message = responseObject[@"energy_stat_list"];
            for(NSDictionary *dic in message)
            {
                NSDictionary *energy = @{@"eid":dic[@"eid"],@"ename":dic[@"ename"],@"minute_time":dic[@"minute_time"]};
                
                [self.enameArr addObject:energy];
                
            }
            [self.tableView reloadData];
        }else {
            [MBProgressHUD showError:responseObject[@"Msg"]];
        }
    }
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return self.enameArr.count;

}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
     MySubEnergyCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
        NSDictionary * dict = self.enameArr[indexPath.row];
        cell.deviceName.text =[NSString stringWithFormat:@"%@", dict[@"ename"]];
        cell.energyTime.text = [NSString stringWithFormat:@"%.1fhr",[dict[@"minute_time"] floatValue]/60];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UIStoryboard * board = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ENenViewController * VC = [board instantiateViewControllerWithIdentifier:@"ENenViewController"];
      NSDictionary * dict = self.enameArr[indexPath.row];
    VC.eqid = [dict[@"eid"] intValue];
    VC.titleName = dict[@"ename"];
    [self.navigationController pushViewController:VC animated:YES];
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
