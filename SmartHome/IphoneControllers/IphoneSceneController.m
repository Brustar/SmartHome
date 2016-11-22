//
//  IphoneSceneController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/9/19.
//  Copyright © 2016年 Brustar. All rights reserved.
//


#define cellWidth self.collectionView.frame.size.width / 2.0 - 10
#define  minSpace 20

#import "IphoneSceneController.h"
#import "RoomManager.h"
#import "Room.h"
#import "SceneCell.h"
#import "SQLManager.h"
#import "Scene.h"
#import "IphoneRoomView.h"
#import "UIImageView+WebCache.h"
#import "SceneManager.h"
#import "HttpManager.h"
#import "MBProgressHUD+NJ.h"
#import <Reachability/Reachability.h>
#import "SocketManager.h"
#import "TouchSubViewController.h"


@interface IphoneSceneController ()<UIScrollViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,IphoneRoomViewDelegate,SceneCellDelegate,UIViewControllerPreviewingDelegate>
@property (strong, nonatomic) IBOutlet IphoneRoomView *roomView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic,assign) int roomID;
@property (nonatomic,strong) NSArray *roomList;
@property (nonatomic,strong) UIButton *selectedRoomBtn;
@property (nonatomic,strong) NSArray *scenes;
@property (nonatomic, assign) int roomIndex;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic,assign) int selectedSId;
@property (nonatomic ,strong) SceneCell *cell;
@property (weak, nonatomic) IBOutlet UIButton *AddSceneBtn;
@property (nonatomic,strong) NSArray * arrayData;
@end

@implementation IphoneSceneController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.roomList = [SQLManager getAllRoomsInfo];
//    self.title = @"场景";
     [self setUpRoomView];
    self.arrayData = @[@"删除此场景",@"收藏",@"语音"];
    //开启网络状况的监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityUpdate:) name: kReachabilityChangedNotification object: nil];
    Reachability *hostReach = [Reachability reachabilityWithHostname:@"www.apple.com"];
    [hostReach startNotifier];  //开始监听,会启动一个run loop
    [self updateInterfaceWithReachability: hostReach];
    
    [self reachNotification];
    
    _AddSceneBtn.layer.cornerRadius = _AddSceneBtn.bounds.size.width / 2.0; //圆角半径
    _AddSceneBtn.layer.masksToBounds = YES; //圆角

    
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
//            [self.netBarBtn setImage:[UIImage imageNamed:@"wifi"]];
            return;
        }
        if (info.connectState==offLine) {
            NSLog(@"离线模式");
//            [self.netBarBtn setImage:[UIImage imageNamed:@"breakWifi"]];
            
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
//            [self.netBarBtn setImage:[UIImage imageNamed:@"atHome"]];
            return;
        }else if (info.connectState==outDoor){
            NSLog(@"外出模式");
//            [self.netBarBtn setImage:[UIImage imageNamed:@"wifi"]];
        }
        if (info.connectState==offLine) {
            NSLog(@"离线模式");
//            [self.netBarBtn setImage:[UIImage imageNamed:@"breakWifi"]];
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
//        [self.netBarBtn setImage:[UIImage imageNamed:@"breakWifi"]];
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
//    NSIndexPath * indexPath =[_collectionView indexPathForItemAtPoint:location];
    
     UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iPhone" bundle:nil];
    TouchSubViewController * touchSubViewVC = [storyboard instantiateViewControllerWithIdentifier:@"TouchSubViewController"];
      touchSubViewVC.preferredContentSize = CGSizeMake(0.0f,500.0f);
    touchSubViewVC.sceneName.text = self.scene.sceneName;
    touchSubViewVC.sceneDescribe.text = @"uuiiihubb";
    
//    touchSubViewVC.title = self.arrayData[indexPath.row];
    
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
    cell.tag = self.scene.sceneID;
    cell.scenseName.text = self.scene.sceneName;
    cell.delegate = self;
//    cell.imgView.image = [UIImage imageNamed:@"u2.png"];
    [cell.imgView sd_setImageWithURL:[NSURL URLWithString: self.scene.picName] placeholderImage:[UIImage imageNamed:@"PL"]];
    
    [cell useLongPressGesture];
   [self registerForPreviewingWithDelegate:self sourceView:cell.contentView];  
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
//添加场景
- (IBAction)AddSceneBtn:(id)sender {
    
    [self performSegueWithIdentifier:@"iphoneAddSceneSegue" sender:self];
}

//删除场景
-(void)sceneDeleteAction:(SceneCell *)cell
{
    self.cell = cell;
    cell.deleteBtn.hidden = YES;
    
    [SQLManager deleteScene:(int)cell.tag];
    Scene *scene = [[SceneManager defaultManager] readSceneByID:(int)cell.tag];
    [[SceneManager defaultManager] delScene:scene];
    
    NSString *url = [NSString stringWithFormat:@"%@SceneDelete.aspx",[IOManager httpAddr]];
    NSDictionary *dict = @{@"AuthorToken":[[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"],@"SID":[NSNumber numberWithInt:scene.sceneID]};
    HttpManager *http=[HttpManager defaultManager];
    http.delegate=self;
    http.tag = 1;
    [http sendPost:url param:dict];
}

//#pragma TouchSubViewController delegate
////删除场景
//-(void)removeSecene
//{
//    SceneCell * cell ;
//    [self sceneDeleteAction:cell];
//
//}
-(void)httpHandler:(id) responseObject tag:(int)tag
{
    if((tag = 1))
    {
        if([responseObject[@"Result"] intValue] == 0)
        {
           
            [MBProgressHUD showSuccess:@"场景删除成功"];
            Room *room = self.roomList[self.roomIndex];
            self.scenes = [SQLManager getScensByRoomId:room.rId];
            [self.collectionView reloadData];
           
            
            
        }else{
            [MBProgressHUD showError:responseObject[@"Msg"]];
        }
        
        
    }
    
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(cellWidth, 133);
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
