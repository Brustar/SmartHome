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
@interface IphoneDeviceListController ()<IphoneRoomViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic,assign) int selectedSId;

@property (nonatomic,strong) NSArray *deviceTypes;
@property (nonatomic,strong) NSArray *typeIDs;

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
    
    if (_nowMusicController) {
        [_nowMusicController.view removeFromSuperview];
        _nowMusicController = nil;
    }
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
        self.typeIDs = [SQLManager deviceTypeIDByRoom:room.rId];
        if (self.deviceTypes.count < 1) {
            [MBProgressHUD showError:@"该房间没有设备"];
            return;
        }
        [self.FirstCollectionView reloadData];
    }
}

-(NSString *) seguaName:(int) typeID
{
    switch (typeID) {
        case light:
            
            return @"lighting";
        case curtain:
            
            return @"curtain";
        case DVDtype:
            
            return @"DVD";
        case bgmusic:
            
            return @"bgmusic";
        case FM:
            
            return @"FM";
        case air:
            
            return @"air";
        case doorclock:
            
            return @"doorclock";
        case projector:
            
            return @"projector";
        case screen:
            
            return @"screen";
        case amplifier:
            
            return @"amplifier";
        case TVtype:
            
            return @"TV";
        case camera:
            
            return @"camera";
        case plugin:
            
            return @"plugin";
        default:
            break;
    }
    return NULL;
}

-(void)goDeviceByRoomID:(NSString *)typeID
{
    int type = [typeID intValue];
    NSString *segua = [self seguaName:type];
    if (segua) {
        [self performSegueWithIdentifier:segua sender:self];
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
    self.typeIDs = [SQLManager deviceTypeIDByRoom:btn.tag];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    id theSegue = segue.destinationViewController;
    Room *room = self.rooms[self.roomIndex];
    [theSegue setValue:[NSString stringWithFormat:@"%d", room.rId] forKey:@"roomID"];
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
    //[self registerForPreviewingWithDelegate:self sourceView:cell.contentView];
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self goDeviceByRoomID:[self.typeIDs objectAtIndex:indexPath.row]];
}

@end
