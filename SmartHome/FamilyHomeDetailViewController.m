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
}

- (void)initUI {
    
    [self.softButton setBackgroundImage:[UIImage imageNamed:@"btn_pressed"] forState:UIControlStateSelected];
    [self.normalButton setBackgroundImage:[UIImage imageNamed:@"btn_pressed"] forState:UIControlStateSelected];
    [self.brightButton setBackgroundImage:[UIImage imageNamed:@"btn_pressed"] forState:UIControlStateSelected];
    [self setNaviBarTitle:self.roomName];
    
    [self.deviceTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    UIImageView *bg = [[UIImageView alloc] initWithFrame:self.deviceTableView.bounds];
    bg.image = [UIImage imageNamed:@"background"];
    [self.deviceTableView setBackgroundView:bg];
    
    [self.deviceTableView registerNib:[UINib nibWithNibName:@"NewLightCell" bundle:nil] forCellReuseIdentifier:@"NewLightCell"];//灯光
    [self.deviceTableView registerNib:[UINib nibWithNibName:@"AireTableViewCell" bundle:nil] forCellReuseIdentifier:@"AireTableViewCell"];//空调
    [self.deviceTableView registerNib:[UINib nibWithNibName:@"CurtainTableViewCell" bundle:nil] forCellReuseIdentifier:@"CurtainTableViewCell"];//窗帘
    [self.deviceTableView registerNib:[UINib nibWithNibName:@"TVTableViewCell" bundle:nil] forCellReuseIdentifier:@"TVTableViewCell"];//网络电视
    [self.deviceTableView registerNib:[UINib nibWithNibName:@"NewColourCell" bundle:nil] forCellReuseIdentifier:@"NewColourCell"];//调色灯
    [self.deviceTableView registerNib:[UINib nibWithNibName:@"OtherTableViewCell" bundle:nil] forCellReuseIdentifier:@"OtherTableViewCell"];//其他
    [self.deviceTableView registerNib:[UINib nibWithNibName:@"ScreenTableViewCell" bundle:nil] forCellReuseIdentifier:@"ScreenTableViewCell"];//投影仪ScreenTableViewCell
    [self.deviceTableView registerNib:[UINib nibWithNibName:@"ScreenCurtainCell" bundle:nil] forCellReuseIdentifier:@"ScreenCurtainCell"];//幕布ScreenCurtainCell
    [self.deviceTableView registerNib:[UINib nibWithNibName:@"DVDTableViewCell" bundle:nil] forCellReuseIdentifier:@"DVDTableViewCell"];//DVD
    [self.deviceTableView registerNib:[UINib nibWithNibName:@"BjMusicTableViewCell" bundle:nil] forCellReuseIdentifier:@"BjMusicTableViewCell"];//背景音乐
    [self.deviceTableView registerNib:[UINib nibWithNibName:@"FMTableViewCell" bundle:nil] forCellReuseIdentifier:@"FMTableViewCell"];//FM收音机
}

- (void)countOfDeviceType {
    _deviceType_count = [SQLManager numbersOfDeviceType];
}

- (void)getAllDevices {
    
    //获取设备类型数量
    [self countOfDeviceType];
    
    if (_deviceType_count >0) {
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
            NSString *deviceTypeName = [SQLManager deviceTypeNameByDeviceID:[_deviceIDArray[i] intValue]];
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
    }
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
        self.normalButton.selected = NO;
        self.brightButton.selected = NO;
        
        if (_lightArray.count >0) {
            [[SceneManager defaultManager] gloomForRoomLights:_lightArray];
        }
    }
}

- (IBAction)normalBtnClicked:(id)sender {
    UIButton *btn = (UIButton *)sender;
    if (!btn.selected) {
        btn.selected = YES;
        self.softButton.selected = NO;
        self.brightButton.selected = NO;
        
        if (_lightArray.count >0) {
            [[SceneManager defaultManager] romanticForRoomLights:_lightArray];
        }
    }
}

