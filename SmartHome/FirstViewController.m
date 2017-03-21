//
//  FirstViewController.m
//  
//
//  Created by zhaona on 2017/3/17.
//
//

#import "FirstViewController.h"
#import "AppDelegate.h"
#import "IphoneFamilyViewController.h"
#import "SocketManager.h"
#import "SceneManager.h"
#import "BgMusic.h"
#import "PackManager.h"
#import "DeviceInfo.h"
#import "AudioManager.h"
#import "SQLManager.h"
#import <AVFoundation/AVFoundation.h>

@interface FirstViewController ()<UITableViewDataSource,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIImageView *SubImageView;//首页的日历大圆
@property (weak, nonatomic) IBOutlet UIView *BtnView;//全屋场景的按钮试图
@property (weak, nonatomic) IBOutlet UIImageView *IconeImageView;//提示消息的头像
@property (weak, nonatomic) IBOutlet UILabel *memberFamilyLabel;//家庭成员label
@property (weak, nonatomic) IBOutlet UIImageView *numberLabelView;//未读消息的视图
@property (weak, nonatomic) IBOutlet UIBarButtonItem *playerBarBtn;//正在播放的按钮
@property (weak, nonatomic) IBOutlet UIView *playerSubView;//正在播放的视图
@property (weak, nonatomic) IBOutlet UIView *FourBtnView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong)NSArray * dataArr;

@end

@implementation FirstViewController
-(NSArray *)dataArr
{

    if (_dataArr == nil) {
        _dataArr =[NSArray array];
    }
    

    return _dataArr;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.FourBtnView.userInteractionEnabled = YES;
    _SubImageView.layer.cornerRadius = _SubImageView.bounds.size.height/2; //圆角半径
    _SubImageView.layer.masksToBounds = YES; //圆角
    _IconeImageView.layer.masksToBounds = YES;
    _IconeImageView.layer.cornerRadius = _IconeImageView.bounds.size.height/2;
    _numberLabelView.layer.masksToBounds = YES;
    _numberLabelView.layer.cornerRadius = _numberLabelView.bounds.size.height / 2;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doTap:)];
    // 允许用户交互
    _SubImageView.userInteractionEnabled = YES;
    [_SubImageView addGestureRecognizer:tap];
    [self setupSlideButton];
//    [self setBtn];
    
    NSArray *bgmusicIDS = [SQLManager getDeviceByTypeName:@"背景音乐" andRoomID:self.roomID];
    if ([bgmusicIDS count]>0) {
        self.deviceid = bgmusicIDS[0];
    }
}
-(void)setBtn
{
    NSArray * arr = @[@"回家",@"离家",@"度假"];
    CGFloat BtnW = self.BtnView.frame.size.width/3;
    CGFloat BtnH = self.BtnView.frame.size.height;
    for (int i = 0; i < 3; i ++) {
        UIButton * button = [[UIButton alloc] init];
        button.tag = i;
        button.frame = CGRectMake(i*BtnW, self.BtnView.bounds.origin.y, BtnW, BtnH);
        [button setTintColor:[UIColor whiteColor]];
        [button setTitle:arr[i] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"button6-14"] forState:UIControlStateNormal];
        [_BtnView addSubview:button];
    }

}
-(void)doTap:(UITapGestureRecognizer *)tap
{
        UIStoryboard *iPhoneStoryBoard  = [UIStoryboard storyboardWithName:@"iPhone" bundle:nil];
        IphoneFamilyViewController *familyVC = [iPhoneStoryBoard instantiateViewControllerWithIdentifier:@"iphoneFamilyViewController"];
        [self.navigationController pushViewController:familyVC animated:YES];

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
//正在播放的点击事件
- (IBAction)playerBarBtn:(id)sender {
    if (self.playerSubView.hidden) {
          self.playerSubView.hidden = NO;
        self.SubImageView.hidden = YES;
        self.BtnView.hidden = YES;
        self.IconeImageView.hidden = YES;
        self.numberLabelView.hidden = YES;
        self.memberFamilyLabel.hidden = YES;
    }else{
          self.playerSubView.hidden = YES;
        self.SubImageView.hidden = NO;
        self.BtnView.hidden = NO;
        self.IconeImageView.hidden = NO;
        self.numberLabelView.hidden = NO;
        self.memberFamilyLabel.hidden = NO;
    }
    
}
//减音量
- (IBAction)smallVolume:(id)sender {
}
//加音量
- (IBAction)additionVolume:(id)sender {
}
//上一步
- (IBAction)lastStep:(id)sender {
    NSLog(@"hhhhhh");
    NSData *data=[[DeviceInfo defaultManager] previous:self.deviceid];
    SocketManager *sock=[SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
    if (BLUETOOTH_MUSIC) {
        AudioManager *audio= [AudioManager defaultManager];
        if ([[audio musicPlayer] indexOfNowPlayingItem]>0) {
            [[audio musicPlayer] skipToPreviousItem];
        }
    }
}
//下一步
- (IBAction)nextStep:(id)sender {
      NSLog(@"hhhhhh");
    NSData *data=[[DeviceInfo defaultManager] next:self.deviceid];
    SocketManager *sock=[SocketManager defaultManager];
    [sock.socket writeData:data withTimeout:1 tag:1];
    if (BLUETOOTH_MUSIC) {
        AudioManager *audio= [AudioManager defaultManager];
        
        if ([[audio musicPlayer] indexOfNowPlayingItem]<audio.songs.count-1) {
            [[audio musicPlayer] skipToNextItem];
        }
    }
}
//开关
- (IBAction)switchPower:(id)sender {
//    NSData *data=[[DeviceInfo defaultManager] pause:self.deviceid];
//    SocketManager *sock=[SocketManager defaultManager];
//    [sock.socket writeData:data withTimeout:1 tag:1];
//    if (BLUETOOTH_MUSIC) {
//        AudioManager *audio= [AudioManager defaultManager];
//        [[audio musicPlayer] pause];
//    }
    UIButton *btn = (UIButton *)sender;
    
    if (_playState == 0) {
        _playState = 1;
        [btn setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
        //发送播放指令
        NSData *data=[[DeviceInfo defaultManager] play:self.deviceid];
        SocketManager *sock=[SocketManager defaultManager];
        [sock.socket writeData:data withTimeout:1 tag:1];
        
        if (BLUETOOTH_MUSIC) {
            AudioManager *audio= [AudioManager defaultManager];
            [[audio musicPlayer] play];
        }
    }else if (_playState == 1) {
        _playState = 0;
        [btn setImage:[UIImage imageNamed:@"broadcast"] forState:UIControlStateNormal];
        //发送停止指令
        NSData *data=[[DeviceInfo defaultManager] pause:self.deviceid];
        SocketManager *sock=[SocketManager defaultManager];
        [sock.socket writeData:data withTimeout:1 tag:1];
        if (BLUETOOTH_MUSIC) {
            AudioManager *audio= [AudioManager defaultManager];
            [[audio musicPlayer] pause];
        }
    }
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArr.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    if (_dataArr.count == 0) {
        self.tableView.hidden = YES;
        
    }
    return cell;
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
