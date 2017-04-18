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
#import "IphoneLightController.h"
#import "AppDelegate.h"
#import "CYLineLayout.h"
#import "CYPhotoCell.h"

static NSString * const CYPhotoId = @"photo";
@interface IphoneDeviceListController ()<IphoneRoomViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UIViewControllerPreviewingDelegate>

@property (nonatomic,assign) int selectedSId;

@property (nonatomic,strong) NSArray *deviceTypes;

@property (nonatomic ,strong) CYPhotoCell *cell;
@property (nonatomic,strong) UIButton *typeSelectedBtn;
@property (nonatomic,strong) UIButton *selectedRoomBtn;
@property (nonatomic,strong) NSArray *rooms;

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
    baseTabbarController.tabbarPanel.hidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self setupNaviBar];
    self.rooms = [SQLManager getAllRoomsInfo];
    
    [self setUpRoomScrollerView];
    [self getUI];
}

- (void)setupNaviBar {
    [self setNaviBarTitle:[UD objectForKey:@"homename"]]; //设置标题
    _naviLeftBtn = [CustomNaviBarView createImgNaviBarBtnByImgNormal:@"clound_white" imgHighlight:@"clound_white" target:self action:@selector(leftBtnClicked:)];
    _naviRightBtn = [CustomNaviBarView createImgNaviBarBtnByImgNormal:@"music_white" imgHighlight:@"music_white" target:self action:@selector(rightBtnClicked:)];
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
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    BgMusicController *bgMusicVC = [storyBoard instantiateViewControllerWithIdentifier:@"BgMusicController"];
    Room *room = self.rooms[self.roomIndex];
    bgMusicVC.roomID = room.rId;
    [self.navigationController pushViewController:bgMusicVC animated:YES];
}

-(void)getUI
{
    // 创建CollectionView
    CGFloat collectionW = self.view.frame.size.width;
    CGFloat collectionH = self.view.frame.size.height-350;
    CGRect frame = CGRectMake(0, 130, collectionW, collectionH);
    // 创建布局
    CYLineLayout *layout = [[CYLineLayout alloc] init];
    if (([UIScreen mainScreen].bounds.size.height == 568.0)) {
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
        self.deviceTypes = [SQLManager deviceSubTypeByRoomId:room.rId];
        if (self.deviceTypes.count < 1) {
            [MBProgressHUD showError:@"该房间没有设备"];
            return;
        }
        [self.FirstCollectionView reloadData];
    }
}

