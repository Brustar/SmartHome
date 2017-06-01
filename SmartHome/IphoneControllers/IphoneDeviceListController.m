//
//  IphoneDeviceListController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/9/19.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "IphoneDeviceListController.h"
#import "SQLManager.h"
#import "Room.h"
#import "LightController.h"
#import "CurtainController.h"
#import "TVController.h"
#import "FMController.h"
#import "FloweringController.h"
#import "PluginViewController.h"
#import "CameraController.h"
#import "AirController.h"
#import "ScreenCurtainController.h"
#import "ProjectController.h"
#import "IphoneRoomView.h"
#import "MBProgressHUD+NJ.h"
#import "AmplifierController.h"
#import "WindowSlidingController.h"
#import "BgMusicController.h"
#import "IPadMenuController.h"
#import "AppDelegate.h"
#import "CYLineLayout.h"
#import "CYPhotoCell.h"

static NSString * const CYPhotoId = @"photo";
@interface IphoneDeviceListController ()<IphoneRoomViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic,assign) int selectedSId;

@property (nonatomic,strong) NSArray *devices;

@property (nonatomic ,strong) CYPhotoCell *cell;
@property (nonatomic,strong) UIButton *typeSelectedBtn;
@property (nonatomic,strong) UIButton *selectedRoomBtn;
@property (nonatomic,strong) NSArray *rooms;
@property (nonatomic,strong) NSArray *icons;

@property (weak, nonatomic) UIViewController *currentViewController;
@property (weak, nonatomic) IBOutlet IphoneRoomView *iphoneRoomView;
@property (nonatomic, assign) int roomIndex;

@property (nonatomic,strong)UICollectionView * FirstCollectionView;
@property (weak, nonatomic) IBOutlet UILabel *DeviceNameLabel;


@end

@implementation IphoneDeviceListController


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    BaseTabBarController *baseTabbarController =  (BaseTabBarController *)self.tabBarController;
    baseTabbarController.tabbarPanel.hidden = NO;
    baseTabbarController.tabBar.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    BaseTabBarController *baseTabbarController =  (BaseTabBarController *)self.tabBarController;
    baseTabbarController.tabbarPanel.hidden = NO;
    baseTabbarController.tabBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    BaseTabBarController *baseTabbarController =  (BaseTabBarController *)self.tabBarController;
    baseTabbarController.tabbarPanel.hidden = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        baseTabbarController.tabbarPanel.hidden = NO;
    }
    
    if (_nowMusicController) {
        [_nowMusicController.view removeFromSuperview];
        _nowMusicController = nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addNotifications];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self setupNaviBar];
    [self showNetStateView];
    self.rooms = [SQLManager getAllRoomsInfo];
    
    [self setUpRoomScrollerView];
    [self getUI];
    self.icons = @[@"cata_light",@"cata_env",@"cata_media",@"cata_single_product",@"cata_curtain"];
    
    //开启网络状况监听器
    [self updateInterfaceWithReachability];
}

//处理连接改变后的情况
- (void)updateInterfaceWithReachability
{
    __block IphoneDeviceListController * FirstBlockSelf = self;
    
    _afNetworkReachabilityManager = [AFNetworkReachabilityManager sharedManager];
    
    [_afNetworkReachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        DeviceInfo *info = [DeviceInfo defaultManager];
        if(status == AFNetworkReachabilityStatusReachableViaWWAN) //手机自带网络
        {
            if (info.connectState == outDoor) {
                [FirstBlockSelf setNetState:netState_outDoor_4G];
                NSLog(@"外出模式-4G");
                
            }else if (info.connectState == atHome){
                [FirstBlockSelf setNetState:netState_atHome_4G];
                NSLog(@"在家模式-4G");
                
            }else if (info.connectState == offLine) {
                [FirstBlockSelf setNetState:netState_notConnect];
                NSLog(@"离线模式");
                
            }
        }
        else if(status == AFNetworkReachabilityStatusReachableViaWiFi) //WIFI
        {
            if (info.connectState == atHome) {
                [FirstBlockSelf setNetState:netState_atHome_WIFI];
                NSLog(@"在家模式-WIFI");
                
                
            }else if (info.connectState == outDoor){
                [FirstBlockSelf setNetState:netState_outDoor_WIFI];
                NSLog(@"外出模式-WIFI");
                
            }else if (info.connectState == offLine) {
                [FirstBlockSelf setNetState:netState_notConnect];
                NSLog(@"离线模式");
                
                
            }
        }else if(status == AFNetworkReachabilityStatusNotReachable){ //没有网络(断网)
            [FirstBlockSelf setNetState:netState_notConnect];
            NSLog(@"离线模式");
            
        }else if (status == AFNetworkReachabilityStatusUnknown) { //未知网络
            [FirstBlockSelf setNetState:netState_notConnect];
            
        }
    }];
    
    [_afNetworkReachabilityManager startMonitoring];//开启网络监视器；
    
}

