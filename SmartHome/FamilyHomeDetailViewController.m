//
//  FamilyHomeDetailViewController.m
//  SmartHome
//
//  Created by KobeBryant on 2017/4/18.
//  Copyright © 2017年 Ecloud. All rights reserved.
//

#import "FamilyHomeDetailViewController.h"

@interface FamilyHomeDetailViewController ()

@end

@implementation FamilyHomeDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    [self getAllScenes];//获取所有场景
    [self getAllDevices];//获取所有设备
    [self getDeviceStateInfoByTcp];//TCP 获取所有设备状态
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [LoadMaskHelper showMaskWithType:FamilyHomeDetail onView:self.tabBarController.view delay:0.5 delegate:self];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [NC postNotificationName:@"refreshRoomDeviceStatusNotification" object:nil];
}

- (void)initUI {
    _isGloom = NO;
    _isRomantic = NO;
    _isSprightly = NO;
    [self.softButton setBackgroundImage:[UIImage imageNamed:@"btn_pressed"] forState:UIControlStateSelected];
    [self.normalButton setBackgroundImage:[UIImage imageNamed:@"btn_pressed"] forState:UIControlStateSelected];
    [self.brightButton setBackgroundImage:[UIImage imageNamed:@"btn_pressed"] forState:UIControlStateSelected];
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
    
    
    [self adjustUI];
}

- (void)adjustUI {
    
    CGFloat leadingGap = 20;
    CGFloat trailingGap = 20;
    CGFloat centerGap = 0;
    CGFloat btnWidth = (UI_SCREEN_WIDTH-leadingGap-trailingGap-centerGap*2)/3;
    
    self.softBtnLeading.constant = leadingGap;
    self.softBtnWidth.constant = btnWidth;
    self.normalBtnLeading.constant = self.softBtnLeading.constant+self.softBtnWidth.constant;
    self.normalBtnWidth.constant = self.softBtnWidth.constant;
    self.brightBtnLeading.constant = self.normalBtnLeading.constant+self.normalBtnWidth.constant;
    self.brightBtnWidth.constant = self.softBtnWidth.constant;
    
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        
        centerGap = 80;
        btnWidth = (UI_SCREEN_WIDTH*3/4-leadingGap-trailingGap-centerGap*2)/3;
        
        
        
        
        self.tableViewLeading.constant = UI_SCREEN_WIDTH/4 + 20;
        self.tableViewTop.constant = 130;
        self.tableViewBottom.constant = 80;
        self.collectionViewTop.constant = 64;
        self.collectionViewTrailing.constant = UI_SCREEN_WIDTH*3/4;
        self.collectionViewLeading.constant = 0;
        self.collectionViewHeight.constant = UI_SCREEN_HEIGHT-80-64;
        [self.collectionViewFlowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        self.softBtnLeading.constant = self.tableViewLeading.constant;
        self.softBtnWidth.constant = btnWidth;
        self.normalBtnLeading.constant = self.softBtnLeading.constant+self.softBtnWidth.constant+centerGap;
        self.normalBtnWidth.constant = self.softBtnWidth.constant;
        self.brightBtnLeading.constant = self.normalBtnLeading.constant+self.normalBtnWidth.constant+centerGap;
        self.brightBtnWidth.constant = self.softBtnWidth.constant;
        
        
    }
}

- (void)countOfDeviceType {
    _deviceType_count = [SQLManager numbersOfDeviceType];
}

- (void)getAllDevices {
    
    //获取设备类型数量
    [self countOfDeviceType];
    
    //if (_deviceType_count >0) {
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
        
        
        [self.deviceTableView reloadData];
    //}
}

