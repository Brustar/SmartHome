//
//  SelectDevicesOfRoomViewController.m
//  SmartHome
//
//  Created by KobeBryant on 2017/5/9.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "SelectDevicesOfRoomViewController.h"

@interface SelectDevicesOfRoomViewController ()

@end

@implementation SelectDevicesOfRoomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    [self initDataSource];
}

- (void)initUI {
    [self setNaviBarTitle:@"选择设备"];
    
    _deviceTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, UI_SCREEN_WIDTH, UI_SCREEN_HEIGHT-64) style:UITableViewStylePlain];
    _deviceTableView.dataSource = self;
    _deviceTableView.delegate = self;
    _deviceTableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
    _deviceTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _deviceTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_deviceTableView];
}

- (void)initDataSource {
    _deviceArray = [NSMutableArray array];
    NSArray *array = [SQLManager getAllDevicesInfo:(int)self.roomID];
    if (array && array.count >0) {
        [_deviceArray addObjectsFromArray:array];
        
        [_deviceTableView reloadData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _deviceArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.5f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    if (section == _deviceArray.count-1) {
        return 0.5f;
    }
    
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UI_SCREEN_WIDTH, 0.5)];
    header.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"login_line"]];
    
    return header;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == _deviceArray.count-1) {
        UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UI_SCREEN_WIDTH, 0.5)];
        footer.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"login_line"]];
        
        return footer;
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"deviceTimerCellIdentifier";
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor colorWithRed:30.0/255.0 green:29.0/255.0 blue:34.0/255.0 alpha:1.0];
    Device *info = _deviceArray[indexPath.section];
    cell.textLabel.text = info.name;
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Device *info = _deviceArray[indexPath.section];
    DeviceTimerSettingViewController *vc = [[DeviceTimerSettingViewController alloc] init];
    vc.device = info;
    vc.roomID = self.roomID;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
