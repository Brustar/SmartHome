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
@property (nonatomic,strong) NSMutableArray * devicesData;
@property (nonatomic,strong) NSMutableArray *chartData;
@property(nonatomic,strong)UIButton *clickButton;
@property(nonatomic,strong)UIButton *selectedButton;

@end

@implementation MySubEnergyVC

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
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self adjustNaviBarFrameForSplitView];
        [self adjustTitleFrameForSplitView];
        [self setNaviBarLeftBtn:nil];
    }
    [self sendRequestToGetEenrgy];
    self.TimerView.backgroundColor = [UIColor colorWithRed:29/255.0 green:30/255.0 blue:34/255.0 alpha:1];
    self.deviceTitleLabel.backgroundColor = [UIColor colorWithRed:29/255.0 green:30/255.0 blue:34/255.0 alpha:1];

    UIView *view = [[UIView alloc] init];
    [view setBackgroundColor:[UIColor clearColor]];
    self.tableView.tableFooterView = view;
    
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
}

- (void)iphoneRoomView:(UIView *)view didSelectButton:(int)index
{
    self.roomIndex = index;
    
    if (self.devicesData.count > index) {
          _chartWithDates.hidden = NO;
          [self loadChartWithDates:self.devicesData[index]];//下面的曲线图
        
    }else{
           _chartWithDates.hidden = YES;
         [MBProgressHUD showSuccess:@"暂无此设备的数据"];
        
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
    NSUInteger unitFlags=NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear;
    NSDateComponents * conponent= [cal components:unitFlags fromDate:senddate];
    NSInteger year=[conponent year];
    NSInteger month=[conponent month];
    NSInteger day=[conponent day];
    _YearLabel.text = [NSString stringWithFormat:@"%ld年",(long)year];
    _monthLabel.text = [NSString stringWithFormat:@"%ld月",(long)month];
    _IntradayLable.text = [NSString stringWithFormat:@"%ld日",(long)day];
    [_monthBtn setTitle:[NSString stringWithFormat:@"%ld月",(long)month] forState:UIControlStateNormal];
    

}
#pragma mark - Setting up the chart

- (void)loadChartWithDates:(NSArray *)data {
    
     _chartData= [NSMutableArray new];
    
    NSMutableArray *months = [NSMutableArray new];
    for(NSDictionary *obj in data)
    {
        [_chartData addObject:obj[@"energy"]];
        NSString *day = [[obj[@"time"] description] substringFromIndex:8];
        [months addObject:day];
    }
    // Setting up the line chart
    _chartWithDates.verticalGridStep = 8;
    _chartWithDates.horizontalGridStep = (int)[months count];
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
    [_chartWithDates setChartData:_chartData];//下面的曲线图
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

-(void)httpHandler:(id)responseObject tag:(int)tag
{
    [self.enameArr removeAllObjects];
    
    if(tag == 1)
    {
        if([responseObject[@"result"] intValue] == 0)
        {
            NSArray *message = responseObject[@"eq_energy_list"];
            self.devicesData =[NSMutableArray new];
            if ([message isKindOfClass:[NSArray class]]) {
                for(NSDictionary *dic in message)
                {
                    NSDictionary *energy = @{@"eid":dic[@"eid"],@"ename":dic[@"ename"],@"today_energy":dic[@"today_energy"],@"month_energy":dic[@"month_energy"]};
                    NSArray * listArr = dic[@"list"];
                    [self.enameArr addObject:energy];
                    
                    [self.devicesData addObject:listArr];
                    [self iphoneRoomView:self.roomView didSelectButton:0];
                }
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

        cell.deviceName.text =[NSString stringWithFormat:@"%@", dict[@"ename"]];
    if (dict[@"today_energy"]) {
         cell.DayKWLabel.text = [NSString stringWithFormat:@"%.f",[dict[@"today_energy"] floatValue]];
    }else{
         cell.DayKWLabel.text = [NSString stringWithFormat:@"%.f",[dict[@"minute_time"] floatValue]];
    }
    
    if (dict[@"month_energy"]) {
         cell.MonthKWLabel.text = [NSString stringWithFormat:@"%.f",[dict[@"month_energy"] floatValue]];
    }else{
        cell.MonthKWLabel.text = @"0";
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
