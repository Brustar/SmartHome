//
//  FirstSceneViewController.m
//  SmartHome
//
//  Created by zhaona on 2017/3/20.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "FirstSceneViewController.h"
#import "CYLineLayout.h"
#import "CYPhotoCell.h"
#import "Room.h"
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
#import "HostIDSController.h"
#import "AppDelegate.h"
#import "IphoneEditSceneController.h"


@interface FirstSceneViewController ()<UICollectionViewDataSource, UICollectionViewDelegate,UIScrollViewDelegate,IphoneRoomViewDelegate,UIViewControllerPreviewingDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *XinImageView;
@property (weak, nonatomic) IBOutlet UIImageView *JiaHaoImageView;
@property (weak, nonatomic) IBOutlet UIImageView *DeletImageView;

@property (weak, nonatomic) IBOutlet IphoneRoomView *roomView;
@property (nonatomic,assign) int roomID;
@property (nonatomic,strong) NSArray *roomList;
@property (nonatomic,strong) UIButton *selectedRoomBtn;
@property (nonatomic,strong) NSArray *scenes;
@property (nonatomic, assign) int roomIndex;
@property (nonatomic,assign) int selectedSId;
//@property (nonatomic ,strong) SceneCell *cell;
@property (weak, nonatomic) IBOutlet UIButton *AddSceneBtn;
@property (nonatomic,strong) NSArray * arrayData;
@property (nonatomic,assign) int sceneID;
//@property (nonatomic,strong) YZNavigationMenuView *menuView;
@property (strong, nonatomic) IBOutlet UIButton *titleButton;
@property(nonatomic,strong)HostIDSController *hostVC;
@property (nonatomic,strong)UICollectionView * collectionView;

@property (weak, nonatomic) IBOutlet UILabel *SceneNameLabel;

@end

@implementation FirstSceneViewController
static NSString * const CYPhotoId = @"photo";
- (void)viewDidLoad {
    [super viewDidLoad];
     self.automaticallyAdjustsScrollViewInsets = NO;
     self.roomList = [SQLManager getAllRoomsInfo];
     self.arrayData = @[@"删除此场景",@"收藏",@"语音"];
      [self setUpRoomView];
      [self reachNotification];
      [self setupSlideButton];
      [self setUI];
    UITapGestureRecognizer * PrivateLetterTap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAvatarView:)];
    [self.JiaHaoImageView addGestureRecognizer:PrivateLetterTap];
    self.JiaHaoImageView.userInteractionEnabled = YES;
}
- (void)tapAvatarView: (UITapGestureRecognizer *)gesture
{
    
    [[SceneManager defaultManager] startScene:self.sceneID];
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
    self.collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
    self.XinImageView.layer.cornerRadius = 25.0f; //圆角半径
    self.XinImageView.layer.masksToBounds = YES; //圆角
    self.JiaHaoImageView.layer.cornerRadius = 25.0f; //圆角半径
    self.JiaHaoImageView.layer.masksToBounds = YES; //圆角
    self.DeletImageView.layer.cornerRadius = 25.0f; //圆角半径
    self.DeletImageView.layer.masksToBounds = YES; //圆角
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.view addSubview:self.collectionView];
    //    self.navigationController.navigationBar.hidden = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;//
    // 注册
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([CYPhotoCell class]) bundle:nil] forCellWithReuseIdentifier:CYPhotoId];

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
#pragma mark - <UICollectionViewDataSource>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
     return self.scenes.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CYPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CYPhotoId forIndexPath:indexPath];
    self.scene = self.scenes[indexPath.row];
    cell.sceneID = self.scene.sceneID;
    cell.tag = self.scene.sceneID;
    self.SceneNameLabel.text = self.scene.sceneName;
   [cell.imageView sd_setImageWithURL:[NSURL URLWithString: self.scene.picName] placeholderImage:[UIImage imageNamed:@"PL"]];
 [self registerForPreviewingWithDelegate:self sourceView:cell.contentView];
    return cell;
}

#pragma mark - <UICollectionViewDelegate>
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    Scene *scene = self.scenes[indexPath.row];
    self.selectedSId = scene.sceneID;
    UIStoryboard *iPhoneStoryBoard  = [UIStoryboard storyboardWithName:@"iPhone" bundle:nil];
//    CYPhotoCell *cell = (CYPhotoCell*)[collectionView cellForItemAtIndexPath:indexPath];
//        [self performSegueWithIdentifier:@"iphoneNewEditSegue" sender:self];
       IphoneEditSceneController * EditSceneVC = [iPhoneStoryBoard instantiateViewControllerWithIdentifier:@"IphoneEditSceneController"];
     [self.navigationController pushViewController:EditSceneVC animated:YES];
        [[SceneManager defaultManager] startScene:scene.sceneID];
        
   
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    Room *room = self.roomList[self.roomIndex];
    if([segue.identifier isEqualToString:@"iphoneAddSceneSegue"])
    {
        [IOManager removeTempFile];
        
        id theSegue = segue.destinationViewController;
        [theSegue setValue:[NSNumber numberWithInt:room.rId] forKey:@"roomId"];
    }else if([segue.identifier isEqualToString:@"iphoneNewEditSegue"]){
        id theSegue = segue.destinationViewController;
        
        [theSegue setValue:[NSNumber numberWithInt:self.selectedSId] forKey:@"sceneID"];
        [theSegue setValue:[NSNumber numberWithInt:room.rId] forKey:@"roomID"];
    }
    
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
