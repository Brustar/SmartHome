//
//  DeviceListTimeVC.m
//  SmartHome
//
//  Created by zhaona on 2017/1/9.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "DeviceListTimeVC.h"
#import "IphoneAddSceneController.h"


@interface DeviceListTimeVC ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation DeviceListTimeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initDataSource];
    self.title = @"定时器";
    UIBarButtonItem *listItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"UO23"] style:UIBarButtonItemStylePlain target:self action:@selector(selectedDevice:)];
//    UIBarButtonItem *editItem = [[UIBarButtonItem alloc]initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(clickEditBtn:)];
    self.navigationItem.rightBarButtonItem = listItem;
//    self.navigationItem.leftBarButtonItem = editItem;
    UIView *view = [[UIView alloc] init];
    [view setBackgroundColor:[UIColor clearColor]];
    self.tableView.tableFooterView = view;
    
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

-(void)selectedDevice:(UIBarButtonItem *)bbi
{
    UIStoryboard * storyBoard = [UIStoryboard storyboardWithName:@"iPhone" bundle:nil];
    IphoneAddSceneController * addSceneVC = [storyBoard instantiateViewControllerWithIdentifier:@"DeviceListTimeVC"];
    
    [self.navigationController pushViewController:addSceneVC animated:YES];
    

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 60, 20)];
    title.text = @"设备";
    return title;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.timerList.count;
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
