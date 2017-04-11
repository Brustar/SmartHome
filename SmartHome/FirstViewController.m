//
//  FirstViewController.m
//  
//
//  Created by zhaona on 2017/3/17.
//
//

#import "FirstViewController.h"
#import "AppDelegate.h"
#import "FamilyHomeViewController.h"
#import "SocketManager.h"
#import "SceneManager.h"
#import "BgMusic.h"
#import "PackManager.h"
#import "DeviceInfo.h"
#import "AudioManager.h"
#import "SQLManager.h"
#import <AVFoundation/AVFoundation.h>
#import "ShortcutKeyViewController.h"
#import "TabbarPanel.h"


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
@property (weak, nonatomic) IBOutlet UIImageView *HeadImageView;
@property (weak, nonatomic) IBOutlet UIView *socialView;
@property (weak, nonatomic) IBOutlet UILabel *calenderDayLabel;//日历-天
@property (weak, nonatomic) IBOutlet UILabel *markedWordsLabel;//提示语
@property (weak, nonatomic) IBOutlet UILabel *calenderMonthLabel;//日历月
@property (weak, nonatomic) IBOutlet UILabel *calenderYearLabel;//日历年
@property (weak, nonatomic) IBOutlet UILabel *UserNameLabel;//用户名的显示
@property (weak, nonatomic) IBOutlet UILabel *WelcomeLabel;
@property (weak, nonatomic) IBOutlet UILabel *TakeTurnsWordsLabel;
@property(nonatomic,strong)NSArray * Urldata;
@property (weak, nonatomic) IBOutlet UIButton *firstBtn;
@property (weak, nonatomic) IBOutlet UIButton *TwoBtn;
@property (weak, nonatomic) IBOutlet UIButton *ThreeBtn;
@property (weak, nonatomic) IBOutlet UIView *subView;

@end

@implementation FirstViewController
-(NSArray *)dataArr
{

    if (_dataArr == nil) {
        _dataArr =[NSArray array];
    }
    

    return _dataArr;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    BaseTabBarController *baseTabbarController =  (BaseTabBarController *)self.tabBarController;
    baseTabbarController.tabbarPanel.hidden = NO;
    baseTabbarController.tabBar.hidden = YES;
       [self setBtn];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    BaseTabBarController *baseTabbarController =  (BaseTabBarController *)self.tabBarController;
    baseTabbarController.tabbarPanel.hidden = NO;
    baseTabbarController.tabBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    BaseTabBarController *baseTabbarController =  (BaseTabBarController *)self.tabBarController;
    baseTabbarController.tabbarPanel.hidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.FourBtnView.userInteractionEnabled = YES;
//    _SubImageView.layer.cornerRadius = _SubImageView.bounds.size.height/2; //圆角半径
//    _SubImageView.layer.masksToBounds = YES; //圆角
    _IconeImageView.layer.masksToBounds = YES;
    _IconeImageView.layer.cornerRadius = _IconeImageView.bounds.size.height/2;
    _numberLabelView.layer.masksToBounds = YES;
    _numberLabelView.layer.cornerRadius = _numberLabelView.bounds.size.height / 2;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doTap:)];
     UITapGestureRecognizer *Headtap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(HeadDoTap:)];
    _HeadImageView.userInteractionEnabled = YES;

    
    [_HeadImageView addGestureRecognizer:Headtap];
    _calenderDayLabel.adjustsFontSizeToFitWidth = YES;
    _calenderYearLabel.adjustsFontSizeToFitWidth = YES;
    _calenderMonthLabel.adjustsFontSizeToFitWidth = YES;
    _markedWordsLabel.adjustsFontSizeToFitWidth = YES;
    _TakeTurnsWordsLabel.adjustsFontSizeToFitWidth = YES;
   
    // 允许用户交互
    _SubImageView.userInteractionEnabled = YES;
    _subView.userInteractionEnabled = YES;
    [_SubImageView addGestureRecognizer:tap];
    [_subView addGestureRecognizer:tap];
    [self setupSlideButton];
//    [self setBtn];
    
    NSArray *bgmusicIDS = [SQLManager getDeviceByTypeName:@"背景音乐" andRoomID:self.roomID];
    if ([bgmusicIDS count]>0) {
        self.deviceid = bgmusicIDS[0];
    }

}

-(void)setBtn
{
       NSMutableArray * arr = [[NSMutableArray alloc] init];

    // 1.获得沙盒根路径
    NSString *home = NSHomeDirectory();
    
    // 2.document路径
    NSString *docPath = [home stringByAppendingPathComponent:@"Documents"];
    
    // 3.文件路径
    NSString *filepath = [docPath stringByAppendingPathComponent:@"data.plist"];
    
    // 4.读取数据
    NSArray *data = [NSArray arrayWithContentsOfFile:filepath];
    NSLog(@"%@", data);
    if (data) {
        arr[0] = data[0];
        arr[1] = data[1];
        arr[2] = data[2];
        [_firstBtn setTitle:arr[0] forState:UIControlStateNormal];
        [_ThreeBtn setTitle:arr[2] forState:UIControlStateNormal];
        [_TwoBtn setTitle:arr[1] forState:UIControlStateNormal];
    }
    
  
}

-(void)HeadDoTap:(UITapGestureRecognizer *)tap
{
    TabbarPanel * tabbar = [[TabbarPanel alloc] init];
    if (self.socialView.hidden) {
        self.socialView.hidden = NO;
        _UserNameLabel.hidden = YES;
        _WelcomeLabel.hidden = YES;
       tabbar.pannelSubBgView.hidden = YES;
    }else{
         self.socialView.hidden = YES;
        _UserNameLabel.hidden = NO;
        _WelcomeLabel.hidden = NO;
    }
}
-(void)doTap:(UITapGestureRecognizer *)tap
{
        UIStoryboard *iPhoneStoryBoard  = [UIStoryboard storyboardWithName:@"Family" bundle:nil];
        FamilyHomeViewController *familyVC = [iPhoneStoryBoard instantiateViewControllerWithIdentifier:@"familyHomeVC"];
         familyVC.hidesBottomBarWhenPushed = YES;
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
        _calenderDayLabel.hidden = YES;
        _calenderYearLabel.hidden = YES;
        _calenderMonthLabel.hidden = YES;
        _UserNameLabel.hidden = YES;
        _WelcomeLabel.hidden = YES;
        _HeadImageView.hidden = YES;
        _TakeTurnsWordsLabel.hidden = YES;
        _markedWordsLabel.hidden = YES;
        
    }else{
          self.playerSubView.hidden = YES;
        self.SubImageView.hidden = NO;
        self.BtnView.hidden = NO;
        self.IconeImageView.hidden = NO;
        self.numberLabelView.hidden = NO;
        self.memberFamilyLabel.hidden = NO;
        _calenderDayLabel.hidden = NO;
        _calenderYearLabel.hidden = NO;
        _calenderMonthLabel.hidden = NO;
        _UserNameLabel.hidden = NO;
        _WelcomeLabel.hidden = NO;
        _HeadImageView.hidden = NO;
        _TakeTurnsWordsLabel.hidden = NO;
        _markedWordsLabel.hidden = NO;
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
