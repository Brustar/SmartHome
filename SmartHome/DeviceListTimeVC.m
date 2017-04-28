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

@end

@implementation DeviceListTimeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initDataSource];
    self.title = @"定时器";

    self.roomList = [SQLManager getAllRoomsInfo];
    
    UIView *view = [[UIView alloc] init];
    [view setBackgroundColor:[UIColor clearColor]];
    self.tableView.tableFooterView = view;
    [self setupNaviBar];
    
}
- (void)setupNaviBar {
    [self setNaviBarTitle:@"设备定时列表"]; //设置标题
    
    _naviRightBtn = [CustomNaviBarView createImgNaviBarBtnByImgNormal:@"deviceTimeadd" imgHighlight:@"deviceTimeadd" target:self action:@selector(rightBtnClicked:)];

    [self setNaviBarRightBtn:_naviRightBtn];
}
-(void)rightBtnClicked:(UIButton *)btn
{
    UIStoryboard * SceneStoryBoard = [UIStoryboard storyboardWithName:@"Scene" bundle:nil];
    IphoneNewAddSceneVC * iphoneNewAddScene = [SceneStoryBoard instantiateViewControllerWithIdentifier:@"IphoneNewAddSceneVC"];
    [self.navigationController pushViewController:iphoneNewAddScene animated:YES];
    
    

}
- (void)initDataSource {
    self.timerList = [[NSMutableArray alloc] init];
    DeviceInfo *device = [DeviceInfo defaultManager];
    if ([device.db isEqualToString:SMART_DB]) {
        
    }else {
        NSDictionary *plistDict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DeviceTimerList" ofType:@"plist"]];
        NSArray *arr = plistDict[@"timer_list"];
        if ([arr isKindOfClass:[NSArray class]] && arr.count >0) {
            for(NSDictionary *timerInfo in arr)
            {
                if ([timerInfo isKindOfClass:[NSDictionary class]]) {
                    DeviceTimerInfo *deviceTimerInfo = [[DeviceTimerInfo alloc] init];
                    deviceTimerInfo.deviceName = timerInfo[@"deviceName"];
                    deviceTimerInfo.deviceValue = timerInfo[@"deviceValue"];
                    deviceTimerInfo.repetition = timerInfo[@"repetition"];
                    deviceTimerInfo.startTime = timerInfo[@"starttime"];
                    deviceTimerInfo.endTime = timerInfo[@"endtime"];
                    deviceTimerInfo.status = timerInfo[@"status"];
                    [self.timerList addObject:deviceTimerInfo];
                }
                
            }
        }
        
        [self.tableView reloadData];
    }
}
//组
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return self.roomList.count;
}
//行
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.timerList.count;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    Room * room = self.roomList[section];
    NSString * str = room.rName;

    return str;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 40.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (self.tableView != tableView) {
        return nil;
    }
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 40)];
    view.backgroundColor = [UIColor colorWithRed:29/255.0 green:30/255.0 blue:34/255.0 alpha:1];
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(20, 0, 100, 30);
    Room * room = self.roomList[section];
    label.textAlignment = NSTextAlignmentLeft;
    label.textColor = [UIColor whiteColor];
    [label setText:room.rName];
    [view addSubview:label];
    
    //上显示线
    
    UILabel *label1=[[ UILabel alloc ] initWithFrame : CGRectMake ( 0 , - 1 , view. frame . size . width , 1 )];
    
    label1. backgroundColor =[ UIColor whiteColor];
    
    [view addSubview :label1];
    
    //下显示线
    
    UILabel *Xlabel=[[ UILabel alloc ] initWithFrame : CGRectMake ( 0 , view. frame . size . height - 1 , view. frame . size . width , 1 )];
    
    Xlabel. backgroundColor =[ UIColor whiteColor];
    
    [view addSubview :Xlabel];
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DeviceTimerCell * cell = [tableView dequeueReusableCellWithIdentifier:@"deviceTimerCell" forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[DeviceTimerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"deviceTimerCell"];
    }
    
    DeviceTimerInfo *info = [self.timerList objectAtIndex:indexPath.row];
    [cell setInfo:info];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
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
