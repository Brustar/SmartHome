//
//  RoomPlaneGraphViewController.m
//  SmartHome
//
//  Created by KobeBryant on 2017/10/11.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "RoomPlaneGraphViewController.h"

@interface RoomPlaneGraphViewController ()

@end

@implementation RoomPlaneGraphViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addNotifications];
    _hostType = [[UD objectForKey:@"HostType"] integerValue];//主机类型 0:Creston  1:C4
    
    [self initUI];
    [self getAllDevices];//获取所有设备
    
    //获取房间状态
    if (_hostType == 0) {  //Creston
        [self getDeviceStateInfoByHttp];//Http获取所有设备的状态
    }else if (_hostType == 1) {   //C4
        [self getDeviceStateInfoByTcp];//TCP获取所有设备状态
    }
    
    [self performSelector:@selector(getPlaneGraphConfiguration) withObject:nil afterDelay:1];
}

- (void)addNotifications {
    [NC addObserver:self selector:@selector(airControllerStatusChangedNotification:) name:@"AirControllerStatusChangedNotifications" object:nil];
}

- (void)airControllerStatusChangedNotification:(NSNotification *)noti {
    [self refreshDeviceTableView];
}

//获取房间平面图配置
- (void)getPlaneGraphConfiguration
{
    NSString *auothorToken = [UD objectForKey:@"AuthorToken"];
    
    if (auothorToken.length >0) {
        
        NSString *url = [NSString stringWithFormat:@"%@%@",[IOManager httpAddr], @"Cloud/room_plane.aspx"];
        
        NSDictionary *dic = @{
                              @"token":  auothorToken,
                              @"room_id": @(self.roomID)
                              };
        
        HttpManager *http = [HttpManager defaultManager];
        http.delegate = self;
        http.tag = 1;
        [http sendPost:url param:dic];
        
    }
}

- (void)getDeviceStateInfoByTcp {
    
    //查询所有的设备ID
    NSArray *devIDs = [SQLManager getAllDevicesInfo:(int)self.roomID];
    
    NSMutableArray *deviceIDs = [[NSMutableArray alloc] init];
    if (devIDs.count >0) {
        [deviceIDs addObjectsFromArray:devIDs];
    }
    
    SocketManager *sock = [SocketManager defaultManager];
    sock.delegate = self;
    
    [deviceIDs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        Device *device = (Device *)obj;
        NSString *deviceID = [NSString stringWithFormat:@"%d", device.eID];
        
        if (device.hTypeId == air) {
            NSData *data = [[DeviceInfo defaultManager] query:deviceID withRoom:device.airID];
            [sock.socket writeData:data withTimeout:1 tag:1];
            
        }else {
            NSData *data = [[DeviceInfo defaultManager] query:deviceID];
            [sock.socket writeData:data withTimeout:1 tag:1];
        }
        
    }];
}

- (void)countOfDeviceType {
    _deviceType_count = [SQLManager numbersOfDeviceType];
}

- (void)getAllDevices {
    
    //获取设备类型数量
    [self countOfDeviceType];
    
    
    //所有设备ID
    NSArray *devIDArray = [SQLManager deviceIdsByRoomId:(int)self.roomID];
    _deviceIDArray = [NSMutableArray array];
    if (devIDArray) {
        [_deviceIDArray addObjectsFromArray:devIDArray];
    }
    
    //所有设备
    _lightArray = [[NSMutableArray alloc] init];
    _curtainArray = [[NSMutableArray alloc] init];
    _environmentArray = [[NSMutableArray alloc] init];
    _multiMediaArray = [[NSMutableArray alloc] init];
    _intelligentArray = [[NSMutableArray alloc] init];
    _securityArray = [[NSMutableArray alloc] init];
    _sensorArray = [[NSMutableArray alloc] init];
    _otherTypeArray = [[NSMutableArray alloc] init];
    _colourLightArr = [[NSMutableArray alloc] init];
    _switchLightArr = [[NSMutableArray alloc] init];
    _lightArr = [[NSMutableArray alloc] init];
    
    
    for(int i = 0; i <_deviceIDArray.count; i++)
    {
        //比较设备大类，进行分组
        NSString *deviceTypeName = [SQLManager getSubTypeNameByDeviceID:[_deviceIDArray[i] intValue]];
        if ([deviceTypeName isEqualToString:LightType]) {
            [_lightArray addObject:_deviceIDArray[i]];
        }else if ([deviceTypeName isEqualToString:EnvironmentType]){
            [_environmentArray addObject:_deviceIDArray[i]];
        }else if ([deviceTypeName isEqualToString:CurtainType]){
            [_curtainArray addObject:_deviceIDArray[i]];
        }else if ([deviceTypeName isEqualToString:MultiMediaType]){
            [_multiMediaArray addObject:_deviceIDArray[i]];
        }else if ([deviceTypeName isEqualToString:IntelligentType]){
            [_intelligentArray addObject:_deviceIDArray[i]];
        }else if ([deviceTypeName isEqualToString:SecurityType]){
            [_securityArray addObject:_deviceIDArray[i]];
        }else if ([deviceTypeName isEqualToString:SensorType]){
            [_sensorArray addObject:_deviceIDArray[i]];
        }else{
            [_otherTypeArray addObject:_deviceIDArray[i]];
        }
    }
    
}

- (void)refreshHomeDetailNotification:(NSNotification *)noti {
    if (_hostType == 0) {  //Crestron
        [self getDeviceStateInfoByHttp];//Http获取所有设备的状态
    }
}

- (void)getDeviceStateInfoByHttp {
    
}

