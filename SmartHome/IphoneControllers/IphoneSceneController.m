//
//  IphoneSceneController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/9/19.
//  Copyright © 2016年 Brustar. All rights reserved.
//


#define cellWidth self.collectionView.frame.size.width/2  - 20
#define cellH self.collectionView.frame.size.height
#define  minSpace 20

#import "IphoneSceneController.h"
#import "Room.h"
#import "SceneCell.h"
#import "SQLManager.h"
#import "Scene.h"
#import "UIImageView+WebCache.h"
#import "SceneManager.h"
#import "HttpManager.h"
#import "MBProgressHUD+NJ.h"
#import "SocketManager.h"
#import "TouchSubViewController.h"
#import <AFNetworking.h>
#import "YZNavigationMenuView.h"
#import "VoiceOrderController.h"
#import "SearchViewController.h"
#import "BgMusicController.h"
#import "HostIDSController.h"
#import "AppDelegate.h"
#import "CYLineLayout.h"
#import "CYPhotoCell.h"
#import "TVIconController.h"
#import "IphoneNewAddSceneVC.h"
#import "DeviceInfo.h"
#import "PhotoGraphViewConteoller.h"


#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)  

@interface IphoneSceneController ()<UIScrollViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,IphoneRoomViewDelegate,CYPhotoCellDelegate,UIViewControllerPreviewingDelegate,UIGestureRecognizerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,PhotoGraphViewConteollerDelegate>


//@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic,assign) int roomID;
@property (nonatomic,strong) NSArray *roomList;
@property (nonatomic,strong) UIButton *selectedRoomBtn;

@property (nonatomic,strong)NSMutableArray *scenes;
@property (nonatomic, assign) int roomIndex;
@property (nonatomic,assign) int selectedSId;
@property (nonatomic,assign) int selectedRoomID;
@property (weak, nonatomic) IBOutlet UIButton *AddSceneBtn;
@property (nonatomic,strong) NSArray * arrayData;
@property (nonatomic,assign) int sceneID;
//@property (nonatomic,strong) YZNavigationMenuView *menuView;
@property (strong, nonatomic) IBOutlet UIButton *titleButton;
@property (nonatomic,strong) HostIDSController *hostVC;
@property (nonatomic,strong) UICollectionView * FirstCollectionView;
@property (nonatomic,strong) UILongPressGestureRecognizer *lgPress;
@property (nonatomic,strong) UIImage *selectSceneImg;
@property (nonatomic,strong) CYPhotoCell *currentCell;
@property (nonatomic,assign) int status;

@end

@implementation IphoneSceneController

static NSString * const CYPhotoId = @"photo";


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
    UIStoryboard * HomeStoryBoard = [UIStoryboard storyboardWithName:@"Home" bundle:nil];
    if (_nowMusicController == nil) {
        _nowMusicController = [HomeStoryBoard instantiateViewControllerWithIdentifier:@"NowMusicController"];
        _nowMusicController.delegate = self;
        [self.view addSubview:_nowMusicController.view];
        [self.view bringSubviewToFront:_nowMusicController.view];
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
- (void)viewDidLoad {
      [super viewDidLoad];
      [self addNotifications];
      self.automaticallyAdjustsScrollViewInsets = NO;
      [self setupNaviBar];
      [self showNetStateView];
      self.roomList = [SQLManager getAllRoomsInfo];
      [self setUpRoomView];
      [self reachNotification];
      [self setUI];
    self.arrayData = @[@"删除此场景",@"收藏",@"语音"];
    _AddSceneBtn.layer.cornerRadius = _AddSceneBtn.bounds.size.width / 2.0; //圆角半径
    _AddSceneBtn.layer.masksToBounds = YES; //圆角
    self.navigationItem.rightBarButtonItems = nil;
    UIImage *image=[UIImage imageNamed:@"4@2x"];
    //    不让tabbar底部有渲染的关键代码
    image=[image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonItemClicked:)];
    self.navigationItem.rightBarButtonItem = rightItem;
    self.navigationController.view.backgroundColor = [UIColor blueColor];
    
    //开启网络状况监听器
    [self updateInterfaceWithReachability];

}

