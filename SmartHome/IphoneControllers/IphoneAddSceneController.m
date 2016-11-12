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

@interface IphoneAddSceneController ()<UITableViewDelegate,UITableViewDataSource>
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
        [deviceName addObject:name];
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
    NSString *sceneFile = [NSString stringWithFormat:@"%@_%d.plist",SCENE_FILE_NAME,self.sceneID];

    NSString *scenePath=[[IOManager scenesPath] stringByAppendingPathComponent:sceneFile];
    NSDictionary *plistDic = [NSDictionary dictionaryWithContentsOfFile:scenePath];
    
    Scene *scene = [[Scene alloc]initWhithoutSchedule];
    [scene setValuesForKeysWithDictionary:plistDic];
    [[DeviceInfo defaultManager] setEditingScene:NO];
//      [[SceneManager defaultManager] saveAsNewScene:scene withName:self.sceneName.text withPic:self.selectSceneImg];
    [[SceneManager defaultManager] addScene:scene withName:self.sceneName.text withImage:[UIImage imageNamed:@""]];
//    self.navigationController.navigationBar.hidden = YES;
    [self.navigationController popViewControllerAnimated:YES];
    
    
}



@end
