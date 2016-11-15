//
//  ScenseController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/7/20.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "SceneController.h"
#import "SceneCell.h"
#import "ScenseSplitViewController.h"
#import <Reachability/Reachability.h>
#import "SocketManager.h"
#import "SQLManager.h"
#import "Scene.h"
#import "HttpManager.h"
#import "MBProgressHUD+NJ.h"
#import "SearchViewController.h"
#import "ECSearchView.h"
#import "RoomManager.h"
#import "IbeaconManager.h"
#import "HostIDSController.h"
#import "UIImageView+WebCache.h"
#import "SceneManager.h"
#import <SDWebImage/UIButton+WebCache.h>


@interface SceneController ()<UICollectionViewDelegate,UICollectionViewDataSource,UIGestureRecognizerDelegate,UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *addSceseBtn;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *netBarBtn;
@property (nonatomic,assign) int selectedSID;

@property (nonatomic,assign) int roomID;
//collecitonView中的scenes
@property (nonatomic,strong) NSArray *collectionScenes;
//场景置顶的两个Btn

@property (weak, nonatomic) IBOutlet UIButton *firstButton;
@property (weak, nonatomic) IBOutlet UIButton *secondButton;


@property (weak, nonatomic) IBOutlet UIButton *firstPowerBtn;
@property (weak, nonatomic) IBOutlet UIButton *secondPowerBtn;

@property (weak, nonatomic) IBOutlet UIView *firstView;
@property (weak, nonatomic) IBOutlet UIView *secondView;

@property (nonatomic,strong) UISearchController *searchVC;


@property(nonatomic,strong)HostIDSController *hostVC;
@end

@implementation SceneController


-(HostIDSController *)hostVC
{
    if(!_hostVC)
    {
        _hostVC =  [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"HostIDSController"];
    }
    return _hostVC;
}
-(UISearchController *)searchVC{
    if(!_searchVC)
    {
        _searchVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SearchViewController"];
        
    }
    return _searchVC;
}

- (void)viewDidLoad {
    [super viewDidLoad];
  
    
    self.addSceseBtn.layer.cornerRadius = self.addSceseBtn.bounds.size.width / 2.0;
    self.addSceseBtn.layer.masksToBounds = YES;
    self.firstView.hidden = YES;
    self.secondView.hidden = YES;

    //开启网络状况的监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityUpdate:) name: kReachabilityChangedNotification object: nil];
    Reachability *hostReach = [Reachability reachabilityWithHostname:@"www.apple.com"];
    [hostReach startNotifier];  //开始监听,会启动一个run loop
    [self updateInterfaceWithReachability: hostReach];
    
    [self reachNotification];

    [self setNavi];
    
}


-(void)setNavi
{
    UIButton *titleButton = [[UIButton alloc]init];
    titleButton.frame = CGRectMake(0, 0, 250, 40);
    [titleButton setTitle:@"逸云智家" forState:UIControlStateNormal];
    [titleButton setImage:[UIImage imageNamed:@"down"] forState:UIControlStateNormal];
    
  
    [titleButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    titleButton.imageEdgeInsets = UIEdgeInsetsMake(0, 180, 0, 0);
    
    [titleButton addTarget:self action:@selector(clickTitleButton:) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.titleView = titleButton;
}
-(void)clickTitleButton:(UIButton *)btn
{
   
    
    
    self.hostVC.modalPresentationStyle = UIModalPresentationPopover;
    self.hostVC.popoverPresentationController.sourceView = btn;
    self.hostVC.popoverPresentationController.sourceRect = btn.bounds;
    
    self.hostVC.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionDown;
    
    [self presentViewController:self.hostVC animated:YES completion:nil];
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    self.scenes = [SQLManager getScensByRoomId:self.roomID];
    [self setUpSceneButton];
    [self judgeScensCount:self.scenes];
    [self.collectionView reloadData];
}

-(void)setUpSceneButton
{
    if(self.scenes.count == 0)
    {
        self.firstView.hidden = YES;
        self.secondView.hidden = YES;
        
    }else if(self.scenes .count == 1)
    {
        self.secondView.hidden = YES;
        self.firstView.hidden = NO;
        Scene *scene = self.scenes[0];
        self.firstButton.tag = scene.sceneID;
        self.firstPowerBtn.tag = scene.sceneID;
        
        [self.firstButton setTitle:scene.sceneName forState:UIControlStateNormal];
        [self.firstButton sd_setBackgroundImageWithURL:[NSURL URLWithString:scene.picName] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"PL"]];
        
        
    }else {
        Scene *scene = self.scenes[0];
        self.firstButton.tag = scene.sceneID;
        self.firstPowerBtn.tag = scene.sceneID;
        [self.firstButton setTitle:scene.sceneName forState:UIControlStateNormal];
        [self.firstButton sd_setBackgroundImageWithURL:[NSURL URLWithString:scene.picName] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"PL"]];
        
        Scene *scondScene = self.scenes[1];
        
        [self.secondButton sd_setBackgroundImageWithURL:[NSURL URLWithString:scondScene.picName] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"PL"]];
        [self.secondButton setTitle:scondScene.sceneName forState:UIControlStateNormal];
        self.secondButton.tag = scondScene.sceneID;
        self.secondPowerBtn.tag = scondScene.sceneID;
       
        self.firstView.hidden = NO;
       
        self.secondView.hidden = NO;
        
    }
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
   
    [self setUpSceneButton];
    [self judgeScensCount:self.scenes];
    
}


