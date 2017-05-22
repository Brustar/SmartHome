//
//  IphoneEditSceneController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/10/10.
//  Copyright © 2016年 Brustar. All rights reserved.
//
#define backGroudColour [UIColor colorWithRed:55/255.0 green:73/255.0 blue:91/255.0 alpha:1]

#import "IphoneEditSceneController.h"
#import "IphoneTypeView.h"
#import "SQLManager.h"
#import "IphoneDeviceListController.h"
#import "LightController.h"
#import "CurtainController.h"

#import "FMController.h"

#import "PluginViewController.h"
#import "CameraController.h"
#import "GuardController.h"
#import "ScreenCurtainController.h"
#import "ProjectController.h"
#import "IphoneRoomView.h"
#import "MBProgressHUD+NJ.h"
#import "AmplifierController.h"
#import "WindowSlidingController.h"
#import "BgMusicController.h"
#import "CollectionViewCell.h"
#import "TouchSubViewController.h"
#import "HttpManager.h"

#import "NewColourCell.h"
#import "NewLightCell.h"
#import "FMTableViewCell.h"
#import "IphoneNewAddSceneVC.h"
#import "SeneLightModel.h"
#import "IphoneNewAddSceneTimerVC.h"


@interface IphoneEditSceneController ()<TouchSubViewDelegate,UITableViewDelegate,UITableViewDataSource>//IphoneTypeViewDelegate

@property (weak, nonatomic) IBOutlet IphoneTypeView *subTypeView;//设备大View
@property (weak, nonatomic) IBOutlet IphoneTypeView *deviceTypeView;//设备子View
@property (weak, nonatomic) IBOutlet UIView *devicelView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveBarBtn;
@property (weak, nonatomic) UIViewController *currentViewController;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *gentleBtn;//柔和
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *TableViewConstraint;

@property (weak, nonatomic) IBOutlet UIButton *normalBtn;//正常
@property (weak, nonatomic) IBOutlet UIView *patternView;//三种模式的父视图

@property (weak, nonatomic) IBOutlet UIButton *brightBtn;//明亮
//设备大类
@property (nonatomic,strong) NSArray *typeArr;
//设备子类
@property(nonatomic,strong) NSArray *devicesTypes;
@property(nonatomic,strong) NSArray * AllDeviceArr;//所有设备ID
@property(nonatomic,strong)  NSMutableArray * lightArr;//灯光
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
@property (nonatomic, assign) int typeIndex;
@property (nonatomic,strong) NSString *typeName;
@property (nonatomic,strong) UIButton * naviRightBtn;
@property (nonatomic,assign) NSInteger htypeID;

@end

@implementation IphoneEditSceneController