- (void)getAllScenes {
    NSArray *sceneArray = [SQLManager getAllSceneWithRoomID:(int)self.roomID];
    _sceneArray = [NSMutableArray array];
    if (sceneArray) {
        [_sceneArray addObjectsFromArray:sceneArray];
    }
    
    [self.sceneListCollectionView reloadData];
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

- (IBAction)softBtnClicked:(id)sender {
    UIButton *btn = (UIButton *)sender;
    if (!btn.selected) {
        btn.selected = YES;
        _isGloom = YES;
        self.normalButton.selected = NO;
        self.brightButton.selected = NO;
        _isRomantic = NO;
        _isSprightly = NO;
        
        if (_lightArray.count >0) {
            [[SceneManager defaultManager] gloomForRoomLights:_lightArray];
        }
        
        [self.deviceTableView reloadData];
    }
}

- (IBAction)normalBtnClicked:(id)sender {
    UIButton *btn = (UIButton *)sender;
    if (!btn.selected) {
        btn.selected = YES;
        _isRomantic = YES;
        self.softButton.selected = NO;
        self.brightButton.selected = NO;
        _isGloom = NO;
        _isSprightly = NO;
        
        if (_lightArray.count >0) {
            [[SceneManager defaultManager] romanticForRoomLights:_lightArray];
        }
        
        [self.deviceTableView reloadData];
    }
}

- (IBAction)brightBtnClicked:(id)sender {
    UIButton *btn = (UIButton *)sender;
    if (!btn.selected) {
        btn.selected = YES;
        _isSprightly = YES;
        self.softButton.selected = NO;
        self.normalButton.selected = NO;
        _isGloom = NO;
        _isRomantic = NO;
        
        if (_lightArray.count >0) {
            [[SceneManager defaultManager] sprightlyForRoomLights:_lightArray];
        }
        
        [self.deviceTableView reloadData];
    }
}

#pragma  mark - UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.sceneArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FamilyHomeDetailSceneCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"familySceneCell" forIndexPath:indexPath];
    
    Scene *scene = self.sceneArray[indexPath.row];
    [cell.sceneButton sd_setBackgroundImageWithURL:[NSURL URLWithString:scene.picName] forState:UIControlStateNormal];
    [cell.sceneButton setTitle:scene.sceneName forState:UIControlStateNormal];
    
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    Scene *scene = self.sceneArray[indexPath.row];
    
    if (ON_IPAD) {
        IpadDeviceListViewController * listVC = [[IpadDeviceListViewController alloc] init];
        listVC.roomID = (int)scene.roomID;
        listVC.sceneID = scene.sceneID;
        [self.navigationController pushViewController:listVC animated:YES];
    }else {
    
    UIStoryboard *iphoneStoryBoard = [UIStoryboard storyboardWithName:@"iPhone" bundle:nil];
    [[SceneManager defaultManager] startScene:scene.sceneID];
    IphoneEditSceneController *vc = [iphoneStoryBoard instantiateViewControllerWithIdentifier:@"IphoneEditSceneController"];
    vc.sceneID = scene.sceneID;
    vc.roomID = (int)scene.roomID;
    [self.navigationController pushViewController:vc animated:YES];
  }
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return CGSizeMake(iPadSceneCellWidth, iPadSceneCellHeight);
    }else {
        return CGSizeMake(SceneCellWidth, SceneCellHeight);
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return CollectionCellSpace;
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return minimumLineSpacing;
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
        return _environmentArray.count;//环境（空调）
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
            powerCell.selectionStyle = UITableViewCellSelectionStyleNone;
            powerCell.backgroundColor = [UIColor clearColor];
            powerCell.powerBtnConstraint.constant = 10;
            powerCell.powerLightNameLabel.text = device.name;
            powerCell.addPowerLightBtn.hidden = YES;
            powerCell.deviceid = _lightArray[indexPath.row];
            powerCell.powerLightBtn.selected = device.power;//开关状态
            
            if (_isGloom || _isRomantic || _isSprightly) {
                powerCell.powerLightBtn.selected = YES;
            }
            
            return powerCell;
            
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
            if (_isGloom) {
                cell.NewLightPowerBtn.selected = YES;//开关状态
                cell.NewLightSlider.value = 20.0f/100.0f;//亮度状态
            }else if (_isRomantic) {
                cell.NewLightPowerBtn.selected = YES;//开关状态
                cell.NewLightSlider.value = 50.0f/100.0f;//亮度状态
            }else if (_isSprightly) {
                cell.NewLightPowerBtn.selected = YES;//开关状态
                cell.NewLightSlider.value = 90.0f/100.0f;//亮度状态
            }
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
            if (_isGloom || _isRomantic || _isSprightly) {
                cell.colourBtn.selected = YES;
            }
            //颜色状态暂不做，slider不好控制
            return cell;
        }
        
    }else if (indexPath.section == 1) {//窗帘
        CurtainTableViewCell *curtainCell = [tableView dequeueReusableCellWithIdentifier:@"CurtainTableViewCell" forIndexPath:indexPath];
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
            otherCell.backgroundColor =[UIColor clearColor];
            otherCell.selectionStyle = UITableViewCellSelectionStyleNone;
            otherCell.AddOtherBtn.hidden = YES;
            otherCell.OtherConstraint.constant = 10;
            otherCell.NameLabel.text = device.name;
            otherCell.OtherSwitchBtn.selected = device.power;//开关
            otherCell.deviceid = [NSString stringWithFormat:@"%d", device.eID];
            return otherCell;
        }
        
    }else if (indexPath.section == 3) {//影音
        Device *device = [SQLManager getDeviceWithDeviceID:[_multiMediaArray[indexPath.row] intValue]];
        
        if (device.hTypeId == 14) { //背景音乐
            BjMusicTableViewCell * BjMusicCell = [tableView dequeueReusableCellWithIdentifier:@"BjMusicTableViewCell" forIndexPath:indexPath];
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
                dvdCell.DVDSlider.value = device.volume;//音量
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
            FMCell.FMSlider.value = device.volume;//音量
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
                tvCell.TVSlider.value = device.volume;//音量
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
                tvCell.TVSlider.value = device.volume;//音量
                tvCell.deviceid = [NSString stringWithFormat:@"%d", device.eID];
                return tvCell;
            }
            
            
        }else if (device.hTypeId == 18) { //功放
            OtherTableViewCell * otherCell = [tableView dequeueReusableCellWithIdentifier:@"OtherTableViewCell" forIndexPath:indexPath];
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
            return 150;
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

- (void)getDeviceStateInfoByTcp {
    
    //查询所有的设备ID
    NSArray *devIDs = [SQLManager getDeviceIDsByRid:self.roomID];
    
    NSMutableArray *deviceIDs = [[NSMutableArray alloc] init];
    if (devIDs.count >0) {
        [deviceIDs addObjectsFromArray:devIDs];
    }
    
    SocketManager *sock = [SocketManager defaultManager];
    sock.delegate = self;
    
    [deviceIDs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        NSData *data = [[DeviceInfo defaultManager] query:[obj stringValue]];
        [sock.socket writeData:data withTimeout:1 tag:1];
    }];
}

