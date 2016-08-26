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
#import "DeviceManager.h"
#import "Device.h"
#import "MBProgressHUD+NJ.h"
#import "DeviceType.h"
#import "KxMenu.h"
#import "SceneManager.h"
#import "IOManager.h"
#import "PrintObject.h"
#import "HttpManager.h"
#import "MBProgressHUD+NJ.h"
@interface DeviceListController ()<UITableViewDelegate,UITableViewDataSource,UISplitViewControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHight;
@property (nonatomic,strong) NSArray *deviceTypes;
@property (weak, nonatomic) IBOutlet UIView *saveSceneView;
@property (weak, nonatomic) IBOutlet UITextField *sceneName;
@property (weak, nonatomic) IBOutlet UIButton *selectSceneImg;
@property (nonatomic,strong)UIImage *sceneImg;
@end

@implementation DeviceListController

-(void)setRoomid:(NSInteger)roomid
{
    _roomid = roomid;
    self.deviceTypes = [DeviceManager deviceSubTypeByRoomId:_roomid];
    self.tableViewHight.constant = self.deviceTypes.count * self.tableView.rowHeight;
    if(self.isViewLoaded)
    {
        
        [self.tableView reloadData];
    }
    
}
    


-(void) viewDidLoad

{
   
    self.segues=[NSArray arrayWithObjects:@"Lighter" ,@"Curtain",@"TV"  ,@"DVD" ,@"Netv",@"FM",@"Guard",@"Camera",@"Air",@"pluginSegue",nil];
    self.tableView.rowHeight=44;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.layer.cornerRadius = 10;
    self.tableView.layer.masksToBounds = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.splitViewController.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;
     self.tableViewHight.constant = self.deviceTypes.count * self.tableView.rowHeight;
}
-(IBAction)remove:(id)sender
{
    Scene *scene=[[Scene alloc] init];
    [scene setSceneID:[self.sceneid intValue]];
    [scene setReadonly:NO];
    [[SceneManager defaultManager] delScenen:scene];
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
    }else if([typeName isEqualToString:@"电视"]){
        segue = @"TV";
    }else if([typeName isEqualToString:@"空调"]){
        segue = @"Air";
    }else if([typeName isEqualToString:@"DVD"]){
        segue = @"DVD";
    }else if([typeName isEqualToString:@"FM"]){
        segue = @"FM";
    }else if([typeName isEqualToString:@"监控"]){
        segue = @"Camera";
    }else if([typeName isEqualToString:@"智能插座"]) {
        segue = @"pluginSegue";
    }
    else {
        segue = @"Guard";

    }

    
        
    [self performSegueWithIdentifier:segue sender:self];
}

#pragma mark - Navigation

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    id theSegue = segue.destinationViewController;
    [theSegue setValue:[NSNumber numberWithInt:(int)self.roomid] forKey:@"roomID"];
    
}

- (IBAction)selectSceneImg:(id)sender {
    
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
    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
        return;
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
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
    self.sceneImg = info[UIImagePickerControllerEditedImage];
    [picker dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)storeScene:(id)sender {
    self.saveSceneView.hidden = NO;
    
}
- (IBAction)sureStoreScene:(id)sender {
    NSString *sceneFile = [NSString stringWithFormat:@"%@_0.plist",SCENE_FILE_NAME];
    NSString *scenePath=[[IOManager scenesPath] stringByAppendingPathComponent:sceneFile];
    NSDictionary *plistDic = [NSDictionary dictionaryWithContentsOfFile:scenePath];
    
    Scene *scene = [[Scene alloc]init];
    [scene setValuesForKeysWithDictionary:plistDic];
    NSString *imgStr = [self UIimageToStr:self.sceneImg];
    
    [[SceneManager defaultManager] addScenen:scene withName:self.sceneName.text withPic:imgStr];

}

- (IBAction)canleStore:(id)sender {
    self.saveSceneView.hidden = YES;
}

-(NSString *)UIimageToStr:(UIImage *)img
{
    NSData *data = UIImageJPEGRepresentation(img,1.0f);
    NSString *str = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    return str;
}
-(void)httpHandler:(id) responseObject
{
   
    if(responseObject[@"Result"] == 0)
    {
        self.saveSceneView.hidden = YES;
        [MBProgressHUD showSuccess:@"创建场景成功"];
       
        
    }
        [MBProgressHUD showError:responseObject[@"Msg"]];
    
    
}


@end
