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
//
//@interface UIImagePickerController (LandScapeImagePicker)
//
//- (UIStatusBarStyle)preferredStatusBarStyle;
//- (NSUInteger)supportedInterfaceOrientations;
//- (BOOL)prefersStatusBarHidden;
//@end
//
//@implementation UIImagePickerController (LandScapeImagePicker)
//
//- (NSUInteger) supportedInterfaceOrientations
//{
//    return UIInterfaceOrientationMaskLandscape;
//}
//
//- (UIStatusBarStyle)preferredStatusBarStyle
//{
//    return UIStatusBarStyleLightContent;
//}
//
//- (BOOL)prefersStatusBarHidden
//{
//    return YES;
//}
//
//@end

@interface IphoneEditSceneController ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet IphoneTypeView *subTypeView;
@property (weak, nonatomic) IBOutlet IphoneTypeView *deviceTypeView;
@property (weak, nonatomic) IBOutlet UIView *devicelView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveBarBtn;


@property (weak, nonatomic) IBOutlet UICollectionView *IphoneEditSceneCell;//添加场景的显示栏
@property (weak, nonatomic) IBOutlet UICollectionView *IphoneSubColleViewCell;

@property (weak, nonatomic) UIViewController *currentViewController;

//设备大类
@property(nonatomic,strong) NSArray *devicesTypes;
//设备子类
@property (nonatomic,strong) NSArray *subTypeArr;
@property (nonatomic, assign) int typeIndex;
@property (weak, nonatomic) UIViewController *IphoneCurrentViewController;
@end

@implementation IphoneEditSceneController

- (void)viewDidLoad {
    [super viewDidLoad];
  
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.title= [SQLManager getSceneName:self.sceneID];
    Scene *scene = [SQLManager sceneBySceneID:self.sceneID];
    if(scene.readonly == YES && !self.isFavor)
    {
//        [self.deleteBtn setEnabled:NO];
        
    }
    [self setupData];

}
- (void)setupData
{
    
    self.devicesTypes = [SQLManager getSubTydpeBySceneID:self.sceneID];
    
    self.subTypeArr = [SQLManager getDeviceTypeNameWithScenID:self.sceneID subTypeName:self.devicesTypes[0]];
    
    [self.IphoneEditSceneCell reloadData];
    [self.IphoneSubColleViewCell reloadData];
    
    
}
-(void)viewWillAppear:(BOOL)animated

