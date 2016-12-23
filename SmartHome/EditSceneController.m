//
//  EditSceneController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/8/3.
//  Copyright © 2016年 Brustar. All rights reserved.
//
#define backGroudColour [UIColor colorWithRed:55/255.0 green:73/255.0 blue:91/255.0 alpha:1]

#import "EditSceneController.h"
#import "EditSceneCell.h"
#import "LightController.h"
#import "CurtainController.h"
#import "TVController.h"
#import "DVDController.h"
#import "NetvController.h"
#import "FMController.h"
#import "SQLManager.h"
#import "Device.h"
#import "SceneManager.h"
#import "DeviceListController.h"
#import "AirController.h"
#import "HttpManager.h"
#import "KxMenu.h"
#import "MBProgressHUD+NJ.h"
#import "PluginViewController.h"
#import "CameraController.h"
#import "GuardController.h"
#import "ScreenCurtainController.h"
#import "ProjectController.h"
#import "AmplifierController.h"
#import "WindowSlidingController.h"
#import "BgMusicController.h"

@interface UIImagePickerController (LandScapeImagePicker)

- (UIStatusBarStyle)preferredStatusBarStyle;
- (NSUInteger)supportedInterfaceOrientations;
- (BOOL)prefersStatusBarHidden;
@end

@implementation UIImagePickerController (LandScapeImagePicker)

- (NSUInteger) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

@end


@interface EditSceneController ()<UITableViewDelegate,UITableViewDataSource,UIPopoverControllerDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITableView *subDeviceTableView;
@property (weak, nonatomic) IBOutlet UIButton *sceneBg;//场景背景

@property (weak, nonatomic) IBOutlet UIView *footerView;
//设备种类
@property(nonatomic,strong) NSArray *devicesTypes;

@property (weak, nonatomic) IBOutlet UIButton *realObjBtn;
@property (weak, nonatomic) IBOutlet UIButton *graphicBtn;
@property (weak, nonatomic) IBOutlet UIButton *stopBtn;
@property (nonatomic,assign) NSInteger selectedRow;
@property (nonatomic,strong) NSArray *subTypeArr;
@property (weak, nonatomic) IBOutlet UIView *storeNewScene;

@property (weak, nonatomic) IBOutlet UIView *devicelView;
@property (nonatomic,strong) LightController *ligthVC;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *deleteBtn;

@property (weak, nonatomic) IBOutlet UIView *coverView;



@property (nonatomic,strong)UIImage *selectSceneImg;
@property (weak, nonatomic) IBOutlet UITextField *storeNewSceneName;

@property (weak, nonatomic) UIViewController *currentViewController;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveBarButton;

@end

@implementation EditSceneController



- (void)viewDidLoad {
    [super viewDidLoad];
    if(self.isFavor)
    {
        self.saveBarButton.enabled = NO;
    }
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView.tableFooterView = self.footerView;
    self.tableView.backgroundColor = backGroudColour;
    self.subDeviceTableView.backgroundColor = backGroudColour;
   // [self.tableView selectRowAtIndexPath:0 animated:YES scrollPosition:UITableViewScrollPositionTop];
    self.devicelView.backgroundColor = [UIColor whiteColor];
    self.view.backgroundColor = backGroudColour;
    self.title= [SQLManager getSceneName:self.sceneID];
    Scene *scene = [SQLManager sceneBySceneID:self.sceneID];
    if(scene.readonly == YES && !self.isFavor)
    {
        [self.deleteBtn setEnabled:NO];
        
    }
    [self setupData];
}




