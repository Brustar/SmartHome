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

@interface IphoneNewAddSceneVC ()<UITableViewDelegate,UITableViewDataSource,IphoneRoomViewDelegate>

@property (weak, nonatomic) IBOutlet IphoneRoomView *roomView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSArray * deviceArr;
@property (nonatomic,strong) NSArray * roomList;
@property (nonatomic, assign) int roomIndex;
@property (nonatomic,strong) NSArray *devices;
@property (nonatomic,strong) UIButton * naviRightBtn;
@property(nonatomic,strong)  NSArray * lightArr;//灯光
@property (nonatomic,strong) NSArray * AirArray;//空调
@property (nonatomic,strong) NSArray * TVArray;//TV
@property (nonatomic,strong) NSArray * FMArray;//FM
@property (nonatomic,strong) NSArray * CurtainArray;//窗帘
@property (nonatomic,strong) NSArray * DVDArray;//DVD
@property (nonatomic,strong) NSArray * OtherArray;//其他
@property (nonatomic,strong) NSArray * LockArray;//智能门锁
@property (nonatomic,strong) NSArray * ColourLightArr;//调色
@property (nonatomic,strong) NSArray * SwitchLightArr;//开关
@property (nonatomic,strong) NSArray * lightArray;//调光
@property (nonatomic,strong) NSArray * PluginArray;//智能单品
@property (nonatomic,strong) NSArray * NetVArray;//机顶盒
@property (nonatomic,strong) NSArray * CameraArray;//摄像头
@property (nonatomic,strong) NSArray * ProjectArray;//投影机
@property (nonatomic,strong) NSArray * BJMusicArray;//背景音乐
@property (nonatomic,strong) NSArray * MBArray;//幕布
@property (nonatomic,strong) NSArray * IntelligentArray;//智能推窗器
@property (nonatomic,strong) NSArray * PowerArray;//功放


@end