//处理连接改变后的情况
- (void)updateInterfaceWithReachability
{
    __block IphoneSceneController * FirstBlockSelf = self;
    
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

-(void)setUI
{
    // 创建CollectionView
    CGFloat collectionW = self.view.frame.size.width;
    CGFloat collectionH = self.view.frame.size.height-200;
    CGRect frame = CGRectMake(0, 130, collectionW, collectionH);
    // 创建布局
    CYLineLayout *layout = [[CYLineLayout alloc] init];
    DeviceInfo *device=[DeviceInfo defaultManager];
    [device deviceGenaration];
    if (([UIScreen mainScreen].bounds.size.height == 568.0)) {
        layout.itemSize = CGSizeMake(collectionW-50, collectionH-20);
    }else{
        layout.itemSize = CGSizeMake(collectionW-90, collectionH-20);
    }
    self.FirstCollectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
    self.FirstCollectionView.backgroundColor = [UIColor clearColor];
    self.FirstCollectionView.dataSource = self;
    self.FirstCollectionView.delegate = self;
    [self.view addSubview:self.FirstCollectionView];
    //    self.navigationController.navigationBar.hidden = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;//
    // 注册
    [self.FirstCollectionView registerNib:[UINib nibWithNibName:NSStringFromClass([CYPhotoCell class]) bundle:nil] forCellWithReuseIdentifier:CYPhotoId];
    
}

- (void)menuBtnAction:(UIButton *)sender {
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

-(void)setNavi
{
    self.titleButton = [[UIButton alloc]init];
    self.titleButton.frame = CGRectMake(0, 0, 180, 40);
    NSArray *roomList = [SQLManager getAllRoomsInfo];
    Room *room = roomList[0];
    [self.titleButton setTitle:room.rName forState:UIControlStateNormal];
    [self.titleButton setImage:[UIImage imageNamed:@"down"] forState:UIControlStateNormal];
    [self.titleButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.titleButton.imageEdgeInsets = UIEdgeInsetsMake(0, 160, 0, 0);
    
    [self.titleButton addTarget:self action:@selector(clickTitleButton:) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.titleView = self.titleButton;
}

-(void)clickTitleButton:(UIButton *)button
{
    [self performSegueWithIdentifier:@"roomListSegue" sender:self];
}

- (void)reachNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subTypeNotification:) name:@"subType" object:nil];
}
- (void)subTypeNotification:(NSNotification *)notification
{
    NSDictionary *dict = notification.userInfo;
    
    self.roomID = [dict[@"subType"] intValue];
//    self.scenes = [SQLManager getScensByRoomId:self.roomID];
    NSArray *tmpArr = [SQLManager getScensByRoomId:self.roomID];
    [self.scenes removeAllObjects];
    [self.scenes addObjectsFromArray:tmpArr];
    NSString *imageName = @"i-add";
    [self.scenes addObject:imageName];
//    [self setUpSceneButton];
//    [self judgeScensCount:self.scenes];
    
}

-(void)setUpRoomView
{
    NSMutableArray *roomNames = [NSMutableArray array];
    
    for (Room *room in self.roomList) {
        NSString *roomName = room.rName;
        [roomNames addObject:roomName];
    }
    self.roomView.dataArray = roomNames;
    
    self.roomView.delegate = self;
    
    [self.roomView setSelectButton:0];
    if ([self.roomList count]>0) {
        [self iphoneRoomView:self.roomView didSelectButton:0];
    }
}

- (void)iphoneRoomView:(UIView *)view didSelectButton:(int)index
{
    self.roomIndex = index;
    Room *room = self.roomList[index];
//    self.scenes = [SQLManager getScensByRoomId:room.rId];
    NSArray *tmpArr = [SQLManager getScensByRoomId:room.rId];
    self.selectedRoomID = room.rId;
    [self.scenes removeAllObjects];
    [self.scenes addObjectsFromArray:tmpArr];
    NSString *imageName = @"i-add";
    [self.scenes addObject:imageName];

    [self.FirstCollectionView reloadData];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([self.roomList count]>0) {
        Room *room = self.roomList[self.roomIndex];
        
        NSArray *tmpArr = [SQLManager getScensByRoomId:room.rId];
        [self.scenes removeAllObjects];
        [self.scenes addObjectsFromArray:tmpArr];
        NSString *imageName = @"i-add";
        [self.scenes addObject:imageName];
    }
    [self setUpRoomView];
    [self.FirstCollectionView reloadData];

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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    BaseTabBarController *baseTabbarController =  (BaseTabBarController *)self.tabBarController;
    baseTabbarController.tabbarPanel.hidden = NO;
    baseTabbarController.tabBar.hidden = YES;
}


#pragma mark - UIViewControllerPreviewingDelegate

- (nullable UIViewController *)previewingContext:(id <UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location
{
     UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iPhone" bundle:nil];
    TouchSubViewController * touchSubViewVC = [storyboard instantiateViewControllerWithIdentifier:@"TouchSubViewController"];
      touchSubViewVC.preferredContentSize = CGSizeMake(0.0f,500.0f);
//      touchSubViewVC.sceneID = self.scene.sceneID;
      touchSubViewVC.sceneID = self.selectedSId;
      touchSubViewVC.roomID = self.roomID;
    
    return touchSubViewVC;
}

- (void)previewingContext:(id <UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit
{
    [self.navigationController pushViewController:viewControllerToCommit animated:NO];
}

#pragma  mark - UICollectionViewDelegate
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.scenes.count;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row+1 >= self.scenes.count) {
        CYPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CYPhotoId forIndexPath:indexPath];
        cell.delegate = self;
        cell.imageView.image = [UIImage imageNamed:@"AddScene-ImageView"];
        cell.subImageView.image = [UIImage imageNamed:@"AddSceneBtn"];
        cell.sceneID = 0;
        cell.SceneName.text = @"点击添加场景";
        cell.SceneNameTopConstraint.constant = 40;
        cell.deleteBtn.hidden = YES;
        cell.powerBtn.hidden = YES;
        cell.seleteSendPowBtn.hidden = YES;
    
        return cell;
    }else{
        CYPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CYPhotoId forIndexPath:indexPath];
         cell.delegate = self;

        Scene *scene = self.scenes[indexPath.row];
       
        cell.sceneID = scene.sceneID;

        if (self.scenes.count == 0) {
            [MBProgressHUD showSuccess:@"暂时没有全屋场景"];
        }
        NSString *sceneFile = [NSString stringWithFormat:@"%@_%d.plist",SCENE_FILE_NAME,scene.sceneID];
        NSString *scenePath=[[IOManager scenesPath] stringByAppendingPathComponent:sceneFile];
        NSDictionary *plistDic = [NSDictionary dictionaryWithContentsOfFile:scenePath];
        NSArray * schedules = plistDic[@"schedules"];
        scene.schedules = schedules;
        if (scene.schedules.count == 0) {
            cell.seleteSendPowBtn.hidden = YES;
            cell.PowerBtnCenterContraint.constant = 35;
        }else{
            cell.seleteSendPowBtn.hidden = NO;
            cell.PowerBtnCenterContraint.constant = 0;
        }
        self.selectedSId = cell.sceneID;
      
        cell.subImageView.image = [UIImage imageNamed:@"Scene-bedroomTSQ"];
        cell.tag = scene.sceneID;
        cell.SceneName.text = scene.sceneName;
        self.lgPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleLongPress:)];
        self.lgPress.delegate = self;
        [collectionView addGestureRecognizer:self.lgPress];
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString: scene.picName] placeholderImage:[UIImage imageNamed:@"PL"]];
        [self registerForPreviewingWithDelegate:self sourceView:cell.contentView];
        cell.deleteBtn.hidden = NO;
        cell.powerBtn.hidden = NO;

        [cell.powerBtn addTarget:self action:@selector(powerBtn:) forControlEvents:UIControlEventTouchUpInside];

        return cell;
       
    }
    
}
-(void)powerBtn:(UIButton *)btn
{
    Scene *scene = self.scenes[btn.tag];
    if (scene) {
        if (scene.status == 0) { //点击前，场景是关闭状态，需打开场景
            [[SceneManager defaultManager] startScene:scene.sceneID];//打开场景
            [SQLManager updateSceneStatus:1 sceneID:scene.sceneID];//更新数据库
        }else if (scene.status == 1) { //点击前，场景是打开状态，需关闭场景
            [[SceneManager defaultManager] poweroffAllDevice:scene.sceneID];//关闭场景
            [SQLManager updateSceneStatus:0 sceneID:scene.sceneID];//更新数据库
        }
        
        [self.FirstCollectionView reloadData];
    }
}