- (void)initUI {
    
    [self setNaviBarTitle:self.roomName];
    
    [self.deviceTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    UIImageView *bg = [[UIImageView alloc] initWithFrame:self.deviceTableView.bounds];
    bg.image = [UIImage imageNamed:@"background"];
    [self.deviceTableView setBackgroundView:bg];
    
    [self.deviceTableView registerNib:[UINib nibWithNibName:@"NewLightCell" bundle:nil] forCellReuseIdentifier:@"NewLightCell"];//调光灯
    [self.deviceTableView registerNib:[UINib nibWithNibName:@"PowerLightCell" bundle:nil] forCellReuseIdentifier:@"PowerLightCell"];//开关灯
    [self.deviceTableView registerNib:[UINib nibWithNibName:@"NewColourCell" bundle:nil] forCellReuseIdentifier:@"NewColourCell"];//调色灯
    
    [self.deviceTableView registerNib:[UINib nibWithNibName:@"AireTableViewCell" bundle:nil] forCellReuseIdentifier:@"AireTableViewCell"];//空调
    [self.deviceTableView registerNib:[UINib nibWithNibName:@"CurtainTableViewCell" bundle:nil] forCellReuseIdentifier:@"CurtainTableViewCell"];//窗帘
    [self.deviceTableView registerNib:[UINib nibWithNibName:@"CurtainC4TableViewCell" bundle:nil] forCellReuseIdentifier:@"CurtainC4TableViewCell"];//窗帘(C4)
    
    if (ON_IPAD) {
        [self.deviceTableView registerNib:[UINib nibWithNibName:@"IpadTVCell" bundle:nil] forCellReuseIdentifier:@"IpadTVCell"];//网络电视
    }else {
        [self.deviceTableView registerNib:[UINib nibWithNibName:@"TVTableViewCell" bundle:nil] forCellReuseIdentifier:@"TVTableViewCell"];//网络电视
    }
    
    [self.deviceTableView registerNib:[UINib nibWithNibName:@"OtherTableViewCell" bundle:nil] forCellReuseIdentifier:@"OtherTableViewCell"];//其他
    [self.deviceTableView registerNib:[UINib nibWithNibName:@"ScreenTableViewCell" bundle:nil] forCellReuseIdentifier:@"ScreenTableViewCell"];//投影仪ScreenTableViewCell
    [self.deviceTableView registerNib:[UINib nibWithNibName:@"ScreenCurtainCell" bundle:nil] forCellReuseIdentifier:@"ScreenCurtainCell"];//幕布ScreenCurtainCell
    
    if (ON_IPAD) {
        [self.deviceTableView registerNib:[UINib nibWithNibName:@"IpadDVDTableViewCell" bundle:nil] forCellReuseIdentifier:@"IpadDVDTableViewCell"];//DVD
    }else {
        [self.deviceTableView registerNib:[UINib nibWithNibName:@"DVDTableViewCell" bundle:nil] forCellReuseIdentifier:@"DVDTableViewCell"];//DVD
    }
    
    
    [self.deviceTableView registerNib:[UINib nibWithNibName:@"BjMusicTableViewCell" bundle:nil] forCellReuseIdentifier:@"BjMusicTableViewCell"];//背景音乐
    [self.deviceTableView registerNib:[UINib nibWithNibName:@"FMTableViewCell" bundle:nil] forCellReuseIdentifier:@"FMTableViewCell"];//FM收音机
    
    [self.planeGraph setContentMode:UIViewContentModeScaleAspectFit];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - UITableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //return _deviceType_count-2;
    return 5;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return _lightArray.count;//灯光(01:开关灯 02:调光灯 03:调色灯)
    }else if (section == 1){
        return _curtainArray.count;//窗帘
    }else if (section == 2){
        return _environmentArray.count;//环境（空调, 新风）
    }else if (section == 3){
        return _multiMediaArray.count;//影音
    }else if (section == 4){
        return _intelligentArray.count;//智能单品
    }/*else if (section == 5){
      return _securityArray.count;//安防
      }else if (section == 6){
      return _sensorArray.count;//感应器
      }*/
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {//灯光
        Device *device = [SQLManager getDeviceWithDeviceID:[_lightArray[indexPath.row] intValue]];
        if (device.hTypeId == 1) { //开关灯
            PowerLightCell * powerCell = [tableView dequeueReusableCellWithIdentifier:@"PowerLightCell" forIndexPath:indexPath];
            powerCell.delegate = self;
            powerCell.selectionStyle = UITableViewCellSelectionStyleNone;
            powerCell.backgroundColor = [UIColor clearColor];
            powerCell.powerBtnConstraint.constant = 10;
            powerCell.powerLightNameLabel.text = device.name;
            powerCell.addPowerLightBtn.hidden = YES;
            powerCell.deviceid = _lightArray[indexPath.row];
            powerCell.powerLightBtn.selected = device.power;//开关状态
            
            return powerCell;
            
        }else if (device.hTypeId == 2) { //调光灯
            NewLightCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NewLightCell" forIndexPath:indexPath];
            cell.delegate = self;
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
            cell.delegate = self;
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
        
    }else if (indexPath.section == 1) {//窗帘
        
        if (_hostType == 0) {  //crestron
            CurtainTableViewCell *curtainCell = [tableView dequeueReusableCellWithIdentifier:@"CurtainTableViewCell" forIndexPath:indexPath];
            curtainCell.delegate = self;
            curtainCell.backgroundColor =[UIColor clearColor];
            curtainCell.selectionStyle = UITableViewCellSelectionStyleNone;
            curtainCell.AddcurtainBtn.hidden = YES;
            curtainCell.curtainContraint.constant = 10;
            curtainCell.roomID = (int)self.roomID;
            Device *device = [SQLManager getDeviceWithDeviceID:[_curtainArray[indexPath.row] intValue]];
            curtainCell.label.text = device.name;
            curtainCell.deviceid = _curtainArray[indexPath.row];
            curtainCell.slider.value = (float)device.position/100.0f;//窗帘位置
            curtainCell.open.selected = device.power;//开关状态
            return curtainCell;
        }else { //C4
        
        CurtainC4TableViewCell *curtainCell = [tableView dequeueReusableCellWithIdentifier:@"CurtainC4TableViewCell" forIndexPath:indexPath];
        //curtainCell.delegate = self;
        curtainCell.backgroundColor =[UIColor clearColor];
        curtainCell.selectionStyle = UITableViewCellSelectionStyleNone;
        curtainCell.addBtn.hidden = YES;
        curtainCell.switchBtnTrailingConstraint.constant = 10;
        curtainCell.roomID = (int)self.roomID;
        Device *device = [SQLManager getDeviceWithDeviceID:[_curtainArray[indexPath.row] intValue]];
        curtainCell.name.text = device.name;
        curtainCell.deviceid = _curtainArray[indexPath.row];
        curtainCell.switchBtn.selected = device.power;//开关状态
        return curtainCell;
      }
    }else if (indexPath.section == 2) { //环境
        
        Device *device = [SQLManager getDeviceWithDeviceID:[_environmentArray[indexPath.row] intValue]];
        if (device.hTypeId == 31) { //空调
            AireTableViewCell * aireCell = [tableView dequeueReusableCellWithIdentifier:@"AireTableViewCell" forIndexPath:indexPath];
            aireCell.backgroundColor = [UIColor clearColor];
            aireCell.selectionStyle = UITableViewCellSelectionStyleNone;
            aireCell.AddAireBtn.hidden = YES;
            aireCell.AireConstraint.constant = 10;
            aireCell.roomID = (int)self.roomID;
            aireCell.AireNameLabel.text = device.name;
            aireCell.deviceid = _environmentArray[indexPath.row];
            aireCell.temperatureLabel.text = [NSString stringWithFormat:@"%ld℃", (long)device.temperature];
            aireCell.AireSlider.value = device.temperature;//温度
            aireCell.AireSwitchBtn.selected = device.power;//开关
            return aireCell;
        }else { //环境的其他类型
            OtherTableViewCell * otherCell = [tableView dequeueReusableCellWithIdentifier:@"OtherTableViewCell" forIndexPath:indexPath];
            otherCell.delegate = self;
            otherCell.backgroundColor =[UIColor clearColor];
            otherCell.selectionStyle = UITableViewCellSelectionStyleNone;
            otherCell.AddOtherBtn.hidden = YES;
            otherCell.OtherConstraint.constant = 10;
            otherCell.NameLabel.text = device.name;
            otherCell.OtherSwitchBtn.selected = device.power;//开关
            otherCell.deviceid = [NSString stringWithFormat:@"%d", device.eID];
            otherCell.hTypeId = device.hTypeId;
            return otherCell;
        }
        
    }else if (indexPath.section == 3) {//影音
        Device *device = [SQLManager getDeviceWithDeviceID:[_multiMediaArray[indexPath.row] intValue]];
        
        if (device.hTypeId == 14) { //背景音乐
            BjMusicTableViewCell * BjMusicCell = [tableView dequeueReusableCellWithIdentifier:@"BjMusicTableViewCell" forIndexPath:indexPath];
            BjMusicCell.delegate = self;
            BjMusicCell.backgroundColor = [UIColor clearColor];
            BjMusicCell.selectionStyle = UITableViewCellSelectionStyleNone;
            BjMusicCell.AddBjmusicBtn.hidden = YES;
            BjMusicCell.BJmusicConstraint.constant = 10;
            BjMusicCell.BjMusicNameLb.text = device.name;
            BjMusicCell.BjPowerButton.selected = device.power;//开关
            BjMusicCell.BjSlider.value = device.volume/100.0;//音量
            BjMusicCell.deviceid = [NSString stringWithFormat:@"%d", device.eID];
            return BjMusicCell;
        }else if (device.hTypeId == 13) { //DVD
            
            if (ON_IPAD) {
                IpadDVDTableViewCell * dvdCell = [tableView dequeueReusableCellWithIdentifier:@"IpadDVDTableViewCell" forIndexPath:indexPath];
                dvdCell.backgroundColor =[UIColor clearColor];
                dvdCell.selectionStyle = UITableViewCellSelectionStyleNone;
                dvdCell.AddDvdBtn.hidden = YES;
                dvdCell.DVDConstraint.constant = 10;
                dvdCell.DVDNameLabel.text = device.name;
                dvdCell.DVDSwitchBtn.selected = device.power;//开关
                dvdCell.DVDSlider.value = device.volume/100.0;//音量
                dvdCell.deviceid = [NSString stringWithFormat:@"%d", device.eID];
                return dvdCell;
            }else {
                DVDTableViewCell * dvdCell = [tableView dequeueReusableCellWithIdentifier:@"DVDTableViewCell" forIndexPath:indexPath];
                dvdCell.backgroundColor =[UIColor clearColor];
                dvdCell.selectionStyle = UITableViewCellSelectionStyleNone;
                dvdCell.AddDvdBtn.hidden = YES;
                dvdCell.DVDConstraint.constant = 10;
                dvdCell.DVDNameLabel.text = device.name;
                dvdCell.DVDSwitchBtn.selected = device.power;//开关
                dvdCell.DVDSlider.value = device.volume/100.0;//音量
                dvdCell.deviceid = [NSString stringWithFormat:@"%d", device.eID];
                return dvdCell;
            }
            
            
        }else if (device.hTypeId == 15) { //FM收音机
            FMTableViewCell * FMCell = [tableView dequeueReusableCellWithIdentifier:@"FMTableViewCell" forIndexPath:indexPath];
            FMCell.backgroundColor =[UIColor clearColor];
            FMCell.selectionStyle = UITableViewCellSelectionStyleNone;
            FMCell.AddFmBtn.hidden = YES;
            FMCell.FMLayouConstraint.constant = 10;
            FMCell.FMNameLabel.text = device.name;
            FMCell.FMSwitchBtn.selected = device.power;//开关
            FMCell.FMSlider.value = device.volume/100.0;//音量
            FMCell.deviceid = [NSString stringWithFormat:@"%d", device.eID];
            return FMCell;
        }else if (device.hTypeId == 17) { //幕布
            ScreenCurtainCell * ScreenCell = [tableView dequeueReusableCellWithIdentifier:@"ScreenCurtainCell" forIndexPath:indexPath];
            ScreenCell.backgroundColor =[UIColor clearColor];
            ScreenCell.selectionStyle = UITableViewCellSelectionStyleNone;
            ScreenCell.AddScreenCurtainBtn.hidden = YES;
            ScreenCell.ScreenCurtainConstraint.constant = 10;
            ScreenCell.ScreenCurtainLabel.text = device.name;
            ScreenCell.ScreenCurtainBtn.selected = device.power;//开关
            ScreenCell.deviceid = [NSString stringWithFormat:@"%d", device.eID];
            return ScreenCell;
        }else if (device.hTypeId == 16) { //投影仪(只有开关)
            OtherTableViewCell * otherCell = [tableView dequeueReusableCellWithIdentifier:@"OtherTableViewCell" forIndexPath:indexPath];
            otherCell.delegate = self;
            otherCell.backgroundColor = [UIColor clearColor];
            otherCell.selectionStyle = UITableViewCellSelectionStyleNone;
            otherCell.AddOtherBtn.hidden = YES;
            otherCell.OtherConstraint.constant = 10;
            otherCell.NameLabel.text = device.name;
            otherCell.OtherSwitchBtn.selected = device.power;//开关
            otherCell.deviceid = [NSString stringWithFormat:@"%d", device.eID];
            return otherCell;
        }else if (device.hTypeId == 11) { //电视（以前叫机顶盒）
            
            if (ON_IPAD) {
                IpadTVCell * tvCell = [tableView dequeueReusableCellWithIdentifier:@"IpadTVCell" forIndexPath:indexPath];
                tvCell.backgroundColor =[UIColor clearColor];
                tvCell.selectionStyle = UITableViewCellSelectionStyleNone;
                tvCell.AddTvDeviceBtn.hidden = YES;
                tvCell.TVConstraint.constant = 10;
                tvCell.TVNameLabel.text = device.name;
                tvCell.TVSwitchBtn.selected = device.power;//开关
                tvCell.TVSlider.value = device.volume/100.0;//音量
                tvCell.deviceid = [NSString stringWithFormat:@"%d", device.eID];
                return tvCell;
            }else {
                TVTableViewCell * tvCell = [tableView dequeueReusableCellWithIdentifier:@"TVTableViewCell" forIndexPath:indexPath];
                tvCell.backgroundColor =[UIColor clearColor];
                tvCell.selectionStyle = UITableViewCellSelectionStyleNone;
                tvCell.AddTvDeviceBtn.hidden = YES;
                tvCell.TVConstraint.constant = 10;
                tvCell.TVNameLabel.text = device.name;
                tvCell.TVSwitchBtn.selected = device.power;//开关
                tvCell.TVSlider.value = device.volume/100.0;//音量
                tvCell.deviceid = [NSString stringWithFormat:@"%d", device.eID];
                return tvCell;
            }
            
            
        }else if (device.hTypeId == 18) { //功放
            OtherTableViewCell * otherCell = [tableView dequeueReusableCellWithIdentifier:@"OtherTableViewCell" forIndexPath:indexPath];
            otherCell.delegate = self;
            otherCell.backgroundColor =[UIColor clearColor];
            otherCell.selectionStyle = UITableViewCellSelectionStyleNone;
            otherCell.AddOtherBtn.hidden = YES;
            otherCell.OtherConstraint.constant = 10;
            otherCell.NameLabel.text = device.name;
            otherCell.OtherSwitchBtn.selected = device.power;//开关
            otherCell.deviceid = [NSString stringWithFormat:@"%d", device.eID];
            return otherCell;
        }else { //影音其他类型
            OtherTableViewCell * otherCell = [tableView dequeueReusableCellWithIdentifier:@"OtherTableViewCell" forIndexPath:indexPath];
            otherCell.delegate = self;
            otherCell.backgroundColor =[UIColor clearColor];
            otherCell.selectionStyle = UITableViewCellSelectionStyleNone;
            otherCell.AddOtherBtn.hidden = YES;
            otherCell.OtherConstraint.constant = 10;
            otherCell.NameLabel.text = device.name;
            otherCell.OtherSwitchBtn.selected = device.power;//开关
            otherCell.deviceid = [NSString stringWithFormat:@"%d", device.eID];
            return otherCell;
        }
        
        
        
    }else if (indexPath.section == 4) {//智能单品
        Device *device = [SQLManager getDeviceWithDeviceID:[_intelligentArray[indexPath.row] intValue]];
        OtherTableViewCell * otherCell = [tableView dequeueReusableCellWithIdentifier:@"OtherTableViewCell" forIndexPath:indexPath];
        otherCell.delegate = self;
        otherCell.backgroundColor =[UIColor clearColor];
        otherCell.selectionStyle = UITableViewCellSelectionStyleNone;
        otherCell.AddOtherBtn.hidden = YES;
        otherCell.OtherConstraint.constant = 10;
        otherCell.NameLabel.text = device.name;
        otherCell.OtherSwitchBtn.selected = device.power;//开关
        otherCell.deviceid = [NSString stringWithFormat:@"%d", device.eID];
        return otherCell;
        
    }/*else if (indexPath.section == 5) {//安防
      Device *device = [SQLManager getDeviceWithDeviceID:[_securityArray[indexPath.row] intValue]];
      
      if (device.hTypeId == 40) { //智能门锁
      OtherTableViewCell * otherCell = [tableView dequeueReusableCellWithIdentifier:@"OtherTableViewCell" forIndexPath:indexPath];
      otherCell.backgroundColor =[UIColor clearColor];
      otherCell.selectionStyle = UITableViewCellSelectionStyleNone;
      otherCell.AddOtherBtn.hidden = YES;
      otherCell.OtherConstraint.constant = 10;
      otherCell.NameLabel.text = device.name;
      return otherCell;
      }else if (device.hTypeId == 45) { //摄像头
      return nil;
      }else {
      OtherTableViewCell * otherCell = [tableView dequeueReusableCellWithIdentifier:@"OtherTableViewCell" forIndexPath:indexPath];
      otherCell.backgroundColor =[UIColor clearColor];
      otherCell.selectionStyle = UITableViewCellSelectionStyleNone;
      otherCell.AddOtherBtn.hidden = YES;
      otherCell.OtherConstraint.constant = 10;
      otherCell.NameLabel.text = device.name;
      return otherCell;
      }
      
      
      }else if (indexPath.section == 6) {//感应器
      Device *device = [SQLManager getDeviceWithDeviceID:[_sensorArray[indexPath.row] intValue]];
      
      OtherTableViewCell * otherCell = [tableView dequeueReusableCellWithIdentifier:@"OtherTableViewCell" forIndexPath:indexPath];
      otherCell.backgroundColor =[UIColor clearColor];
      otherCell.selectionStyle = UITableViewCellSelectionStyleNone;
      otherCell.AddOtherBtn.hidden = YES;
      otherCell.OtherConstraint.constant = 10;
      otherCell.NameLabel.text = device.name;
      return otherCell;
      }*/
    
    return [UITableViewCell new];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) { //灯光： 1:开关灯cell高度50;   2,  3:调光灯，调色灯cell高度100
        Device *device = [SQLManager getDeviceWithDeviceID:[_lightArray[indexPath.row] intValue]];
        
        if (ON_IPAD) {
            if (device.hTypeId == 1) {
                return 80;
            }else {
                return 150;
            }
        }else {
            
            if (device.hTypeId == 1) {
                return 80;
            }else {
                return 100;
            }
        }
    }else if (indexPath.section == 1) { //窗帘
        if (ON_IPAD) {
            return 100;
        }else {
            return 100;
        }
    }else if (indexPath.section == 2) { // 空调
        if (ON_IPAD) {
            return 150;
        }else {
            return 100;
        }
    }
    
    else if (indexPath.section == 3) { //影音
        
        Device *device = [SQLManager getDeviceWithDeviceID:[_multiMediaArray[indexPath.row] intValue]];
        
        if (ON_IPAD) {
            if (device.hTypeId == 14 || device.hTypeId == 17) { //背景音乐，幕布
                return 150;
            }else if (device.hTypeId == 16) {//投影仪
                return 80;
            }else if (device.hTypeId == 11 || device.hTypeId == 13 || device.hTypeId == 15) { //TV,  DVD , FM
                return 210;
            }else {
                return 100; //功放等其他影音设备
            }
        }else {
            
            if (device.hTypeId == 11 || device.hTypeId == 12 || device.hTypeId == 13 || device.hTypeId == 15) {
                return 150;
            }else if (device.hTypeId == 16 || device.hTypeId == 18) {
                return 50;
            }else {
                return 100;
            }
        }
    }
    
    else if (indexPath.section == 4) { //智能单品
        if (ON_IPAD) {
            return 100;
        }else {
            return 50;
        }
    }
    
    
    return 100;
}