- (void)addNotifications {
    [NC addObserver:self selector:@selector(netWorkDidChangedNotification:) name:@"NetWorkDidChangedNotification" object:nil];
}

- (void)netWorkDidChangedNotification:(NSNotification *)noti {
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];//开启网络监视器；
}

- (void)removeNotifications {
    [NC removeObserver:self];
}

- (void)setupNaviBar {
    [self setNaviBarTitle:[UD objectForKey:@"homename"]]; //设置标题
    _naviLeftBtn = [CustomNaviBarView createImgNaviBarBtnByImgNormal:@"clound_white" imgHighlight:@"clound_white" target:self action:@selector(leftBtnClicked:)];
    
    NSString *music_icon = nil;
    NSInteger isPlaying = [[UD objectForKey:@"IsPlaying"] integerValue];
    if (isPlaying) {
        music_icon = @"music-red";
    }else {
        music_icon = @"music_white";
    }
    
    _naviRightBtn = [CustomNaviBarView createImgNaviBarBtnByImgNormal:music_icon imgHighlight:music_icon target:self action:@selector(rightBtnClicked:)];
    [self setNaviBarLeftBtn:_naviLeftBtn];
    [self setNaviBarRightBtn:_naviRightBtn];
}

- (void)leftBtnClicked:(UIButton *)btn {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (appDelegate.LeftSlideVC.closed)
    {
        [appDelegate.LeftSlideVC openLeftView];
    }
    else
    {
        [appDelegate.LeftSlideVC closeLeftView];
    }
}

- (void)rightBtnClicked:(UIButton *)btn {
    //[self performSegueWithIdentifier:@"FM" sender:self];
    
    UIStoryboard * HomeStoryBoard = [UIStoryboard storyboardWithName:@"Home" bundle:nil];
    if (_nowMusicController == nil) {
        _nowMusicController = [HomeStoryBoard instantiateViewControllerWithIdentifier:@"NowMusicController"];
        _nowMusicController.delegate = self;
        [self.view addSubview:_nowMusicController.view];
    }else {
        [_nowMusicController.view removeFromSuperview];
        _nowMusicController = nil;
    }
}

- (void)onBgButtonClicked:(UIButton *)sender {
    if (_nowMusicController) {
        [_nowMusicController.view removeFromSuperview];
        _nowMusicController = nil;
    }
}

-(void)getUI
{
    // 创建CollectionView
    CGFloat collectionW = self.view.frame.size.width;
    CGFloat collectionH = self.view.frame.size.height-200;
    CGRect frame = CGRectMake(0, 130, collectionW, collectionH);
    // 创建布局
    CYLineLayout *layout = [[CYLineLayout alloc] init];
    if (([UIScreen mainScreen].bounds.size.height <= 568.0)) {
        layout.itemSize = CGSizeMake(collectionW-50, collectionH-20);
    }else{
        layout.itemSize = CGSizeMake(collectionW-90, collectionH-20);
    }

    //layout.itemSize = CGSizeMake(collectionW-110, collectionH-20);
    self.FirstCollectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
    self.FirstCollectionView.backgroundColor = [UIColor clearColor];
    self.FirstCollectionView.dataSource = self;
    self.FirstCollectionView.delegate = self;

    [self.view addSubview:self.FirstCollectionView];
    self.automaticallyAdjustsScrollViewInsets = NO;
    // 注册
    [self.FirstCollectionView registerNib:[UINib nibWithNibName:NSStringFromClass([CYPhotoCell class]) bundle:nil] forCellWithReuseIdentifier:CYPhotoId];
}

-(void)setUpRoomScrollerView
{
    NSMutableArray *roomNames = [NSMutableArray array];
    
    for (Room *room in self.rooms) {
        NSString *roomName = room.rName;
        [roomNames addObject:roomName];
    }
    self.iphoneRoomView.dataArray = roomNames;
    self.iphoneRoomView.delegate = self;
    if (self.iphoneRoomView.dataArray.count == 0) {
        return;
    }
    [self.iphoneRoomView setSelectButton:0];
    
    [self iphoneRoomView:self.iphoneRoomView didSelectButton:0];
}

- (void)iphoneRoomView:(UIView *)view didSelectButton:(int)index {
    if (view == self.iphoneRoomView) {
        self.roomIndex = index;
        Room *room = self.rooms[index];
        self.devices = [SQLManager getCatalogWithRoomID:room.rId];
        
        if (self.devices.count < 1) {
            [MBProgressHUD showError:@"该房间没有设备"];
            return;
        }
        [self.FirstCollectionView reloadData];
    }
}

