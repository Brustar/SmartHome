//
//  IpadSceneViewController.m
//  SmartHome
//
//  Created by zhaona on 2017/5/24.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "IpadSceneViewController.h"
#import "SQLManager.h"
#import "Room.h"
#import "CYLineLayout.h"
#import "CYPhotoCell.h"
#import "MBProgressHUD+NJ.h"
#import "PhotoGraphViewConteoller.h"
#import "SceneManager.h"
#import "IpadSceneCell.h"
#import "IphoneNewAddSceneVC.h"
#import "HttpManager.h"
#import "BaseTabBarController.h"
#import "AppDelegate.h"
#import "IpadDeviceListViewController.h"
//#import "IpadDeviceTypeVC.h"
#import "AddIpadSceneVC.h"

static NSString * const IpadSceneId = @"photo";

@interface IpadSceneViewController ()<IphoneRoomViewDelegate,UIScrollViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,IpadSceneCellDelegate,PhotoGraphViewConteollerDelegate,UIGestureRecognizerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic,strong) NSArray *roomList;
@property (nonatomic,strong)NSMutableArray *scenes;
@property (nonatomic,strong) UICollectionView * FirstCollectionView;
@property (nonatomic,assign) int selectedSId;
@property (nonatomic,strong) UILongPressGestureRecognizer *lgPress;
@property (nonatomic,strong) IpadSceneCell *currentCell;
@property (nonatomic, assign) int roomIndex;
@property (nonatomic,assign) int selectedRoomID;
@property (nonatomic,strong) UIImage * selectSceneImg;
@property (nonatomic,assign) int sceneID;
@property (nonatomic, readonly) UIButton *naviRightBtn;
@property (nonatomic, readonly) UIButton *naviLeftBtn;
@property (nonatomic, readonly) UIButton *naviMiddletBtn;
@property (nonatomic,strong) BaseTabBarController *baseTabbarController;

@end

@implementation IpadSceneViewController

#pragma mark -- lazy load
-(NSMutableArray *)scenes{
    if (!_scenes) {
        _scenes = [NSMutableArray new];
        NSString *imageName = @"AddSceneBtn";
        [_scenes addObject:imageName];
    }
    return _scenes;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.roomList = [SQLManager getAllRoomsInfo];
    [self setUpRoomView];
    [self reachNotification];
    [self setupNaviBar];
    [self setUI];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _baseTabbarController =  (BaseTabBarController *)self.tabBarController;
    _baseTabbarController.tabbarPanel.hidden = NO;
    _baseTabbarController.tabBar.hidden = YES;
    
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _baseTabbarController =  (BaseTabBarController *)self.tabBarController;
    _baseTabbarController.tabbarPanel.hidden = NO;
    _baseTabbarController.tabBar.hidden = YES;
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    _baseTabbarController =  (BaseTabBarController *)self.tabBarController;
    _baseTabbarController.tabbarPanel.hidden = YES;
}
- (void)setupNaviBar {
    
//    [self setNaviBarTitle:[UD objectForKey:@"homename"]]; //设置标题
    _naviMiddletBtn = [[UIButton alloc] init];
    [_naviMiddletBtn setTitle:[UD objectForKey:@"homename"] forState:UIControlStateNormal];
    //    [_naviMiddletBtn addTarget:self action:@selector(MiddleBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
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
        [self setNaviMiddletBtn:_naviMiddletBtn];
}
-(void)rightBtnClicked:(UIButton *)btn
{


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
    
    NSArray *tmpArr = [SQLManager getScensByRoomId:room.rId];
    self.selectedRoomID = room.rId;
    [self.scenes removeAllObjects];
    [self.scenes addObjectsFromArray:tmpArr];
    NSString *imageName = @"i-add";
    [self.scenes addObject:imageName];
    
    [self.FirstCollectionView reloadData];
    
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
    layout.itemSize = CGSizeMake(450, 540);
    self.FirstCollectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
    self.FirstCollectionView.backgroundColor = [UIColor clearColor];
    self.FirstCollectionView.dataSource = self;
    self.FirstCollectionView.delegate = self;
    [self.view addSubview:self.FirstCollectionView];
    //    self.navigationController.navigationBar.hidden = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;//
    // 注册
    [self.FirstCollectionView registerNib:[UINib nibWithNibName:NSStringFromClass([IpadSceneCell class]) bundle:nil] forCellWithReuseIdentifier:IpadSceneId];
}

