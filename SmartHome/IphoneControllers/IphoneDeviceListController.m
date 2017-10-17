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
#import "NewWindController.h"
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
#import "IPadDevicesView.h"
#import "GuardController.h"
#import "SocketManager.h"
#import "PackManager.h"

static NSString * const CYPhotoId = @"photo";
@interface IphoneDeviceListController ()<IphoneRoomViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic,assign) int selectedSId;

@property (nonatomic,strong) NSArray *devices;
@property (nonatomic,assign) int sum;
@property (nonatomic ,strong) CYPhotoCell *cell;
@property (nonatomic,strong) UIButton *typeSelectedBtn;
@property (nonatomic,strong) UIButton *selectedRoomBtn;
@property (nonatomic,strong) NSArray *rooms;
@property (nonatomic,weak) NSString *deviceid;
@property (weak, nonatomic) UIViewController *currentViewController;
@property (weak, nonatomic) IBOutlet IphoneRoomView *iphoneRoomView;
@property (nonatomic, assign) int roomIndex;
@property (nonatomic,strong) NSMutableArray * bgmusicIDS;
@property (nonatomic,strong) NSMutableArray * bgmusicIDArr;
@property (nonatomic,strong)UICollectionView * FirstCollectionView;
@property (weak, nonatomic) IBOutlet UILabel *DeviceNameLabel;
@property (nonatomic,strong) BaseTabBarController *baseTabbarController;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *menuRight;
@property (weak, nonatomic) IBOutlet UIButton *switcher;
@property (weak, nonatomic) IPadDevicesView *deviceView;

@end

@implementation IphoneDeviceListController


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _baseTabbarController =  (BaseTabBarController *)self.tabBarController;
    _baseTabbarController.tabbarPanel.hidden = NO;
    _baseTabbarController.tabBar.hidden = YES;
    [self addNotifications];
    [LoadMaskHelper showMaskWithType:DeviceHome onView:self.tabBarController.view delay:0.5 delegate:self];
      [_bgmusicIDArr removeAllObjects];
     [self setupNaviBar];
    
    
    SocketManager *sock=[SocketManager defaultManager];
    sock.delegate=self;
    _bgmusicIDS = [[NSMutableArray alloc] init];
    NSArray * roomArr = [SQLManager getAllRoomsWhenHasDevices];
    for (int i = 0; i < roomArr.count; i ++) {
        Room * roomName = roomArr[i];
        if (![SQLManager isWholeHouse:roomName.rId]) {
            self.deviceid = [SQLManager singleDeviceWithCatalogID:bgmusic byRoom:roomName.rId];
        }
        if (self.deviceid.length != 0) {
            [_bgmusicIDS addObject:self.deviceid];
            //查询设备状态
            NSData *data = [[DeviceInfo defaultManager] query:self.deviceid];
            [sock.socket writeData:data withTimeout:1 tag:1];
            
        }
    }
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
    _bgmusicIDArr = [[NSMutableArray alloc] init];
    self.automaticallyAdjustsScrollViewInsets = NO;
   
    [self showNetStateView];

    self.rooms = [SQLManager getAllRoomsWhenHasDevices];
    
    [self setUpRoomScrollerView];
    [self getUI];
    
    //开启网络状况监听器
    [self updateInterfaceWithReachability];
}

