//
//  IphoneNewAddSceneVC.m
//  SmartHome
//
//  Created by zhaona on 2017/4/6.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "IphoneNewAddSceneVC.h"
#import "IphoneRoomView.h"
#import "Room.h"
#import "SQLManager.h"
#import "MBProgressHUD+NJ.h"
#import "IphoneNewAddSceneCell.h"
#import "IphoneSaveNewSceneController.h"
#import "LightCell.h"
#import "CurtainTableViewCell.h"
#import "DVDTableViewCell.h"
#import "AireTableViewCell.h"
#import "BjMusicTableViewCell.h"
#import "ScreenCurtainCell.h"
#import "ScreenTableViewCell.h"
#import "OtherTableViewCell.h"
#import "TVTableViewCell.h"
#import "NewColourCell.h"
#import "NewLightCell.h"
#import "FMTableViewCell.h"

@interface IphoneNewAddSceneVC ()<UITableViewDelegate,UITableViewDataSource,IphoneRoomViewDelegate>

@property (weak, nonatomic) IBOutlet IphoneRoomView *roomView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSArray * deviceArr;
@property (nonatomic,strong) NSArray * roomList;
@property (nonatomic, assign) int roomIndex;
@property (nonatomic,strong) NSArray *devices;
@property (nonatomic,strong) UIButton * naviRightBtn;
@property(nonatomic,strong)  NSArray * lightArr;//灯光
@property (nonatomic,strong) NSMutableArray * AirArray;//空调
@property (nonatomic,strong) NSMutableArray * TVArray;//TV
@property (nonatomic,strong) NSMutableArray * FMArray;//FM
@property (nonatomic,strong) NSMutableArray * CurtainArray;//窗帘
@property (nonatomic,strong) NSMutableArray * DVDArray;//DVD
@property (nonatomic,strong) NSMutableArray * OtherArray;//其他
@property (nonatomic,strong) NSMutableArray * LockArray;//智能门锁
@property (nonatomic,strong) NSMutableArray * ColourLightArr;//调色
@property (nonatomic,strong) NSMutableArray * SwitchLightArr;//开关
@property (nonatomic,strong) NSMutableArray * lightArray;//调光
@property (nonatomic,strong) NSMutableArray * PluginArray;//智能单品
@property (nonatomic,strong) NSMutableArray * NetVArray;//机顶盒
@property (nonatomic,strong) NSMutableArray * CameraArray;//摄像头
@property (nonatomic,strong) NSMutableArray * ProjectArray;//投影机
@property (nonatomic,strong) NSMutableArray * BJMusicArray;//背景音乐
@property (nonatomic,strong) NSMutableArray * MBArray;//幕布
@property (nonatomic,strong) NSMutableArray * IntelligentArray;//智能推窗器
@property (nonatomic,strong) NSMutableArray * PowerArray;//功放
@property (nonatomic,assign) NSInteger htypeID;

@end