-(void)goDeviceByRoomID:(int)roomID typeName:(NSString *)typeName
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIStoryboard *iphoneBoard  = [UIStoryboard storyboardWithName:@"iPhone" bundle:nil];
    if([typeName isEqualToString:@"网络电视"])
    {
        IphoneTVController *tVC = [iphoneBoard instantiateViewControllerWithIdentifier:@"IphoneTVController"];
        tVC.roomID = roomID;
        [self.navigationController pushViewController:tVC animated:YES];
    }else if([typeName isEqualToString:@"灯光"])
    {
        IphoneLightController * ligthVC = [iphoneBoard instantiateViewControllerWithIdentifier:@"LightController"];
        ligthVC.roomID = roomID;
        [self.navigationController pushViewController:ligthVC animated:YES];
    }else if([typeName isEqualToString:@"窗帘"])
    {
        CurtainController *curtainVC = [storyBoard instantiateViewControllerWithIdentifier:@"CurtainController"];
        curtainVC.roomID = roomID;
        
        [self.navigationController pushViewController:curtainVC animated:YES];
        
    }else if([typeName isEqualToString:@"DVD"])
    {
        
        IphoneDVDController *dvdVC = [iphoneBoard instantiateViewControllerWithIdentifier:@"IphoneDVDController"];
        dvdVC.roomID = roomID;
        
        [self.navigationController pushViewController:dvdVC animated:YES];
    }else if([typeName isEqualToString:@"FM"])
    {
        FMController *fmVC = [iphoneBoard instantiateViewControllerWithIdentifier:@"IphoneFMController"];
        fmVC.roomID = roomID;
        
        [self.navigationController pushViewController:fmVC animated:YES];
    }else if([typeName isEqualToString:@"空调"])
    {
        IphoneAirController *airVC = [iphoneBoard instantiateViewControllerWithIdentifier:@"IphoneAirController"];
        airVC.roomID = roomID;
        
        [self.navigationController pushViewController:airVC animated:YES];
    }else if([typeName isEqualToString:@"机顶盒"]){
        IphoneNetTvController *netVC = [iphoneBoard instantiateViewControllerWithIdentifier:@"IphoneNetTvController"];
        netVC.roomID = roomID;
        
        [self.navigationController pushViewController:netVC animated:YES];
    }else if([typeName isEqualToString:@"摄像头"]){
        DeviceInfo *device = [DeviceInfo defaultManager];
        if (![device.db isEqualToString:SMART_DB]) { //体验版：老人房摄像头页面只显示一张房间图片
            [self.navigationController pushViewController:[self addOldmanRoomCameraImage] animated:YES];
            return;
        }
        
        CameraController *camerVC = [storyBoard instantiateViewControllerWithIdentifier:@"CameraController"];
        camerVC.roomID = roomID;

        [self.navigationController pushViewController:camerVC animated:YES];
    }else if([typeName isEqualToString:@"智能门锁"]){
        GuardController *guardVC = [storyBoard instantiateViewControllerWithIdentifier:@"GuardController"];
        guardVC.roomID = roomID;
        
        [self.navigationController pushViewController:guardVC animated:YES];
    }else if([typeName isEqualToString:@"幕布"]){
        ScreenCurtainController *screenCurtainVC = [storyBoard instantiateViewControllerWithIdentifier:@"ScreenCurtainController"];
        screenCurtainVC.roomID = roomID;
        [self.navigationController pushViewController:screenCurtainVC animated:YES];
        
    }else if([typeName isEqualToString:@"投影"])
    {
        ProjectController *projectVC = [storyBoard instantiateViewControllerWithIdentifier:@"ProjectController"];
        projectVC.roomID = roomID;
        [self.navigationController pushViewController:projectVC animated:YES];
    }else if([typeName isEqualToString:@"功放"]){
        AmplifierController *amplifierVC = [storyBoard instantiateViewControllerWithIdentifier:@"AmplifierController"];
        amplifierVC.roomID = roomID;
        
        [self.navigationController pushViewController:amplifierVC animated:YES];
    }
    else if([typeName isEqualToString:@"智能推窗器"]){
        WindowSlidingController *windowSlidVC = [storyBoard instantiateViewControllerWithIdentifier:@"WindowSlidingController"];
        windowSlidVC.roomID = roomID;
        
        [self.navigationController pushViewController:windowSlidVC animated:YES];
    }
    else if([typeName isEqualToString:@"背景音乐"]){
        BgMusicController *bgMusicVC = [storyBoard instantiateViewControllerWithIdentifier:@"BgMusicController"];
        bgMusicVC.roomID = roomID;
        
        [self.navigationController pushViewController:bgMusicVC animated:YES];
    }else {
        PluginViewController *pluginVC = [storyBoard instantiateViewControllerWithIdentifier:@"PluginViewController"];
        pluginVC.roomID = roomID;
        
        [self.navigationController pushViewController:pluginVC animated:YES];
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
    self.deviceTypes = [SQLManager deviceSubTypeByRoomId:btn.tag];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma  mark - UICollectionViewDelegate
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.deviceTypes.count;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CYPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CYPhotoId forIndexPath:indexPath];
    cell.sceneLabel.text = self.deviceTypes[indexPath.row];
    self.DeviceNameLabel.text = self.deviceTypes[indexPath.row];
    NSString *imgName = [NSString stringWithFormat:@"catalog_%ld",(long)indexPath.row];
    UIImage *img = [UIImage imageNamed:imgName];
    [cell.imageView sd_setImageWithURL:nil placeholderImage:img];
    [self registerForPreviewingWithDelegate:self sourceView:cell.contentView];
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    Room *room = self.rooms[self.roomIndex];
    [self goDeviceByRoomID:room.rId typeName:[self.deviceTypes objectAtIndex:indexPath.row]];
}

@end
