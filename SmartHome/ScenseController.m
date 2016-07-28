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

@interface ScenseController ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *addSceseBtn;

@end

@implementation ScenseController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.addSceseBtn.layer.cornerRadius = self.addSceseBtn.bounds.size.width / 2.0;
    self.addSceseBtn.layer.masksToBounds = YES;
    
    self.scenes=[NSArray arrayWithObjects:@"清晨" ,@"睡眠" ,@"约会" ,@"用餐" ,@"派对" ,@"影院" ,@"欢迎" ,@"离家" ,nil];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    //开启网络状况的监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityUpdate:) name: kReachabilityChangedNotification object: nil];
    Reachability *hostReach = [Reachability reachabilityWithHostname:@"www.apple.com"];
    [hostReach startNotifier];  //开始监听,会启动一个run loop
    [self updateInterfaceWithReachability: hostReach];
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
            return;
        }else if (sock.netMode==outDoor){
            NSLog(@"外出模式");
        }
        //connect master
        [sock connectUDP:[IOManager udpPort]];
    }else{
        NSLog(@"离线模式");
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.scenes.count;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ScenseCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"scenseCell" forIndexPath:indexPath];
    cell.scenseName.text = self.scenes[indexPath.row];
    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //[self performSegueWithIdentifier:@"newScene" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"newScene"])
    {
        id theSegue = segue.destinationViewController;
        //        NSInteger row = self.tableView.indexPathForSelectedRow.row;
        [theSegue setValue:@"2" forKey:@"sceneid"];
        //        [theSegue setValue:[NSString stringWithFormat:@"%@",self.scenes[row]] forKey:@"title"];
    }
}

- (IBAction)storeScense:(id)sender {
}

//- (IBAction)addSencesBtn:(id)sender {
//    [self performSegueWithIdentifier:@"addScene" sender:self];
//
//}
- (IBAction)addScence:(id)sender {
    
    ScenseSplitViewController *splitVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ScenseSplitViewController"];
    [self presentViewController:splitVC animated:YES completion:nil];
}


-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
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
