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

@interface IphoneEditSceneController ()<IphoneTypeViewDelegate,TouchSubViewDelegate>


@property (weak, nonatomic) IBOutlet IphoneTypeView *subTypeView;

@property (weak, nonatomic) IBOutlet IphoneTypeView *deviceTypeView;
@property (weak, nonatomic) IBOutlet UIView *devicelView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveBarBtn;


@property (weak, nonatomic) UIViewController *currentViewController;

//设备大类
@property (nonatomic,strong) NSArray *typeArr;
//设备子类
@property(nonatomic,strong) NSArray *devicesTypes;

@property (nonatomic, assign) int typeIndex;

@end

@implementation IphoneEditSceneController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = [SQLManager getSceneName:self.sceneID];
    
    self.typeArr = [SQLManager getSubTydpeBySceneID:self.sceneID];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.devicesTypes = [SQLManager getDeviceTypeNameWithScenID:self.sceneID subTypeName:self.typeArr[0]];
    if(self.isFavor)
    {
        self.saveBarBtn.enabled = NO;
    }
    [self setupSubTypeView];
    
}

-(void)setupSubTypeView
{
    self.subTypeView.delegate = self;
    
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
    [self iphoneTypeView:self.subTypeView didSelectButton:0];
    
}
-(void)setupDeviceTypeView
{
    self.deviceTypeView.delegate = self;
    
    [self.deviceTypeView clearItem];
    
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
    
    [self.deviceTypeView setSelectButton:0];
    [self iphoneTypeView:self.deviceTypeView didSelectButton:0];
    
}
-(void)iphoneTypeView:(IphoneTypeView *)typeView didSelectButton:(int)index
{
    if(typeView == self.subTypeView)
    {
        self.typeIndex = index;
        self.devicesTypes = [SQLManager getDeviceTypeNameWithScenID:self.sceneID subTypeName:self.typeArr[index]];
        [self setupDeviceTypeView];
    }else{
        [self selectedType:self.devicesTypes[index]];
    }
    
}

-(void)selectedType:(NSString *)typeName
{
    
    [self goDeviceByRoomID:self.roomID typeName:typeName];
}

-(void)goDeviceByRoomID:(int)roomID typeName:(NSString *)typeName
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIStoryboard *iphoneBoard  = [UIStoryboard storyboardWithName:@"iPhone" bundle:nil];
    if([typeName isEqualToString:@"网络电视"])
    {
        IphoneTVController *tVC = [iphoneBoard instantiateViewControllerWithIdentifier:@"IphoneTVController"];
        tVC.roomID = roomID;
        tVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
        
        [self addViewAndVC:tVC];
        
    }else if([typeName isEqualToString:@"灯光"])
    {
        LightController *ligthVC = [storyBoard instantiateViewControllerWithIdentifier:@"LightController"];
        ligthVC.roomID = roomID;
        ligthVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
        [self addViewAndVC:ligthVC];
        
    }else if([typeName isEqualToString:@"窗帘"])
    {
        CurtainController *curtainVC = [storyBoard instantiateViewControllerWithIdentifier:@"CurtainController"];
        curtainVC.roomID = roomID;
        curtainVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
        [self addViewAndVC:curtainVC];
        
        
    }else if([typeName isEqualToString:@"DVD"])
    {
        
        IphoneDVDController *dvdVC = [iphoneBoard instantiateViewControllerWithIdentifier:@"IphoneDVDController"];
        dvdVC.roomID = roomID;
        dvdVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
        [self addViewAndVC:dvdVC];
        
    }else if([typeName isEqualToString:@"FM"])
    {
        FMController *fmVC = [iphoneBoard instantiateViewControllerWithIdentifier:@"IphoneFMController"];
        fmVC.roomID = roomID;
        fmVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
        [self addViewAndVC:fmVC];
        
    }else if([typeName isEqualToString:@"空调"])
    {
        IphoneAirController *airVC = [iphoneBoard instantiateViewControllerWithIdentifier:@"IphoneAirController"];
        airVC.roomID = roomID;
        airVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
        [self addViewAndVC:airVC];
        
    }else if([typeName isEqualToString:@"机顶盒"]){
        IphoneNetTvController *netVC = [iphoneBoard instantiateViewControllerWithIdentifier:@"IphoneNetTvController"];
        netVC.roomID = roomID;
        netVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
        [self addViewAndVC:netVC];
        
    }else if([typeName isEqualToString:@"摄像头"]){
        CameraController *camerVC = [storyBoard instantiateViewControllerWithIdentifier:@"CameraController"];
        camerVC.roomID = roomID;
        camerVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
        [self addViewAndVC:camerVC];
        
    }else if([typeName isEqualToString:@"智能门锁"]){
        GuardController *guardVC = [storyBoard instantiateViewControllerWithIdentifier:@"GuardController"];
        guardVC.roomID = roomID;
        guardVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
        [self addViewAndVC:guardVC];
        
    }else if([typeName isEqualToString:@"幕布"]){
        ScreenCurtainController *screenCurtainVC = [storyBoard instantiateViewControllerWithIdentifier:@"ScreenCurtainController"];
        screenCurtainVC.roomID = roomID;
        screenCurtainVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
        
        [self addViewAndVC:screenCurtainVC];
        
        
    }else if([typeName isEqualToString:@"投影"])
    {
        ProjectController *projectVC = [storyBoard instantiateViewControllerWithIdentifier:@"ProjectController"];
        projectVC.roomID = roomID;
        projectVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
        
        [self addViewAndVC:projectVC];
    }else if([typeName isEqualToString:@"功放"]){
        AmplifierController *amplifierVC = [storyBoard instantiateViewControllerWithIdentifier:@"AmplifierController"];
        amplifierVC.roomID = roomID;
        amplifierVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
        [self addViewAndVC:amplifierVC];
        
    }else if([typeName isEqualToString:@"智能推窗器"])
    {
        WindowSlidingController *windowSlidVC = [storyBoard instantiateViewControllerWithIdentifier:@"WindowSlidingController"];
        windowSlidVC.roomID = roomID;
        windowSlidVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
        [self addViewAndVC:windowSlidVC];
    }else if([typeName isEqualToString:@"背景音乐"]){
        BgMusicController *bgMusicVC = [storyBoard instantiateViewControllerWithIdentifier:@"BgMusicController"];
        bgMusicVC.roomID = roomID;
        bgMusicVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
        [self addViewAndVC:bgMusicVC];
        
    }else {
        PluginViewController *pluginVC = [storyBoard instantiateViewControllerWithIdentifier:@"PluginViewController"];
        pluginVC.roomID = roomID;
        pluginVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
        [self addViewAndVC:pluginVC];
    }
   
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
        
        
        
        
        Scene *scene = [[SceneManager defaultManager] readSceneByID:self.sceneID];
        
        
        [[SceneManager defaultManager] favoriteScene:scene withName:scene.sceneName];
        
    }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:action1];
    [alert addAction:action2];
    
    [self presentViewController:alert animated:YES completion:nil];
    
    
    
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


@end