#pragma mark - TCP recv delegate
- (void)recv:(NSData *)data withTag:(long)tag
{
    Proto proto=protocolFromData(data);
    if (CFSwapInt16BigToHost(proto.masterID) != [[DeviceInfo defaultManager] masterID]) {
        return;
    }
    //同步设备状态
    if(proto.cmd == 0x01) {
        
        NSString *devID=[SQLManager getDeviceIDByENumberForC4:CFSwapInt16BigToHost(proto.deviceID) airID:proto.action.B];
        Device *device = [SQLManager getDeviceWithDeviceID:devID.intValue airID:proto.action.B];
        
        if (device) {
            device.actionState = proto.action.state;
            
            if(proto.action.state == 0x6B) { //温度
                device.temperature  = proto.action.RValue;
                
            }
            
            else if(proto.action.state == 0x1A) { //亮度
                device.bright = proto.action.RValue;
            }
            
            else if(proto.action.state == 0x1B) { //颜色
                device.color = [NSString stringWithFormat:@"%d,%d,%d", proto.action.RValue, proto.action.G, proto.action.B];
            }
            
            else if (proto.action.state == 0x2A) { //窗帘的位置
                device.position = proto.action.RValue;
            }
            
            else if (proto.action.state == PROTOCOL_VOLUME) { //音量
                device.volume = proto.action.RValue;
            }
            
            else if (proto.action.state == PROTOCOL_OFF || proto.action.state == PROTOCOL_ON) { //开关
                device.power = proto.action.state;
                
                if (proto.deviceType == 0x14) {
                    NSLog(@"背景音乐---开关---  %d", proto.action.state);
                }
                
                if (proto.deviceType == 0x13) {
                    NSLog(@"DVD---开关---  %d", proto.action.state);
                }
                
                if (proto.deviceType == 0x11) {
                    NSLog(@"电视---开关---  %d", proto.action.state);
                }
            }
            
            [SQLManager updateDeviceStatus:device];
            [self refreshDeviceTableView];
            
        }
        
    } else if(proto.cmd == 0x02) {
        
        NSLog(@"0x02---0x02");
    }
}