@implementation IphoneNewAddSceneVC
-(NSArray *)deviceArr
{
    if (_deviceArr == nil) {
        _deviceArr = [NSArray array];
    }
    return _deviceArr;
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
    [self.tableView registerNib:[UINib nibWithNibName:@"OtherTableViewCell" bundle:nil] forCellReuseIdentifier:@"OtherTableViewCell"];//其他
    [self.tableView registerNib:[UINib nibWithNibName:@"ScreenTableViewCell" bundle:nil] forCellReuseIdentifier:@"ScreenTableViewCell"];//幕布ScreenCurtainCell
    [self.tableView registerNib:[UINib nibWithNibName:@"ScreenCurtainCell" bundle:nil] forCellReuseIdentifier:@"ScreenCurtainCell"];//幕布ScreenCurtainCell
    [self.tableView registerNib:[UINib nibWithNibName:@"DVDTableViewCell" bundle:nil] forCellReuseIdentifier:@"DVDTableViewCell"];//DVD
    [self.tableView registerNib:[UINib nibWithNibName:@"BjMusicTableViewCell" bundle:nil] forCellReuseIdentifier:@"BjMusicTableViewCell"];//背景音乐
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
//    UIStoryboard * iphoneStoryBoard = [UIStoryboard storyboardWithName:@"iPhone" bundle:nil];
//    IphoneSaveNewSceneController * iphoneSaveNewScene = [iphoneStoryBoard instantiateViewControllerWithIdentifier:@"IphoneSaveNewSceneController"];
////     [self presentViewController:iphoneSaveNewScene animated:YES completion:nil];
//    [self.navigationController pushViewController:iphoneSaveNewScene animated:YES];
      [self performSegueWithIdentifier:@"iphoneAddNewScene" sender:self];
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
}
- (void)iphoneRoomView:(UIView *)view didSelectButton:(int)index
{
    self.roomIndex = index;
    if (self.roomList.count == 0) {
        [MBProgressHUD showError:@"该房间没有设备"];
    }else{
        NSString * selectSubTypeStr = self.roomList[index];
        //    getDeviceTypeNameWithSubTypeName:(NSString *)subTypeName
        self.devices = [SQLManager  getDeviceTypeNameWithSubTypeName:selectSubTypeStr];
        for (NSString * TypeName in self.devices) {
            if ([TypeName isEqualToString:@"背景音乐"]) {
//                _BJMusicArray = [SQLManager deviceSubTypeByRoomId:self.roomID];
                _BJMusicArray = [SQLManager getDeviceBysubTypeName:@"背景音乐" andRoomID:self.roomID];
            } if ([TypeName isEqualToString:@"投影"]) {
//                _ProjectArray = [SQLManager deviceSubTypeByRoomId:self.roomID];
                _ProjectArray = [SQLManager getDeviceBysubTypeName:@"投影" andRoomID:self.roomID];
            } if ([TypeName isEqualToString:@"功放"]) {
//                 _PowerArray = [SQLManager deviceSubTypeByRoomId:self.roomID];
                 _PowerArray = [SQLManager getDeviceBysubTypeName:@"功放" andRoomID:self.roomID];
            }if ([TypeName isEqualToString:@"网络电视"]) {
//                 _TVArray = [SQLManager deviceSubTypeByRoomId:self.roomID];
                 _TVArray = [SQLManager getDeviceBysubTypeName:@"网络电视" andRoomID:self.roomID];
            }if ([TypeName isEqualToString:@"DVD"]) {
//                 _DVDArray = [SQLManager deviceSubTypeByRoomId:self.roomID];
                 _DVDArray = [SQLManager getDeviceBysubTypeName:@"DVD" andRoomID:self.roomID];
            }if ([TypeName isEqualToString:@"机顶盒"]) {
//                 _NetVArray = [SQLManager deviceSubTypeByRoomId:self.roomID];
                 _NetVArray = [SQLManager getDeviceBysubTypeName:@"机顶盒" andRoomID:self.roomID];
            }if ([TypeName isEqualToString:@"空调"]) {
//                 _AirArray = [SQLManager deviceSubTypeByRoomId:self.roomID];
                 _AirArray = [SQLManager getDeviceBysubTypeName:@"空调" andRoomID:self.roomID];
            }if ([TypeName isEqualToString:@"摄像头"]) {
//                 _CameraArray = [SQLManager deviceSubTypeByRoomId:self.roomID];
                 _CameraArray = [SQLManager getDeviceBysubTypeName:@"摄像头" andRoomID:self.roomID];
            }if ([TypeName isEqualToString:@"智能门锁"]) {
//                 _LockArray = [SQLManager deviceSubTypeByRoomId:self.roomID];
                 _LockArray = [SQLManager getDeviceBysubTypeName:@"智能门锁" andRoomID:self.roomID];
            }if ([TypeName isEqualToString:@"窗帘"]) {
//                 _CurtainArray = [SQLManager deviceSubTypeByRoomId:self.roomID];
                 _CurtainArray = [SQLManager getDeviceBysubTypeName:@"窗帘" andRoomID:self.roomID];
            }if ([TypeName isEqualToString:@"智能单品"]) {
//                 _PluginArray = [SQLManager deviceSubTypeByRoomId:self.roomID];
                 _PluginArray = [SQLManager getDeviceBysubTypeName:@"智能单品" andRoomID:self.roomID];
            }if ([TypeName isEqualToString:@"智能推窗器"]) {
//                 _IntelligentArray = [SQLManager deviceSubTypeByRoomId:self.roomID];
                 _IntelligentArray = [SQLManager getDeviceBysubTypeName:@"智能推窗器" andRoomID:self.roomID];
            }if ([TypeName isEqualToString:@"灯光"]) {
//                _lightArr = [SQLManager deviceSubTypeByRoomId:self.roomID];
                 _lightArr = [SQLManager getDeviceBysubTypeName:@"灯光" andRoomID:self.roomID];
            }
        }
        [self.tableView reloadData];
    }
    
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
        return _BJMusicArray.count;
    }if (section == 1) {
        return _ProjectArray .count;
    }if (section == 2) {
        return _PowerArray.count;
    }if (section == 3) {
        return _TVArray.count;
    }if (section == 4) {
        return _DVDArray.count;
    }if (section == 5) {
        return _NetVArray.count;
    }if (section == 6) {
        return _AirArray.count;
    }if (section == 7) {
        return _CameraArray.count;
    }if (section == 8) {
        return _LockArray.count;
    }if (section == 9) {
        return _CurtainArray.count;
    }if (section == 10) {
        return _PluginArray.count;
    }if (section == 11) {
        return _IntelligentArray.count;
    }
    return _lightArr.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    IphoneNewAddSceneCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