-(void) UISplit:(NSArray *)controllers
{
    if ([controllers count]==2){ 
        CustomViewController *root = [[CustomViewController alloc] init];
        //初始化UISplitViewController
        UISplitViewController *splitVC = [[UISplitViewController alloc] init];
        //配置分屏视图界面外观
        splitVC.preferredDisplayMode = UISplitViewControllerDisplayModeAutomatic;
        //调整masterViewController的宽度，按百分比调整
        splitVC.preferredPrimaryColumnWidthFraction = 0.25;
        splitVC.viewControllers = controllers;
        [root.view addSubview:splitVC.view];
        [root addChildViewController:splitVC];
        [self.navigationController pushViewController:root animated:YES];
        [root setNaviBarTitle:[[controllers lastObject] title]];
    }
    
    if ([controllers count]==1){
        [self.navigationController pushViewController:[controllers firstObject] animated:YES];
    }
}

-(NSString *) seguaName:(int) typeID
{
    switch (typeID) {
        case cata_light:
            return @"lighting";
        case cata_curtain:
            return @"curtain";
        case cata_env:
            return @"air";
        case cata_single_product:
            return @"flowering";
        case cata_media:
            return @"TV";
        default:
            break;
    }
    return NULL;
}

-(NSArray *)calcontroller:(int) typeID
{
    NSArray *controllers = @[];
    IPadMenuController *menu = [[IPadMenuController alloc] init];
    menu.typeID = typeID;
    Room *room = self.rooms[self.roomIndex];
    menu.roomID = room.rId;
    UIStoryboard *devicesStoryBoard  = [UIStoryboard storyboardWithName:@"Devices" bundle:nil];
    id device;
    switch (typeID) {
        case cata_light:
            device = [devicesStoryBoard instantiateViewControllerWithIdentifier:@"LightController"];
            ((LightController*)device).roomID = room.rId;
            
            return @[menu,device];
        case cata_curtain:
            device = [devicesStoryBoard instantiateViewControllerWithIdentifier:@"CurtainController"];
            ((CurtainController*)device).roomID = room.rId;
            return @[device];
        case cata_env:
            device = [devicesStoryBoard instantiateViewControllerWithIdentifier:@"AirController"];
            ((AirController*)device).roomID = room.rId;
            return @[device];
        case cata_single_product:
            device = [devicesStoryBoard instantiateViewControllerWithIdentifier:@"FloweringController"];
            ((FloweringController*)device).roomID = room.rId;
            return @[menu,device];
        case cata_media:
            device = [devicesStoryBoard instantiateViewControllerWithIdentifier:@"TVController"];
            ((TVController*)device).roomID = room.rId;
            return @[menu,device];
        default:
            break;
    }
    
    return controllers;
}

-(void)goDeviceByRoomID:(NSString *)typeID
{
    int type = [typeID intValue];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        NSString *segua = [self seguaName:type];
        if (segua) {
            [self performSegueWithIdentifier:segua sender:self];
        }
    }else{
        NSArray *controllers = [self calcontroller:type];
        [self UISplit:controllers];
    }
}

- (UIViewController *)addOldmanRoomCameraImage {
    UIViewController *vc = [[UIViewController alloc] init];
    UIImage *img = [UIImage imageNamed:@"oldman"];
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, img.size.width, img.size.height)];
    imgView.image = img;
    [vc.view addSubview:imgView];
    
    return vc;
}

-(void)selectedRoom:(UIButton *)btn
{
    self.selectedRoomBtn.selected = NO;
    btn.selected = YES;
    self.selectedRoomBtn = btn;
    [self.selectedRoomBtn setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
    self.devices = [SQLManager getCatalogWithRoomID:(int)btn.tag];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    id theSegue = segue.destinationViewController;
    Room *room = self.rooms[self.roomIndex];
    [[DeviceInfo defaultManager] setRoomID:room.rId];
    [theSegue setValue:[NSString stringWithFormat:@"%d", room.rId] forKey:@"roomID"];
}

#pragma  mark - UICollectionViewDelegate
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.devices.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CYPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CYPhotoId forIndexPath:indexPath];
    
        cell.deleteBtn.hidden = YES;
        cell.powerBtn.hidden = YES;
        cell.seleteSendPowBtn.hidden = YES;
        Device * device = self.devices[indexPath.row];
        cell.SceneName.text = device.subTypeName;
        cell.SceneNameTopConstraint.constant = 40;
    NSString *imgName = [NSString stringWithFormat:@"catalog_%ld",(long)indexPath.row];
    UIImage *img = [UIImage imageNamed:imgName];
    [cell.imageView sd_setImageWithURL:nil placeholderImage:img];
    if ([self.icons count]>indexPath.row) {
        cell.icon.hidden = NO;
        cell.icon.image = [UIImage imageNamed:[self.icons objectAtIndex:indexPath.row]];
    }
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    Device *device = self.devices[indexPath.row];
    [self goDeviceByRoomID:[NSString stringWithFormat:@"%ld",device.subTypeId]];
}

- (void)dealloc {
    [self removeNotifications];
}

@end
