//
//  IpadAddDeviceTypeVC.m
//  SmartHome
//
//  Created by zhaona on 2017/6/1.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "IpadAddDeviceTypeVC.h"
#import "NewLightCell.h"
#import "SQLManager.h"
#import "BgMusicController.h"
#import "CollectionViewCell.h"
#import "TouchSubViewController.h"
#import "HttpManager.h"
#import "NewColourCell.h"
#import "NewLightCell.h"
#import "FMTableViewCell.h"
#import "SeneLightModel.h"
#import "AireTableViewCell.h"
#import "CurtainTableViewCell.h"
#import "TVTableViewCell.h"
#import "ScreenCurtainCell.h"
#import "OtherTableViewCell.h"
#import "DVDTableViewCell.h"
#import "BjMusicTableViewCell.h"
#import "AddDeviceCell.h"
#import "IphoneNewAddSceneVC.h"
#import "MBProgressHUD+NJ.h"


@interface IpadAddDeviceTypeVC ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
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
@property (nonatomic,strong) NSMutableArray * ProjectArray;//投影
@property (nonatomic,strong) NSMutableArray * BJMusicArray;//背景音乐
@property (nonatomic,strong) NSMutableArray * MBArray;//幕布
@property (nonatomic,strong) NSMutableArray * IntelligentArray;//智能推窗器
@property (nonatomic,strong) NSMutableArray * PowerArray;//功放
@property (nonatomic,assign) NSInteger htypeID;

@end

