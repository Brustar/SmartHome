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
#import "FSLineChart.h"
#import "UIColor+FSPalette.h"
#import "IphoneRoomView.h"
#import "SQLManager.h"


@interface MySubEnergyVC ()<UITableViewDelegate,UITableViewDataSource,IphoneRoomViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *TimerView;
@property (weak, nonatomic) IBOutlet UIView *deviceTitleLabel;
@property (weak, nonatomic) IBOutlet FSLineChart *chartWithDates;
@property (weak, nonatomic) IBOutlet UILabel *IntradayLable;//当天的日期
@property (weak, nonatomic) IBOutlet UILabel *YearLabel;//年
@property (nonatomic, assign) int roomIndex;
@property (weak, nonatomic) IBOutlet UILabel *monthLabel;//月
@property (weak, nonatomic) IBOutlet UIButton *TVEnergy;//电视能耗
@property (weak, nonatomic) IBOutlet UIButton *AireEnergy;//空调能耗
@property (weak, nonatomic) IBOutlet UIButton *monthBtn;//当月
@property (weak, nonatomic) IBOutlet UIButton *historyBtn;//历史
@property (weak, nonatomic) IBOutlet IphoneRoomView *roomView;
@property (nonatomic,strong) NSMutableArray * enameArr;
@property (nonatomic,strong) NSMutableArray * minute_timeArr;
@property (nonatomic,strong) NSMutableArray * eidArr;
@property (nonatomic,strong) NSMutableArray * historyArr;
@property(nonatomic,strong)UIButton *clickButton;
@property(nonatomic,strong)UIButton *selectedButton;

@end

@implementation MySubEnergyVC
-(NSMutableArray *)historyArr
{
    if (!_historyArr) {
        _historyArr = [NSMutableArray array];
    }

    return _historyArr;
}
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
    [self setNaviBarTitle:@"智能账单"];
    [self.monthBtn addTarget:self action:@selector(save:) forControlEvents:UIControlEventTouchUpInside];
    [self.historyBtn addTarget:self action:@selector(save:) forControlEvents:UIControlEventTouchUpInside];
//    [self.TVEnergy addTarget:self action:@selector(save:) forControlEvents:UIControlEventTouchUpInside];
//    [self.AireEnergy addTarget:self action:@selector(save:) forControlEvents:UIControlEventTouchUpInside];
     self.TimerView.backgroundColor = [UIColor colorWithRed:29/255.0 green:30/255.0 blue:34/255.0 alpha:1];
     self.deviceTitleLabel.backgroundColor = [UIColor colorWithRed:29/255.0 green:30/255.0 blue:34/255.0 alpha:1];
      DeviceInfo *device = [DeviceInfo defaultManager];
    if ([device.db isEqualToString:SMART_DB]) {
//        [self sendRequestToGetEenrgy];
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
                [self loadChartWithDates];//下面的曲线图
                 [self setTime];
                 self.tableView.allowsSelection = NO;
                 [self setUpRoomView];
        
    
}
-(void)setUpRoomView
{
    NSMutableArray * arr =[NSMutableArray arrayWithObjects:@"空调",@"网络电视", nil];
    self.roomView.dataArray =arr;
    self.roomView.delegate = self;
  
    [self.roomView setSelectButton:0];
    if ([arr count]>0) {
        [self iphoneRoomView:self.roomView didSelectButton:0];
    }
}

- (void)iphoneRoomView:(UIView *)view didSelectButton:(int)index
{
    self.roomIndex = index;
    if (index == 0) {
        
         [self sendRequestToGetEenrgy];
        
    }else {
        
        
    }
    
}

-(void)setTime
{

    //获取系统时间
    NSDate * senddate=[NSDate date];
    
    NSDateFormatter *dateformatter=[[NSDateFormatter alloc] init];
    
    [dateformatter setDateFormat:@"HH:mm"];
    
    NSString * locationString=[dateformatter stringFromDate:senddate];
    
    NSLog(@"-------%@",locationString);
    NSCalendar * cal=[NSCalendar currentCalendar];
    NSUInteger unitFlags=NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit;
    NSDateComponents * conponent= [cal components:unitFlags fromDate:senddate];
    NSInteger year=[conponent year];
    NSInteger month=[conponent month];
    NSInteger day=[conponent day];
    _YearLabel.text = [NSString stringWithFormat:@"%ld年",year];
    _monthLabel.text = [NSString stringWithFormat:@"%ld月",month];
    _IntradayLable.text = [NSString stringWithFormat:@"%ld日",day];
    [_monthBtn setTitle:[NSString stringWithFormat:@"%ld月",month] forState:UIControlStateNormal];
    

}
#pragma mark - Setting up the chart

