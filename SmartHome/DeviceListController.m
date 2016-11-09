//
//  DeviceListController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/7/22.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "DeviceListController.h"
#import "Scene.h"
#import "SceneManager.h"
#import "SQLManager.h"
#import "Device.h"
#import "MBProgressHUD+NJ.h"
#import "DeviceType.h"
#import "KxMenu.h"
#import "SceneManager.h"
#import "IOManager.h"
#import "PrintObject.h"
#import "HttpManager.h"
#import "MBProgressHUD+NJ.h"
//#import "UIImagePickerController+LandScapeImagePicker.h"
#import "AmplifierController.h"
#import "UploadManager.h"
#import "ECloudTabBarController.h"
#import "ECloudTabBar.h"
@interface DeviceListController ()<UITableViewDelegate,UITableViewDataSource,UISplitViewControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHight;
@property (nonatomic,strong) NSArray *deviceTypes;
@property (weak, nonatomic) IBOutlet UIView *saveSceneView;

@property (weak, nonatomic) IBOutlet UITextField *sceneName;
@property (weak, nonatomic) IBOutlet UIButton *selectSceneImg;

@property (nonatomic,strong)UIImage *sceneImg;
@property (nonatomic, assign) CGRect detialFrame;
@property (nonatomic, assign) BOOL isSetDetialFrame;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveBtn;

@end

@implementation DeviceListController

-(void)setRoomid:(NSInteger)roomid
{
    _roomid = roomid;
    self.deviceTypes = [SQLManager deviceSubTypeByRoomId:_roomid];
   
   // self.tableViewHight.constant = (self.deviceTypes.count +1) * self.tableView.rowHeight ;
    if(self.isViewLoaded)
    {
        
        [self.tableView reloadData];
    }
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!self.isSetDetialFrame) {
        self.detialFrame = self.navigationController.view.bounds;
        self.isSetDetialFrame = YES;
    }
}

-(void) viewDidLoad

{
    if(self.sceneid)
    {
        self.saveBtn.enabled = NO;
    }

    
    self.tableView.rowHeight=44;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.layer.cornerRadius = 10;
    self.tableView.layer.masksToBounds = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
   
    
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    if(self.isSetDetialFrame)
    {
        self.navigationController.view.bounds = self.detialFrame;
        
    }
    
    self.splitViewController.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;
    self.tableViewHight.constant = self.deviceTypes.count * self.tableView.rowHeight;
}

-(IBAction)remove:(id)sender
{
    Scene *scene=[[Scene alloc] init];
    [scene setSceneID:[self.sceneid intValue]];
    [scene setReadonly:NO];
    [[SceneManager defaultManager] delScene:scene];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
 
#pragma mark - SplitViewController

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.deviceTypes.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
   
    
    cell.textLabel.text=self.deviceTypes[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.splitViewController.preferredDisplayMode = UISplitViewControllerDisplayModePrimaryHidden;
    NSString *typeName = self.deviceTypes[indexPath.row];
    
    //    self.deviceid = deviceType.subTypeID;
    NSString *segue;
    if([typeName isEqualToString:@"灯光"]){
        segue = @"Lighter";
    }else if([typeName isEqualToString:@"窗帘"]){
        segue = @"Curtain";
    }else if([typeName isEqualToString:@"网络电视"]){
        segue = @"TV";
    }else if([typeName isEqualToString:@"空调"]){
        segue = @"Air";
    }else if([typeName isEqualToString:@"DVD"]){
        segue = @"DVD";
    }else if([typeName isEqualToString:@"FM"]){
        segue = @"FM";
    }else if([typeName isEqualToString:@"摄像头"]){
        segue = @"Camera";
    }else if([typeName isEqualToString:@"智能插座"]) {
        segue = @"pluginSegue";
    }
    else if([typeName isEqualToString:@"机顶盒"])
    {
        segue = @"Netv";

    }else if([typeName isEqualToString:@"功放"]){
        segue = @"amplifierSegue";
        
    }else if([typeName isEqualToString:@"背景音乐"]){
        segue = @"musicSegue";
        
    }else if([typeName isEqualToString:@"幕布"]){
        segue = @"screenCurtain";
    }else if([typeName isEqualToString:@"投影"]){
        segue = @"projectSegue";
        
    }else if([typeName isEqualToString:@"智能推窗器"]){
        segue = @"windowSlider";
        
    }else{
        segue = @"Guard";
    }

    
        
    [self performSegueWithIdentifier:segue sender:self];
}

#pragma mark - Navigation

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if(![segue.identifier isEqualToString:@"deviceToSceneSegue"])
    {
        id theSegue = segue.destinationViewController;
        [theSegue setValue:[NSNumber numberWithInt:(int)self.roomid] forKey:@"roomID"];
        [theSegue setValue:self.sceneid forKey:@"sceneid"];
        [theSegue setValue:@"YES" forKey:@"isAddDevice"];
    }
    
    
}
- (IBAction)selectedSceneImage:(id)sender {
    UIButton *btn = sender;
    UIView *view = btn.superview;
    CGFloat y = view.frame.origin.y -(view.frame.size.width - btn.frame.size.width);
    [KxMenu showMenuInView:self.view fromRect:CGRectMake(view.frame.origin.x, y , view.frame.size.width, view.frame.size.height) menuItems:@[
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
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
        return;
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [picker shouldAutorotate];
    [picker supportedInterfaceOrientations];
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)takePhoto:(KxMenuItem *)item {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    
    [self presentViewController:picker animated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
   [DeviceInfo defaultManager].isPhotoLibrary = NO;
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    
    [self.selectSceneImg setBackgroundImage:image forState:UIControlStateNormal];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [DeviceInfo defaultManager].isPhotoLibrary = NO;
    [picker dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)storeScene:(id)sender {

    self.saveSceneView.hidden = NO;
   [self.sceneName becomeFirstResponder];
    
    
}



- (IBAction)sureStoreScene:(id)sender {
    if (self.sceneName.text.length <=0) {
        //[MBProgressHUD showError:@"场景名不能为空"];
        return;
    }
    self.saveSceneView.hidden = YES;
    
    NSString *sceneFile = [NSString stringWithFormat:@"%@_0.plist",SCENE_FILE_NAME];
    NSString *scenePath=[[IOManager scenesPath] stringByAppendingPathComponent:sceneFile];
    NSDictionary *plistDic = [NSDictionary dictionaryWithContentsOfFile:scenePath];

    Scene *scene = [[Scene alloc] initWhithoutSchedule];
    [scene setValuesForKeysWithDictionary:plistDic];
    [[DeviceInfo defaultManager] setEditingScene:NO];
    [[SceneManager defaultManager] addScene:scene withName:self.sceneName.text withImage:self.selectSceneImg.currentBackgroundImage];
    [self.splitViewController dismissViewControllerAnimated:YES completion:nil];
    
    NSDictionary *dic = @{@"type":[NSNumber numberWithInt:0],@"subType":[NSNumber numberWithInteger:self.roomid ]};
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:@"tabBar" object:nil userInfo:dic];
    

}
- (IBAction)canleStore:(id)sender {
    self.saveSceneView.hidden = YES;
}





@end