@implementation IpadAddDeviceTypeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self getUI];
    self.tableView.tableFooterView = [UIView new];
    
}
-(void)getUI
{
    _lightArr = [[NSMutableArray alloc] init];//场景下的所有设备
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
    [self.tableView registerNib:[UINib nibWithNibName:@"AireTableViewCell" bundle:nil] forCellReuseIdentifier:@"AireTableViewCell"];//空调
    [self.tableView registerNib:[UINib nibWithNibName:@"CurtainTableViewCell" bundle:nil] forCellReuseIdentifier:@"CurtainTableViewCell"];//窗帘
    [self.tableView registerNib:[UINib nibWithNibName:@"TVTableViewCell" bundle:nil] forCellReuseIdentifier:@"TVTableViewCell"];//网络电视
    [self.tableView registerNib:[UINib nibWithNibName:@"NewColourCell" bundle:nil] forCellReuseIdentifier:@"NewColourCell"];//调色灯
    [self.tableView registerNib:[UINib nibWithNibName:@"OtherTableViewCell" bundle:nil] forCellReuseIdentifier:@"OtherTableViewCell"];//其他
    [self.tableView registerNib:[UINib nibWithNibName:@"ScreenTableViewCell" bundle:nil] forCellReuseIdentifier:@"ScreenTableViewCell"];//幕布ScreenCurtainCell
    [self.tableView registerNib:[UINib nibWithNibName:@"ScreenCurtainCell" bundle:nil] forCellReuseIdentifier:@"ScreenCurtainCell"];//幕布ScreenCurtainCell
    [self.tableView registerNib:[UINib nibWithNibName:@"DVDTableViewCell" bundle:nil] forCellReuseIdentifier:@"DVDTableViewCell"];//DVD
    [self.tableView registerNib:[UINib nibWithNibName:@"BjMusicTableViewCell" bundle:nil] forCellReuseIdentifier:@"BjMusicTableViewCell"];//背景音乐
    [self.tableView registerNib:[UINib nibWithNibName:@"AddDeviceCell" bundle:nil] forCellReuseIdentifier:@"AddDeviceCell"];//添加设备的cell
    [self.tableView registerNib:[UINib nibWithNibName:@"NewLightCell" bundle:nil] forCellReuseIdentifier:@"NewLightCell"];//调光灯
    [self.tableView registerNib:[UINib nibWithNibName:@"FMTableViewCell" bundle:nil] forCellReuseIdentifier:@"FMTableViewCell"];//FM
    //    NSArray *lightArr = [SQLManager getDeviceIDsBySeneId:self.sceneID];
    
    for(int i = 0; i <self.deviceIdArr.count; i++)
    {
        if (self.deviceIdArr.count == 0) {
            [MBProgressHUD showSuccess:@"此房间没有此类设备"];
        }
        _htypeID = [SQLManager deviceHtypeIDByDeviceID:[self.deviceIdArr[i] intValue]];
        if (_htypeID == 2) {//调光灯
            //            [_lightArray addObject:lightArr[i]];
            SeneLightModel  *seneLight = [[SeneLightModel alloc] init];
            seneLight.ID = self.deviceIdArr[i];
            seneLight.value = 0.0f;
            seneLight.sene_light_model = SENE_LIGHTS_MODEL_CUSTOMER;
            [self.lightArray addObject:seneLight];
            
        }else if (_htypeID == 1){//开关灯
            [_SwitchLightArr addObject:self.deviceIdArr[i]];
        }else if (_htypeID == 3){//调色灯
            [_ColourLightArr addObject:self.deviceIdArr[i]];
        }else if (_htypeID == 31){//空调
            [_AirArray addObject:self.deviceIdArr[i]];
        }else if (_htypeID == 21){//窗帘
            [_CurtainArray addObject:self.deviceIdArr[i]];
        }else if (_htypeID == 11){//网路电视
            [_TVArray addObject:self.deviceIdArr[i]];
        }else if (_htypeID == 13){//DVD
            [_DVDArray addObject:self.deviceIdArr[i]];
        }else if (_htypeID == 16){//投影
            [_ProjectArray addObject:self.deviceIdArr[i]];
        }else if (_htypeID == 12){//机顶盒
            [_NetVArray addObject:self.deviceIdArr[i]];
        }else if (_htypeID == 15){//FM
            [_FMArray addObject:self.deviceIdArr[i]];
        }else if (_htypeID == 14){//背景音乐
            [_BJMusicArray addObject:self.deviceIdArr[i]];
        }else if (_htypeID == 17){//幕布
            [_MBArray addObject:self.deviceIdArr[i]];
        }else{
            [_OtherArray addObject:self.deviceIdArr[i]];
        }
    }
}
#pragma UItableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 13;
    
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return _lightArray.count;//调光灯
    }if (section == 1){//调色灯
        return _ColourLightArr.count;
    }if (section == 2){//开关灯
        return _SwitchLightArr.count;
    }
    if (section == 3){
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
        SeneLightModel *model = self.lightArray[indexPath.row];
        Device   *device = [SQLManager getDeviceWithDeviceID:[model.ID intValue]];
        cell.NewLightNameLabel.text = device.name;
        cell.NewLightSlider.continuous = NO;
        switch (model.sene_light_model) {
            case SENE_LIGHTS_MODEL_SOFT://
                [cell.NewLightSlider setValue:0.2f];
                break;
            case SENE_LIGHTS_MODEL_NORMAL:
                [cell.NewLightSlider setValue:0.5f];
                break;
            case SENE_LIGHTS_MODEL_BRIGHT:
                [cell.NewLightSlider setValue:0.9f];
                break;
            case SENE_LIGHTS_MODEL_CUSTOMER:
                [cell.NewLightSlider setValue:(float)model.value];
                break;
            default:
                break;
        }
        //        [cell.NewLightSlider setValue:20.0f];
        //        cell.deviceid = _lightArray[indexPath.row];
        cell.deviceid = model.ID;
        
        return cell;
    }if (indexPath.section == 1) {//调色灯
        NewColourCell * newColourCell = [tableView dequeueReusableCellWithIdentifier:@"NewColourCell" forIndexPath:indexPath];
        newColourCell.backgroundColor =[UIColor clearColor];
        Device *device = [SQLManager getDeviceWithDeviceID:[_ColourLightArr[indexPath.row] intValue]];
        newColourCell.colourNameLabel.text = device.name;
        
        return newColourCell;
    }if (indexPath.section == 2) {//开关灯
        NewColourCell * newColourCell = [tableView dequeueReusableCellWithIdentifier:@"NewColourCell" forIndexPath:indexPath];
        newColourCell.backgroundColor =[UIColor clearColor];
        Device *device = [SQLManager getDeviceWithDeviceID:[_SwitchLightArr[indexPath.row] intValue]];
        newColourCell.colourNameLabel.text = device.name;
        newColourCell.supimageView.hidden = YES;
        newColourCell.lowImageView.hidden = YES;
        newColourCell.highImageView.hidden = YES;
        newColourCell.colourSlider.hidden = YES;
        
        return newColourCell;
    }
    if (indexPath.section == 3) {//空调
        AireTableViewCell * aireCell = [tableView dequeueReusableCellWithIdentifier:@"AireTableViewCell" forIndexPath:indexPath];
        aireCell.backgroundColor =[UIColor clearColor];
        aireCell.roomID = self.roomID;
        aireCell.sceneid = self.sceneid;
        Device *device = [SQLManager getDeviceWithDeviceID:[_AirArray[indexPath.row] intValue]];
        aireCell.AireNameLabel.text = device.name;
        aireCell.deviceid = _AirArray[indexPath.row];
        
        return aireCell;
    }if (indexPath.section == 4) {//窗帘
        CurtainTableViewCell * aireCell = [tableView dequeueReusableCellWithIdentifier:@"CurtainTableViewCell" forIndexPath:indexPath];
        aireCell.backgroundColor = [UIColor clearColor];
        aireCell.roomID = self.roomID;
        aireCell.sceneid = self.sceneid;
        Device *device = [SQLManager getDeviceWithDeviceID:[_CurtainArray[indexPath.row] intValue]];
        aireCell.label.text = device.name;
        aireCell.deviceid = _CurtainArray[indexPath.row];
        
        return aireCell;
    }if (indexPath.section == 5) {//TV
        TVTableViewCell * TVCell = [tableView dequeueReusableCellWithIdentifier:@"TVTableViewCell" forIndexPath:indexPath];
        TVCell.backgroundColor =[UIColor clearColor];
        Device *device = [SQLManager getDeviceWithDeviceID:[_TVArray[indexPath.row] intValue]];
        TVCell.TVNameLabel.text = device.name;
        
        return TVCell;
    }if (indexPath.section == 6) {//DVD
        DVDTableViewCell * DVDCell = [tableView dequeueReusableCellWithIdentifier:@"DVDTableViewCell" forIndexPath:indexPath];
        DVDCell.backgroundColor =[UIColor clearColor];
        Device *device = [SQLManager getDeviceWithDeviceID:[_DVDArray[indexPath.row] intValue]];
        DVDCell.DVDNameLabel.text = device.name;
        
        return DVDCell;
    }if (indexPath.section == 7) {//投影
        OtherTableViewCell * otherCell = [tableView dequeueReusableCellWithIdentifier:@"OtherTableViewCell" forIndexPath:indexPath];
        otherCell.backgroundColor = [UIColor clearColor];
        Device *device = [SQLManager getDeviceWithDeviceID:[_ProjectArray[indexPath.row] intValue]];
        otherCell.NameLabel.text = device.name;
        otherCell.deviceid = _ProjectArray[indexPath.row];
        
        return otherCell;
    }if (indexPath.section == 8) {//FM
        FMTableViewCell * FMCell = [tableView dequeueReusableCellWithIdentifier:@"FMTableViewCell" forIndexPath:indexPath];
        FMCell.backgroundColor =[UIColor clearColor];
        Device *device = [SQLManager getDeviceWithDeviceID:[_FMArray[indexPath.row] intValue]];
        FMCell.FMNameLabel.text = device.name;
        FMCell.deviceid = _FMArray[indexPath.row];
        
        return FMCell;
    }if (indexPath.section == 9) {//机顶盒
        OtherTableViewCell * otherCell = [tableView dequeueReusableCellWithIdentifier:@"OtherTableViewCell" forIndexPath:indexPath];
        otherCell.backgroundColor =[UIColor clearColor];
        Device *device = [SQLManager getDeviceWithDeviceID:[_NetVArray[indexPath.row] intValue]];
        otherCell.NameLabel.text = device.name;
        otherCell.deviceid = _NetVArray[indexPath.row];
        
        return otherCell;
    }if (indexPath.section == 10) {//幕布
        ScreenCurtainCell * ScreenCell = [tableView dequeueReusableCellWithIdentifier:@"ScreenCurtainCell" forIndexPath:indexPath];
        ScreenCell.backgroundColor =[UIColor clearColor];
        Device *device = [SQLManager getDeviceWithDeviceID:[_MBArray[indexPath.row] intValue]];
        ScreenCell.ScreenCurtainLabel.text = device.name;
        ScreenCell.deviceid = _MBArray[indexPath.row];
        
        return ScreenCell;
    }if (indexPath.section == 11) {//背景音乐
        BjMusicTableViewCell * BjMusicCell = [tableView dequeueReusableCellWithIdentifier:@"BjMusicTableViewCell" forIndexPath:indexPath];
        BjMusicCell.backgroundColor = [UIColor clearColor];
        Device *device = [SQLManager getDeviceWithDeviceID:[_BJMusicArray[indexPath.row] intValue]];
        BjMusicCell.BjMusicNameLb.text = device.name;
        BjMusicCell.deviceid = _BJMusicArray[indexPath.row];
        
        return BjMusicCell;
    }
    
        OtherTableViewCell * otherCell = [tableView dequeueReusableCellWithIdentifier:@"OtherTableViewCell" forIndexPath:indexPath];
        otherCell.backgroundColor = [UIColor clearColor];
        otherCell.deviceid = _OtherArray[indexPath.row];
        if (_OtherArray.count) {
            Device *device = [SQLManager getDeviceWithDeviceID:[_OtherArray[indexPath.row] intValue]];
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
    if (indexPath.section == 9 || indexPath.section == 7 || indexPath.section == 12) {
        return 50;
    }
    return 100;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end