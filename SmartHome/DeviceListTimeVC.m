//
//  DeviceListTimeVC.m
//  SmartHome
//
//  Created by zhaona on 2017/1/9.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "DeviceListTimeVC.h"
#import "IphoneAddSceneController.h"
#import "IphoneNewAddSceneVC.h"
#import "SQLManager.h"
#import "Room.h"

@interface DeviceListTimeVC ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic,strong) UIButton * naviRightBtn;
@property (nonatomic,strong) NSArray * roomList;
@property (nonatomic,strong) Room * room;

@end

@implementation DeviceListTimeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initDataSource];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self setupNaviBar];
    [self fetchDeviceTimerList];
}
- (void)setupNaviBar {
    [self setNaviBarTitle:@"定时器"]; //设置标题
    _naviRightBtn = [CustomNaviBarView createImgNaviBarBtnByImgNormal:@"deviceTimeadd" imgHighlight:@"deviceTimeadd" target:self action:@selector(rightBtnClicked:)];
    [self setNaviBarRightBtn:_naviRightBtn];
}
-(void)rightBtnClicked:(UIButton *)btn
{
    SelectRoomViewController *vc = [[SelectRoomViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];

}
- (void)initDataSource {
    _timerList = [NSMutableArray array];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return _timerList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDictionary *roomDict = _timerList[section];
    if (roomDict && [roomDict isKindOfClass:[NSDictionary class]]) {
        NSArray *scheduleList = roomDict[@"schedule_list"];
        if (scheduleList && [scheduleList isKindOfClass:[NSArray class]]) {
            return scheduleList.count;
        }
    }
   
    return 0 ;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 40.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 59.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UI_SCREEN_WIDTH, 40)];
    view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UI_SCREEN_WIDTH, 0.5)];
    line.backgroundColor = [UIColor whiteColor];
    [view addSubview:line];
    
    UILabel *roomNameLabel = [[UILabel alloc] init];
    roomNameLabel.frame = CGRectMake(20, 10, 100, 20);
    roomNameLabel.textAlignment = NSTextAlignmentLeft;
    roomNameLabel.textColor = [UIColor whiteColor];
    [view addSubview:roomNameLabel];
    
    NSDictionary *roomDict = _timerList[section];
    if (roomDict && [roomDict isKindOfClass:[NSDictionary class]]) {
       [roomNameLabel setText:roomDict[@"room_name"]];
        
    }

    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DeviceTimerCell * cell = [tableView dequeueReusableCellWithIdentifier:@"deviceTimerCell" forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[DeviceTimerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"deviceTimerCell"];
    }
    
    cell.delegate = self;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSDictionary *roomDict = _timerList[indexPath.section];
    if (roomDict && [roomDict isKindOfClass:[NSDictionary class]]) {
        NSArray *scheduleList = roomDict[@"schedule_list"];
        if (scheduleList && [scheduleList isKindOfClass:[NSArray class]]) {
            NSDictionary *timerDict = scheduleList[indexPath.row];
            if (timerDict && [timerDict isKindOfClass:[NSDictionary class]]) {
                DeviceTimerInfo *info = [[DeviceTimerInfo alloc] init];
                info.timerID = [timerDict[@"schedule_id"] integerValue];
                info.startTime = timerDict[@"starttime"];
                info.endTime = timerDict[@"endtime"];
                info.repetition = timerDict[@"week_value"];
                info.isActive = [timerDict[@"isactive"] integerValue];
                info.deviceName = timerDict[@"ename"];
                info.htype = timerDict[@"htype"];
                
                [cell setInfo:info];
                
            }
        }
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

// 设置 哪一行的编辑按钮 状态 指定编辑样式
- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

// 判断点击按钮的样式 来去做添加 或删除
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 删除的操作
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        NSDictionary *roomDict = _timerList[indexPath.section];
        if (roomDict && [roomDict isKindOfClass:[NSDictionary class]]) {
            NSArray *scheduleList = roomDict[@"schedule_list"];
            if (scheduleList && [scheduleList isKindOfClass:[NSArray class]]) {
                NSDictionary *timerDict = scheduleList[indexPath.row];
                if (timerDict && [timerDict isKindOfClass:[NSDictionary class]]) {
                    
                    [self deleteDeviceTimerWithTimerId:[timerDict[@"schedule_id"] integerValue]];
                    
                }
            }
        }
    }
}