//   
//     cell.backgroundColor = [UIColor clearColor];
//     cell.DeviceNameLabel.text = self.devices[indexPath.row];
//    return cell;
    if (indexPath.section == 0) {//灯光
        LightCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
//        cell.roomID = self.roomID;
//        cell.sceneID = self.sceneid;
        Device *device = [SQLManager getDeviceWithDeviceID:[_lightArr[indexPath.row] intValue]];
        cell.LightNameLabel.text = device.name;
        cell.slider.continuous = NO;
        cell.deviceid = _lightArr[indexPath.row];
        return cell;
    }if (indexPath.section == 1) {//空调
        AireTableViewCell * aireCell = [tableView dequeueReusableCellWithIdentifier:@"AireTableViewCell" forIndexPath:indexPath];
        aireCell.backgroundColor =[UIColor clearColor];
//        aireCell.roomID = self.roomID;
//        aireCell.sceneID = self.sceneid;
        Device *device = [SQLManager getDeviceWithDeviceID:[_AirArray[indexPath.row] intValue]];
        aireCell.deviceNameLabel.text = device.name;
        aireCell.deviceid = _AirArray[indexPath.row];
        
        return aireCell;
    }if (indexPath.section == 2) {//窗帘
        CurtainTableViewCell * aireCell = [tableView dequeueReusableCellWithIdentifier:@"CurtainTableViewCell" forIndexPath:indexPath];
        aireCell.backgroundColor = [UIColor clearColor];
//        aireCell.roomID = self.roomID;
//        aireCell.sceneID = self.sceneid;
        Device *device = [SQLManager getDeviceWithDeviceID:[_CurtainArray[indexPath.row] intValue]];
        aireCell.label.text = device.name;
        aireCell.deviceid = _CurtainArray[indexPath.row];
        return aireCell;
    }if (indexPath.section == 3) {//TV
        TVTableViewCell * aireCell = [tableView dequeueReusableCellWithIdentifier:@"TVTableViewCell" forIndexPath:indexPath];
        aireCell.backgroundColor =[UIColor clearColor];
        Device *device = [SQLManager getDeviceWithDeviceID:[_TVArray[indexPath.row] intValue]];
        aireCell.TVNameLabel.text = device.name;
        return aireCell;
    }if (indexPath.section == 4) {//DVD
        DVDTableViewCell * otherCell = [tableView dequeueReusableCellWithIdentifier:@"DVDTableViewCell" forIndexPath:indexPath];
        otherCell.backgroundColor =[UIColor clearColor];
        Device *device = [SQLManager getDeviceWithDeviceID:[_DVDArray[indexPath.row] intValue]];
        otherCell.DVDNameLabel.text = device.name;
        return otherCell;
    }if (indexPath.section == 5) {//投影幕
        ScreenCurtainCell * ScreenCell = [tableView dequeueReusableCellWithIdentifier:@"ScreenCurtainCell" forIndexPath:indexPath];
        ScreenCell.backgroundColor =[UIColor clearColor];
        Device *device = [SQLManager getDeviceWithDeviceID:[_ProjectArray[indexPath.row] intValue]];
        ScreenCell.ScreenCurtainLabel.text = device.name;
        return ScreenCell;
    }if (indexPath.section == 6) {//FM
        OtherTableViewCell * otherCell = [tableView dequeueReusableCellWithIdentifier:@"OtherTableViewCell" forIndexPath:indexPath];
        otherCell.backgroundColor =[UIColor clearColor];
        Device *device = [SQLManager getDeviceWithDeviceID:[_FMArray[indexPath.row] intValue]];
        otherCell.OtherNameLabel.text = device.name;
    }if (indexPath.section == 7) {//机顶盒
        OtherTableViewCell * otherCell = [tableView dequeueReusableCellWithIdentifier:@"OtherTableViewCell" forIndexPath:indexPath];
        otherCell.backgroundColor =[UIColor clearColor];
        Device *device = [SQLManager getDeviceWithDeviceID:[_NetVArray[indexPath.row] intValue]];
        otherCell.OtherNameLabel.text = device.name;
    }if (indexPath.section == 8) {//投影机
        OtherTableViewCell * otherCell = [tableView dequeueReusableCellWithIdentifier:@"OtherTableViewCell" forIndexPath:indexPath];
        otherCell.backgroundColor = [UIColor clearColor];
        Device *device = [SQLManager getDeviceWithDeviceID:[_MBArray[indexPath.row] intValue]];
        otherCell.OtherNameLabel.text = device.name;
    }if (indexPath.section == 9) {//背景音乐
        BjMusicTableViewCell * BjMusicCell = [tableView dequeueReusableCellWithIdentifier:@"BjMusicTableViewCell" forIndexPath:indexPath];
        BjMusicCell.backgroundColor = [UIColor clearColor];
        Device *device = [SQLManager getDeviceWithDeviceID:[_BJMusicArray[indexPath.row] intValue]];
        BjMusicCell.BjMusicNameLb.text = device.name;
    }if (indexPath.section == 10) {//其他
        OtherTableViewCell * otherCell = [tableView dequeueReusableCellWithIdentifier:@"OtherTableViewCell" forIndexPath:indexPath];
        otherCell.backgroundColor = [UIColor clearColor];
        if (_OtherArray.count) {
            Device *device = [SQLManager getDeviceWithDeviceID:[_OtherArray[indexPath.row] intValue]];
            if (device.name == nil) {
                otherCell.OtherNameLabel.text = @"";
            }else{
                otherCell.OtherNameLabel.text = device.name;
            }
            
        }
        
        return otherCell;
    }
    return nil;
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