-(NSArray *)AllDeviceArr
{
    if (_AllDeviceArr == nil) {
        _AllDeviceArr = [NSArray array];
    }

    return _AllDeviceArr;
}
- (void)viewDidLoad {
    [super viewDidLoad];
//     _AllDeviceArr = [SQLManager getDeviceIDWithRoomID:self.roomID sceneID:self.sceneID];
    self.title = [SQLManager getSceneName:self.sceneID];
    self.typeArr = [SQLManager getSubTydpeBySceneID:self.sceneID];//设备大类作为分组
   
    [self getUI];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.devicesTypes = [SQLManager getDeviceTypeNameWithScenID:self.sceneID subTypeName:self.typeArr[0] ];//设备子类作为每一组的展示
 
    if(self.isFavor)
    {
        self.saveBarBtn.enabled = NO;
    }
    TouchSubViewController * touchVC = [[TouchSubViewController alloc] init];
    touchVC.delegate = self;
    [self getButtonUI];
    [self setupNaviBar];
    if (_lightArray.count == 0 && _SwitchLightArr.count == 0 && _ColourLightArr.count == 0) {
        
        self.patternView.hidden = YES;
        self.TableViewConstraint.constant = -60;
        
    }
}
- (void)setupNaviBar {
    
     NSString * roomName =[SQLManager getRoomNameByRoomID:self.roomID];
     self.title = [SQLManager getSceneName:self.sceneID];
     [self setNaviBarTitle:[NSString stringWithFormat:@"%@-%@",roomName,self.title]]; //设置标题
    _naviRightBtn = [CustomNaviBarView createNormalNaviBarBtnByTitle:@"保存" target:self action:@selector(rightBtnClicked:)];
    _naviRightBtn.tintColor = [UIColor whiteColor];
    //    [self setNaviBarLeftBtn:_naviLeftBtn];
    [self setNaviBarRightBtn:_naviRightBtn];
}
-(void)rightBtnClicked:(UIButton *)bbi
{
//     [self performSegueWithIdentifier:@"storeNewScene" sender:self];
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"请选择" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *saveAction = [UIAlertAction actionWithTitle:@"保存" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //场景ID不变
        NSString *sceneFile = [NSString stringWithFormat:@"%@_%d.plist",SCENE_FILE_NAME,self.sceneID];
        NSString *scenePath=[[IOManager scenesPath] stringByAppendingPathComponent:sceneFile];
        NSDictionary *plistDic = [NSDictionary dictionaryWithContentsOfFile:scenePath];
        
        Scene *scene = [[Scene alloc]init];
        [scene setValuesForKeysWithDictionary:plistDic];
        
        [[SceneManager defaultManager] editScene:scene];
    }];
    [alertVC addAction:saveAction];
    UIAlertAction *saveNewAction = [UIAlertAction actionWithTitle:@"另存为新场景" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //另存为场景，新的场景ID
        
        [self performSegueWithIdentifier:@"storeNewScene" sender:self];
        
    }];
    [alertVC addAction:saveNewAction];
    [alertVC addAction:saveAction];
    UIAlertAction *editAction = [UIAlertAction actionWithTitle:@"编辑定时" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //重新编辑场景的定时
        
        UIStoryboard * sceneStoryBoard = [UIStoryboard storyboardWithName:@"Scene" bundle:nil];
        
        IphoneNewAddSceneTimerVC * newTimerVC = [sceneStoryBoard instantiateViewControllerWithIdentifier:@"IphoneNewAddSceneTimerVC"];
        newTimerVC.sceneID = self.sceneID;
        newTimerVC.roomid = self.roomID;
        
        [self.navigationController pushViewController:newTimerVC animated:YES];
       
        
    }];
    [alertVC addAction:editAction];
//    UIAlertAction *favScene = [UIAlertAction actionWithTitle:@"收藏场景" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        
//        
//        [self favorScene];
//        
//    }];
//    [alertVC addAction:favScene];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [alertVC dismissViewControllerAnimated:YES completion:nil];
    }];
    [alertVC addAction:cancelAction];
    [[DeviceInfo defaultManager] setEditingScene:NO];
    [self presentViewController:alertVC animated:YES completion:nil];

}
-(void)getButtonUI
{
//    [self.gentleBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 60)];
//    [self.gentleBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 60, 0, 0)];
//    [self.normalBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 60)];
//    [self.normalBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 60, 0, 0)];
//    [self.brightBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 60)];
//    [self.brightBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 60, 0, 0)];
    [_gentleBtn setBackgroundImage:[UIImage imageNamed:@"Scene-bedroomJJ"] forState:UIControlStateNormal];
    [_gentleBtn setBackgroundImage:[UIImage imageNamed:@"Scene-bedroom_05_2"] forState:UIControlStateDisabled];
    [_normalBtn setBackgroundImage:[UIImage imageNamed:@"Scene-bedroomJJ"] forState:UIControlStateNormal];
    [_normalBtn setBackgroundImage:[UIImage imageNamed:@"Scene-bedroom_05_2"] forState:UIControlStateDisabled];
    [_brightBtn setBackgroundImage:[UIImage imageNamed:@"Scene-bedroomJJ"] forState:UIControlStateNormal];
    [_brightBtn setBackgroundImage:[UIImage imageNamed:@"Scene-bedroom_05_2"] forState:UIControlStateDisabled];
  
}
//柔和
- (IBAction)gentleBtn:(id)sender {
    
    for (int i = 0; i < _lightArray.count; i++) {
        
//        self.sceneid = _lightArray[i];
        SeneLightModel *model = _lightArray[i];
        model.sene_light_model = SENE_LIGHTS_MODEL_SOFT;
        NSLog(@"id:%@",model.ID);
        [[SceneManager defaultManager] gloom:[model.ID intValue]];
        //修改ui
    }
    

    [self.tableView reloadData];
  
}

