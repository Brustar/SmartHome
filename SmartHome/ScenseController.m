//
//  ScenseController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/7/20.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "ScenseController.h"
#import "ScenseCell.h"
#import "ScenseSplitViewController.h"
#import <Reachability/Reachability.h>
#import "SocketManager.h"
#import "SceneManager.h"
#import "Scene.h"
#import "HttpManager.h"
#import "MBProgressHUD+NJ.h"

@interface ScenseController ()<UICollectionViewDelegate,UICollectionViewDataSource,ScenseCellDelegate,UIGestureRecognizerDelegate>
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


@end

@implementation ScenseController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.addSceseBtn.layer.cornerRadius = self.addSceseBtn.bounds.size.width / 2.0;
    self.addSceseBtn.layer.masksToBounds = YES;
    self.firstView.hidden = YES;
    self.secondView.hidden = YES;

   
    self.automaticallyAdjustsScrollViewInsets = NO;
    
   
    
    //开启网络状况的监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityUpdate:) name: kReachabilityChangedNotification object: nil];
    Reachability *hostReach = [Reachability reachabilityWithHostname:@"www.apple.com"];
    [hostReach startNotifier];  //开始监听,会启动一个run loop
    [self updateInterfaceWithReachability: hostReach];
    
    [self reachNotification];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
     self.scenes = [SceneManager getAllSceneWithRoomID:self.roomID];
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
        UIImage *image = [self getImgByUrl:scene.picName];
        [self.firstButton setBackgroundImage:image forState:UIControlStateNormal];
        
    }else {
        Scene *scene = self.scenes[0];
        self.firstButton.tag = scene.sceneID;
        self.firstPowerBtn.tag = scene.sceneID;
                [self.firstButton setTitle:scene.sceneName forState:UIControlStateNormal];
        UIImage *image = [self getImgByUrl:scene.picName];
        [self.firstButton setBackgroundImage:image forState:UIControlStateNormal];
        Scene *scondScene = self.scenes[1];
        [self.secondButton setTitle:scondScene.sceneName forState:UIControlStateNormal];
        image = [self getImgByUrl:scondScene.picName];
        [self.secondButton setBackgroundImage:image forState:UIControlStateNormal];
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
    
    self.scenes = [SceneManager getAllSceneWithRoomID:self.roomID];
    [self setUpSceneButton];
    [self judgeScensCount:self.scenes];
    
}
-(UIImage *)getImgByUrl:(NSString *)url
{
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
    return [UIImage imageWithData:data];
    
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
            [self.netBarBtn setImage:[UIImage imageNamed:@"out"]];
            return;
        }
        if (info.connectState==offLine) {
            NSLog(@"离线模式");
            [self.netBarBtn setImage:[UIImage imageNamed:@"breakWifi"]];
        
            //connect cloud
            NSUserDefaults *userdefault=[NSUserDefaults standardUserDefaults];
            [sock initTcp:[userdefault objectForKey:@"subIP"] port:[[userdefault objectForKey:@"subPort"] intValue] delegate:self];
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
            [self.netBarBtn setImage:[UIImage imageNamed:@"out"]];
        }
        if (info.connectState==offLine) {
            NSLog(@"离线模式");
            [self.netBarBtn setImage:[UIImage imageNamed:@"breakWifi"]];
            
            int sed = (arc4random() % 3) + 1;
            if (sed == 1) {
                //connect master
                [sock connectUDP:[IOManager udpPort]];
            }else{
                //connect cloud
                [sock connectTcp];
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
    ScenseCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"scenseCell" forIndexPath:indexPath];
    [cell.powerBtn addTarget:self action:@selector(startSceneAction:) forControlEvents:UIControlEventTouchUpInside];
    
    Scene *scene = self.collectionScenes[indexPath.row];
    cell.scenseName.text = scene.sceneName;
    //cell.backgroundColor = [UIColor colorWithPatternImage:[self getImgByUrl:scene.picName]];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSData * data = [[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:scene.sceneName]];
        UIImage *image = [[UIImage alloc]initWithData:data];
        if (data != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                 cell.backgroundView = [[UIImageView alloc]initWithImage:image];
            });
        }
    });
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
