//
//  IphoneAddSceneController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/9/26.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "IphoneAddSceneController.h"
#import "SQLManager.h"
#import "SceneManager.h"
#import "MBProgressHUD+NJ.h"
#import "KxMenu.h"

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

@interface IphoneAddSceneController ()<UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *sceneName;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSArray *devices;
@property (weak, nonatomic) IBOutlet UILabel *startTime;//开始时间
@property (weak, nonatomic) IBOutlet UILabel *endTime;//结束时间
@property (weak, nonatomic) IBOutlet UILabel *repeat;//设置重复日期
@property (weak, nonatomic) IBOutlet UILabel *StartDayLael;//开始日期
@property (weak, nonatomic) IBOutlet UILabel *EndDayLabel;//结束日期

@property (weak, nonatomic) IBOutlet UIView *timeView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveNewScene;//保存按钮

@property (weak, nonatomic) IBOutlet UIView *SceneView;//弹出框的视图

@property (weak, nonatomic) IBOutlet UIButton *ImageBtn;//场景图片按钮
@property (nonatomic,strong) UIImage * selectSceneImg;

@end

@implementation IphoneAddSceneController

- (void)viewDidLoad {
    [super viewDidLoad];
    if(self.isFavor)
    {
        self.saveNewScene.enabled = NO;
    }
    self.tableView.tableFooterView = [UIView new];
     self.automaticallyAdjustsScrollViewInsets = NO;
  
    [self reachNotification];
  
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.devices = [self deviceAdded];
    [self.tableView reloadData];
}

-(void)reachNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getFixTimeInfo:) name:@"time" object:nil];
}
-(void)getFixTimeInfo:(NSNotification *)notification
{
    NSDictionary *dic = notification.userInfo;
    self.startTime.text = dic[@"startTime"];
    self.endTime.text = dic[@"endTime"];
    self.StartDayLael.text = dic[@"startDay"];
    self.EndDayLabel.text = dic[@"endDay"];
    self.repeat.text = dic[@"repeat"];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"gotoDeviceSegue"])
    {
        id theSegue = segue.destinationViewController;
        [theSegue setValue:[NSNumber numberWithInt:self.roomId] forKey:@"roomId"];
       
    }

}
//添加定时
- (IBAction)addFixTime:(id)sender {
    
    
    [self performSegueWithIdentifier:@"addTimeSegue" sender:self];
    
}

-(NSArray *)deviceAdded
{
    NSString *sceneFile = [NSString stringWithFormat:@"%@_%d.plist",SCENE_FILE_NAME,self.sceneID];
    NSString *scenePath=[[IOManager scenesPath] stringByAppendingPathComponent:sceneFile];
    NSDictionary *plistDic = [NSDictionary dictionaryWithContentsOfFile:scenePath];
    NSArray *devices = plistDic[@"devices"];
    NSMutableArray *deviceName = [NSMutableArray array];
    for(NSDictionary *dic in devices)
    {
        //dic[@"deviceID"];
        NSString *name = [SQLManager deviceNameByDeviceID:[dic[@"deviceID"] intValue]];
        if (name) {
              [deviceName addObject:name];
        }
        
      
    }
    return [deviceName copy];

}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.devices.count;
   
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(!cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = self.devices[indexPath.row];

    
    return cell;
}

//保存场景
- (IBAction)saveNewScene:(id)sender {
    
    if ([self.sceneName.text isEqualToString:@""]) {
        [MBProgressHUD showError:@"场景名不能为空!"];
        return;
    }
     [self.view bringSubviewToFront:self.SceneView];
    self.SceneView.hidden = NO;
    

    
    
}
- (IBAction)cancelBtn:(id)sender {
    
    self.SceneView.hidden = YES;
}
- (IBAction)SureBtn:(id)sender {
    
        NSString *sceneFile = [NSString stringWithFormat:@"%@_%d.plist",SCENE_FILE_NAME,self.sceneID];
    
        NSString *scenePath=[[IOManager scenesPath] stringByAppendingPathComponent:sceneFile];
        NSDictionary *plistDic = [NSDictionary dictionaryWithContentsOfFile:scenePath];
    
        Scene *scene = [[Scene alloc]initWhithoutSchedule];
        [scene setValuesForKeysWithDictionary:plistDic];
        [[DeviceInfo defaultManager] setEditingScene:NO];
    
        [[SceneManager defaultManager] addScene:scene withName:self.sceneName.text withImage:self.selectSceneImg];
        [self.navigationController popViewControllerAnimated:YES];
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
    [picker shouldAutorotate];
    [picker supportedInterfaceOrientations];
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
    self.selectSceneImg = info[UIImagePickerControllerEditedImage];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [DeviceInfo defaultManager].isPhotoLibrary = NO;
    [picker dismissViewControllerAnimated:YES completion:nil];
}
@end
