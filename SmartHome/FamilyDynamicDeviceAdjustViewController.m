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
    [self fetchDevicesStatus];//灯的状态
}

- (void)initUI {
    [self setNaviBarTitle:self.roomName];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self adjustNaviBarFrameForSplitView];
        [self adjustTitleFrameForSplitView];
    }
    [self setupMonitorView];
    [self.deviceTableView registerNib:[UINib nibWithNibName:@"NewLightCell" bundle:nil] forCellReuseIdentifier:@"NewLightCell"];//灯光
    [self.deviceTableView registerNib:[UINib nibWithNibName:@"NewColourCell" bundle:nil] forCellReuseIdentifier:@"NewColourCell"];//调色灯
    
    self.monitorView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
    self.deviceTableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
    self.deviceTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.deviceTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    if (ON_IPAD) {
        self.monitorViewHeight.constant = 520;
        self.deviceTableTop.constant = 570;
    }
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
        NSString *deviceTypeName = [SQLManager getSubTypeNameByDeviceID:[_deviceIDArray[i] intValue]];
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
    Device *device = [SQLManager getDeviceWithDeviceID:[_lightArray[indexPath.row] intValue]];
    
    
    if (device.hTypeId == 1) { //开关灯(不需要Slider)
        NewColourCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NewColourCell" forIndexPath:indexPath];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.AddColourLightBtn.hidden = YES;
        cell.ColourLightConstraint.constant = 10;
        cell.colourNameLabel.text = device.name;
        cell.colourSlider.continuous = NO;
        cell.colourSlider.hidden = YES;
        cell.supimageView.hidden = YES;
        cell.lowImageView.hidden = YES;
        cell.highImageView.hidden = YES;
        cell.deviceid = _lightArray[indexPath.row];
        cell.colourBtn.selected = device.power;//开关状态
        return cell;
    }else if (device.hTypeId == 2) { //调光灯
        NewLightCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NewLightCell" forIndexPath:indexPath];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.AddLightBtn.hidden = YES;
        cell.LightConstraint.constant = 10;
        cell.NewLightNameLabel.text = device.name;
        cell.NewLightSlider.continuous = NO;
        cell.NewLightSlider.hidden = NO;
        cell.deviceid = _lightArray[indexPath.row];
        cell.NewLightPowerBtn.selected = device.power;//开关状态
        cell.NewLightSlider.value = (float)device.bright/100.0f;//亮度状态
        return cell;
    }else if (device.hTypeId == 3) { //调色灯
        NewColourCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NewColourCell" forIndexPath:indexPath];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.AddColourLightBtn.hidden = YES;
        cell.ColourLightConstraint.constant = 10;
        cell.colourNameLabel.text = device.name;
        cell.colourSlider.continuous = NO;
        cell.colourSlider.hidden = NO;
        cell.supimageView.hidden = NO;
        cell.lowImageView.hidden = NO;
        cell.highImageView.hidden = NO;
        cell.deviceid = _lightArray[indexPath.row];
        cell.colourBtn.selected = device.power;//开关状态
        //颜色状态暂不做，slider不好控制
        return cell;
    }
    
    return [UITableViewCell new];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

#pragma mark - 获取房间设备状态
- (void)fetchDevicesStatus {
    NSString *url = [NSString stringWithFormat:@"%@Cloud/equipment_status_list.aspx",[IOManager httpAddr]];
    NSString *auothorToken = [UD objectForKey:@"AuthorToken"];
    
    if (auothorToken.length >0) {
        NSDictionary *dict = @{@"token":auothorToken,
                               @"optype":@(2),
                               @"roomid":@(self.roomID)
                               };
        HttpManager *http = [HttpManager defaultManager];
        http.delegate = self;
        http.tag = 1;
        [http sendPost:url param:dict showProgressHUD:NO];
    }
    
}

#pragma mark - Http Delegate
- (void)httpHandler:(id)responseObject tag:(int)tag
{
    if (tag == 1) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSLog(@"responseObject:%@", responseObject);
            if ([responseObject[@"result"] integerValue] == 0) {
                NSArray *deviceArray = responseObject[@"equipment_status_list"];
                
                if ([deviceArray isKindOfClass:[NSArray class]] && deviceArray.count >0 ) {
                    for(NSDictionary *device in deviceArray) {
                        if ([device isKindOfClass:[NSDictionary class]]) {
                            Device *devInfo = [[Device alloc] init];
                            devInfo.eID = [device[@"equipmentid"] intValue];
                            devInfo.hTypeId = [device[@"htype"] integerValue];
                            devInfo.power = [device[@"status"] integerValue];
                            devInfo.bright = [device[@"bright"] integerValue];
                            devInfo.color = device[@"color"];
                            devInfo.position = [device[@"position"] integerValue];
                            devInfo.temperature = [device[@"temperature"] integerValue];
                            devInfo.fanspeed = [device[@"fanspeed"] integerValue];
                            devInfo.air_model = [device[@"model"] integerValue];
                            
                            [SQLManager updateDeviceStatus:devInfo];
                        }
                    }
                }
                
                //刷新UI
                [self.deviceTableView reloadData];
                
                
                
                
            }else {
                NSLog(@"设备状态获取失败！");
            }
        }else {
            NSLog(@"设备状态获取失败！");
        }
    }
}

@end