- (void)refreshDeviceTableView {
    [self.deviceTableView reloadData];//刷新UI
}

#pragma mark - Http callback
- (void)httpHandler:(id)responseObject tag:(int)tag
{
    if (tag == 1) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            if ([responseObject[@"result"] integerValue] == 0) {
                
                   NSString *photoWidth =  responseObject[@"width"];
                   NSString *photoHeight =  responseObject[@"height"];
                
                   self.photoWidth = [photoWidth floatValue];
                   self.photoHeight = [photoHeight floatValue];
                
                    NSString *bgImgUrl = responseObject[@"imgpath"];//设置平面背景
                    if (bgImgUrl.length >0) {
                        [self.planeGraph sd_setImageWithURL:[NSURL URLWithString:bgImgUrl] placeholderImage:nil options:SDWebImageRetryFailed];
                    }
                    NSString *plistURL = responseObject[@"plist_path"];
                    if (plistURL.length >0) {
                        //下载plist
                        [self downloadPlist:plistURL];
                    }
                
            }
        }
    }
    
}

//下载场景plist文件到本地
-(void)downloadPlist:(NSString *)plistURL
{
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:plistURL]];
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        
        //下载进度
        NSLog(@"%@",downloadProgress);
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        //下载到哪个文件夹
        NSString *path = [[IOManager planeScenePath] stringByAppendingPathComponent:response.suggestedFilename];
        
        return [NSURL fileURLWithPath:path];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        NSLog(@"room_planeGraph_PlistFile下载完了 %@",filePath);
        
        NSString *plistFilePath = [[filePath absoluteString] substringFromIndex:7];
        //保存到UD
        [UD setObject:plistFilePath forKey:@"Room_Plane_Graph_PlistFile"];
        [UD synchronize];
        
        //获取所有设备信息
        [self getDeviceInfoFromPlist:plistFilePath];
        
    }];
    
    [task resume];
}