-(void)judgeScensCount:(NSArray *)scenes
{
    if(scenes.count > 2)
    {
        NSMutableArray *arr = [NSMutableArray array];
        for (int i = 2; i < scenes.count ; i++)
        {
            [arr addObject:scenes[i]];
        }
        self.collectionScenes = [arr copy];
    }else {
        self.collectionScenes = nil;
    }
    
    [self.collectionView reloadData];
}


//监听到网络状态改变
- (void) reachabilityUpdate: (NSNotification* )note
{
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    [self updateInterfaceWithReachability: curReach];
}


//处理连接改变后的情况
- (void) updateInterfaceWithReachability: (Reachability*) curReach
{
    //对连接改变做出响应的处理动作。
    NetworkStatus status = [curReach currentReachabilityStatus];
    SocketManager *sock=[SocketManager defaultManager];
    DeviceInfo *info = [DeviceInfo defaultManager];
    if(status == ReachableViaWWAN)
    {
        if (info.connectState==outDoor) {
            NSLog(@"外出模式");
            [self.netBarBtn setImage:[UIImage imageNamed:@"wifi"]];
            return;
        }
        if (info.connectState==offLine) {
            NSLog(@"离线模式");
            [self.netBarBtn setImage:[UIImage imageNamed:@"breakWifi"]];
        
            //connect cloud
            if ([info.db isEqualToString:SMART_DB]) {
                [sock connectTcp];
            }
        }
    }
    else if(status == ReachableViaWiFi)
    {
        if (info.connectState==atHome) {
            NSLog(@"在家模式");
            [self.netBarBtn setImage:[UIImage imageNamed:@"atHome"]];
            return;
        }else if (info.connectState==outDoor){
            NSLog(@"外出模式");
            [self.netBarBtn setImage:[UIImage imageNamed:@"wifi"]];
        }
        if (info.connectState==offLine) {
            NSLog(@"离线模式");
            [self.netBarBtn setImage:[UIImage imageNamed:@"breakWifi"]];
            if ([info.db isEqualToString:SMART_DB]) {
            int sed = (arc4random() % 3) + 1;
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad && sed == 1) {
                //connect master
                [sock connectUDP:[IOManager udpPort]];
            }else{
                //connect cloud
                [sock connectTcp];
            }
            }
        }
    }else{
        NSLog(@"离线模式");
        [self.netBarBtn setImage:[UIImage imageNamed:@"breakWifi"]];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
   
    return self.collectionScenes.count;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SceneCell*cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"scenseCell" forIndexPath:indexPath];
    [cell.powerBtn addTarget:self action:@selector(startSceneAction:) forControlEvents:UIControlEventTouchUpInside];
    
    Scene *scene = self.collectionScenes[indexPath.row];
    cell.scenseName.text = scene.sceneName;

    [cell.imgView sd_setImageWithURL:[NSURL URLWithString: scene.picName] placeholderImage:[UIImage imageNamed:@"PL"]];
    cell.powerBtn.tag = scene.sceneID;
   
   
    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath

{
    
    Scene *scene = self.collectionScenes[indexPath.row];
    self.selectedSID = scene.sceneID;

    [[SceneManager defaultManager] startScene:scene.sceneID];
    [self performSegueWithIdentifier:@"sceneDetailSegue" sender:self];
}
-(void)startSceneAction:(UIButton *)btn{
    int sceneId = (int)btn.tag;
    [btn setTintColor:[UIColor redColor]];
    [[SceneManager defaultManager] startScene:sceneId];
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"sceneDetailSegue"])
    {
        id theSegue = segue.destinationViewController;
        
        [theSegue setValue:[NSNumber numberWithInt:self.selectedSID] forKey:@"sceneID"];
        [theSegue setValue:[NSNumber numberWithInt:self.roomID] forKey:@"roomID"];
    
        
    }
}




- (IBAction)addScence:(id)sender {
    
    [IOManager removeTempFile];
    ScenseSplitViewController *splitVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ScenseSplitViewController"];
    [self presentViewController:splitVC animated:YES completion:nil];
    [[DeviceInfo defaultManager] setEditingScene:YES];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



- (IBAction)clickSceneBtn:(UIButton *)sender {
   
    
    self.selectedSID =(int)sender.tag;
    [[SceneManager defaultManager] startScene:self.selectedSID];
    [self performSegueWithIdentifier:@"sceneDetailSegue" sender:self];
}

- (IBAction)clickSartSceneBtn:(UIButton *)sender {
    
    
    [sender setTintColor:[UIColor redColor]];
    [[SceneManager defaultManager] startScene:(int)sender.tag];
}


//搜索功能
- (IBAction)startSearch:(UIBarButtonItem *)sender {

    
    [self.navigationController pushViewController:self.searchVC animated:NO];
    
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