//正常
- (IBAction)normalBtn:(id)sender {
    
//    [[SceneManager defaultManager] romantic:[self.sceneid intValue]];
    for (int i = 0; i < _lightArray.count; i++) {
        
        //        self.sceneid = _lightArray[i];
        SeneLightModel *model = _lightArray[i];
        model.sene_light_model = SENE_LIGHTS_MODEL_NORMAL;
        [[SceneManager defaultManager] romantic:[model.ID intValue]];
        //修改ui
    }
    [self.tableView reloadData];
}

//明亮
- (IBAction)brightBtn:(id)sender {
    
//   [[SceneManager defaultManager] sprightly:[self.sceneid intValue]];
    for (int i = 0; i < _lightArray.count; i++) {
        
        //        self.sceneid = _lightArray[i];
        SeneLightModel *model = _lightArray[i];
        model.sene_light_model = SENE_LIGHTS_MODEL_BRIGHT;
        [[SceneManager defaultManager] sprightly:[model.ID intValue]];
        //修改ui
    }
    [self.tableView reloadData];
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
    NSArray *lightArr = [SQLManager getDeviceIDsBySeneId:self.sceneID];
 
    for(int i = 0; i <lightArr.count; i++)
    {
        _htypeID = [SQLManager deviceHtypeIDByDeviceID:[lightArr[i] intValue]];
        if (_htypeID == 2) {//调光灯
//            [_lightArray addObject:lightArr[i]];
            SeneLightModel  *seneLight = [[SeneLightModel alloc] init];
            seneLight.ID = lightArr[i];
            seneLight.value = 0.0f;
            seneLight.sene_light_model = SENE_LIGHTS_MODEL_CUSTOMER;
            [self.lightArray addObject:seneLight];
            
        }else if (_htypeID == 1){//开关灯
             [_SwitchLightArr addObject:lightArr[i]];
        }else if (_htypeID == 3){//调色灯
             [_ColourLightArr addObject:lightArr[i]];
        }else if (_htypeID == 31){//空调
            [_AirArray addObject:lightArr[i]];
        }else if (_htypeID == 21){//窗帘
            [_CurtainArray addObject:lightArr[i]];
        }else if ([_typeName isEqualToString:@"FM"]){
            [_FMArray addObject:lightArr[i]];
        }else if (_htypeID == 11){//网路电视
            [_TVArray addObject:lightArr[i]];
        }else if (_htypeID == 13){//DVD
            [_DVDArray addObject:lightArr[i]];
        }else if (_htypeID == 16){//投影
            [_ProjectArray addObject:lightArr[i]];
        }else if (_htypeID == 12){//机顶盒
            [_NetVArray addObject:lightArr[i]];
        }else if (_htypeID == 15){//FM
            [_FMArray addObject:lightArr[i]];
        }else if (_htypeID == 14){//背景音乐
            [_BJMusicArray addObject:lightArr[i]];
        }else if (_htypeID == 17){//幕布
            [_MBArray addObject:lightArr[i]];
        }else{
            [_OtherArray addObject:lightArr[i]];
        }
    }
}
//根据设备子类的名字得到所有场景下的设备
-(void)getAlldevices
{
    for(NSString *deviceType in self.devicesTypes)
    {
        if([deviceType isEqualToString:@"灯光"])
        {
            [self.deviceTypeView addItemWithTitle:@"灯光" imageName:@"lamp"];
        }else if([deviceType isEqualToString:@"窗帘"]){
            [self.deviceTypeView addItemWithTitle:@"窗帘" imageName:@"curtainType"];
        }else if([deviceType isEqualToString:@"空调"])
        {
            [self.deviceTypeView addItemWithTitle:@"空调" imageName:@"air"];
        }else if ([deviceType isEqualToString:@"FM"])
        {
            [self.deviceTypeView addItemWithTitle:@"FM" imageName:@"fm"];
        }else if([deviceType isEqualToString:@"网络电视"]){
            [self.deviceTypeView addItemWithTitle:@"网络电视" imageName:@"TV"];
        }else if([deviceType isEqualToString:@"智能门锁"]){
            [self.deviceTypeView addItemWithTitle:@"智能门锁" imageName:@"guard"];
        }else if([deviceType isEqualToString:@"DVD"]){
            [self.deviceTypeView addItemWithTitle:@"DVD电视" imageName:@"DVD"];
        }else{
            [self.deviceTypeView addItemWithTitle:@"其他" imageName:@"safe"];
        }
        
    }

}
-(void)setupSubTypeView
{
//    self.subTypeView.delegate = self;
    
    [self.subTypeView clearItem];
    
    for(NSString *type in self.typeArr)
    {
        if([type isEqualToString:@"照明"])
        {
            [self.subTypeView addItemWithTitle:@"照明" imageName:@"lights"];
        }else if([type isEqualToString:@"环境"]){
            [self.subTypeView addItemWithTitle:@"环境" imageName:@"environment"];
        }else if([type isEqualToString:@"影音"])
        {
            [self.subTypeView addItemWithTitle:@"影音" imageName:@"medio"];
        }else if ([type isEqualToString:@"安防"])
        {
            [self.subTypeView addItemWithTitle:@"安防" imageName:@"safe"];
        }else{
            [self.subTypeView addItemWithTitle:@"其他" imageName:@"others"];
        }
    }
    
    [self.subTypeView setSelectButton:0];
//    [self iphoneTypeView:self.subTypeView didSelectButton:self.typeIndex];
    
}