@implementation IphoneNewAddSceneVC
-(NSArray *)deviceArr
{
    if (_deviceArr == nil) {
        _deviceArr = [NSArray array];
    }
    return _deviceArr;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

      self.roomList = [SQLManager getDevicesSubTypeNamesWithRoomID:self.roomID];
      [self setUpRoomView];
//          [self reachNotification];
    UIView *view = [[UIView alloc] init];
    [view setBackgroundColor:[UIColor clearColor]];
    self.tableView.tableFooterView = view;
    [self setupNaviBar];
    [self.tableView registerNib:[UINib nibWithNibName:@"AireTableViewCell" bundle:nil] forCellReuseIdentifier:@"AireTableViewCell"];//空调
    [self.tableView registerNib:[UINib nibWithNibName:@"CurtainTableViewCell" bundle:nil] forCellReuseIdentifier:@"CurtainTableViewCell"];//窗帘
    [self.tableView registerNib:[UINib nibWithNibName:@"TVTableViewCell" bundle:nil] forCellReuseIdentifier:@"TVTableViewCell"];//网络电视
    [self.tableView registerNib:[UINib nibWithNibName:@"NewColourCell" bundle:nil] forCellReuseIdentifier:@"NewColourCell"];//调色灯
    [self.tableView registerNib:[UINib nibWithNibName:@"OtherTableViewCell" bundle:nil] forCellReuseIdentifier:@"OtherTableViewCell"];//其他
    [self.tableView registerNib:[UINib nibWithNibName:@"ScreenTableViewCell" bundle:nil] forCellReuseIdentifier:@"ScreenTableViewCell"];//幕布ScreenCurtainCell
    [self.tableView registerNib:[UINib nibWithNibName:@"ScreenCurtainCell" bundle:nil] forCellReuseIdentifier:@"ScreenCurtainCell"];//幕布ScreenCurtainCell
    [self.tableView registerNib:[UINib nibWithNibName:@"DVDTableViewCell" bundle:nil] forCellReuseIdentifier:@"DVDTableViewCell"];//DVD
    [self.tableView registerNib:[UINib nibWithNibName:@"BjMusicTableViewCell" bundle:nil] forCellReuseIdentifier:@"BjMusicTableViewCell"];//背景音乐
     [self.tableView registerNib:[UINib nibWithNibName:@"NewLightCell" bundle:nil] forCellReuseIdentifier:@"NewLightCell"];//背景音乐
    [self.tableView registerNib:[UINib nibWithNibName:@"FMTableViewCell" bundle:nil] forCellReuseIdentifier:@"FMTableViewCell"];//FM
}
- (void)setupNaviBar {
    [self setNaviBarTitle:@"添加场景"]; //设置标题
    _naviRightBtn = [CustomNaviBarView createNormalNaviBarBtnByTitle:@"保存" target:self action:@selector(rightBtnClicked:)];
    _naviRightBtn.tintColor = [UIColor whiteColor];
//    [self setNaviBarLeftBtn:_naviLeftBtn];
    [self setNaviBarRightBtn:_naviRightBtn];
}
-(void)rightBtnClicked:(UIButton *)bbi
{
   UIStoryboard * iphoneStoryBoard = [UIStoryboard storyboardWithName:@"iPhone" bundle:nil];
    IphoneSaveNewSceneController * iphoneSaveNewScene = [iphoneStoryBoard instantiateViewControllerWithIdentifier:@"IphoneSaveNewSceneController"];
    // [self presentViewController:iphoneSaveNewScene animated:YES completion:nil];
    [self.navigationController pushViewController:iphoneSaveNewScene animated:YES];
      //[self performSegueWithIdentifier:@"iphoneAddNewScene" sender:self];
}
-(void)setUpRoomView
{
    NSMutableArray *roomNames = [NSMutableArray array];
    
    for (NSString *subTypeStr in self.roomList) {
        if([subTypeStr isEqualToString:@"灯光"]){
            [roomNames addObject:subTypeStr];
        }if ([subTypeStr isEqualToString:@"影音"]) {
            [roomNames addObject:subTypeStr];
        }if([subTypeStr isEqualToString:@"环境"]){
            [roomNames addObject:subTypeStr];
        }if([subTypeStr isEqualToString:@"安防"]){
            [roomNames addObject:subTypeStr];
        }if([subTypeStr isEqualToString:@"智能单品"]){
            [roomNames addObject:subTypeStr];
        }if ([subTypeStr isEqualToString:@"窗帘"]) {
             [roomNames addObject:subTypeStr];
        }
    }
    self.roomView.dataArray = roomNames;
    
    self.roomView.delegate = self;
    
    [self.roomView setSelectButton:0];
    
    [self iphoneRoomView:self.roomView didSelectButton:0];
     [self.tableView reloadData];
}
- (void)iphoneRoomView:(UIView *)view didSelectButton:(int)index
{
    _lightArray = [[NSMutableArray alloc] init];
    _ColourLightArr = [[NSMutableArray alloc] init];
    _SwitchLightArr = [[NSMutableArray alloc] init];
    _CurtainArray = [[NSMutableArray alloc] init];
    _AirArray = [[NSMutableArray alloc] init];
    _FMArray = [[NSMutableArray alloc] init];
    _TVArray = [[NSMutableArray alloc] init];
    _LockArray = [[NSMutableArray alloc] init];
    _DVDArray = [[NSMutableArray alloc] init];
    _OtherArray = [[NSMutableArray alloc] init];
    _NetVArray = [[NSMutableArray alloc] init];
    _CameraArray = [[NSMutableArray alloc] init];
    _ProjectArray = [[NSMutableArray alloc] init];
    _PluginArray = [[NSMutableArray alloc] init];
    _BJMusicArray = [[NSMutableArray alloc] init];
    _MBArray = [[NSMutableArray alloc] init];
    _PowerArray =[[NSMutableArray alloc] init];
    _IntelligentArray = [[NSMutableArray alloc] init];
    _ColourLightArr = [[NSMutableArray alloc] init];
    _SwitchLightArr = [[NSMutableArray alloc] init];
    self.roomIndex = index;
    if (self.roomList.count == 0) {
        [MBProgressHUD showError:@"该房间没有设备"];
    }else{
        NSString * selectSubTypeStr = self.roomList[index];

        self.devices = [SQLManager getDevicesIDWithRoomID:self.roomID SubTypeName:selectSubTypeStr];
        for (int i = 0; i < self.devices.count; i ++) {
            _htypeID = [SQLManager deviceHtypeIDByDeviceID:[self.devices[i] intValue]];
            if (_htypeID == 2) {//调光灯
                [_lightArray addObject:self.devices[i]];
            }else if (_htypeID == 1){//开关灯
                [_SwitchLightArr addObject:self.devices[i]];
            }else if (_htypeID == 3){//调色灯
                [_ColourLightArr addObject:self.devices[i]];
            }else if (_htypeID == 31){//空调
                [_AirArray addObject:self.devices[i]];
            }else if (_htypeID == 21){//窗帘
                [_CurtainArray addObject:self.devices[i]];
            }else if (_htypeID == 0){//FM
                [_FMArray addObject:self.devices[i]];
            }else if (_htypeID == 12){//网路电视
                [_TVArray addObject:self.devices[i]];
            }else if (_htypeID == 13){//DVD
                [_DVDArray addObject:self.devices[i]];
            }else if (_htypeID == 16){//投影幕
                [_ProjectArray addObject:self.devices[i]];
            }else if (_htypeID == 11){//机顶盒
                [_NetVArray addObject:self.devices[i]];
            }else if (_htypeID == 14){//背景音乐
                [_BJMusicArray addObject:self.devices[i]];
            }else if (_htypeID == 17){//幕布
                [_MBArray addObject:self.devices[i]];
            }else{
                [_OtherArray addObject:self.devices[i]];
            }
        }
    }
     [self.tableView reloadData];
}
- (void)reachNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subTypeNotification:) name:@"subType" object:nil];
}
- (void)subTypeNotification:(NSNotification *)notification
{
    NSDictionary *dict = notification.userInfo;
    
    self.roomID = [dict[@"subType"] intValue];
    
    self.devices = [SQLManager getScensByRoomId:self.roomID];
    
    //    [self setUpSceneButton];
    //    [self judgeScensCount:self.scenes];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma UITableViewDelegate的代理
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 13;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    return _devices.count;
    if (section == 0) {
        return _lightArray.count;//调光灯
    }if (section == 1){//调色灯
        return _ColourLightArr.count;
    }if (section == 2){//开关灯
        return _SwitchLightArr.count;
    }if (section == 3){
        return _AirArray.count;//空调
    }if (section == 4){
        return _CurtainArray.count;//窗帘
    }if (section == 5){
        return _TVArray.count;//TV
    }if (section == 6){
        return _DVDArray.count;//DVD
    }if (section == 7){
        return _ProjectArray.count;//投影
    }if (section == 8){
        return _FMArray.count;//FM
    }if (section == 9){
        return _NetVArray.count;//机顶盒
    }if (section == 10){
        return _MBArray.count;//幕布
    }if (section == 11){
        return _BJMusicArray.count;//背景音乐
    }
        return _OtherArray.count;//其他
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {//调灯光
        NewLightCell * cell = [tableView dequeueReusableCellWithIdentifier:@"NewLightCell" forIndexPath:indexPath];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
       // cell.roomID = self.roomID;
//        cell.sceneID = self.sceneid;
        Device * device = [SQLManager getDeviceWithDeviceHtypeID:[_lightArray[indexPath.row] intValue]];
        cell.NewLightNameLabel.text = device.name;
        cell.NewLightSlider.continuous = NO;
        cell.deviceid = _lightArray[indexPath.row];
        
        return cell;
    }if (indexPath.section == 1) {//调色灯
        NewColourCell * newColourCell = [tableView dequeueReusableCellWithIdentifier:@"NewColourCell" forIndexPath:indexPath];
        newColourCell.backgroundColor =[UIColor clearColor];
         Device * device = [SQLManager getDeviceWithDeviceHtypeID:[_ColourLightArr[indexPath.row] intValue]];
        newColourCell.colourNameLabel.text = device.name;
        
        return newColourCell;
    }if (indexPath.section == 2) {//开关灯
        NewColourCell * newColourCell = [tableView dequeueReusableCellWithIdentifier:@"NewColourCell" forIndexPath:indexPath];
        newColourCell.backgroundColor =[UIColor clearColor];
         Device * device = [SQLManager getDeviceWithDeviceHtypeID:[_SwitchLightArr[indexPath.row] intValue]];
        newColourCell.colourNameLabel.text = device.name;
        newColourCell.supimageView.hidden = YES;
        newColourCell.lowImageView.hidden = YES;
        newColourCell.highImageView.hidden = YES;
        
        return newColourCell;
    }if (indexPath.section == 3) {//空调
        AireTableViewCell * aireCell = [tableView dequeueReusableCellWithIdentifier:@"AireTableViewCell" forIndexPath:indexPath];
        aireCell.backgroundColor =[UIColor clearColor];
        aireCell.roomID = self.roomID;
//        aireCell.sceneID = self.sceneid;
         Device * device = [SQLManager getDeviceWithDeviceHtypeID:[_AirArray[indexPath.row] intValue]];
        aireCell.AireNameLabel.text = device.name;
        aireCell.deviceid = _AirArray[indexPath.row];
        
        return aireCell;
    }if (indexPath.section == 4) {//窗帘
        CurtainTableViewCell * aireCell = [tableView dequeueReusableCellWithIdentifier:@"CurtainTableViewCell" forIndexPath:indexPath];
        aireCell.backgroundColor = [UIColor clearColor];
        aireCell.roomID = self.roomID;
//        aireCell.sceneID = self.sceneid;
          Device * device = [SQLManager getDeviceWithDeviceHtypeID:[_CurtainArray[indexPath.row] intValue]];
        aireCell.label.text = device.name;
        aireCell.deviceid = _CurtainArray[indexPath.row];
        
        return aireCell;
    }if (indexPath.section == 5) {//TV
        TVTableViewCell * TVCell = [tableView dequeueReusableCellWithIdentifier:@"TVTableViewCell" forIndexPath:indexPath];
      //  TVCell.TVConstraint.constant= 10;
        TVCell.backgroundColor =[UIColor clearColor];
        Device * device = [SQLManager getDeviceWithDeviceHtypeID:[_TVArray[indexPath.row] intValue]];
        TVCell.TVNameLabel.text = device.name;
        
        return TVCell;
    }if (indexPath.section == 6) {//DVD
        DVDTableViewCell * DVDCell = [tableView dequeueReusableCellWithIdentifier:@"DVDTableViewCell" forIndexPath:indexPath];
        DVDCell.backgroundColor =[UIColor clearColor];
          Device * device = [SQLManager getDeviceWithDeviceHtypeID:[_DVDArray[indexPath.row] intValue]];
        DVDCell.DVDNameLabel.text = device.name;
        
        return DVDCell;
    }if (indexPath.section == 7) {//投影机
        ScreenCurtainCell * ScreenCell = [tableView dequeueReusableCellWithIdentifier:@"ScreenCurtainCell" forIndexPath:indexPath];
        ScreenCell.backgroundColor =[UIColor clearColor];
          Device * device = [SQLManager getDeviceWithDeviceHtypeID:[_ProjectArray[indexPath.row] intValue]];
        ScreenCell.ScreenCurtainLabel.text = device.name;
        
        return ScreenCell;
    }if (indexPath.section == 8) {//FM
        FMTableViewCell * FMCell = [tableView dequeueReusableCellWithIdentifier:@"FMTableViewCell" forIndexPath:indexPath];
        FMCell.backgroundColor =[UIColor clearColor];
         Device * device = [SQLManager getDeviceWithDeviceHtypeID:[_FMArray[indexPath.row] intValue]];
        FMCell.FMNameLabel.text = device.name;
        
        return FMCell;
    }if (indexPath.section == 9) {//机顶盒
        OtherTableViewCell * otherCell = [tableView dequeueReusableCellWithIdentifier:@"OtherTableViewCell" forIndexPath:indexPath];
        otherCell.backgroundColor =[UIColor clearColor];
        Device * device = [SQLManager getDeviceWithDeviceHtypeID:[_NetVArray[indexPath.row] intValue]];
        otherCell.NameLabel.text = device.name;
        
        return otherCell;
    }if (indexPath.section == 10) {//幕布
        OtherTableViewCell * otherCell = [tableView dequeueReusableCellWithIdentifier:@"OtherTableViewCell" forIndexPath:indexPath];
        otherCell.backgroundColor = [UIColor clearColor];
        Device * device = [SQLManager getDeviceWithDeviceHtypeID:[_MBArray[indexPath.row] intValue]];
        otherCell.NameLabel.text = device.name;
        
        return otherCell;
    }if (indexPath.section == 11) {//背景音乐
        BjMusicTableViewCell * BjMusicCell = [tableView dequeueReusableCellWithIdentifier:@"BjMusicTableViewCell" forIndexPath:indexPath];
        BjMusicCell.backgroundColor = [UIColor clearColor];
        Device * device = [SQLManager getDeviceWithDeviceHtypeID:[_BJMusicArray[indexPath.row] intValue]];
        BjMusicCell.BjMusicNameLb.text = device.name;
        
        return BjMusicCell;
    }
        OtherTableViewCell * otherCell = [tableView dequeueReusableCellWithIdentifier:@"OtherTableViewCell" forIndexPath:indexPath];
        otherCell.backgroundColor = [UIColor clearColor];
        if (_OtherArray.count) {
            Device * device = [SQLManager getDeviceWithDeviceHtypeID:[_OtherArray[indexPath.row] intValue]];
            if (device.name == nil) {
                otherCell.NameLabel.text = @"";
            }else{
                otherCell.NameLabel.text = device.name;
            }
        }
        return otherCell;
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 5 || indexPath.section == 6 || indexPath.section == 8) {
        return 150;
    }
    if (indexPath.section == 9 || indexPath.section == 10 || indexPath.section == 12 ) {
        return 50;
    }
    return 100;
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
