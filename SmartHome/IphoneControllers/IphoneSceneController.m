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
#import "IphoneRoomView.h"
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
//#import "IphoneRoomListController.h"

@interface IphoneSceneController ()<UIScrollViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,IphoneRoomViewDelegate,CYPhotoCellDelegate,UIViewControllerPreviewingDelegate,YZNavigationMenuViewDelegate>
@property (strong, nonatomic) IBOutlet IphoneRoomView *roomView;
//@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic,assign) int roomID;
@property (nonatomic,strong) NSArray *roomList;
@property (nonatomic,strong) UIButton *selectedRoomBtn;
@property (nonatomic,strong) NSArray *scenes;
@property (nonatomic, assign) int roomIndex;
@property (nonatomic,assign) int selectedSId;
@property (nonatomic ,strong) CYPhotoCell *cell;
@property (weak, nonatomic) IBOutlet UIButton *AddSceneBtn;
@property (nonatomic,strong) NSArray * arrayData;
@property (nonatomic,assign) int sceneID;
@property (nonatomic,strong) YZNavigationMenuView *menuView;
@property (strong, nonatomic) IBOutlet UIButton *titleButton;
@property(nonatomic,strong)HostIDSController *hostVC;
@property (weak, nonatomic) IBOutlet UIImageView *delegateImageView;
@property (weak, nonatomic) IBOutlet UIImageView *startImageView;
@property (weak, nonatomic) IBOutlet UIImageView *blockImageView;
@property (weak, nonatomic) IBOutlet UILabel *SceneNameLabel;
@property (nonatomic,strong)UICollectionView * FirstCollectionView;
@end