-(void)handleLongPress:(UILongPressGestureRecognizer *)lgr
{
    NSIndexPath *indexPath = [self.FirstCollectionView indexPathForItemAtPoint:[lgr locationInView:self.FirstCollectionView]];
    self.currentCell = (CYPhotoCell *)[self.FirstCollectionView cellForItemAtIndexPath:indexPath];
    
    UIAlertController * alerController = [UIAlertController alertControllerWithTitle:@"温馨提示更换场景图片" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alerController addAction:[UIAlertAction actionWithTitle:@"现在就拍" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = YES;
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:picker animated:YES completion:NULL];

        
    }]];
    [alerController addAction:[UIAlertAction actionWithTitle:@"从相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
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
        
    }]];
    [alerController addAction:[UIAlertAction actionWithTitle:@"从预设图库选" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIStoryboard *MainStoryBoard  = [UIStoryboard storyboardWithName:@"Scene" bundle:nil];
        PhotoGraphViewConteoller *PhotoIconVC = [MainStoryBoard instantiateViewControllerWithIdentifier:@"PhotoGraphViewConteoller"];
        PhotoIconVC.delegate = self;
        [self.navigationController pushViewController:PhotoIconVC animated:YES];
    }]];
    [alerController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    
    [self presentViewController:alerController animated:YES completion:^{
        
    }];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [DeviceInfo defaultManager].isPhotoLibrary = NO;
    self.selectSceneImg = info[UIImagePickerControllerOriginalImage];
    
    Scene *scene = [[Scene alloc] initWhithoutSchedule];
    scene.sceneID = self.currentCell.sceneID;
    scene.roomID = self.roomID;
    [[SceneManager defaultManager] editScene:scene newSceneImage:self.selectSceneImg];
    
    [self.currentCell.imageView setImage:self.selectSceneImg];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)PhotoIconController:(PhotoGraphViewConteoller *)iconVC withImgName:(NSString *)imgName
{
    self.selectSceneImg = [UIImage imageNamed:imgName];
    [DeviceInfo defaultManager].isPhotoLibrary = NO;
    
    [self.currentCell.imageView setImage:self.selectSceneImg];
    //场景ID不变
    self.sceneID = self.selectedSId;
    NSString *sceneFile = [NSString stringWithFormat:@"%@_%d.plist",SCENE_FILE_NAME,self.sceneID];
    NSString *scenePath=[[IOManager scenesPath] stringByAppendingPathComponent:sceneFile];
    NSDictionary *plistDic = [NSDictionary dictionaryWithContentsOfFile:scenePath];
    
    Scene *scene = [[Scene alloc] init];
    if (plistDic) {
        [scene setValuesForKeysWithDictionary:plistDic];
    
        [[SceneManager defaultManager] editScene:scene newSceneImage:self.selectSceneImg];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [DeviceInfo defaultManager].isPhotoLibrary = NO;
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
     if (indexPath.row+1 >= self.scenes.count) {
         UIStoryboard * SceneStoryBoard = [UIStoryboard storyboardWithName:@"Scene" bundle:nil];
         IphoneNewAddSceneVC * iphoneNewAddSceneVC = [SceneStoryBoard instantiateViewControllerWithIdentifier:@"IphoneNewAddSceneVC"];
         iphoneNewAddSceneVC.roomID = self.selectedRoomID;
         [self.navigationController pushViewController:iphoneNewAddSceneVC animated:YES];
         
//         [self performSegueWithIdentifier:@"iphoneAddSceneSegue" sender:self];IphoneNewAddSceneVC
     }else{
         Scene *scene = self.scenes[indexPath.row];
         self.selectedSId = scene.sceneID;
         CYPhotoCell *cell = (CYPhotoCell*)[collectionView cellForItemAtIndexPath:indexPath];
         if (scene.status == 0) {
             [cell.powerBtn setBackgroundImage:[UIImage imageNamed:@"close_red"] forState:UIControlStateSelected];
             [[SceneManager defaultManager] startScene:scene.sceneID];
             [SQLManager updateSceneStatus:1 sceneID:scene.sceneID];
         }
             [self performSegueWithIdentifier:@"iphoneEditSegue" sender:self];
     }
  
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}

//添加场景
- (IBAction)AddSceneBtn:(id)sender {
    
    [self performSegueWithIdentifier:@"iphoneAddSceneSegue" sender:self];
}

- (void)rightBarButtonItemClicked:(UIBarButtonItem *)sender {
    
      [self performSegueWithIdentifier:@"iphoneAddSceneSegue" sender:self];
}

-(void)powerBtnAction:(UIButton *)sender sceneStatus:(int)status
{

}
//删除场景
-(void)sceneDeleteAction:(CYPhotoCell *)cell
{
    self.currentCell = cell;
    self.sceneID = (int)cell.tag;
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"是否删除“%@”场景？",self.currentCell.SceneName.text] preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        NSString *url = [NSString stringWithFormat:@"%@Cloud/scene_delete.aspx",[IOManager httpAddr]];
        NSDictionary *dict = @{@"token":[UD objectForKey:@"AuthorToken"], @"scenceid":@(self.sceneID),@"optype":@(1)};
        HttpManager *http=[HttpManager defaultManager];
        http.delegate=self;
        http.tag = 1;
        [http sendPost:url param:dict];
        
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        NSLog(@"点击了取消按钮");
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
  
}

