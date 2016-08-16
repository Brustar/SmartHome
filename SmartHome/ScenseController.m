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
@interface ScenseController ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *addSceseBtn;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *netBarBtn;
@property (nonatomic,assign) int selectedSID;
@property (nonatomic,assign) int selectedDID;
@property (nonatomic,assign) int roomID;
//collecitonView中的scenes
@property (nonatomic,strong) NSArray *collectionScenes;
//场景置顶的两个Btn

@property (weak, nonatomic) IBOutlet UIButton *firstButton;
@property (weak, nonatomic) IBOutlet UIButton *secondButton;




@end

@implementation ScenseController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.addSceseBtn.layer.cornerRadius = self.addSceseBtn.bounds.size.width / 2.0;
    self.addSceseBtn.layer.masksToBounds = YES;
    self.firstButton.hidden = YES;
    self.secondButton.hidden = YES;

   
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    //开启网络状况的监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityUpdate:) name: kReachabilityChangedNotification object: nil];
    Reachability *hostReach = [Reachability reachabilityWithHostname:@"www.apple.com"];
    [hostReach startNotifier];  //开始监听,会启动一个run loop
    [self updateInterfaceWithReachability: hostReach];
    
    
    
    [self reachNotification];
}

-(void)setUpSceneButton
{
    if(self.scenes.count == 0)
    {
        self.firstButton.hidden = YES;
        self.secondButton.hidden = YES;
    }else if(self.scenes .count == 1)
    {
        self.secondButton.hidden = YES;
        self.firstButton.hidden = NO;
        Scene *scene = self.scenes[0];
        [self.firstButton setTitle:scene.sceneName forState:UIControlStateNormal];
    }else {
        Scene *scene = self.scenes[0];
        [self.firstButton setTitle:scene.sceneName forState:UIControlStateNormal];
        Scene *scondScene = self.scenes[1];
        [self.secondButton setTitle:scondScene.sceneName forState:UIControlStateNormal];
        self.firstButton.hidden = NO;
        self.secondButton.hidden = NO;
        
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
    if(self.scenes.count > 2)
    {
        NSMutableArray *arr = [NSMutableArray array];
        for (int i = 2; i < self.scenes.count ; i++)
        {
            [arr addObject:self.scenes[i]];
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
    if(status == ReachableViaWWAN)
    {
        if (sock.netMode==outDoor) {
            return;
        }
        NSLog(@"外出模式");
        //connect cloud
        NSUserDefaults *userdefault=[NSUserDefaults standardUserDefaults];
        [sock initTcp:[userdefault objectForKey:@"subIP"] port:[[userdefault objectForKey:@"subPort"] intValue] mode:outDoor delegate:self];
    }
    else if(status == ReachableViaWiFi)
    {
        if (sock.netMode==atHome) {
            NSLog(@"在家模式");
            [self.netBarBtn setImage:[UIImage imageNamed:@"wifi"]];
            return;
        }else if (sock.netMode==outDoor){
            NSLog(@"外出模式");
            [self.netBarBtn setImage:[UIImage imageNamed:@"4g"]];

        }
        //connect master
        [sock connectUDP:[IOManager udpPort]];
    }else{
        [self.netBarBtn setImage:[UIImage imageNamed:@"breakWifi"]];

        NSLog(@"离线模式");
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
    Scene *scene = self.collectionScenes[indexPath.row];
    cell.scenseName.text = scene.sceneName;
    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath

{
    Scene *scene = self.collectionScenes[indexPath.row];
    self.selectedSID = scene.sceneID;
    self.selectedDID = scene.eID;
    [self performSegueWithIdentifier:@"sceneDetailSegue" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"sceneDetailSegue"])
    {
        id theSegue = segue.destinationViewController;
        
        [theSegue setValue:[NSNumber numberWithInt:self.selectedSID] forKey:@"sceneID"];
        [theSegue setValue:[NSNumber numberWithInt:self.selectedDID] forKey:@"deviceID"];
        [theSegue setValue:[NSNumber numberWithInt:self.roomID] forKey:@"roomID"];
    }
}

- (IBAction)storeScense:(id)sender {
}


- (IBAction)addScence:(id)sender {
    
    ScenseSplitViewController *splitVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ScenseSplitViewController"];
    [self presentViewController:splitVC animated:YES completion:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)clickFirstButton:(UIButton *)sender {
}

- (IBAction)clickSecondBtn:(UIButton *)sender {
    Scene *scene = self.scenes[sender.tag];
    self.selectedSID = scene.sceneID;
    self.selectedDID = scene.eID;
    [self performSegueWithIdentifier:@"sceneDetailSegue" sender:self];
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