- (void)refreshUI {
    DeviceInfo *info = [DeviceInfo defaultManager];
    if([[AFNetworkReachabilityManager sharedManager] isReachableViaWWAN]) { //手机自带网络
        if (info.connectState == offLine) {
            [self setNetState:netState_notConnect];
            [self.baseTabbarController.tabbarPanel.sliderBtn setBackgroundImage:[UIImage  imageNamed:@"slider"] forState:UIControlStateNormal];
            NSLog(@"离线模式");
        }else{
            [self setNetState:netState_outDoor_4G];
            [self.baseTabbarController.tabbarPanel.sliderBtn setBackgroundImage:[UIImage imageNamed:@"Scene-selected"] forState:UIControlStateNormal];
            NSLog(@"外出模式-4G");
        }
    }else if ([[AFNetworkReachabilityManager sharedManager] isReachableViaWiFi]) { //WIFI
        
        if (info.connectState == atHome) {
            [self setNetState:netState_atHome_WIFI];
            [self.baseTabbarController.tabbarPanel.sliderBtn setBackgroundImage:[UIImage imageNamed:@"Scene-selected"] forState:UIControlStateNormal];
            NSLog(@"在家模式-WIFI");
            
            
        }else if (info.connectState == outDoor){
            [self setNetState:netState_outDoor_WIFI];
            [self.baseTabbarController.tabbarPanel.sliderBtn setBackgroundImage:[UIImage imageNamed:@"Scene-selected"] forState:UIControlStateNormal];
            NSLog(@"外出模式-WIFI");
            
        }else if (info.connectState == offLine) {
            [self setNetState:netState_notConnect];
            [self.baseTabbarController.tabbarPanel.sliderBtn setBackgroundImage:[UIImage imageNamed:@"slider"] forState:UIControlStateNormal];
            NSLog(@"离线模式");
        }
        
    }else {
        [self setNetState:netState_notConnect];
        [self.baseTabbarController.tabbarPanel.sliderBtn setBackgroundImage:[UIImage imageNamed:@"slider"] forState:UIControlStateNormal];
        NSLog(@"离线模式");
    }
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
            if (info.connectState == offLine) {
                [FirstBlockSelf setNetState:netState_notConnect];
                [FirstBlockSelf.baseTabbarController.tabbarPanel.sliderBtn setBackgroundImage:[UIImage  imageNamed:@"slider"] forState:UIControlStateNormal];
                NSLog(@"离线模式");
            }else{
                [FirstBlockSelf setNetState:netState_outDoor_4G];
                [FirstBlockSelf.baseTabbarController.tabbarPanel.sliderBtn setBackgroundImage:[UIImage imageNamed:@"Scene-selected"] forState:UIControlStateNormal];
                NSLog(@"外出模式-4G");
            }
        }
        else if(status == AFNetworkReachabilityStatusReachableViaWiFi) //WIFI
        {
            if (info.connectState == atHome) {
                [FirstBlockSelf setNetState:netState_atHome_WIFI];
                [FirstBlockSelf.baseTabbarController.tabbarPanel.sliderBtn setBackgroundImage:[UIImage imageNamed:@"Scene-selected"] forState:UIControlStateNormal];
                NSLog(@"在家模式-WIFI");
                
                
            }else if (info.connectState == outDoor){
                [FirstBlockSelf setNetState:netState_outDoor_WIFI];
                [FirstBlockSelf.baseTabbarController.tabbarPanel.sliderBtn setBackgroundImage:[UIImage imageNamed:@"Scene-selected"] forState:UIControlStateNormal];
                NSLog(@"外出模式-WIFI");
                
            }else if (info.connectState == offLine) {
                [FirstBlockSelf setNetState:netState_notConnect];
                [FirstBlockSelf.baseTabbarController.tabbarPanel.sliderBtn setBackgroundImage:[UIImage imageNamed:@"slider"] forState:UIControlStateNormal];
                NSLog(@"离线模式");
                
                
            }
        }else if(status == AFNetworkReachabilityStatusNotReachable){ //没有网络(断网)
            [FirstBlockSelf setNetState:netState_notConnect];
            [FirstBlockSelf.baseTabbarController.tabbarPanel.sliderBtn setBackgroundImage:[UIImage imageNamed:@"slider"] forState:UIControlStateNormal];
            NSLog(@"离线模式");
            
        }else if (status == AFNetworkReachabilityStatusUnknown) { //未知网络
            [FirstBlockSelf setNetState:netState_notConnect];
            [FirstBlockSelf.baseTabbarController.tabbarPanel.sliderBtn setBackgroundImage:[UIImage imageNamed:@"slider"] forState:UIControlStateNormal];
            NSLog(@"离线模式");
            
        }
    }];
    
    [_afNetworkReachabilityManager startMonitoring];//开启网络监视器
}