-(void )addViewAndVC:(UIViewController *)vc
{
    if (self.currentViewController != nil) {
        [self.currentViewController.view removeFromSuperview];
        [self.currentViewController removeFromParentViewController];
    }
    
    vc.view.frame = CGRectMake(0, 0, self.devicelView.bounds.size.width, self.devicelView.bounds.size.height);
    
    [self.devicelView addSubview:vc.view];
    [self addChildViewController:vc];
    self.currentViewController = vc;
}

- (IBAction)closeScene:(id)sender {
    
    [[SceneManager defaultManager] poweroffAllDevice:self.sceneID];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma TouchSubViewController delegate

//关闭场景
-(void)colseSecene
{
    [self closeScene:self.saveBarBtn];
}
//收藏场景
-(void)collectSecene
{
    [self favorScene];
}

-(void)favorScene{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"收藏场景" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"确定" style:  UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        NSString *url = [NSString stringWithFormat:@"%@Cloud/store_scene.aspx",[IOManager httpAddr]];
        NSDictionary *dict = @{
                               @"token":[UD objectForKey:@"AuthorToken"],
                               @"scenceid":@(self.sceneID),
                               @"optype":@(1)
                               };
        
        HttpManager *http = [HttpManager defaultManager];
        http.delegate = self;
        http.tag = 3;
        [http sendPost:url param:dict];
        
    }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:action1];
    [alert addAction:action2];
    
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)httpHandler:(id) responseObject tag:(int)tag
{
    if (tag == 3) {
        if([responseObject[@"result"] intValue] == 0)
        {
            Scene *scene = [[SceneManager defaultManager] readSceneByID:self.sceneID];
            if (scene) {
                BOOL result = [[SceneManager defaultManager] favoriteScene:scene];
                if (result) {
                    [MBProgressHUD showSuccess:@"已收藏"];
                }else {
                    [MBProgressHUD showError:@"收藏失败"];
                }
                
            }else {
                NSLog(@"scene 不存在！");
                [MBProgressHUD showError:@"收藏失败"];
            }
            
        }else {
            [MBProgressHUD showError:responseObject[@"msg"]];
        }
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 14;

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
    }if (section == 12){
         return _OtherArray.count;//其他
    }
    return 1;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView * view = [UIView new];
    view.frame = CGRectMake(0, 0, self.view.bounds.size.width, 0.5);
    view.backgroundColor = [UIColor whiteColor];
    
    switch (section) {
        case 0:
            if (_lightArray.count == 0) {
                view.hidden = YES;
            }
            break;
        case 1:
            if (_ColourLightArr.count == 0) {
                view.hidden = YES;
            }
            break;
       case 2:
            if (_SwitchLightArr.count == 0) {
                view.hidden = YES;
            }
            break;
        case 3:
            if (_AirArray.count == 0) {
                view.hidden = YES;
            }
            break;
        case 4:
            if (_CurtainArray.count == 0) {
                view.hidden = YES;
            }
            break;
        case 5:
            if (_TVArray.count == 0) {
                view.hidden = YES;
            }
            break;
        case 6:
            if (_DVDArray.count == 0) {
                view.hidden = YES;
            }
            break;
        case 7:
            if (_ProjectArray.count == 0) {
                view.hidden = YES;
            }
            break;
        case 8:
            if (_FMArray.count == 0) {
                view.hidden = YES;
            }
            break;
        case 9:
            if (_NetVArray.count == 0) {
                view.hidden = YES;
            }
            break;
        case 10:
            if (_MBArray.count == 0) {
                view.hidden = YES;
            }
            break;
        case 11:
            if (_BJMusicArray.count == 0) {
                view.hidden = YES;
            }
            break;
        case 12:
            if (_OtherArray.count == 0) {
                view.hidden = YES;
            }
            break;
        default:
            break;
    }
   
    return view;

}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.5;

}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   if (indexPath.section == 0) {//调灯光
        NewLightCell * cell = [tableView dequeueReusableCellWithIdentifier:@"NewLightCell" forIndexPath:indexPath];
        cell.AddLightBtn.hidden = YES;
        cell.LightConstraint.constant = 10;
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        //cell.roomID = self.roomID;
       // cell.sceneID = self.sceneid;
//        Device *device = [SQLManager getDeviceWithDeviceID:[_lightArray[indexPath.row] intValue]];
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
       newColourCell.AddColourLightBtn.hidden = YES;
       newColourCell.ColourLightConstraint.constant = 10;
       newColourCell.backgroundColor =[UIColor clearColor];
        Device *device = [SQLManager getDeviceWithDeviceID:[_ColourLightArr[indexPath.row] intValue]];
       newColourCell.colourNameLabel.text = device.name;
       
       return newColourCell;
   }if (indexPath.section == 2) {//开关灯
       NewColourCell * newColourCell = [tableView dequeueReusableCellWithIdentifier:@"NewColourCell" forIndexPath:indexPath];
       newColourCell.AddColourLightBtn.hidden = YES;
       newColourCell.ColourLightConstraint.constant = 10;
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
        aireCell.AddAireBtn.hidden = YES;
        aireCell.AireConstraint.constant = 10;
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
        aireCell.AddcurtainBtn.hidden = YES;
        aireCell.curtainContraint.constant = 10;
        aireCell.roomID = self.roomID;
        aireCell.sceneid = self.sceneid;
        Device *device = [SQLManager getDeviceWithDeviceID:[_CurtainArray[indexPath.row] intValue]];
        aireCell.label.text = device.name;
        aireCell.deviceid = _CurtainArray[indexPath.row];
        
        return aireCell;
    }if (indexPath.section == 5) {//TV
        TVTableViewCell * TVCell = [tableView dequeueReusableCellWithIdentifier:@"TVTableViewCell" forIndexPath:indexPath];
        TVCell.TVConstraint.constant = 10;
        TVCell.AddTvDeviceBtn.hidden = YES;
        TVCell.backgroundColor =[UIColor clearColor];
          Device *device = [SQLManager getDeviceWithDeviceID:[_TVArray[indexPath.row] intValue]];
        TVCell.TVNameLabel.text = device.name;
        
        return TVCell;
    }if (indexPath.section == 6) {//DVD
        DVDTableViewCell * DVDCell = [tableView dequeueReusableCellWithIdentifier:@"DVDTableViewCell" forIndexPath:indexPath];
        DVDCell.AddDvdBtn.hidden = YES;
        DVDCell.DVDConstraint.constant = 10;
        DVDCell.backgroundColor =[UIColor clearColor];
        Device *device = [SQLManager getDeviceWithDeviceID:[_DVDArray[indexPath.row] intValue]];
        DVDCell.DVDNameLabel.text = device.name;
        
        return DVDCell;
    }if (indexPath.section == 7) {//投影
        OtherTableViewCell * otherCell = [tableView dequeueReusableCellWithIdentifier:@"OtherTableViewCell" forIndexPath:indexPath];
        otherCell.AddOtherBtn.hidden = YES;
        otherCell.OtherConstraint.constant = 10;
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
        FMCell.AddFmBtn.hidden = YES;
        FMCell.FMLayouConstraint.constant = 5;
        
        return FMCell;
    }if (indexPath.section == 9) {//机顶盒
        OtherTableViewCell * otherCell = [tableView dequeueReusableCellWithIdentifier:@"OtherTableViewCell" forIndexPath:indexPath];
        otherCell.AddOtherBtn.hidden = YES;
        otherCell.OtherConstraint.constant = 10;
        otherCell.backgroundColor =[UIColor clearColor];
        Device *device = [SQLManager getDeviceWithDeviceID:[_NetVArray[indexPath.row] intValue]];
        otherCell.NameLabel.text = device.name;
        otherCell.deviceid = _NetVArray[indexPath.row];
        
        return otherCell;
    }if (indexPath.section == 10) {//幕布
        ScreenCurtainCell * ScreenCell = [tableView dequeueReusableCellWithIdentifier:@"ScreenCurtainCell" forIndexPath:indexPath];
        ScreenCell.AddScreenCurtainBtn.hidden = YES;
        ScreenCell.ScreenCurtainConstraint.constant = 10;
        ScreenCell.backgroundColor =[UIColor clearColor];
        Device *device = [SQLManager getDeviceWithDeviceID:[_MBArray[indexPath.row] intValue]];
        ScreenCell.ScreenCurtainLabel.text = device.name;
        ScreenCell.deviceid = _MBArray[indexPath.row];
        
        return ScreenCell;
    }if (indexPath.section == 11) {//背景音乐
        BjMusicTableViewCell * BjMusicCell = [tableView dequeueReusableCellWithIdentifier:@"BjMusicTableViewCell" forIndexPath:indexPath];
        BjMusicCell.backgroundColor = [UIColor clearColor];
        BjMusicCell.AddBjmusicBtn.hidden = YES;
        BjMusicCell.BJmusicConstraint.constant = 10;
        Device *device = [SQLManager getDeviceWithDeviceID:[_BJMusicArray[indexPath.row] intValue]];
        BjMusicCell.BjMusicNameLb.text = device.name;
        BjMusicCell.deviceid = _BJMusicArray[indexPath.row];
        
        return BjMusicCell;
    }if (indexPath.section == 12) {//其他
        OtherTableViewCell * otherCell = [tableView dequeueReusableCellWithIdentifier:@"OtherTableViewCell" forIndexPath:indexPath];
        otherCell.AddOtherBtn.hidden = YES;
        otherCell.OtherConstraint.constant = 10;
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
    AddDeviceCell * addDeviceCell = [tableView dequeueReusableCellWithIdentifier:@"AddDeviceCell" forIndexPath:indexPath];
    addDeviceCell.backgroundColor = [UIColor clearColor];
    
    return addDeviceCell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
      [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 13) {
        UIStoryboard * iphoneStoryBoard = [UIStoryboard storyboardWithName:@"Scene" bundle:nil];
        IphoneNewAddSceneVC * devicesVC = [iphoneStoryBoard instantiateViewControllerWithIdentifier:@"IphoneNewAddSceneVC"];
        devicesVC.roomID = self.roomID;
        devicesVC.sceneID = self.sceneID;
        [self.navigationController pushViewController:devicesVC animated:YES];
//        [self performSegueWithIdentifier:@"NewAddDeviceSegue" sender:self];
        
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 5 || indexPath.section == 6 || indexPath.section == 8) {
        return 150;
    }
    if (indexPath.section == 9 || indexPath.section == 7 || indexPath.section == 12 || indexPath.section == 13) {
        return 50;
    }
    return 100;
}

@end