- (IBAction)brightBtnClicked:(id)sender {
    UIButton *btn = (UIButton *)sender;
    if (!btn.selected) {
        btn.selected = YES;
        self.softButton.selected = NO;
        self.normalButton.selected = NO;
        
        if (_lightArray.count >0) {
            [[SceneManager defaultManager] sprightlyForRoomLights:_lightArray];
        }
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
    UIStoryboard *iphoneStoryBoard = [UIStoryboard storyboardWithName:@"iPhone" bundle:nil];
    //[self.navigationController popToRootViewControllerAnimated:YES];
    
    Scene *scene = self.sceneArray[indexPath.row];
    [[SceneManager defaultManager] startScene:scene.sceneID];
    IphoneEditSceneController *vc = [iphoneStoryBoard instantiateViewControllerWithIdentifier:@"IphoneEditSceneController"];
    vc.sceneID = scene.sceneID;
    [self.navigationController pushViewController:vc animated:YES];
    
    /*UIStoryboard * storyBoard = [UIStoryboard storyboardWithName:@"Family" bundle:nil];
    FamilyHomeDetailViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"familyHomeDetailVC"];
    RoomStatus *roomInfo = self.roomArray[indexPath.row];
    vc.roomID = roomInfo.roomId;
    vc.roomName = roomInfo.roomName;
    [self.navigationController pushViewController:vc animated:YES];*/
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(SceneCellWidth, SceneCellHeight);
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
    return _deviceType_count-2;
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
            return aireCell;
        }else { //环境的其他类型
            OtherTableViewCell * otherCell = [tableView dequeueReusableCellWithIdentifier:@"OtherTableViewCell" forIndexPath:indexPath];
            otherCell.backgroundColor =[UIColor clearColor];
            otherCell.selectionStyle = UITableViewCellSelectionStyleNone;
            otherCell.AddOtherBtn.hidden = YES;
            otherCell.OtherConstraint.constant = 10;
            otherCell.NameLabel.text = device.name;
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
            return BjMusicCell;
        }else if (device.hTypeId == 13) { //DVD
            DVDTableViewCell * dvdCell = [tableView dequeueReusableCellWithIdentifier:@"DVDTableViewCell" forIndexPath:indexPath];
            dvdCell.backgroundColor =[UIColor clearColor];
            dvdCell.selectionStyle = UITableViewCellSelectionStyleNone;
            dvdCell.AddDvdBtn.hidden = YES;
            dvdCell.DVDConstraint.constant = 10;
            dvdCell.DVDNameLabel.text = device.name;
            return dvdCell;
        }else if (device.hTypeId == 15) { //FM收音机
            FMTableViewCell * FMCell = [tableView dequeueReusableCellWithIdentifier:@"FMTableViewCell" forIndexPath:indexPath];
            FMCell.backgroundColor =[UIColor clearColor];
            FMCell.selectionStyle = UITableViewCellSelectionStyleNone;
            FMCell.AddFmBtn.hidden = YES;
            //FMCell.ScreenCurtainConstraint.constant = 10;
            FMCell.FMNameLabel.text = device.name;
            return FMCell;
        }else if (device.hTypeId == 17) { //幕布
            ScreenCurtainCell * ScreenCell = [tableView dequeueReusableCellWithIdentifier:@"ScreenCurtainCell" forIndexPath:indexPath];
            ScreenCell.backgroundColor =[UIColor clearColor];
            ScreenCell.selectionStyle = UITableViewCellSelectionStyleNone;
            ScreenCell.AddScreenCurtainBtn.hidden = YES;
            ScreenCell.ScreenCurtainConstraint.constant = 10;
            ScreenCell.ScreenCurtainLabel.text = device.name;
            return ScreenCell;
        }else if (device.hTypeId == 16) { //投影仪(只有开关)
            OtherTableViewCell * otherCell = [tableView dequeueReusableCellWithIdentifier:@"OtherTableViewCell" forIndexPath:indexPath];
            otherCell.backgroundColor = [UIColor clearColor];
            otherCell.selectionStyle = UITableViewCellSelectionStyleNone;
            otherCell.AddOtherBtn.hidden = YES;
            otherCell.OtherConstraint.constant = 10;
            otherCell.NameLabel.text = device.name;
            return otherCell;
        }else if (device.hTypeId == 11) { //电视（以前叫机顶盒）
            TVTableViewCell * tvCell = [tableView dequeueReusableCellWithIdentifier:@"TVTableViewCell" forIndexPath:indexPath];
            tvCell.backgroundColor =[UIColor clearColor];
            tvCell.selectionStyle = UITableViewCellSelectionStyleNone;
            tvCell.AddTvDeviceBtn.hidden = YES;
            tvCell.TVConstraint.constant = 10;
            tvCell.TVNameLabel.text = device.name;
            return tvCell;
        }else if (device.hTypeId == 18) { //功放
            OtherTableViewCell * otherCell = [tableView dequeueReusableCellWithIdentifier:@"OtherTableViewCell" forIndexPath:indexPath];
            otherCell.backgroundColor =[UIColor clearColor];
            otherCell.selectionStyle = UITableViewCellSelectionStyleNone;
            otherCell.AddOtherBtn.hidden = YES;
            otherCell.OtherConstraint.constant = 10;
            otherCell.NameLabel.text = device.name;
            return otherCell;
        }else { //影音其他类型
            OtherTableViewCell * otherCell = [tableView dequeueReusableCellWithIdentifier:@"OtherTableViewCell" forIndexPath:indexPath];
            otherCell.backgroundColor =[UIColor clearColor];
            otherCell.selectionStyle = UITableViewCellSelectionStyleNone;
            otherCell.AddOtherBtn.hidden = YES;
            otherCell.OtherConstraint.constant = 10;
            otherCell.NameLabel.text = device.name;
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
    
    return nil;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) { //灯光： 1:开关灯cell高度50;   2,  3:调光灯，调色灯cell高度100
        Device *device = [SQLManager getDeviceWithDeviceID:[_lightArray[indexPath.row] intValue]];
        if (device.hTypeId == 1) {
            return 70;
        }else {
            return 100;
        }
    }
    
    else if (indexPath.section == 3) {
        Device *device = [SQLManager getDeviceWithDeviceID:[_multiMediaArray[indexPath.row] intValue]];
        
        if (device.hTypeId == 11 || device.hTypeId == 12 || device.hTypeId == 13 || device.hTypeId == 15) {
            return 150;
        }else if (device.hTypeId == 16 || device.hTypeId == 18) {
            return 50;
        }else {
            return 100;
        }
    }
    
    else if (indexPath.section == 4 /* || indexPath.section == 5 || indexPath.section == 6 */) {
        return 50;
    }
    
    
    return 100;
}


@end