- (void)setupData
{
   
    self.devicesTypes = [SQLManager getSubTydpeBySceneID:self.sceneID];
    
    self.subTypeArr = [SQLManager getDeviceTypeNameWithScenID:self.sceneID subTypeName:self.devicesTypes[0]];
    
    [self.tableView reloadData];
    [self.subDeviceTableView reloadData];
    
   
}
-(void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:YES];
    
    for(int i = 0; i < self.devicesTypes.count; i++)
    {
        NSString *subTypeName = self.devicesTypes[i];
        if([subTypeName isEqualToString:@"影音"])
        {
            [self tableView:self.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            self.subTypeArr = [SQLManager getDeviceTypeNameWithScenID:self.sceneID subTypeName:self.devicesTypes[i]];
            
            for(int i = 0; i < self.subTypeArr.count; i++)
            {
                NSString *typeName = self.subTypeArr[i];
                if([typeName isEqualToString:@"背景音乐"])
                {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                    [self tableView:self.subDeviceTableView didSelectRowAtIndexPath:indexPath];
                }
            }
        }
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //右边的根据左边选中的设备大类的设备子类数量
    if (tableView == self.tableView) {
        return self.devicesTypes.count;
    }
    else {
        return self.subTypeArr.count;
    }

   
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EditSceneCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EditSceneCell" forIndexPath:indexPath];
    if(tableView == self.tableView)
    {
        NSString *subType  = self.devicesTypes[indexPath.row];
        cell.label.text = subType;
        if([subType isEqualToString:@"照明"])
        {
            [cell.button setBackgroundImage:[UIImage imageNamed:@"lights"] forState:UIControlStateNormal];
        }else if([subType isEqualToString:@"环境"])
        {
            [cell.button setBackgroundImage:[UIImage imageNamed:@"environment"] forState:UIControlStateNormal];
        }else if([subType isEqualToString:@"影音"])
        {
            [cell.button setBackgroundImage:[UIImage imageNamed:@"medio"] forState:UIControlStateNormal];
        }else if ([subType isEqualToString:@"安防"]){
            [cell.button setBackgroundImage:[UIImage imageNamed:@"safe"] forState:UIControlStateNormal];
        }else{
            [cell.button setBackgroundImage:[UIImage imageNamed:@"others"] forState:UIControlStateNormal];
        }

    }else {
        //根据设备子类数据
        
        NSString *type  = self.subTypeArr[indexPath.row];
        cell.label.text = type;
        if([type isEqualToString:@"灯光"])
        {
            [cell.button setBackgroundImage:[UIImage imageNamed:@"lamp"] forState:UIControlStateNormal];
        }else if([type isEqualToString:@"窗帘"])
        {
            [cell.button setBackgroundImage:[UIImage imageNamed:@"curtainType"] forState:UIControlStateNormal];
        }else if([type isEqualToString:@"空调"])
            
        {
            [cell.button setBackgroundImage:[UIImage imageNamed:@"air"] forState:UIControlStateNormal];
        }else if ([type isEqualToString:@"FM"]){
            [cell.button setBackgroundImage:[UIImage imageNamed:@"fm"] forState:UIControlStateNormal];
        }else if([type isEqualToString:@"网络电视"]){
            [cell.button setBackgroundImage:[UIImage imageNamed:@"TV"] forState:UIControlStateNormal];
        }else if ([type isEqualToString:@"智能门锁"]){
            [cell.button setBackgroundImage:[UIImage imageNamed:@"guard"] forState:UIControlStateNormal];
        }else  if ([type isEqualToString:@"DVD"]){
            [cell.button setBackgroundImage:[UIImage imageNamed:@"DVD"] forState:UIControlStateNormal];
        }else {
            [cell.button setBackgroundImage:[UIImage imageNamed:@"safe"] forState:UIControlStateNormal];
        }
    }
    
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(tableView == self.tableView)
    {
        self.subTypeArr = [SQLManager getDeviceTypeNameWithScenID:self.sceneID subTypeName:self.devicesTypes[indexPath.row]];
        [self.subDeviceTableView reloadData];
    }
    
    if(tableView == self.subDeviceTableView)
    {
        if (!self.subTypeArr) {
            return;
        }
        //灯光，窗帘，DVD，网络电视
        NSString *typeName = self.subTypeArr[indexPath.row];
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        if([typeName isEqualToString:@"网络电视"])
        {
            TVController *tVC = [storyBoard instantiateViewControllerWithIdentifier:@"TVController"];
            tVC.sceneid =[NSString stringWithFormat:@"%d",self.sceneID];
            
            [self addViewAndVC:tVC];
            
        }else if([typeName isEqualToString:@"灯光"])
        {
            LightController *ligthVC = [storyBoard instantiateViewControllerWithIdentifier:@"LightController"];
            ligthVC.showLightView = YES;
            ligthVC.roomID = self.roomID;
            ligthVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
            [self addViewAndVC:ligthVC];

        }else if([typeName isEqualToString:@"窗帘"])
        {
            CurtainController *curtainVC = [storyBoard instantiateViewControllerWithIdentifier:@"CurtainController"];
            curtainVC.roomID = self.roomID;
            curtainVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
            [self addViewAndVC:curtainVC];

            
        }else if([typeName isEqualToString:@"DVD"])
        {
            
            DVDController *dvdVC = [storyBoard instantiateViewControllerWithIdentifier:@"DVDController"];
            dvdVC.roomID = self.roomID;
            dvdVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
            [self addViewAndVC:dvdVC];

        }else if([typeName isEqualToString:@"FM"])
        {
             FMController *fmVC = [storyBoard instantiateViewControllerWithIdentifier:@"FMController"];
            fmVC.roomID = self.roomID;
            fmVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
            [self addViewAndVC:fmVC];

        }else if([typeName isEqualToString:@"空调"])
        {
            AirController *airVC = [storyBoard instantiateViewControllerWithIdentifier:@"AirController"];
            airVC.roomID = self.roomID;
            airVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
            [self addViewAndVC:airVC];
        }else if([typeName isEqualToString:@"机顶盒"]){
            NetvController *netVC = [storyBoard instantiateViewControllerWithIdentifier:@"NetvController"];
            netVC.roomID = self.roomID;
            netVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
            [self addViewAndVC:netVC];

        }else if([typeName isEqualToString:@"摄像头"]){
             CameraController *camerVC = [storyBoard instantiateViewControllerWithIdentifier:@"CameraController"];
            camerVC.roomID = self.roomID;
            camerVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
            [self addViewAndVC:camerVC];
           
        }else if([typeName isEqualToString:@"智能门锁"]){
            GuardController *guardVC = [storyBoard instantiateViewControllerWithIdentifier:@"GuardController"];
            guardVC.roomID = self.roomID;
            guardVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
            [self addViewAndVC:guardVC];
        
        }else if([typeName isEqualToString:@"幕布"]){
            ScreenCurtainController *screenCurtainVC = [storyBoard instantiateViewControllerWithIdentifier:@"ScreenCurtainController"];
            screenCurtainVC.roomID = self.roomID;
            screenCurtainVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
            [self addViewAndVC:screenCurtainVC];
           

        }else if([typeName isEqualToString:@"投影"])
        {
            ProjectController *projectVC = [storyBoard instantiateViewControllerWithIdentifier:@"ProjectController"];
            projectVC.roomID = self.roomID;
            projectVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
            [self addViewAndVC:projectVC];
        }else if([typeName isEqualToString:@"功放"]){
            AmplifierController *amplifierVC = [storyBoard instantiateViewControllerWithIdentifier:@"AmplifierController"];
            amplifierVC.roomID = self.roomID;
            amplifierVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
            [self addViewAndVC:amplifierVC];
            
        }else if([typeName isEqualToString:@"智能推窗器"]){
            WindowSlidingController *windowSlidVC = [storyBoard instantiateViewControllerWithIdentifier:@"WindowSlidingController"];
            windowSlidVC.roomID = self.roomID;
            windowSlidVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
            [self addViewAndVC:windowSlidVC];
            
        }else if([typeName isEqualToString:@"背景音乐"]){
            BgMusicController *bgVC = [storyBoard instantiateViewControllerWithIdentifier:@"BgMusicController"];
            bgVC.roomID = self.roomID;
            bgVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
            [self addViewAndVC:bgVC];
            
            
        }else{
            PluginViewController *pluginVC = [storyBoard instantiateViewControllerWithIdentifier:@"PluginViewController"];
            pluginVC.roomID = self.roomID;
            pluginVC.sceneid = [NSString stringWithFormat:@"%d",self.sceneID];
            [self addViewAndVC:pluginVC];
        }
    }
    
    
}

-(void )addViewAndVC:(UIViewController *)vc
{
    if (self.currentViewController != nil) {
        [self.currentViewController.view removeFromSuperview];
        [self.currentViewController removeFromParentViewController];
    }

    vc.view.frame = CGRectMake(100, 64, self.view.bounds.size.width - 200  , self.view.bounds.size.height);
    [self.view addSubview:vc.view];
    [self addChildViewController:vc];
     self.currentViewController = vc;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
     cell.backgroundColor = backGroudColour;
    
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"deviceListSegue"])
    {
        id theSegue = segue.destinationViewController;
        [theSegue setValue:[NSNumber numberWithInt:self.roomID] forKey:@"roomid"];
        [theSegue setValue:[NSNumber numberWithInt:self.sceneID] forKey:@"sceneid"];
    }
       
}