#pragma  mark - UICollectionViewDelegate
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.scenes.count;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row+1 >= self.scenes.count) {
        IpadSceneCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:IpadSceneId forIndexPath:indexPath];
        cell.delegate = self;
        cell.imageView.image = [UIImage imageNamed:@"AddScene-ImageView"];
        cell.subImageView.image = [UIImage imageNamed:@"AddSceneBtn"];
        cell.sceneID = 0;
        cell.SceneName.text = @" ";
        cell.SceneNameTopConstraint.constant = 40;
        cell.deleteBtn.hidden = YES;
        cell.powerBtn.hidden = YES;
        cell.seleteSendPowBtn.hidden = YES;
        cell.partternBtnView.hidden = YES;
        
        return cell;
    }else{
        IpadSceneCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:IpadSceneId forIndexPath:indexPath];
        cell.delegate = self;
        
        Scene *scene = self.scenes[indexPath.row];
        
        cell.sceneID = scene.sceneID;
        cell.sceneStatus = scene.status;
        
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
//        [self registerForPreviewingWithDelegate:self sourceView:cell.contentView];
        cell.deleteBtn.hidden = NO;
        cell.powerBtn.hidden = NO;
        cell.partternBtnView.hidden = NO;
        cell.delegate = self;
        if (scene.status == 0) {
            [cell.powerBtn setBackgroundImage:[UIImage imageNamed:@"close_white"] forState:UIControlStateNormal];
        }else if (scene.status == 1) {
            [cell.powerBtn setBackgroundImage:[UIImage imageNamed:@"close_red"] forState:UIControlStateNormal];
        }
        
        return cell;
        
    }
    
}

-(void)handleLongPress:(UILongPressGestureRecognizer *)lgr
{
    NSIndexPath *indexPath = [self.FirstCollectionView indexPathForItemAtPoint:[lgr locationInView:self.FirstCollectionView]];
    self.currentCell = (IpadSceneCell *)[self.FirstCollectionView cellForItemAtIndexPath:indexPath];
    
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
    UIPopoverPresentationController *popPresenter = [alerController
                                                     popoverPresentationController];
    popPresenter.sourceView = self.currentCell;
    popPresenter.sourceRect = self.currentCell.bounds;
    [self presentViewController:alerController animated:YES completion:nil];
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
    Scene *scene = [[Scene alloc] initWhithoutSchedule];
    scene.sceneID = self.currentCell.sceneID;
    scene.roomID = self.roomID;
    [[SceneManager defaultManager] editScene:scene newSceneImage:self.selectSceneImg];
    [self.currentCell.imageView setImage:self.selectSceneImg];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [DeviceInfo defaultManager].isPhotoLibrary = NO;
    [picker dismissViewControllerAnimated:YES completion:nil];
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row+1 >= self.scenes.count) {
        UIStoryboard * SceneStoryBoard = [UIStoryboard storyboardWithName:@"Scene-iPad" bundle:nil];
        AddIpadSceneVC * AddIpadSceneVC = [SceneStoryBoard instantiateViewControllerWithIdentifier:@"AddIpadSceneVC"];
        AddIpadSceneVC.roomID = self.selectedRoomID;
     
         [self presentViewController:AddIpadSceneVC animated:YES completion:nil];
        
    }else{
        Scene *scene = self.scenes[indexPath.row];
        self.selectedSId = scene.sceneID;
        UIStoryboard *SceneiPadStoryBoard = [UIStoryboard storyboardWithName:@"Scene-iPad" bundle:nil];
        IpadDeviceListViewController * listVC = [SceneiPadStoryBoard instantiateViewControllerWithIdentifier:@"IpadDeviceListViewController"];
         listVC.roomID = self.selectedRoomID;
         listVC.sceneID = self.selectedSId;
        [self presentViewController:listVC animated:YES completion:nil];
        
    }
    
}

//删除场景
-(void)sceneDeleteAction:(IpadSceneCell *)cell
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
-(void)powerBtnAction:(UIButton *)sender sceneStatus:(int)status
{
    
}

@end
