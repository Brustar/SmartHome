//
//  FamilyDynamicDeviceAdjustViewController.m
//  SmartHome
//
//  Created by KobeBryant on 2017/5/7.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "FamilyDynamicDeviceAdjustViewController.h"

@interface FamilyDynamicDeviceAdjustViewController ()

@end

@implementation FamilyDynamicDeviceAdjustViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    [self getLights];//获取所有灯
}

- (void)initUI {
    [self setNaviBarTitle:self.roomName];
    [self setupMonitorView];
    [self.deviceTableView registerNib:[UINib nibWithNibName:@"NewLightCell" bundle:nil] forCellReuseIdentifier:@"NewLightCell"];//灯光
    self.monitorView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
    self.deviceTableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
    self.deviceTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.deviceTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)getLights {
    //所有设备ID
    NSArray *devIDArray = [SQLManager deviceIdsByRoomId:(int)self.roomID];   
    _deviceIDArray = [NSMutableArray array];
    _lightArray = [NSMutableArray array];
    if (devIDArray) {
        [_deviceIDArray addObjectsFromArray:devIDArray];
    }
    
    for(int i = 0; i <_deviceIDArray.count; i++)
    {
        //比较设备大类，进行分组
        NSString *deviceTypeName = [SQLManager deviceTypeNameByDeviceID:[_deviceIDArray[i] intValue]];
        if ([deviceTypeName isEqualToString:LightType]) {
            [_lightArray addObject:_deviceIDArray[i]];
        }
    }
    
    [self.deviceTableView reloadData];
}

- (void)setupMonitorView {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Family" bundle:nil];
    MonitorViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"MonitorVC"];
    vc.cameraURL = self.cameraURL;
    vc.deviceID = self.deviceID;
    vc.view.frame = CGRectMake(0, 0, FW(self.monitorView), FH(self.monitorView));
    [self.monitorView addSubview:vc.view];
    [self addChildViewController:vc];
    vc.adjustBtn.hidden = YES;
    vc.roomNameLabel.hidden = YES;
    vc.fullScreenBtn.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _lightArray.count;//灯光
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
        NewLightCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NewLightCell" forIndexPath:indexPath];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.AddLightBtn.hidden = YES;
        cell.LightConstraint.constant = 10;
        Device *device = [SQLManager getDeviceWithDeviceID:[_lightArray[indexPath.row] intValue]];
        cell.NewLightNameLabel.text = device.name;
        cell.NewLightSlider.continuous = NO;
        cell.deviceid = _lightArray[indexPath.row];
        return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

@end