- (IBAction)saveScene:(UIBarButtonItem *)sender {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"请选择" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *saveAction = [UIAlertAction actionWithTitle:@"保存" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //场景ID不变
        NSString *sceneFile = [NSString stringWithFormat:@"%@_%d.plist",SCENE_FILE_NAME,self.sceneID];
        NSString *scenePath=[[IOManager scenesPath] stringByAppendingPathComponent:sceneFile];
        NSDictionary *plistDic = [NSDictionary dictionaryWithContentsOfFile:scenePath];
        
        Scene *scene = [[Scene alloc] init];
        [scene setValuesForKeysWithDictionary:plistDic];
        
        [[SceneManager defaultManager] editScene:scene];
    }];
    
    [alertVC addAction:saveAction];
    
    UIAlertAction *saveNewAction = [UIAlertAction actionWithTitle:@"另存为新场景" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //另存为场景，新的场景ID
        [self.view bringSubviewToFront:self.devicelView];
        self.coverView.hidden = NO;
        self.storeNewScene.hidden = NO;
        [self.storeNewSceneName becomeFirstResponder];
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

//收藏场景
-(void)favorScene {
     UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"收藏场景?" message:@"" preferredStyle:UIAlertControllerStyleAlert];
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

- (IBAction)cancelSaveScene:(id)sender {
    
    self.storeNewScene.hidden = YES;
    self.coverView.hidden = YES;
    [self.view bringSubviewToFront:self.currentViewController.view];
}
- (IBAction)selectSceneImg:(id)sender {
    UIButton *btn = sender;
    UIView *view = btn.superview;
    CGFloat w = view.frame.size.width;
    CGFloat h = view.frame.size.height;
    CGFloat y = btn.frame.origin.y + btn.frame.size.height / 2 - 10;
    CGFloat x = btn.center.x - w / 2 - 30;
    [KxMenu showMenuInView:view fromRect:CGRectMake(x, y , w, h) menuItems:@[
                                                                                                                                             [KxMenuItem menuItem:@"本地图库"
                                                                                                                                                            image:nil
                                                                                                                                                           target:self
                                                                                                                                                           action:@selector(selectPhoto:)],
                                                                                                                                             [KxMenuItem menuItem:@"现在拍摄"
                                                                                                                                                            image:nil
                                                                                                                                                           target:self
                                                                                                                                                           action:@selector(takePhoto:)],
                                                                                                                                             ]];
    
}
- (void)selectPhoto:(KxMenuItem *)item {
    [DeviceInfo defaultManager].isPhotoLibrary = YES;
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)takePhoto:(KxMenuItem *)item {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:picker animated:YES completion:NULL];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [DeviceInfo defaultManager].isPhotoLibrary = NO;
    self.selectSceneImg = info[UIImagePickerControllerOriginalImage];
    [self.sceneBg setBackgroundImage:self.selectSceneImg forState:UIControlStateNormal];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [DeviceInfo defaultManager].isPhotoLibrary = NO;
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)sureStoreNewScene:(id)sender {
    if ([self.storeNewSceneName.text isEqualToString:@""]) {
       [MBProgressHUD showError:@"场景名不能为空!"];
        return;
    }
    NSString *sceneFile = [NSString stringWithFormat:@"%@_%d.plist",SCENE_FILE_NAME,self.sceneID];
    NSString *scenePath=[[IOManager scenesPath] stringByAppendingPathComponent:sceneFile];
    NSDictionary *plistDic = [NSDictionary dictionaryWithContentsOfFile:scenePath];
    Scene *scene = [[Scene alloc] initWhithoutSchedule];
    [scene setValuesForKeysWithDictionary:plistDic];
    [[SceneManager defaultManager] saveAsNewScene:scene withName:self.storeNewSceneName.text withPic:self.selectSceneImg];
    self.storeNewScene.hidden = YES;
    [self.view bringSubviewToFront:self.currentViewController.view];
    [self.navigationController popViewControllerAnimated:YES];


}
       
