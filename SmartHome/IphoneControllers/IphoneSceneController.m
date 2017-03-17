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
//#import "IphoneRoomListController.h"

@interface IphoneSceneController ()<UIScrollViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,IphoneRoomViewDelegate,SceneCellDelegate,UIViewControllerPreviewingDelegate,YZNavigationMenuViewDelegate>
@property (strong, nonatomic) IBOutlet IphoneRoomView *roomView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic,assign) int roomID;
@property (nonatomic,strong) NSArray *roomList;
@property (nonatomic,strong) UIButton *selectedRoomBtn;
@property (nonatomic,strong) NSArray *scenes;
@property (nonatomic, assign) int roomIndex;
@property (nonatomic,assign) int selectedSId;
@property (nonatomic ,strong) SceneCell *cell;
@property (weak, nonatomic) IBOutlet UIButton *AddSceneBtn;
@property (nonatomic,strong) NSArray * arrayData;
@property (nonatomic,assign) int sceneID;
@property (nonatomic,strong) YZNavigationMenuView *menuView;
@property (strong, nonatomic) IBOutlet UIButton *titleButton;
@property(nonatomic,strong)HostIDSController *hostVC;

@end

@implementation IphoneSceneController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self setupSlideButton];
    self.roomList = [SQLManager getAllRoomsInfo];
//    self.title = @"场景";
     [self setUpRoomView];
    self.arrayData = @[@"删除此场景",@"收藏",@"语音"];
    //开启网络状况的监听
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityUpdate:) name: AFNetworkingReachabilityDidChangeNotification object: nil];
//    [self updateInterfaceWithReachability];
    [self reachNotification];
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

////处理连接改变后的情况
//- (void) updateInterfaceWithReachability
//{
//    AFNetworkReachabilityManager *afNetworkReachabilityManager = [AFNetworkReachabilityManager sharedManager];
//    //[afNetworkReachabilityManager startMonitoring];  //开启网络监视器；
//    [afNetworkReachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
//        DeviceInfo *info = [DeviceInfo defaultManager];
//        if(status == AFNetworkReachabilityStatusReachableViaWWAN)
//        {
//            if (info.connectState==outDoor) {
//                //NSLog(@"外出模式");
//    //            [self.netBarBtn setImage:[UIImage imageNamed:@"wifi"]];
//                return;
//            }
//            if (info.connectState==offLine) {
//                NSLog(@"离线模式");
//    //            [self.netBarBtn setImage:[UIImage imageNamed:@"breakWifi"]];
//            }
//        }
//        else if(status == AFNetworkReachabilityStatusReachableViaWiFi)
//        {
//            if (info.connectState==atHome) {
//                NSLog(@"在家模式");
//    //            [self.netBarBtn setImage:[UIImage imageNamed:@"atHome"]];
//                return;
//            }else if (info.connectState==outDoor){
//                //NSLog(@"外出模式");
//    //            [self.netBarBtn setImage:[UIImage imageNamed:@"wifi"]];
//            }
//            if (info.connectState==offLine) {
//                NSLog(@"离线模式");
//    //            [self.netBarBtn setImage:[UIImage imageNamed:@"breakWifi"]];
//
//            }
//        }else{
//            NSLog(@"离线模式");
//    //        [self.netBarBtn setImage:[UIImage imageNamed:@"breakWifi"]];
//        }
//    }];
//}

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
    [self.collectionView reloadData];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    Room *room = self.roomList[self.roomIndex];
    self.scenes = [SQLManager getScensByRoomId:room.rId];
    [self.collectionView reloadData];

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
    SceneCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"collectionCell" forIndexPath:indexPath];
    
    cell.layer.cornerRadius = 20;
    cell.layer.masksToBounds = YES;
    self.scene = self.scenes[indexPath.row];
    cell.sceneID = self.scene.sceneID;
    cell.tag = self.scene.sceneID;
    cell.scenseName.text = self.scene.sceneName;
    cell.delegate = self;
    [cell.imgView sd_setImageWithURL:[NSURL URLWithString: self.scene.picName] placeholderImage:[UIImage imageNamed:@"PL"]];
    [cell useLongPressGesture];
   [self registerForPreviewingWithDelegate:self sourceView:cell.contentView];
//    [self.collectionView reloadData];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    Scene *scene = self.scenes[indexPath.row];
    self.selectedSId = scene.sceneID;
    
    SceneCell *cell = (SceneCell*)[collectionView cellForItemAtIndexPath:indexPath];
    
    [cell useLongPressGesture];
    if(cell.deleteBtn.hidden)
    {
        [self performSegueWithIdentifier:@"iphoneEditSegue" sender:self];
        [[SceneManager defaultManager] startScene:scene.sceneID];
        
    }else{
        cell.deleteBtn.hidden = YES;
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
    
//    if (self.view.subviews.count == 6) {
//        NSMutableArray *imageArray = [NSMutableArray arrayWithCapacity:0];
//        for (int i = 0; i < 4; i++) {
//            NSString *name = [NSString stringWithFormat:@"%d",i + 1];
//            UIImage *image  = [UIImage imageNamed:name];
//            [imageArray addObject:image];
//            
//        }
//        
//        self.menuView = [[YZNavigationMenuView alloc] initWithPositionOfDirection:CGPointMake(self.view.frame.size.width - 24, 64) images:imageArray titleArray:@[@"语音",@"搜索",@"正在播放",@"添加场景"]];
//        self.menuView.delegate = self;
//        [self.view addSubview:self.menuView];
//    }else if (self.view.subviews.count > 6){
////        [self.view removeFromSuperview];
//        [self.menuView removeFromSuperview];
//    }
    
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
-(void)sceneDeleteAction:(SceneCell *)cell
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
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(cellWidth, cellWidth);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return minSpace;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return minSpace;
}

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