{
    
    [super viewWillAppear:YES];
    NSIndexPath *indexPath = 0;
    
    for(int i = 0; i < self.devicesTypes.count; i++)
    {
        NSString *subTypeName = self.devicesTypes[i];
        if([subTypeName isEqualToString:@"影音"])
        {
            
            [self collectionView:self.IphoneEditSceneCell didSelectItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
            
            
            self.subTypeArr = [SQLManager getDeviceTypeNameWithScenID:self.sceneID subTypeName:self.devicesTypes[i]];
            
            for(int i = 0; i < self.subTypeArr.count; i++)
            {
                NSString *typeName = self.subTypeArr[i];
                if([typeName isEqualToString:@"背景音乐"])
                {
                    indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                    
                    
                }
            }
            
        }
    }
    
    [self collectionView:self.IphoneSubColleViewCell didSelectItemAtIndexPath:indexPath];
    
    
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{

    if (collectionView == self.IphoneEditSceneCell) {
        return self.devicesTypes.count;
    }else{
        
        return self.subTypeArr.count;
    }

}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"IphoneEditSceneCell" forIndexPath:indexPath];
    if (collectionView == self.IphoneEditSceneCell) {
        NSString *subType  = self.devicesTypes[indexPath.row];
        cell.NameLabel.text = subType;
        if([subType isEqualToString:@"照明"])
        {
            [cell.IconBtn setBackgroundImage:[UIImage imageNamed:@"lights"] forState:UIControlStateNormal];
        }else if([subType isEqualToString:@"环境"])
        {
            [cell.IconBtn setBackgroundImage:[UIImage imageNamed:@"environment"] forState:UIControlStateNormal];
        }else if([subType isEqualToString:@"影音"])
            
        {
            [cell.IconBtn setBackgroundImage:[UIImage imageNamed:@"medio"] forState:UIControlStateNormal];
        }else if ([subType isEqualToString:@"安防"]){
            [cell.IconBtn setBackgroundImage:[UIImage imageNamed:@"safe"] forState:UIControlStateNormal];
        }else{
            [cell.IconBtn setBackgroundImage:[UIImage imageNamed:@"others"] forState:UIControlStateNormal];
        }
        
    }else {
        //根据设备子类数据
        
        NSString *type  = self.subTypeArr[indexPath.row];
        cell.NameLabel.text = type;
        if([type isEqualToString:@"灯光"])
        {
            [cell.IconBtn setBackgroundImage:[UIImage imageNamed:@"lamp"] forState:UIControlStateNormal];
        }else if([type isEqualToString:@"窗帘"])
        {
            [cell.IconBtn setBackgroundImage:[UIImage imageNamed:@"curtainType"] forState:UIControlStateNormal];
        }else if([type isEqualToString:@"空调"])
            
        {
            [cell.IconBtn setBackgroundImage:[UIImage imageNamed:@"air"] forState:UIControlStateNormal];
        }else if ([type isEqualToString:@"FM"]){
            [cell.IconBtn setBackgroundImage:[UIImage imageNamed:@"fm"] forState:UIControlStateNormal];
        }else if([type isEqualToString:@"网络电视"]){
            [cell.IconBtn setBackgroundImage:[UIImage imageNamed:@"TV"] forState:UIControlStateNormal];
        }else if ([type isEqualToString:@"智能门锁"]){
            [cell.IconBtn setBackgroundImage:[UIImage imageNamed:@"guard"] forState:UIControlStateNormal];
        }else  if ([type isEqualToString:@"DVD"]){
            [cell.IconBtn setBackgroundImage:[UIImage imageNamed:@"DVD"] forState:UIControlStateNormal];
        }else {
            [cell.IconBtn setBackgroundImage:[UIImage imageNamed:@"safe"] forState:UIControlStateNormal];
        }
        
    }
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(collectionView == self.IphoneEditSceneCell)
    {
        
        
        self.subTypeArr = [SQLManager getDeviceTypeNameWithScenID:self.sceneID subTypeName:self.devicesTypes[indexPath.row]];
        
        [self.IphoneSubColleViewCell reloadData];
    }
    if(collectionView == self.IphoneSubColleViewCell)
        
    {
        //灯光，窗帘，DVD，网络电视
        
        NSString *typeName = self.subTypeArr[indexPath.row];
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIStoryboard *iphoneBoard  = [UIStoryboard storyboardWithName:@"iPhone" bundle:nil];
        if([typeName isEqualToString:@"网络电视"])
        {
            IphoneTVController *tVC = [iphoneBoard instantiateViewControllerWithIdentifier:@"IphoneTVController"];
            tVC.roomID = _roomID;
            tVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
            
           [self IphoneAddViewAndVC:tVC];

        }else if([typeName isEqualToString:@"灯光"])
        {
            LightController *ligthVC = [storyBoard instantiateViewControllerWithIdentifier:@"LightController"];
            ligthVC.roomID = _roomID;
            ligthVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
       [self IphoneAddViewAndVC:ligthVC];
            
        }else if([typeName isEqualToString:@"窗帘"])
        {
            CurtainController *curtainVC = [storyBoard instantiateViewControllerWithIdentifier:@"CurtainController"];
            curtainVC.roomID = _roomID;
            curtainVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
            [self IphoneAddViewAndVC:curtainVC];
            
            
        }else if([typeName isEqualToString:@"DVD"])
        {
            
            IphoneDVDController *dvdVC = [iphoneBoard instantiateViewControllerWithIdentifier:@"IphoneDVDController"];
            dvdVC.roomID = _roomID;
            dvdVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
           [self IphoneAddViewAndVC:dvdVC];
            
        }else if([typeName isEqualToString:@"FM"])
        {
            FMController *fmVC = [iphoneBoard instantiateViewControllerWithIdentifier:@"IphoneFMController"];
            fmVC.roomID = _roomID;
            fmVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
      [self IphoneAddViewAndVC:fmVC];
            
        }else if([typeName isEqualToString:@"空调"])
        {
            IphoneAirController *airVC = [iphoneBoard instantiateViewControllerWithIdentifier:@"IphoneAirController"];
            airVC.roomID = _roomID;
            airVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
            [self IphoneAddViewAndVC:airVC];
            
        }else if([typeName isEqualToString:@"机顶盒"]){
            IphoneNetTvController *netVC = [iphoneBoard instantiateViewControllerWithIdentifier:@"IphoneNetTvController"];
            netVC.roomID = _roomID;
            netVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
          [self IphoneAddViewAndVC:netVC];
            
        }else if([typeName isEqualToString:@"摄像头"]){
            CameraController *camerVC = [storyBoard instantiateViewControllerWithIdentifier:@"CameraController"];
            camerVC.roomID = _roomID;
            camerVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
          [self IphoneAddViewAndVC:camerVC];
            
        }else if([typeName isEqualToString:@"智能门锁"]){
            GuardController *guardVC = [storyBoard instantiateViewControllerWithIdentifier:@"GuardController"];
            guardVC.roomID = _roomID;
            guardVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
         [self IphoneAddViewAndVC:guardVC];
            
        }else if([typeName isEqualToString:@"幕布"]){
            ScreenCurtainController *screenCurtainVC = [storyBoard instantiateViewControllerWithIdentifier:@"ScreenCurtainController"];
            screenCurtainVC.roomID = _roomID;
            screenCurtainVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
            
          [self IphoneAddViewAndVC:screenCurtainVC];
            
            
        }else if([typeName isEqualToString:@"投影"])
        {
            ProjectController *projectVC = [storyBoard instantiateViewControllerWithIdentifier:@"ProjectController"];
            projectVC.roomID = _roomID;
            projectVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
            
        [self IphoneAddViewAndVC:projectVC];
        }else if([typeName isEqualToString:@"功放"]){
            AmplifierController *amplifierVC = [storyBoard instantiateViewControllerWithIdentifier:@"AmplifierController"];
            amplifierVC.roomID = _roomID;
            amplifierVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
           [self IphoneAddViewAndVC:amplifierVC];
            
        }else if([typeName isEqualToString:@"智能推窗器"])
        {
            WindowSlidingController *windowSlidVC = [storyBoard instantiateViewControllerWithIdentifier:@"WindowSlidingController"];
            windowSlidVC.roomID = _roomID;
            windowSlidVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
          [self IphoneAddViewAndVC:windowSlidVC];
        }else if([typeName isEqualToString:@"背景音乐"]){
            BgMusicController *bgMusicVC = [storyBoard instantiateViewControllerWithIdentifier:@"BgMusicController"];
            bgMusicVC.roomID = _roomID;
            bgMusicVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
          [self IphoneAddViewAndVC:bgMusicVC];
            
        }else {
            PluginViewController *pluginVC = [storyBoard instantiateViewControllerWithIdentifier:@"PluginViewController"];
            pluginVC.roomID = _roomID;
            pluginVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
            [self IphoneAddViewAndVC:pluginVC];
            
        }
    }

}
    

-(void )IphoneAddViewAndVC:(UIViewController *)vc
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
-(void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = backGroudColour;

}


- (IBAction)closeScene:(id)sender {
    
    [[SceneManager defaultManager] poweroffAllDevice:self.sceneID];
    [self.navigationController popViewControllerAnimated:YES];
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
        
        
        Scene *scene = [[SceneManager defaultManager] readSceneByID:self.sceneID];
        
        
        [[SceneManager defaultManager] favoriteScene:scene withName:scene.sceneName];
        
    }];
    [alertVC addAction:favScene];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [alertVC dismissViewControllerAnimated:YES completion:nil];
    }];
    [alertVC addAction:cancelAction];
    [[DeviceInfo defaultManager] setEditingScene:NO];
    [self presentViewController:alertVC animated:YES completion:nil];
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