-(NSString *)UIimageToStr:(UIImage *)img
{
    NSData *data = UIImageJPEGRepresentation(img,1.0f);
    NSString *str = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    return str;
}

-(void)httpHandler:(id) responseObject tag:(int)tag
{
    if(tag == 2) //删除场景的回调
    {
         if([responseObject[@"result"] intValue] == 0)
         {
             //删除数据库记录
           BOOL delSuccess = [SQLManager deleteScene:self.sceneID];
             if (delSuccess) {
                 //删除场景文件
                 Scene *scene = [[SceneManager defaultManager] readSceneByID:self.sceneID];
                 if (scene) {
                     [[SceneManager defaultManager] delScene:scene];
                     [MBProgressHUD showSuccess:@"删除成功"];
                 }else {
                     NSLog(@"scene 不存在！");
                     [MBProgressHUD showSuccess:@"删除失败"];
                 }
             }else {
                 NSLog(@"数据库删除失败（场景表）");
                 [MBProgressHUD showSuccess:@"删除失败"];
             }
         }else{
             [MBProgressHUD showError:responseObject[@"msg"]];
         }
        
        [self.navigationController popViewControllerAnimated:YES];
        
    }else if(tag == 3) { //收藏场景的回调
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
- (IBAction)clickStopBtn:(id)sender {
    [[SceneManager defaultManager] poweroffAllDevice:self.sceneID];
    [self.navigationController popViewControllerAnimated:YES];

}
- (IBAction)deleteScene:(UIBarButtonItem *)sender {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"确定删除吗?" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *sureAction =  [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                NSString *url = [NSString stringWithFormat:@"%@Cloud/scene_delete.aspx",[IOManager httpAddr]];
                NSDictionary *dict = @{
                                       @"token":[UD objectForKey:@"AuthorToken"],
                                       @"scenceid":@(self.sceneID),
                                       @"optype":@(1)
                                       };
                HttpManager *http = [HttpManager defaultManager];
                http.delegate = self;
                http.tag = 2;
                [http sendPost:url param:dict];
    }];
    
    [alertVC addAction:sureAction];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [alertVC dismissViewControllerAnimated:YES completion:nil];
    }];
    [alertVC addAction:cancelAction];
    [self presentViewController:alertVC animated:YES completion:nil];
    
   }

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end
