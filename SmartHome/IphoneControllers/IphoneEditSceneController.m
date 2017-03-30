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
#import "IphoneTVController.h"
#import "IphoneDVDController.h"
#import "IphoneNetTvController.h"
#import "FMController.h"
#import "IphoneAirController.h"
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
#import "IphoneLightController.h"
#import "LightCell.h"
#import "AireTableViewCell.h"
#import "CurtainTableViewCell.h"
#import "TVTableViewCell.h"
#import "OtherTableViewCell.h"
#import "ScreenTableViewCell.h"
#import "DVDTableViewCell.h"

@interface IphoneEditSceneController ()<TouchSubViewDelegate,UITableViewDelegate,UITableViewDataSource>//IphoneTypeViewDelegate

@property (weak, nonatomic) IBOutlet IphoneTypeView *subTypeView;//设备大View
@property (weak, nonatomic) IBOutlet IphoneTypeView *deviceTypeView;//设备子View
@property (weak, nonatomic) IBOutlet UIView *devicelView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveBarBtn;
@property (weak, nonatomic) UIViewController *currentViewController;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *gentleBtn;//柔和

@property (weak, nonatomic) IBOutlet UIButton *normalBtn;//正常

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
//    [self setupSubTypeView];
    
    TouchSubViewController * touchVC = [[TouchSubViewController alloc] init];
    touchVC.delegate = self;
   

}
-(void)getUI
{
    [self.gentleBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 60)];
    [self.gentleBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 60, 0, 0)];
    [self.normalBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 60)];
    [self.normalBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 60, 0, 0)];
    [self.brightBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 60)];
    [self.brightBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 60, 0, 0)];
    [self.tableView registerNib:[UINib nibWithNibName:@"AireTableViewCell" bundle:nil] forCellReuseIdentifier:@"AireTableViewCell"];//空调
    [self.tableView registerNib:[UINib nibWithNibName:@"CurtainTableViewCell" bundle:nil] forCellReuseIdentifier:@"CurtainTableViewCell"];//窗帘
    [self.tableView registerNib:[UINib nibWithNibName:@"TVTableViewCell" bundle:nil] forCellReuseIdentifier:@"TVTableViewCell"];//网络电视
    [self.tableView registerNib:[UINib nibWithNibName:@"OtherTableViewCell" bundle:nil] forCellReuseIdentifier:@"OtherTableViewCell"];//其他
    [self.tableView registerNib:[UINib nibWithNibName:@"ScreenTableViewCell" bundle:nil] forCellReuseIdentifier:@"ScreenTableViewCell"];//幕布
    [self.tableView registerNib:[UINib nibWithNibName:@"DVDTableViewCell" bundle:nil] forCellReuseIdentifier:@"DVDTableViewCell"];//DVD
    NSArray *lightArr = [SQLManager getDeviceIDsBySeneId:self.sceneID];
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
    for(int i = 0; i <lightArr.count; i++)
    {
        _typeName = [SQLManager deviceTypeNameByDeviceID:[lightArr[i] intValue]];
        if ([_typeName isEqualToString:@"灯光"]) {
            [_lightArray addObject:lightArr[i]];
        }else if ([_typeName isEqualToString:@"空调"]){
            [_AirArray addObject:lightArr[i]];
        }else if ([_typeName isEqualToString:@"窗帘"]){
            [_CurtainArray addObject:lightArr[i]];
        }else if ([_typeName isEqualToString:@"FM"]){
            [_FMArray addObject:lightArr[i]];
        }else if ([_typeName isEqualToString:@"网络电视"]){
            [_TVArray addObject:lightArr[i]];
        }else if ([_typeName isEqualToString:@"智能门锁"]){
            [_LockArray addObject:lightArr[i]];
        }else if ([_typeName isEqualToString:@"DVD"]){
            [_DVDArray addObject:lightArr[i]];
        }else if ([_typeName isEqualToString:@"智能单品"]){
            [_PluginArray addObject:lightArr[i]];
        }else if ([_typeName isEqualToString:@"投影"]){
            [_ProjectArray addObject:lightArr[i]];
        }else if ([_typeName isEqualToString:@"机顶盒"]){
            [_NetVArray addObject:lightArr[i]];
        }else if ([_typeName isEqualToString:@"背景音乐"]){
            [_BJMusicArray addObject:lightArr[i]];
        }else if ([_typeName isEqualToString:@"幕布"]){
            [_MBArray addObject:lightArr[i]];
        }else if ([_typeName isEqualToString:@"功放"]){
            [_PowerArray addObject:lightArr[i]];
        }else if ([_typeName isEqualToString:@"智能推窗器"]){
            [_IntelligentArray addObject:lightArr[i]];
        }
        else{
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
//-(void)setupDeviceTypeView
//{
//    self.deviceTypeView.delegate = self;
//    
//    [self.deviceTypeView clearItem];
//    
//    for(NSString *deviceType in self.devicesTypes)
//    {
//        if([deviceType isEqualToString:@"灯光"])
//        {
//            [self.deviceTypeView addItemWithTitle:@"灯光" imageName:@"lamp"];
//        }else if([deviceType isEqualToString:@"窗帘"]){
//            [self.deviceTypeView addItemWithTitle:@"窗帘" imageName:@"curtainType"];
//        }else if([deviceType isEqualToString:@"空调"])
//        {
//            [self.deviceTypeView addItemWithTitle:@"空调" imageName:@"air"];
//        }else if ([deviceType isEqualToString:@"FM"])
//        {
//            [self.deviceTypeView addItemWithTitle:@"FM" imageName:@"fm"];
//        }else if([deviceType isEqualToString:@"网络电视"]){
//            [self.deviceTypeView addItemWithTitle:@"网络电视" imageName:@"TV"];
//        }else if([deviceType isEqualToString:@"智能门锁"]){
//            [self.deviceTypeView addItemWithTitle:@"智能门锁" imageName:@"guard"];
//        }else if([deviceType isEqualToString:@"DVD"]){
//            [self.deviceTypeView addItemWithTitle:@"DVD电视" imageName:@"DVD"];
//        }else{
//            [self.deviceTypeView addItemWithTitle:@"其他" imageName:@"safe"];
//        }
//        
//    }
//    
//    [self.deviceTypeView setSelectButton:0];
//    [self iphoneTypeView:self.deviceTypeView didSelectButton:self.typeIndex];
//    
//}
//-(void)iphoneTypeView:(IphoneTypeView *)typeView didSelectButton:(int)index
//{
//    if(typeView == self.subTypeView)
//    {
//        self.typeIndex = index;
//        self.devicesTypes = [SQLManager getDeviceTypeNameWithScenID:self.sceneID subTypeName:self.typeArr[index]];
//        [self setupDeviceTypeView];
//    }else{
//        [self selectedType:self.devicesTypes[index]];
//    }
//    
//}

//-(void)selectedType:(NSString *)typeName
//{
//    
//    [self goDeviceByRoomID:self.roomID typeName:typeName];
//}

//-(void)goDeviceByRoomID:(int)roomID typeName:(NSString *)typeName
//{
//    
//    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    UIStoryboard *iphoneBoard  = [UIStoryboard storyboardWithName:@"iPhone" bundle:nil];
//    if([typeName isEqualToString:@"网络电视"])
//    {
//        IphoneTVController *tVC = [iphoneBoard instantiateViewControllerWithIdentifier:@"IphoneTVController"];
//        tVC.roomID = roomID;
//        tVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
//        
//        [self addViewAndVC:tVC];
//        
//    }else if([typeName isEqualToString:@"灯光"])
//    {
////        LightController *ligthVC = [storyBoard instantiateViewControllerWithIdentifier:@"LightController"];
//         IphoneLightController * ligthVC = [iphoneBoard instantiateViewControllerWithIdentifier:@"LightController"];
//        ligthVC.roomID = roomID;
//        ligthVC.isEditScene = YES;
//        ligthVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
//        [self addViewAndVC:ligthVC];
//        
//    }else if([typeName isEqualToString:@"窗帘"])
//    {
//        CurtainController *curtainVC = [storyBoard instantiateViewControllerWithIdentifier:@"CurtainController"];
//        curtainVC.roomID = roomID;
//        curtainVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
//        [self addViewAndVC:curtainVC];
//        
//        
//    }else if([typeName isEqualToString:@"DVD"])
//    {
//        
//        IphoneDVDController *dvdVC = [iphoneBoard instantiateViewControllerWithIdentifier:@"IphoneDVDController"];
//        dvdVC.roomID = roomID;
//        dvdVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
//        [self addViewAndVC:dvdVC];
//        
//    }else if([typeName isEqualToString:@"FM"])
//    {
//        FMController *fmVC = [iphoneBoard instantiateViewControllerWithIdentifier:@"IphoneFMController"];
//        fmVC.roomID = roomID;
//        fmVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
//        [self addViewAndVC:fmVC];
//        
//    }else if([typeName isEqualToString:@"空调"])
//    {
//        IphoneAirController *airVC = [iphoneBoard instantiateViewControllerWithIdentifier:@"IphoneAirController"];
//        airVC.roomID = roomID;
//        airVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
//        [self addViewAndVC:airVC];
//        
//    }else if([typeName isEqualToString:@"机顶盒"]){
//        IphoneNetTvController *netVC = [iphoneBoard instantiateViewControllerWithIdentifier:@"IphoneNetTvController"];
//        netVC.roomID = roomID;
//        netVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
//        [self addViewAndVC:netVC];
//        
//    }else if([typeName isEqualToString:@"摄像头"]){
//        CameraController *camerVC = [storyBoard instantiateViewControllerWithIdentifier:@"CameraController"];
//        camerVC.roomID = roomID;
//        camerVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
//        [self addViewAndVC:camerVC];
//        
//    }else if([typeName isEqualToString:@"智能门锁"]){
//        GuardController *guardVC = [storyBoard instantiateViewControllerWithIdentifier:@"GuardController"];
//        guardVC.roomID = roomID;
//        guardVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
//        [self addViewAndVC:guardVC];
//        
//    }else if([typeName isEqualToString:@"幕布"]){
//        ScreenCurtainController *screenCurtainVC = [storyBoard instantiateViewControllerWithIdentifier:@"ScreenCurtainController"];
//        screenCurtainVC.roomID = roomID;
//        screenCurtainVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
//        
//        [self addViewAndVC:screenCurtainVC];
//        
//        
//    }else if([typeName isEqualToString:@"投影"])
//    {
//        ProjectController *projectVC = [storyBoard instantiateViewControllerWithIdentifier:@"ProjectController"];
//        projectVC.roomID = roomID;
//        projectVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
//        
//        [self addViewAndVC:projectVC];
//    }else if([typeName isEqualToString:@"功放"]){
//        AmplifierController *amplifierVC = [storyBoard instantiateViewControllerWithIdentifier:@"AmplifierController"];
//        amplifierVC.roomID = roomID;
//        amplifierVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
//        [self addViewAndVC:amplifierVC];
//        
//    }else if([typeName isEqualToString:@"智能推窗器"])
//    {
//        WindowSlidingController *windowSlidVC = [storyBoard instantiateViewControllerWithIdentifier:@"WindowSlidingController"];
//        windowSlidVC.roomID = roomID;
//        windowSlidVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
//        [self addViewAndVC:windowSlidVC];
//    }else if([typeName isEqualToString:@"背景音乐"]){
//        BgMusicController *bgMusicVC = [storyBoard instantiateViewControllerWithIdentifier:@"BgMusicController"];
//        bgMusicVC.roomID = roomID;
//        bgMusicVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
//        [self addViewAndVC:bgMusicVC];
//        
//    }else {
//        PluginViewController *pluginVC = [storyBoard instantiateViewControllerWithIdentifier:@"PluginViewController"];
//        pluginVC.roomID = roomID;
//        pluginVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
//        [self addViewAndVC:pluginVC];
//    }
//   
//}
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
- (IBAction)storeScene:(id)sender {
    
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
    UIAlertAction *favScene = [UIAlertAction actionWithTitle:@"收藏场景" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        
        [self favorScene];
        
    }];
    [alertVC addAction:favScene];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [alertVC dismissViewControllerAnimated:YES completion:nil];
    }];
    [alertVC addAction:cancelAction];
    [[DeviceInfo defaultManager] setEditingScene:NO];
    [self presentViewController:alertVC animated:YES completion:nil];
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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    id theSegue = segue.destinationViewController;
    
    if([segue.identifier isEqualToString:@"addDeviceSegue"])
    {
        
        [theSegue setValue:[NSNumber numberWithInt:self.roomID] forKey:@"roomId"];
        [theSegue setValue:[NSNumber numberWithInt:self.sceneID] forKey:@"sceneId"];
    }else if([segue.identifier isEqualToString:@"storeNewScene"]){
        [theSegue setValue:[NSNumber numberWithInt:self.sceneID] forKey:@"sceneID"];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 15;

}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return _lightArray.count;//灯光
    }else if (section == 1){
        return _AirArray.count;//空调
    }else if (section == 2){
        return _CurtainArray.count;//窗帘
    }else if (section == 3){
        return _TVArray.count;//TV
    }else if (section == 4){
        return _LockArray.count;//智能门锁
    }else if (section == 5){
        return _DVDArray.count;//DVD
    }else if (section == 6){
        return _ProjectArray.count;//投影
    }else if (section == 7){
        return _FMArray.count;//FM
    }else if (section == 8){
        return _NetVArray.count;//机顶盒
    }else if (section == 9){
        return _MBArray.count;//幕布
    }else if (section == 10){
        return _PowerArray.count;//功放
    }else if (section == 11){
        return _IntelligentArray.count;//智能推窗器
    }else if (section == 12){
        return _BJMusicArray.count;//背景音乐
    }else if (section == 13){
        return _PluginArray.count;//智能单品
    }
    return _OtherArray.count;//其他
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   if (indexPath.section == 0) {//灯光
        LightCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.roomID = self.roomID;
        cell.sceneID = self.sceneid;
        Device *device = [SQLManager getDeviceWithDeviceID:[_lightArray[indexPath.row] intValue]];
        cell.LightNameLabel.text = device.name;
        cell.slider.continuous = NO;
        cell.deviceid = _lightArray[indexPath.row];
          return cell;
    }if (indexPath.section == 1) {//空调
        AireTableViewCell * aireCell = [tableView dequeueReusableCellWithIdentifier:@"AireTableViewCell" forIndexPath:indexPath];
        aireCell.roomID = self.roomID;
        aireCell.sceneID = self.sceneid;
         Device *device = [SQLManager getDeviceWithDeviceID:[_AirArray[indexPath.row] intValue]];
        aireCell.AireNameLabel.text = device.name;
        aireCell.deviceid = _AirArray[indexPath.row];
        
        return aireCell;
    }if (indexPath.section == 2) {//窗帘
        CurtainTableViewCell * aireCell = [tableView dequeueReusableCellWithIdentifier:@"CurtainTableViewCell" forIndexPath:indexPath];
        aireCell.roomID = self.roomID;
        aireCell.sceneID = self.sceneid;
        Device *device = [SQLManager getDeviceWithDeviceID:[_CurtainArray[indexPath.row] intValue]];
        aireCell.label.text = device.name;
        aireCell.deviceid = _CurtainArray[indexPath.row];
        return aireCell;
    }if (indexPath.section == 3) {//TV
        TVTableViewCell * aireCell = [tableView dequeueReusableCellWithIdentifier:@"TVTableViewCell" forIndexPath:indexPath];
          Device *device = [SQLManager getDeviceWithDeviceID:[_TVArray[indexPath.row] intValue]];
        aireCell.TVNameLabel.text = device.name;
        return aireCell;
    }if (indexPath.section == 4) {//智能门锁
        OtherTableViewCell * otherCell = [tableView dequeueReusableCellWithIdentifier:@"OtherTableViewCell" forIndexPath:indexPath];
        Device *device = [SQLManager getDeviceWithDeviceID:[_LockArray[indexPath.row] intValue]];
        otherCell.NameLabel.text = device.name;
        return otherCell;
    }if (indexPath.section == 5) {//DVD
        DVDTableViewCell * otherCell = [tableView dequeueReusableCellWithIdentifier:@"DVDTableViewCell" forIndexPath:indexPath];
        Device *device = [SQLManager getDeviceWithDeviceID:[_DVDArray[indexPath.row] intValue]];
        otherCell.DVDNameLabel.text = device.name;
        return otherCell;
    }if (indexPath.section == 6) {//投影
        ScreenTableViewCell * ScreenCell = [tableView dequeueReusableCellWithIdentifier:@"ScreenTableViewCell" forIndexPath:indexPath];
         Device *device = [SQLManager getDeviceWithDeviceID:[_ProjectArray[indexPath.row] intValue]];
        ScreenCell.screenNameLabel.text = device.name;
        return ScreenCell;
    }if (indexPath.section == 7) {//FM
        OtherTableViewCell * otherCell = [tableView dequeueReusableCellWithIdentifier:@"OtherTableViewCell" forIndexPath:indexPath];
        Device *device = [SQLManager getDeviceWithDeviceID:[_FMArray[indexPath.row] intValue]];
        otherCell.NameLabel.text = device.name;
    }if (indexPath.section == 8) {//机顶盒
        OtherTableViewCell * otherCell = [tableView dequeueReusableCellWithIdentifier:@"OtherTableViewCell" forIndexPath:indexPath];
        Device *device = [SQLManager getDeviceWithDeviceID:[_NetVArray[indexPath.row] intValue]];
        otherCell.NameLabel.text = device.name;
    }if (indexPath.section == 9) {//幕布
        OtherTableViewCell * otherCell = [tableView dequeueReusableCellWithIdentifier:@"OtherTableViewCell" forIndexPath:indexPath];
        Device *device = [SQLManager getDeviceWithDeviceID:[_MBArray[indexPath.row] intValue]];
        otherCell.NameLabel.text = device.name;
    }if (indexPath.section == 10) {//功放
        OtherTableViewCell * otherCell = [tableView dequeueReusableCellWithIdentifier:@"OtherTableViewCell" forIndexPath:indexPath];
        Device *device = [SQLManager getDeviceWithDeviceID:[_PowerArray[indexPath.row] intValue]];
        otherCell.NameLabel.text = device.name;
    }if (indexPath.section == 11) {//智能推窗器
        OtherTableViewCell * otherCell = [tableView dequeueReusableCellWithIdentifier:@"OtherTableViewCell" forIndexPath:indexPath];
        Device *device = [SQLManager getDeviceWithDeviceID:[_IntelligentArray[indexPath.row] intValue]];
        otherCell.NameLabel.text = device.name;
    }if (indexPath.section == 12) {//背景音乐
        OtherTableViewCell * otherCell = [tableView dequeueReusableCellWithIdentifier:@"OtherTableViewCell" forIndexPath:indexPath];
        Device *device = [SQLManager getDeviceWithDeviceID:[_BJMusicArray[indexPath.row] intValue]];
        otherCell.NameLabel.text = device.name;
    }if (indexPath.section == 13) {//智能单品
        OtherTableViewCell * otherCell = [tableView dequeueReusableCellWithIdentifier:@"OtherTableViewCell" forIndexPath:indexPath];
        Device *device = [SQLManager getDeviceWithDeviceID:[_PluginArray[indexPath.row] intValue]];
        otherCell.NameLabel.text = device.name;
    }
     OtherTableViewCell * otherCell = [tableView dequeueReusableCellWithIdentifier:@"OtherTableViewCell" forIndexPath:indexPath];
    if (_OtherArray.count) {
        Device *device = [SQLManager getDeviceWithDeviceID:[_OtherArray[indexPath.row] intValue]];
        if (device.name == nil) {
            otherCell.NameLabel.text = @"Label";
        }else{
               otherCell.NameLabel.text = device.name;
        }
     
    }
    
    return otherCell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 76;
}
@end