- (void)addNotifications {
    
    [NC addObserver:self selector:@selector(netWorkDidChangedNotification:) name:@"NetWorkDidChangedNotification" object:nil];
    [NC addObserver:self selector:@selector(SumNumber:) name:@"SumNumber" object:nil];
    [NC addObserver:self selector:@selector(changeHostRefreshUINotification:) name:@"ChangeHostRefreshUINotification" object:nil];
}

- (void)changeHostRefreshUINotification:(NSNotification *)noti {
    self.rooms = [SQLManager getAllRoomsWhenHasDevices];
    [self setUpRoomScrollerView];
}

-(void)SumNumber:(NSNotification *)no
{
    NSString * sumNumber = no.object;
    _sum = [sumNumber intValue];
    
    if (_sum != 0) {
        [self showMassegeLabel];
    }
}
- (void)netWorkDidChangedNotification:(NSNotification *)noti {
    [self refreshUI];
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
        music_icon = @"Ipad-NowMusic-red";
    }else {
        music_icon = @"Ipad-NowMusic";
    }
    
    _naviRightBtn = [CustomNaviBarView createImgNaviBarBtnByImgNormal:music_icon imgHighlight:music_icon target:self action:@selector(rightBtnClicked:)];
    if (isPlaying) {
        UIImageView * imageView = _naviRightBtn.imageView ;
        
        imageView.animationImages = [NSArray arrayWithObjects:
                                     [UIImage imageNamed:@"Ipad-NowMusic-red2"],
                                     [UIImage imageNamed:@"Ipad-NowMusic-red3"],
                                     [UIImage imageNamed:@"Ipad-NowMusic-red4"],
                                     [UIImage imageNamed:@"Ipad-NowMusic-red5"],
                                     [UIImage imageNamed:@"Ipad-NowMusic-red6"],
                                     [UIImage imageNamed:@"Ipad-NowMusic-red7"],
                                     [UIImage imageNamed:@"Ipad-NowMusic-red8"],
                                     [UIImage imageNamed:@"Ipad-NowMusic-red9"],
                                     [UIImage imageNamed:@"Ipad-NowMusic-red10"],
                                     [UIImage imageNamed:@"Ipad-NowMusic-red11"],
                                     [UIImage imageNamed:@"Ipad-NowMusic-red12"],
                                     [UIImage imageNamed:@"Ipad-NowMusic-red13"],
                                     [UIImage imageNamed:@"Ipad-NowMusic-red14"],
                                     [UIImage imageNamed:@"Ipad-NowMusic-red15"],
                                     [UIImage imageNamed:@"Ipad-NowMusic-red16"],
                                     [UIImage imageNamed:@"Ipad-NowMusic-red17"],
                                     [UIImage imageNamed:@"Ipad-NowMusic-red18"],
                                     [UIImage imageNamed:@"Ipad-NowMusic-red19"],
                                     
                                     nil];
        
        //设置动画总时间
        imageView.animationDuration = 2.0;
        //设置重复次数，0表示无限
        imageView.animationRepeatCount = 0;
        //开始动画
        if (! imageView.isAnimating) {
            [imageView startAnimating];
        }
    }
    [self setNaviBarLeftBtn:_naviLeftBtn];
    [self setNaviBarRightBtn:_naviRightBtn];
}

- (void)leftBtnClicked:(UIButton *)btn {
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        iPadMyViewController *myVC = [[iPadMyViewController alloc] init];
        [self.navigationController pushViewController:myVC animated:YES];
    }else {
    
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
}