- (void)onDeviceTimerBtnClicked:(UIButton *)sender {
    _currentBtn = sender;
    _currentActive = sender.selected;
    [self deviceTimerOperationWithTimerId:sender.tag isActive:sender.selected];
}

- (void)deleteDeviceTimerWithTimerId:(NSInteger)timerId {
    NSString *url = [NSString stringWithFormat:@"%@Cloud/eq_timing.aspx",[IOManager httpAddr]];
    NSString *auothorToken = [UD objectForKey:@"AuthorToken"];
    
    if (auothorToken.length >0) {
        NSDictionary *dict = @{@"token":auothorToken,
                               @"optype":@(3),
                               @"scheduleid":@(timerId)
                               };
        HttpManager *http = [HttpManager defaultManager];
        http.delegate = self;
        http.tag = 3;
        [http sendPost:url param:dict];
    }
}

- (void)deviceTimerOperationWithTimerId:(NSInteger)timerId isActive:(NSInteger)active {
    NSString *url = [NSString stringWithFormat:@"%@Cloud/eq_timing.aspx",[IOManager httpAddr]];
    NSString *auothorToken = [UD objectForKey:@"AuthorToken"];
    
    if (auothorToken.length >0) {
        NSDictionary *dict = @{@"token":auothorToken,
                               @"optype":@(4),
                               @"scheduleid":@(timerId),
                               @"isactive":@(active)
                               };
        HttpManager *http = [HttpManager defaultManager];
        http.delegate = self;
        http.tag = 2;
        [http sendPost:url param:dict];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)fetchDeviceTimerList {
    NSString *url = [NSString stringWithFormat:@"%@Cloud/eq_timing.aspx",[IOManager httpAddr]];
    NSString *auothorToken = [UD objectForKey:@"AuthorToken"];
    
    if (auothorToken.length >0) {
        NSDictionary *dict = @{@"token":auothorToken,
                               @"optype":@(5)
                               };
        HttpManager *http = [HttpManager defaultManager];
        http.delegate = self;
        http.tag = 1;
        [http sendPost:url param:dict];
    }
}

#pragma mark - Http callback
- (void)httpHandler:(id)responseObject tag:(int)tag
{
    if(tag == 1) { //定时器列表
        
        if ([responseObject[@"result"] intValue] == 0) {
            NSArray *roomList = responseObject[@"eq_timing_list"];
            if (roomList && [roomList isKindOfClass:[NSArray class]]) {
                [_timerList removeAllObjects];
                [_timerList addObjectsFromArray:roomList];
                [self.tableView reloadData];
            }
        }
    }else if (tag == 2) { //启动，停止定时器
        if ([responseObject[@"result"] intValue] == 0) {
            [MBProgressHUD showSuccess:responseObject[@"msg"]];
        }else {
            [MBProgressHUD showError:responseObject[@"msg"]];
            if (_currentActive == 1) {
               [_currentBtn setBackgroundImage:[UIImage imageNamed:@"dvd_btn_switch_off"] forState:UIControlStateNormal];
            }else {
               [_currentBtn setBackgroundImage:[UIImage imageNamed:@"dvd_btn_switch_on"] forState:UIControlStateNormal];
            }
        }
    }else if (tag == 3) { //删除
        if ([responseObject[@"result"] intValue] == 0) {
            [MBProgressHUD showSuccess:responseObject[@"msg"]];
            [self fetchDeviceTimerList];
        }else {
            [MBProgressHUD showError:responseObject[@"msg"]];
        }
    }
}

@end