@implementation IphoneSceneController
static NSString * const CYPhotoId = @"photo";
- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self setupSlideButton];
    self.roomList = [SQLManager getAllRoomsInfo];
      [self setUpRoomView];
      [self reachNotification];
     [self setupSlideButton];
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
//    [self setNavi];
    
    
}
- (void)setupSlideButton {
    UIButton *menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    menuBtn.frame = CGRectMake(0, 0, 44, 44);
    [menuBtn setImage:[UIImage imageNamed:@"logo"] forState:UIControlStateNormal];
    [menuBtn addTarget:self action:@selector(menuBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menuBtn];
}
-(void)setUI
{
    // 创建CollectionView
    CGFloat collectionW = self.view.frame.size.width;
    CGFloat collectionH = self.view.frame.size.height-350;
    CGRect frame = CGRectMake(0, 115, collectionW, collectionH);
    // 创建布局
    CYLineLayout *layout = [[CYLineLayout alloc] init];
    layout.itemSize = CGSizeMake(collectionW-110, collectionH-20);
    self.FirstCollectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
    self.FirstCollectionView.backgroundColor = [UIColor clearColor];
    self.delegateImageView.layer.cornerRadius = 25.0f; //圆角半径
    self.delegateImageView.layer.masksToBounds = YES; //圆角
    self.blockImageView.layer.cornerRadius = 25.0f; //圆角半径
    self.blockImageView.layer.masksToBounds = YES; //圆角
    self.startImageView.layer.cornerRadius = 25.0f; //圆角半径
    self.startImageView.layer.masksToBounds = YES; //圆角
    
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
    
    self.scenes = [SQLManager getScensByRoomId:self.roomID];
    
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
    
    [self iphoneRoomView:self.roomView didSelectButton:0];
}

- (void)iphoneRoomView:(UIView *)view didSelectButton:(int)index
{
    self.roomIndex = index;
    Room *room = self.roomList[index];
    self.scenes = [SQLManager getScensByRoomId:room.rId];
    [self.FirstCollectionView reloadData];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    Room *room = self.roomList[self.roomIndex];
    self.scenes = [SQLManager getScensByRoomId:room.rId];
    [self.FirstCollectionView reloadData];
    
    BaseTabBarController *baseTabbarController =  (BaseTabBarController *)self.tabBarController;
    baseTabbarController.tabbarPanel.hidden = NO;
    baseTabbarController.tabBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    BaseTabBarController *baseTabbarController =  (BaseTabBarController *)self.tabBarController;
    baseTabbarController.tabbarPanel.hidden = YES;
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
    CYPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CYPhotoId forIndexPath:indexPath];
    self.scene = self.scenes[indexPath.row];
    cell.sceneID = self.scene.sceneID;
    cell.tag = self.scene.sceneID;
    cell.sceneLabel.text = self.scene.sceneName;
    self.SceneNameLabel.tag = self.scene.sceneID;
    self.SceneNameLabel.text = cell.sceneLabel.text;
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString: self.scene.picName] placeholderImage:[UIImage imageNamed:@"PL"]];
    [self registerForPreviewingWithDelegate:self sourceView:cell.contentView];
   
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    Scene *scene = self.scenes[indexPath.row];
    self.selectedSId = scene.sceneID;
    
    CYPhotoCell *cell = (CYPhotoCell*)[collectionView cellForItemAtIndexPath:indexPath];
    
    [cell useLongPressGesture];
    if(cell.deleteBtn.hidden)
    {
         cell.deleteBtn.hidden = YES;
        
    }else{
        
        [self performSegueWithIdentifier:@"iphoneEditSegue" sender:self];
        [[SceneManager defaultManager] startScene:scene.sceneID];
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
- (void)navigationMenuView:(YZNavigationMenuView *)menuView clickedAtIndex:(NSInteger)index;
{
    
    UIStoryboard * storyBoard = [UIStoryboard storyboardWithName:@"iPhone" bundle:nil];
    UIStoryboard * MainBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
   
    if (index == 0) {
        VoiceOrderController * voiceVC = [storyBoard instantiateViewControllerWithIdentifier:@"VoiceOrderController"];
        [self.navigationController pushViewController:voiceVC animated:YES];
        [self.menuView removeFromSuperview];
    }else if (index == 1){
        SearchViewController * searchVC = [storyBoard instantiateViewControllerWithIdentifier:@"SearchViewController"];
        [self.navigationController pushViewController:searchVC animated:YES];
        [self.menuView removeFromSuperview];
    }else if (index == 2){
        BgMusicController * BgVC = [MainBoard instantiateViewControllerWithIdentifier:@"BgMusicController"];
        [self.navigationController pushViewController:BgVC animated:YES];
        [self.menuView removeFromSuperview];
    }else if (index == 3){
        [self performSegueWithIdentifier:@"iphoneAddSceneSegue" sender:self];
        [self.menuView removeFromSuperview];
    }
}
//删除场景
-(void)sceneDeleteAction:(CYPhotoCell *)cell
{
    self.cell = cell;
    cell.deleteBtn.hidden = YES;
    self.sceneID = (int)cell.tag;
//    [SQLManager deleteScene:self.sceneID];
//    Scene *scene = [[SceneManager defaultManager] readSceneByID:(int)cell.tag];
//    [[SceneManager defaultManager] delScene:scene];
    
    NSString *url = [NSString stringWithFormat:@"%@Cloud/scene_delete.aspx",[IOManager httpAddr]];
    NSDictionary *dict = @{@"token":[UD objectForKey:@"AuthorToken"], @"scenceid":@(self.sceneID),@"optype":@(1)};
    HttpManager *http=[HttpManager defaultManager];
    http.delegate=self;
    http.tag = 1;
    [http sendPost:url param:dict];
  
}

-(void)httpHandler:(id) responseObject tag:(int)tag
{
    if((tag = 1))
    {
        if([responseObject[@"result"] intValue] == 0)
        {
            [MBProgressHUD showSuccess:@"场景删除成功"];
            Room *room = self.roomList[self.roomIndex];
            self.scenes = [SQLManager getScensByRoomId:room.rId];
            [self.collectionView reloadData];
            
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
                        [self.collectionView reloadData];
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
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    return CGSizeMake(cellWidth, cellWidth);
//}
//
//- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
//    
//}
//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
//{
//    return minSpace;
//}
//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
//{
//    return minSpace;
//}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    Room *room = self.roomList[self.roomIndex];
    if([segue.identifier isEqualToString:@"iphoneAddSceneSegue"])
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

@end