#pragma mark - TCP recv delegate
-(void)recv:(NSData *)data withTag:(long)tag
{
    Proto proto=protocolFromData(data);
    if (CFSwapInt16BigToHost(proto.masterID) != [[DeviceInfo defaultManager] masterID]) {
        return;
    }
    //同步设备状态
    if(proto.cmd == 0x01) {
        
        NSString *devID=[SQLManager getDeviceIDByENumber:CFSwapInt16BigToHost(proto.deviceID)];
        Device *device = [SQLManager getDeviceWithDeviceID:devID.intValue];
        
        if (device) {
            device.actionState = proto.action.state;
            
            if(proto.action.state == 0x6A) { //温度
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
            }
            
            [SQLManager updateDeviceStatus:device];
            
            [self.deviceTableView reloadData];//刷新UI
        }
        
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

#pragma mark - SingleMaskViewDelegate
- (void)onNextButtonClicked:(UIButton *)btn pageType:(PageTye)pageType {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)onSkipButtonClicked:(UIButton *)btn pageType:(PageTye)pageType {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)onTransparentBtnClicked:(UIButton *)btn {
    
    if (btn.tag == 1) { //柔和
        
    }else if (btn.tag == 2) {  //正常
        
        
    }else if (btn.tag == 3) {  //明亮
        
        
    }
    
}

@end