- (void)getDeviceInfoFromPlist:(NSString *)plist {
    if (plist.length >0) {
        NSDictionary *plistDic = [NSDictionary dictionaryWithContentsOfFile:plist];
        NSArray *deviceIconPositionArray = [plistDic objectForKey:@"device_positions"];
        if ([deviceIconPositionArray isKindOfClass:[NSArray class]]) {
            
            [self.planeGraph removeAllSubviews];  
            
            for (NSDictionary *dict in deviceIconPositionArray) {
                
                int deviceId = [[dict objectForKey:@"deviceID"] intValue];
                NSString *iconRectStr = [dict objectForKey:@"rect"];
                CGRect iconRect = CGRectFromString(iconRectStr);
                CGFloat iconWidth = 20.0f;
                CGFloat iconHeight = 20.0f;
                NSString *deviceIconNormal = @"";//设备(关闭)
                NSString *deviceIconSelected = @"";//设备(打开)
                
                Device * device = [SQLManager getDeviceWithDeviceID:deviceId];
                if (device.subTypeId == cata_light) {  //灯
                    if (device.UITypeOfLight == 1) { // 射灯
                        deviceIconNormal = @"lv_icon_light_off";
                        deviceIconSelected = @"lv_icon_light_on";
                    }else if (device.UITypeOfLight == 2) { //灯带
                        deviceIconNormal = @"light_off_dd";
                        deviceIconSelected = @"light_on_dd";
                        if ([device.name isEqualToString:@"鞋柜灯带"]) {
                            deviceIconNormal = @"light_off_dd_h";
                            deviceIconSelected = @"light_on_dd_h";
                        }
                    }else if (device.UITypeOfLight == 3) { //色灯
                        deviceIconNormal = @"lv_icon_light_off";
                        deviceIconSelected = @"lv_icon_light_on";
                    }
                }else if(device.subTypeId == cata_curtain) { //窗帘
                        deviceIconNormal = @"blind_icon";
                        deviceIconSelected = @"blind_icon";
                }else if(device.subTypeId == cata_env) { //环境
                    if (device.hTypeId == newWind) { //新风
                        deviceIconNormal = @"newWind_off";
                        deviceIconSelected = @"newWind_on";
                    }else if (device.hTypeId == air) {  //空调
                        deviceIconNormal = @"airControl_off_v";
                        deviceIconSelected = @"airControl_off_v";
                    }
                    
                }else if(device.subTypeId == cata_media) { //影音
                     deviceIconNormal = @"media_off";
                     deviceIconSelected = @"media_on";
                }
                
                UIImage *imageNormal = [UIImage imageNamed:deviceIconNormal];
                UIImage *imageSelected = [UIImage imageNamed:deviceIconSelected];
                
                
                UIButton *deviceBtn = [[UIButton alloc] initWithFrame:CGRectMake(iconRect.origin.x, iconRect.origin.y, iconWidth, iconHeight)];
                deviceBtn.tag = deviceId;
                [deviceBtn setImage:imageNormal forState:UIControlStateNormal];
                [deviceBtn setImage:imageSelected forState:UIControlStateSelected];
                deviceBtn.selected = device.power; //开关状态
                
                CGFloat offset_X = (self.planeGraph.size.width - self.photoWidth)/2;
                CGFloat offset_Y = (self.planeGraph.size.height - self.photoHeight)/2;
                
                if (deviceBtn.selected) {
                    [deviceBtn setFrame:CGRectMake(iconRect.origin.x+offset_X, iconRect.origin.y+offset_Y, imageSelected.size.width, imageSelected.size.height)];
                }else {
                    [deviceBtn setFrame:CGRectMake(iconRect.origin.x+offset_X, iconRect.origin.y+offset_Y, imageNormal.size.width, imageNormal.size.height)];
                }
                
                
//                if (device.hTypeId == air) {  //空调
//                    [deviceBtn setFrame:CGRectMake(iconRect.origin.x, iconRect.origin.y+offset_Y, imageNormal.size.width, imageNormal.size.height+30)];
//                }
                
                if (device.hTypeId == newWind) { //新风
                    [deviceBtn setFrame:CGRectMake(iconRect.origin.x+offset_X, iconRect.origin.y+offset_Y+10, imageNormal.size.width, imageNormal.size.height)];
                }
                
                [deviceBtn addTarget:self action:@selector(deviceBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
                
                [self.planeGraph addSubview:deviceBtn];
            }
            
        }
    }
}

- (void)deviceBtnClicked:(UIButton *)btn {
    int deviceId = (int)btn.tag;
    Device * device = [SQLManager getDeviceWithDeviceID:deviceId];
    
    if (device.subTypeId == cata_light) {  //灯
        
        for (UIButton *button in self.planeGraph.subviews) {
            if ([button isKindOfClass:[UIButton class]]) {
                if (button.tag == btn.tag) {
                    button.selected = !button.selected;
                    
                    if (device.hTypeId == switchLight || device.hTypeId == dimmarLight) { //开关灯 or 调光灯
                        
                        if (device.UITypeOfLight == 1) { // 射灯
                            
                            NSString *deviceIconNormal = @"lv_icon_light_off";
                            NSString *deviceIconSelected = @"lv_icon_light_on";
                            if (button.selected) {
                                [button setImage:[UIImage imageNamed:deviceIconSelected] forState:UIControlStateSelected];
                                CGRect temp = button.frame;
                                temp.size.width = [UIImage imageNamed:deviceIconSelected].size.width;
                                temp.size.height = [UIImage imageNamed:deviceIconSelected].size.height;
                                button.frame = temp;
                            }else {
                                [button setImage:[UIImage imageNamed:deviceIconNormal] forState:UIControlStateNormal];
                                CGRect temp = button.frame;
                                temp.size.width = [UIImage imageNamed:deviceIconNormal].size.width;
                                temp.size.height = [UIImage imageNamed:deviceIconNormal].size.height;
                                button.frame = temp;
                            }
                            
                        }
                        
                        
                    }
                    
                }
            }
        }
        
        
        NSData *data = [[DeviceInfo defaultManager] toogleLight:btn.selected deviceID:[NSString stringWithFormat:@"%d", deviceId]];
        SocketManager *sock = [SocketManager defaultManager];
        [sock.socket writeData:data withTimeout:1 tag:1];
        
        //更新左侧列表设备状态
        [SQLManager updateDevicePowerStatus:deviceId power:btn.selected];
        [self refreshDeviceTableView];
        
        if (device.hTypeId == dimmarLight) {  //调光灯
            /*UIButton *touchBg = [[UIButton alloc] initWithFrame:self.view.frame];
            touchBg.backgroundColor = RGB(0, 0, 0, 0.7);
            [touchBg addTarget:self action:@selector(touchBgAction:) forControlEvents:UIControlEventTouchUpInside];
            
            UIViewController *superVC = [[UIViewController alloc] init];
            superVC.view.frame = CGRectMake((UI_SCREEN_WIDTH-UI_SCREEN_WIDTH*2/3)/2, (UI_SCREEN_HEIGHT-UI_SCREEN_HEIGHT*2/3)/2, UI_SCREEN_WIDTH*2/3, 50);
            
            CustomSliderViewController *vc = [[CustomSliderViewController alloc] initWithNibName:@"CustomSliderViewController" bundle:nil];
            vc.deviceid = [NSString stringWithFormat:@"%d", device.eID];
            vc.view.frame = CGRectMake(100, 0, UI_SCREEN_WIDTH*1/3, 50);
            
            [superVC.view addSubview:vc.view];
            [superVC addChildViewController:vc];
            [touchBg addSubview:superVC.view];
            [self.tabBarController.view addSubview:touchBg];*/
            
        }
        
    }else if(device.subTypeId == cata_curtain) { //窗帘
        
        UIButton *touchBg = [[UIButton alloc] initWithFrame:self.view.frame];
        touchBg.backgroundColor = RGB(0, 0, 0, 0.7);
        [touchBg addTarget:self action:@selector(touchBgAction:) forControlEvents:UIControlEventTouchUpInside];
        
        UIViewController *superVC = [[UIViewController alloc] init];
        superVC.view.frame = CGRectMake((UI_SCREEN_WIDTH-UI_SCREEN_WIDTH*2/3)/2, (UI_SCREEN_HEIGHT-UI_SCREEN_HEIGHT*2/3)/2, UI_SCREEN_WIDTH*2/3, UI_SCREEN_HEIGHT*2/3);
        
        UIViewController *deviceVC = [DeviceInfo calcController:device.hTypeId];
        
        CurtainController *control = (CurtainController *)deviceVC;
        control.deviceid = [NSString stringWithFormat:@"%d", device.eID];
        control.roomID = (int)self.roomID;
        deviceVC.view.frame = CGRectMake(0, 0, UI_SCREEN_WIDTH*2/3, UI_SCREEN_HEIGHT*2/3);
        [control hideNaviBar:YES];
        
        [superVC.view addSubview:deviceVC.view];
        [superVC addChildViewController:deviceVC];
        [touchBg addSubview:superVC.view];
        [self.tabBarController.view addSubview:touchBg];
        
    }else if(device.subTypeId == cata_env) { //环境
        
        UIButton *touchBg = [[UIButton alloc] initWithFrame:self.view.frame];
        touchBg.backgroundColor = RGB(0, 0, 0, 0.7);
        [touchBg addTarget:self action:@selector(touchBgAction:) forControlEvents:UIControlEventTouchUpInside];
        
        UIViewController *superVC = [[UIViewController alloc] init];
        superVC.view.frame = CGRectMake((UI_SCREEN_WIDTH-UI_SCREEN_WIDTH*2/3)/2, (UI_SCREEN_HEIGHT-UI_SCREEN_HEIGHT*2/3)/2, UI_SCREEN_WIDTH*2/3, UI_SCREEN_HEIGHT*2/3);
        
        UIViewController *deviceVC = [DeviceInfo calcController:device.hTypeId];
        
        if (device.hTypeId == newWind) { //新风
            [[DeviceInfo defaultManager] setRoomID:self.roomID];
            NewWindController *control = (NewWindController *)deviceVC;
            control.deviceID = [NSString stringWithFormat:@"%d", device.eID];
            control.roomID = (int)self.roomID;
            deviceVC.view.frame = CGRectMake(0, 0, UI_SCREEN_WIDTH*2/3, UI_SCREEN_HEIGHT*2/3);
            [control hideNaviBar:YES];
            control.highSpeedBtnBottomConstraint.constant = 50;
            control.middleSpeedBtnBottomConstraint.constant = 50;
            control.lowSpeedBtnBottomConstraint.constant = 50;
            
            [superVC.view addSubview:deviceVC.view];
            [superVC addChildViewController:deviceVC];
            [touchBg addSubview:superVC.view];
            [self.tabBarController.view addSubview:touchBg];
           
        }else if (device.hTypeId == air) {  //空调
            [[DeviceInfo defaultManager] setRoomID:self.roomID];
            AirController *control = (AirController *)deviceVC;
            control.deviceid = [NSString stringWithFormat:@"%d", device.eID];
            control.roomID = (int)self.roomID;
            deviceVC.view.frame = CGRectMake(0, 0, UI_SCREEN_WIDTH*2/3, UI_SCREEN_HEIGHT*2/3);
            [control hideNaviBar:YES];
            control.control_bannerConstraint.constant = 10;
            control.control_banner.hidden = YES;
            control.windSpeedBtn.hidden = YES;
            
            [superVC.view addSubview:deviceVC.view];
            [superVC addChildViewController:deviceVC];
            [touchBg addSubview:superVC.view];
            [self.tabBarController.view addSubview:touchBg];
        }
        
    }else if(device.subTypeId == cata_media) { //影音
       
    }
    
    
    
    
    
}

- (void)touchBgAction:(UIButton *)btn {
    [btn removeFromSuperview];
}

#pragma mark - refresh planeGraph
- (void)refreshPlaneGraph {
    for (UIButton *btn in self.planeGraph.subviews) {
        if ([btn isKindOfClass:[UIButton class]]) {
            
            int deviceId = (int)btn.tag;
            Device * device = [SQLManager getDeviceWithDeviceID:deviceId];
            btn.selected = device.power;
            
            if (device.hTypeId == switchLight || device.hTypeId == dimmarLight) { //开关灯 or 调光灯
                
                if (device.UITypeOfLight == 1) { // 射灯
                    
                    NSString *deviceIconNormal = @"lv_icon_light_off";
                    NSString *deviceIconSelected = @"lv_icon_light_on";
                    if (btn.selected) {
                        [btn setImage:[UIImage imageNamed:deviceIconSelected] forState:UIControlStateSelected];
                        CGRect temp = btn.frame;
                        temp.size.width = [UIImage imageNamed:deviceIconSelected].size.width;
                        temp.size.height = [UIImage imageNamed:deviceIconSelected].size.height;
                        btn.frame = temp;
                    }else {
                        [btn setImage:[UIImage imageNamed:deviceIconNormal] forState:UIControlStateNormal];
                        CGRect temp = btn.frame;
                        temp.size.width = [UIImage imageNamed:deviceIconNormal].size.width;
                        temp.size.height = [UIImage imageNamed:deviceIconNormal].size.height;
                        btn.frame = temp;
                    }
                    
                }
                
                
            }
            
        }
    }
}

#pragma mark - NewLightCellDelegate
- (void)onLightPowerBtnClicked:(UIButton *)btn deviceID:(int)deviceID {
    [SQLManager updateDevicePowerStatus:deviceID power:btn.selected];
    [self refreshPlaneGraph];
}

- (void)onLightSliderValueChanged:(UISlider *)slider deviceID:(int)deviceID {
    [SQLManager updateDeviceBrightStatus:deviceID value:slider.value];
    [self refreshPlaneGraph];
}

#pragma mark - PowerLightCellDelegate
- (void)onPowerLightPowerBtnClicked:(UIButton *)btn deviceID:(int)deviceID {
    [SQLManager updateDevicePowerStatus:deviceID power:btn.selected];
    [self refreshPlaneGraph];
}

#pragma mark - NewColourCellDelegate
- (void)onColourSwitchBtnClicked:(UIButton *)btn deviceID:(int)deviceID {
    [SQLManager updateDevicePowerStatus:deviceID power:btn.selected];
    [self refreshPlaneGraph];
}

#pragma mark - CurtainTableViewCellDelegate
- (void)onCurtainOpenBtnClicked:(UIButton *)btn deviceID:(int)deviceID {
    [SQLManager updateCurtainPowerStatus:deviceID power:btn.selected];
}

- (void)onCurtainSliderBtnValueChanged:(UISlider *)slider deviceID:(int)deviceID {
    [SQLManager updateCurtainPositionStatus:deviceID value:slider.value];
}

#pragma mark - BjMusicTableViewCellDelegate
- (void)onBjPowerButtonClicked:(UIButton *)btn deviceID:(int)deviceID {
    [SQLManager updateDevicePowerStatus:deviceID power:btn.selected];
}

#pragma mark - OtherTableViewCellDelegate
- (void)onOtherSwitchBtnClicked:(UIButton *)btn deviceID:(int)deviceID {
    [SQLManager updateDevicePowerStatus:deviceID power:btn.selected];
    [self refreshPlaneGraph];
}

- (void)dealloc {
    [NC removeObserver:self];
}

@end