- (void)rightBtnClicked:(UIButton *)btn {
    NSInteger isPlaying = [[UD objectForKey:@"IsPlaying"] integerValue];
    if (isPlaying == 0) {
        [MBProgressHUD showError:@"没有正在播放的设备"];
        return;
    }
    
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

- (IBAction)switchUI:(id)sender {
    UIButton *btn =(UIButton *)sender;
    btn.selected = !btn.selected;
    if (btn.selected) {
        [btn setImage:[UIImage imageNamed:@"switch_device"] forState:UIControlStateNormal];
    }else{
        [btn setImage:[UIImage imageNamed:@"switch_room"] forState:UIControlStateNormal];
    }
    self.deviceView.hidden = !btn.selected;
    self.showDevices= btn.selected;
}

-(void)getUI
{
    // 创建CollectionView
    CGFloat collectionW = self.view.frame.size.width-50;
    CGFloat collectionH = self.view.frame.size.height-200;
    CGRect frame = CGRectMake(25, 130, collectionW, collectionH);
    // 创建布局
    CYLineLayout *layout = [[CYLineLayout alloc] init];
    if (([UIScreen mainScreen].bounds.size.height <= 568.0)) {
        layout.itemSize = CGSizeMake(collectionW-50, collectionH-20);
    }else{
        layout.itemSize = CGSizeMake(collectionW-90, collectionH-20);
    }

    self.FirstCollectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
    self.FirstCollectionView.backgroundColor = [UIColor clearColor];
    self.FirstCollectionView.dataSource = self;
    self.FirstCollectionView.delegate = self;

    [self.view addSubview:self.FirstCollectionView];
    self.automaticallyAdjustsScrollViewInsets = NO;
    // 注册
    [self.FirstCollectionView registerNib:[UINib nibWithNibName:NSStringFromClass([CYPhotoCell class]) bundle:nil] forCellWithReuseIdentifier:CYPhotoId];
    
    if (ON_IPAD) {
        layout.itemSize = CGSizeMake(320, 540);
        self.menuRight.constant = 100;
        self.switcher.hidden = NO;
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"IPadDevices" owner:self options:nil];
        
        self.deviceView = array[0];
        Room *room = self.rooms[self.roomIndex];
        self.deviceView.roomID = room.rId;
        [self.deviceView initData];
        self.deviceView.hidden = YES;
        [self.view addSubview:self.deviceView];
    }
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
    self.roomIndex = index;
    Room *room = self.rooms[index];
    if (ON_IPAD && self.showDevices) {
        if ([SQLManager isWholeHouse:room.rId]) {
            self.deviceView.devices = self.deviceView.temp;
        }else{
            NSPredicate *pred = [NSPredicate predicateWithFormat:@"rID==%d", room.rId];
            self.deviceView.devices = [self.deviceView.temp filteredArrayUsingPredicate:pred];
        }
        self.deviceView.roomID = room.rId;
        [self.deviceView.content reloadData];
        NSIndexPath *selected = [self.deviceView.menu indexPathForSelectedRow];
        if(selected) [self.deviceView.menu deselectRowAtIndexPath:selected animated:NO];
        return;
    }
    
    if (view == self.iphoneRoomView) {
        self.devices = [SQLManager getCatalogWithRoomID:room.rId];
        
        if (self.devices.count < 1) {
            [MBProgressHUD showError:@"该房间没有设备"];
            return;
        }
        ((CYLineLayout*)self.FirstCollectionView.collectionViewLayout).itemS = (int)self.devices.count;
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
    
    if ([controllers count] == 1){
        [self.navigationController pushViewController:[controllers firstObject] animated:YES];
    }
}

-(NSString *) storyIDByroom:(int)type
{
    switch (type) {
        case TVtype:
            return @"TV";
        case DVDtype:
            return @"DVD";
        case FM:
            return @"FM";
        case bgmusic:
            return @"bgmusic";
        case amplifier:
            return @"amplifier";
        case screen:
            return @"screen";
        case projector:
            return @"projector";
        case air:
            return @"air";
        case newWind:
            return @"newWind";
        case plugin:
            return @"plugin";
        case flowering:
            return @"flowering";
        case feeding:
            return @"feeding";
        case Wetting:
            return @"Wetting";
        default:
            break;
    }
    return @"";
}

-(NSString *) seguaName:(int) typeID
{
    Room *room = self.rooms[self.roomIndex];
    switch (typeID) {
        case cata_light:
            return @"lighting";
        case cata_curtain:
            return @"curtain";
        case cata_env:
        {
            int type = [SQLManager currentDevicesOfRoom:room.rId subTypeID:cata_env];
            return [self storyIDByroom:type];
        }
        case cata_single_product:
        {
            int type = [SQLManager currentDevicesOfRoom:room.rId subTypeID:cata_single_product];
            return [self storyIDByroom:type];
            //return @"flowering";
        }
        case cata_media:
        {
            int type = [SQLManager currentDevicesOfRoom:room.rId subTypeID:cata_media];
            return [self storyIDByroom:type];
        }
        case cata_security:
            return @"doorclock";
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
            device = [devicesStoryBoard instantiateViewControllerWithIdentifier:@"NewWindController"];
            ((NewWindController *)device).roomID = room.rId;
            [[DeviceInfo defaultManager] setRoomID:room.rId];
            return @[menu,device];
        case cata_single_product:
            device = [devicesStoryBoard instantiateViewControllerWithIdentifier:@"FloweringController"];
            ((FloweringController*)device).roomID = room.rId;
            return @[menu,device];
        case cata_media:
            device = [devicesStoryBoard instantiateViewControllerWithIdentifier:@"TVController"];
            ((TVController*)device).roomID = room.rId;
            return @[menu,device];
        case cata_security:
            device = [devicesStoryBoard instantiateViewControllerWithIdentifier:@"GuardController"];
            ((GuardController*)device).roomID = room.rId;
            return @[menu,device];
        default:
            break;
    }
    
    return controllers;
}

-(void)goDeviceByRoomID:(NSString *)typeID
{
    int type = [typeID intValue];
    if (ON_IPONE) {
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
    cell.icon.hidden = NO;
    cell.icon.image = [UIImage imageNamed:[NSString stringWithFormat:@"cata_%ld",(long)device.subTypeId]];
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    Device *device = self.devices[indexPath.row];
    [self goDeviceByRoomID:[NSString stringWithFormat:@"%ld",(long)device.subTypeId]];
}

- (void)dealloc {
    [self removeNotifications];
}
#pragma mark - TCP recv delegate
-(void)recv:(NSData *)data withTag:(long)tag
{
    Proto proto=protocolFromData(data);
    
    if (CFSwapInt16BigToHost(proto.masterID) != [[DeviceInfo defaultManager] masterID]) {
        return;
    }
    for (int i = 0; i <self.bgmusicIDS.count; i ++) {
        if (proto.cmd==0x01) {
            NSString *devID=[SQLManager getDeviceIDByENumber:CFSwapInt16BigToHost(proto.deviceID)];
            if ([devID intValue]==[self.bgmusicIDS[i] intValue]) {
                if (proto.action.state == PROTOCOL_VOLUME) {
                    NSLog(@"有音量");
                }if (proto.action.state == PROTOCOL_ON) {
                    NSLog(@"开启状态");
                    [IOManager writeUserdefault:@"1" forKey:@"IsPlaying"];
                    
                    [_bgmusicIDArr addObject:devID];
                    
                }if (proto.action.state == PROTOCOL_OFF) {
                    NSLog(@"关闭状态");
                    [IOManager writeUserdefault:@"0" forKey:@"IsPlaying"];
                }
            }
        }
    }
      [self setupNaviBar];
}
#pragma mark - SingleMaskViewDelegate
- (void)onNextButtonClicked:(UIButton *)btn pageType:(PageTye)pageType {
    Device *device = self.devices[1];
    [self goDeviceByRoomID:[NSString stringWithFormat:@"%ld",(long)device.subTypeId]];
}

- (void)onSkipButtonClicked:(UIButton *)btn pageType:(PageTye)pageType {
    
    [UD setObject:@"haveShownMask" forKey:ShowMaskViewDeviceAir];
    [UD synchronize];
    
    [NC postNotificationName:@"TabbarPanelClickedNotificationHome" object:nil];
    
}

- (void)onTransparentBtnClicked:(UIButton *)btn {
    Device *device = self.devices[1];
    [self goDeviceByRoomID:[NSString stringWithFormat:@"%ld",(long)device.subTypeId]];
}

@end
