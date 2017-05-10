//
//  SelectRoomViewController.m
//  SmartHome
//
//  Created by KobeBryant on 2017/5/9.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "SelectRoomViewController.h"

@interface SelectRoomViewController ()

@end

@implementation SelectRoomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNaviBarTitle:@"选择房间"];

    _roomTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, UI_SCREEN_WIDTH, UI_SCREEN_HEIGHT-64) style:UITableViewStylePlain];
    _roomTableView.dataSource = self;
    _roomTableView.delegate = self;
    _roomTableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
    _roomTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _roomTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_roomTableView];
    
    _roomArray = [NSMutableArray array];
    
    NSArray *array = [SQLManager getAllRoomsInfoWithoutIsAll];
    if (array.count >0) {
        [_roomArray addObjectsFromArray:array];
        [_roomTableView reloadData];
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _roomArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.5f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    if (section == _roomArray.count-1) {
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
    if (section == _roomArray.count-1) {
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
    Room *info = _roomArray[indexPath.section];
    cell.textLabel.text = info.rName;
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Room *info = _roomArray[indexPath.section];
    SelectDevicesOfRoomViewController *vc = [[SelectDevicesOfRoomViewController alloc] init];
    vc.roomID = info.rId;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