- (void)loadChartWithDates {
    
//    NSMutableArray* chartData = [NSMutableArray arrayWithCapacity:7];
//    for(int i=0;i<7;i++) {
//        chartData[i] = [NSNumber numberWithFloat: (float)i / 30.0f + (float)(rand() % 100) / 100.0f];
//    }
    NSArray * chartData = @[@"0",@"50",@"100",@"150",@"200",@"250",@"300"];
    
    NSArray* months = @[@"01", @"05", @"10", @"15", @"20", @"25", @"30"];
    
    // Setting up the line chart
    _chartWithDates.verticalGridStep = 7;
    _chartWithDates.horizontalGridStep = 6;
    _chartWithDates.fillColor = nil;
    _chartWithDates.displayDataPoint = YES;
    _chartWithDates.dataPointColor = [UIColor whiteColor];
    _chartWithDates.dataPointBackgroundColor = [UIColor whiteColor];
    _chartWithDates.dataPointRadius = 3;
    _chartWithDates.color = [_chartWithDates.dataPointColor colorWithAlphaComponent:0.3];
    _chartWithDates.valueLabelPosition = ValueLabelLeft;
    
    _chartWithDates.labelForIndex = ^(NSUInteger item) {
        return months[item];
    };
    _chartWithDates.labelForValue = ^(CGFloat value) {
        return [NSString stringWithFormat:@"%.02f", value];
    };
    [_chartWithDates setChartData:chartData];//下面的曲线图
}
-(void)sendRequestToGetEenrgy
{
    NSString *url = [NSString stringWithFormat:@"%@Cloud/energy_list.aspx",[IOManager httpAddr]];
    NSString *authorToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"];
    if (authorToken) {
        NSDictionary *dic = @{@"token":authorToken,@"optype":[NSNumber numberWithInteger:4]};
        HttpManager *http = [HttpManager defaultManager];
        http.delegate = self;
        http.tag =1;
        [http sendPost:url param:dic];
    }
}
-(void)sendHistoryGetEenrgy
{
    NSString *url = [NSString stringWithFormat:@"%@Cloud/energy_list.aspx",[IOManager httpAddr]];
    NSString *authorToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"];
    if (authorToken) {
        NSDictionary *dic = @{@"token":authorToken,@"optype":[NSNumber numberWithInteger:2]};
        HttpManager *http = [HttpManager defaultManager];
        http.delegate = self;
        http.tag =2;
        [http sendPost:url param:dic];
    }
}
-(void)httpHandler:(id)responseObject tag:(int)tag
{
    [self.enameArr removeAllObjects];
    if(tag == 1)
    {
        if([responseObject[@"result"] intValue] == 0)
        {
            NSArray *message = responseObject[@"eq_energy_list"];
            if ([message isKindOfClass:[NSArray class]]) {
                for(NSDictionary *dic in message)
                {
                    NSDictionary *energy = @{@"eid":dic[@"eid"],@"ename":dic[@"ename"],@"today_energy":dic[@"today_energy"],@"month_energy":dic[@"month_energy"]};
                     NSArray * listArr = dic[@"list"];
                    if ([listArr isKindOfClass:[NSArray class]]) {
                        
                        NSDictionary * historYenergy = @{@"time":@"time",@"energy":@"energy"};
                        
                        [self.historyArr addObject:historYenergy];
                    }
                    
                    [self.enameArr addObject:energy];
                    
                }
            }
           
            [self.tableView reloadData];
        }else {
            [MBProgressHUD showError:responseObject[@"Msg"]];
        }
    } if(tag == 2)
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

#pragma mark - Table view data source

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
        cell.backgroundColor = [UIColor colorWithRed:29/255.0 green:30/255.0 blue:34/255.0 alpha:1];
//    cell.backgroundColor = [UIColor clearColor];
        cell.deviceName.text =[NSString stringWithFormat:@"%@", dict[@"ename"]];
    if (dict[@"today_energy"]) {
         cell.DayKWLabel.text = [NSString stringWithFormat:@"%.fwk.h",[dict[@"today_energy"] floatValue]];
    }else{
         cell.DayKWLabel.text = [NSString stringWithFormat:@"%.fwk.h",[dict[@"minute_time"] floatValue]];
    }
    
    if (dict[@"month_energy"]) {
         cell.MonthKWLabel.text = [NSString stringWithFormat:@"%.fwk.h",[dict[@"month_energy"] floatValue]];
    }else{
        cell.MonthKWLabel.text = @"0wk.h";
    }
    
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
-(void)save:(UIButton *)sender
{
    if (self.clickButton != sender) {
       [self sendRequestToGetEenrgy];
    }
    if (sender.selected == NO) {
        sender.selected = YES;
//       [self sendHistoryGetEenrgy];
        [self changeClickButton:sender];
    }
      self.clickButton = sender;
}
-(void)changeClickButton:(UIButton *)sender{
    
    self.selectedButton.selected = NO;
    self.selectedButton = sender;
    sender.selected = YES;
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