-(void)httpHandler:(id) responseObject tag:(int)tag
{
    if((tag = 1))
    {
        if([responseObject[@"result"] intValue] == 0)
        {
            [MBProgressHUD showSuccess:@"场景删除成功"];
            Room *room = self.roomList[self.roomIndex];
//            self.scenes = [SQLManager getScensByRoomId:room.rId];
            NSArray *tmpArr = [SQLManager getScensByRoomId:room.rId];
            [self.scenes removeAllObjects];
            [self.scenes addObjectsFromArray:tmpArr];
            NSString *imageName = @"i-add";
            [self.scenes addObject:imageName];
            [self.FirstCollectionView reloadData];
            
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
                        [self setUpRoomView];
                        [self.FirstCollectionView reloadData];
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
        }
    }
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    Room *room = self.roomList[self.roomIndex];
    if([segue.identifier isEqualToString:@"IphoneNewAddSceneVC"])
    {
        [IOManager removeTempFile];

        id theSegue = segue.destinationViewController;
        [theSegue setValue:[NSNumber numberWithInt:room.rId] forKey:@"roomId"];
    }else if([segue.identifier isEqualToString:@"iphoneEditSegue"]){
        id theSegue = segue.destinationViewController;
        
        [theSegue setValue:[NSNumber numberWithInt:self.selectedSId] forKey:@"sceneID"];
        [theSegue setValue:[NSNumber numberWithInt:room.rId] forKey:@"roomID"];
    }
}

#pragma mark -- lazy load
-(NSMutableArray *)scenes{
    if (!_scenes) {
        _scenes = [NSMutableArray new];
        NSString *imageName = @"AddSceneBtn";
        [_scenes addObject:imageName];
    }
    return _scenes;
}

- (void)dealloc {
    [self removeNotifications];
}

@end
