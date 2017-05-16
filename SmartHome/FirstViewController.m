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
#import "SceneShortcutsViewController.h"
#import "TabbarPanel.h"

#import <RongIMKit/RongIMKit.h>
#import "ConversationViewController.h"
#import <RBStoryboardLink.h>
#import "IOManager.h"
#import "NowMusicController.h"
#import "UIImageView+WebCache.h"

@interface FirstViewController ()<RCIMReceiveMessageDelegate,HttpDelegate,TcpRecvDelegate>
@property (weak, nonatomic) IBOutlet UIImageView * SubImageView;//首页的日历大圆
@property (weak, nonatomic) IBOutlet UIView * BtnView;//全屋场景的按钮试图
@property (weak, nonatomic) IBOutlet UIImageView * IconeImageView;//提示消息的头像
@property (weak, nonatomic) IBOutlet UILabel * memberFamilyLabel;//家庭成员label
@property (weak, nonatomic) IBOutlet UIImageView * numberLabelView;//未读消息的视图
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;//未读消息的个数

@property (weak, nonatomic) IBOutlet UIBarButtonItem * playerBarBtn;//正在播放的按钮
@property (weak, nonatomic) IBOutlet UIView * FourBtnView;
@property (nonatomic,strong) NSArray * dataArr;
@property (weak, nonatomic) IBOutlet UIImageView * HeadImageView;
@property (weak, nonatomic) IBOutlet UIView * socialView;
@property (weak, nonatomic) IBOutlet UILabel * calenderDayLabel;//日历-天
@property (weak, nonatomic) IBOutlet UILabel * markedWordsLabel;//提示语下
@property (weak, nonatomic) IBOutlet UILabel * calenderMonthLabel;//日历月
@property (weak, nonatomic) IBOutlet UILabel * calenderYearLabel;//日历年
@property (weak, nonatomic) IBOutlet UILabel * UserNameLabel;//用户名的显示
@property (weak, nonatomic) IBOutlet UILabel * WelcomeLabel;
@property (weak, nonatomic) IBOutlet UILabel * TakeTurnsWordsLabel;//提示语上
@property (nonatomic,strong) NSArray * Urldata;
@property (weak, nonatomic) IBOutlet UIButton * firstBtn;
@property (weak, nonatomic) IBOutlet UIButton * TwoBtn;
@property (weak, nonatomic) IBOutlet UIButton * ThreeBtn;
@property (weak, nonatomic) IBOutlet UIView * subView;
@property (weak, nonatomic) IBOutlet UIButton *UnreadButton;//点击未读消息的按钮
@property (nonatomic,strong) NSString * familyNum;
@property (weak, nonatomic) IBOutlet UILabel *chatlabel;//聊天的label
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *DayLabelUpConstraint;//距离上边距的值
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *DayLabelLeftConstraint;//距离左边距的值
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *YLabelrightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *NLabelrightConstraint;
@property (nonatomic,strong) BaseTabBarController *baseTabbarController;
@property (weak, nonatomic) IBOutlet UIView *iconeView;
@property (nonatomic, strong) NSMutableArray *shortcutsArray;

@end

@implementation FirstViewController
-(NSArray *)dataArr
{
    if (_dataArr == nil) {
        _dataArr =[NSArray array];
    }
    return _dataArr;
}

- (void)addNotifications {
    [NC addObserver:self selector:@selector(netWorkDidChangedNotification:) name:@"NetWorkDidChangedNotification" object:nil];
}

- (void)netWorkDidChangedNotification:(NSNotification *)noti {
    [_afNetworkReachabilityManager startMonitoring];//开启网络监视器；
}

- (void)removeNotifications {
    [NC removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _baseTabbarController =  (BaseTabBarController *)self.tabBarController;
    _baseTabbarController.tabbarPanel.hidden = NO;
    _baseTabbarController.tabBar.hidden = YES;
    int unread = [[RCIMClient sharedRCIMClient] getTotalUnreadCount];
    self.numberLabel.text = [NSString stringWithFormat:@"%d" ,unread];
    [self getScenesFromPlist];
 
    NSArray  *paths  =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *docDir = [paths objectAtIndex:0];
    NSString *filePath = [docDir stringByAppendingPathComponent:@"Title.plist"];
    NSString *filePath1 = [docDir stringByAppendingPathComponent:@"Detail.plist"];
    NSArray * TitleArray = [[NSArray alloc] initWithContentsOfFile:filePath];
    NSArray * DetailArray = [[NSArray alloc] initWithContentsOfFile:filePath1];
    NSMutableSet *titleSet = [[NSMutableSet alloc] init];
    NSMutableSet *DetailSet = [[NSMutableSet alloc] init];
    if (TitleArray.count!=0) {
        while ([titleSet count] < 1) {
            int r = arc4random() % [TitleArray count];
            [titleSet addObject:[TitleArray objectAtIndex:r]];
        }
        NSArray * title = [titleSet allObjects];
        self.TakeTurnsWordsLabel.text = title[0];
        
        while ([DetailSet count] < 1) {
            int r = arc4random() % [DetailArray count];
            [DetailSet addObject:[DetailArray objectAtIndex:r]];
        }
        NSArray * detail = [DetailSet allObjects];
        self.TakeTurnsWordsLabel.text = detail[0];
    }

       [self setBtn];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _baseTabbarController =  (BaseTabBarController *)self.tabBarController;
    _baseTabbarController.tabbarPanel.hidden = NO;
    _baseTabbarController.tabBar.hidden = YES;
    if (_afNetworkReachabilityManager.reachableViaWiFi) {
        NSLog(@"WIFI: %d", _afNetworkReachabilityManager.reachableViaWiFi);
    }
    
    if (_afNetworkReachabilityManager.reachableViaWWAN) {
        NSLog(@"WWAN: %d", _afNetworkReachabilityManager.reachableViaWWAN);
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (_nowMusicController) {
        [_nowMusicController.view removeFromSuperview];
        _nowMusicController = nil;
    }
    
    _baseTabbarController =  (BaseTabBarController *)self.tabBarController;
    _baseTabbarController.tabbarPanel.hidden = YES;
    
    NSInteger status = _afNetworkReachabilityManager.networkReachabilityStatus;
    NSLog(@"NetworkReachabilityStatus: %ld", (long)status);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addNotifications];
    if ([[UD objectForKey:@"HostID"] intValue] == 258) { //九号大院
        SocketManager *sock = [SocketManager defaultManager];
        [sock connectTcp];
        sock.delegate = self;
    }else{
        [self connect];
    }
    
    [self setupNaviBar];
    [self showNetStateView];
    //开启网络状况监听器
    
    [self setUIMessage];
    [self chatConnect];
    [self getScenesFromPlist];
   
}

-(void)setUIMessage
{
    self.FourBtnView.userInteractionEnabled = YES;
    _IconeImageView.layer.masksToBounds = YES;
    _IconeImageView.layer.cornerRadius = _IconeImageView.bounds.size.height/2;
    _numberLabel.layer.masksToBounds = YES;
    _numberLabel.layer.cornerRadius = _numberLabelView.bounds.size.height / 2;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doTap:)];
    UITapGestureRecognizer *Headtap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(HeadDoTap:)];
    _HeadImageView.userInteractionEnabled = YES;
    _familyNum = [[NSUserDefaults standardUserDefaults] objectForKey:@"familyNum"];
    self.memberFamilyLabel.text = [NSString stringWithFormat:@"家庭成员（%@）",_familyNum];
    self.UserNameLabel.text = [NSString stringWithFormat:@"Hi! %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"Account"]];
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
    
    
    NSArray *bgmusicIDS = [SQLManager getDeviceByTypeName:@"背景音乐" andRoomID:self.roomID];
    if ([bgmusicIDS count]>0) {
        self.deviceid = bgmusicIDS[0];
    }
    
    self.iconeView.userInteractionEnabled = YES;
    UITapGestureRecognizer *iconeTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTap:)];//点击进入聊天页面
    [self.iconeView addGestureRecognizer:iconeTap];
    //获取系统时间
    NSDate * senddate=[NSDate date];
    
    NSDateFormatter *dateformatter=[[NSDateFormatter alloc] init];
    
    [dateformatter setDateFormat:@"HH:mm"];
    
    NSString * locationString=[dateformatter stringFromDate:senddate];
    
    NSLog(@"-------%@",locationString);
    NSCalendar * cal=[NSCalendar currentCalendar];
    NSUInteger unitFlags=NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit;
    NSDateComponents * conponent= [cal components:unitFlags fromDate:senddate];
    NSInteger year=[conponent year];
    NSInteger month=[conponent month];
    if (month == 1) {
        _calenderMonthLabel.text = @"January";
    }if (month == 2) {
        _calenderMonthLabel.text = @"February";
    }if (month == 3) {
        _calenderMonthLabel.text = @"March";
    }if (month == 4) {
        _calenderMonthLabel.text = @"April";
    }if (month == 5) {
        _calenderMonthLabel.text = @"May";
    }if (month == 6) {
        _calenderMonthLabel.text = @"June";
    }if (month == 7) {
        _calenderMonthLabel.text = @"July";
    }if (month == 8) {
        _calenderMonthLabel.text = @"August";
    }if (month == 9) {
        _calenderMonthLabel.text = @"September";
    }if (month == 10) {
        _calenderMonthLabel.text = @"October";
    }if (month == 11) {
        _calenderMonthLabel.text = @"November";
    }if (month == 12) {
        _calenderMonthLabel.text = @"December";
    }
    NSInteger day=[conponent day];
    _calenderYearLabel.text = [NSString stringWithFormat:@"%ld",year];
    if (([UIScreen mainScreen].bounds.size.height == 568.0)) {
        _DayLabelUpConstraint.constant = -10;
        _DayLabelLeftConstraint.constant = -5;
        _YLabelrightConstraint.constant = 0;
        _NLabelrightConstraint.constant = 0;
        _calenderDayLabel.font = [UIFont systemFontOfSize:70];
    }if (([UIScreen mainScreen].bounds.size.height == 667.0)) {
        _calenderDayLabel.font = [UIFont systemFontOfSize:113];
    }
    _calenderDayLabel.text = [NSString stringWithFormat:@"%ld",day];

}

- (void)connect
{
    SocketManager *sock = [SocketManager defaultManager];
    if ([[UD objectForKey:@"HostID"] intValue] > 0x8000) {
        [sock connectUDP:[IOManager udpPort]];
    }else{
        [sock connectTcp];
    }
    sock.delegate = self;
}

-(void)actionTap:(UIGestureRecognizer *)tap
{
    [self setRCIM];
}
//处理连接改变后的情况
- (void)updateInterfaceWithReachability
{
    __block FirstViewController  * FirstBlockSelf = self;
    
    _afNetworkReachabilityManager = [AFNetworkReachabilityManager sharedManager];
    
    [_afNetworkReachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        DeviceInfo *info = [DeviceInfo defaultManager];
        if(status == AFNetworkReachabilityStatusReachableViaWWAN) //手机自带网络
        {
            if (info.connectState == outDoor) {
                [FirstBlockSelf setNetState:netState_outDoor_4G];
                FirstBlockSelf.SubImageView.image = [UIImage imageNamed:@"circular"];
                [FirstBlockSelf.baseTabbarController.tabbarPanel.sliderBtn setBackgroundImage:[UIImage imageNamed:@"Scene-selected"] forState:UIControlStateNormal];
                NSLog(@"外出模式-4G");
                
            }else if (info.connectState == atHome){
                [FirstBlockSelf setNetState:netState_atHome_4G];
                FirstBlockSelf.SubImageView.image = [UIImage imageNamed:@"circular"];
                [FirstBlockSelf.baseTabbarController.tabbarPanel.sliderBtn setBackgroundImage:[UIImage imageNamed:@"Scene-selected"] forState:UIControlStateNormal];
                NSLog(@"在家模式-4G");
                
            }else if (info.connectState == offLine) {
                [FirstBlockSelf setNetState:netState_notConnect];
                NSLog(@"离线模式");
               FirstBlockSelf.SubImageView.image = [UIImage imageNamed:@"UNcircular"];
              [FirstBlockSelf.baseTabbarController.tabbarPanel.sliderBtn setBackgroundImage:[UIImage imageNamed:@"slider"] forState:UIControlStateNormal];
                
            }
        }
        else if(status == AFNetworkReachabilityStatusReachableViaWiFi) //WIFI
        {
            if (info.connectState == atHome) {
                [FirstBlockSelf setNetState:netState_atHome_WIFI];
                FirstBlockSelf.SubImageView.image = [UIImage imageNamed:@"circular"];
                [FirstBlockSelf.baseTabbarController.tabbarPanel.sliderBtn setBackgroundImage:[UIImage imageNamed:@"Scene-selected"] forState:UIControlStateNormal];
                NSLog(@"在家模式-WIFI");
                
                
            }else if (info.connectState == outDoor){
                [FirstBlockSelf setNetState:netState_outDoor_WIFI];
                FirstBlockSelf.SubImageView.image = [UIImage imageNamed:@"circular"];
                [FirstBlockSelf.baseTabbarController.tabbarPanel.sliderBtn setBackgroundImage:[UIImage imageNamed:@"Scene-selected"] forState:UIControlStateNormal];
                NSLog(@"外出模式-WIFI");
                
            }else if (info.connectState == offLine) {
                [FirstBlockSelf setNetState:netState_notConnect];
                 FirstBlockSelf.SubImageView.image = [UIImage imageNamed:@"UNcircular"];
                 [FirstBlockSelf.baseTabbarController.tabbarPanel.sliderBtn setBackgroundImage:[UIImage imageNamed:@"slider"] forState:UIControlStateNormal];
                NSLog(@"离线模式");
                
                
            }
        }else if(status == AFNetworkReachabilityStatusNotReachable){ //没有网络(断网)
            [FirstBlockSelf setNetState:netState_notConnect];
             FirstBlockSelf.SubImageView.image = [UIImage imageNamed:@"UNcircular"];
             [FirstBlockSelf.baseTabbarController.tabbarPanel.sliderBtn setBackgroundImage:[UIImage imageNamed:@"slider"] forState:UIControlStateNormal];
            NSLog(@"离线模式");
            
        }else if (status == AFNetworkReachabilityStatusUnknown) { //未知网络
            [FirstBlockSelf setNetState:netState_notConnect];
            FirstBlockSelf.SubImageView.image = [UIImage imageNamed:@"UNcircular"];
             [FirstBlockSelf.baseTabbarController.tabbarPanel.sliderBtn setBackgroundImage:[UIImage imageNamed:@"slider"] forState:UIControlStateNormal];
            
        }
    }];
    
    [_afNetworkReachabilityManager startMonitoring];//开启网络监视器；
    
}
-(void) chatConnect
{
    NSString *token = [UD objectForKey:@"rctoken"];
    [[RCIM sharedRCIM] connectWithToken:token success:^(NSString *userId) {
        NSLog(@"登陆成功。当前登录的用户ID：%@", userId);
        [RCIM sharedRCIM].receiveMessageDelegate=self;
    } error:nil tokenIncorrect:nil];
}

- (void)onRCIMReceiveMessage:(RCMessage *)message left:(int)left
{
    NSString *nickname = [SQLManager queryChat:message.senderUserId][0];
    NSString *protrait = [SQLManager queryChat:message.senderUserId][1];
    int unread = [[RCIMClient sharedRCIMClient] getTotalUnreadCount];
    NSString *tip=@"您有新消息";
    if ([message.objectName isEqualToString:RCTextMessageTypeIdentifier]) {
        tip = message.content.conversationDigest;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self.chatlabel.text =[NSString stringWithFormat:@"%@ : %@" , nickname, tip];
        self.numberLabel.text = [NSString stringWithFormat:@"%d" ,unread<0?0:unread];
        [self.IconeImageView sd_setImageWithURL:[NSURL URLWithString:protrait] placeholderImage:[UIImage imageNamed:@"logo"] options:SDWebImageRetryFailed];
    });

}

- (void)getScenesFromPlist
{
    _shortcutsArray = [[NSMutableArray alloc] init];
    NSString *shortcutsPath = [[IOManager sceneShortcutsPath] stringByAppendingPathComponent:@"sceneShortcuts.plist"];
    NSDictionary *dictionary = [[NSDictionary alloc] initWithContentsOfFile:shortcutsPath];
    if (dictionary) {
        NSArray *scenesArray = dictionary[@"Scenes"];
        if (scenesArray && [scenesArray isKindOfClass:[NSArray class]]) {
            for (NSDictionary *scene in scenesArray) {
                if ([scene isKindOfClass:[NSDictionary class]]) {
                    Scene *info = [[Scene alloc] init];
                    info.sceneID = [scene[@"sceneID"] intValue];
                    info.sceneName = scene[@"sceneName"];
                    info.roomID = [scene[@"roomID"] integerValue];
                    info.roomName = scene[@"roomName"];
                    
                    [_shortcutsArray addObject:info];
                }
            }
        }
    }
}

-(void)setBtn
{
    
    _firstBtn.selected = !_firstBtn.selected;
    _TwoBtn.selected = !_TwoBtn.selected;
    _ThreeBtn.selected = !_ThreeBtn.selected;
    _TwoBtn.titleLabel.font = [UIFont systemFontOfSize:10];
    _ThreeBtn.titleLabel.font = [UIFont systemFontOfSize:10];
    _firstBtn.titleLabel.font = [UIFont systemFontOfSize:10];
    if (_shortcutsArray.count != 0) {
        if (_shortcutsArray.count == 1) {
            Scene * info = _shortcutsArray[0];
            [_firstBtn setTitle:info.sceneName forState:UIControlStateNormal];
            _firstBtn.titleLabel.font = [UIFont systemFontOfSize:10];
            _firstBtn.hidden = NO;
            _TwoBtn.hidden = YES;
            [_ThreeBtn setTitle:@"" forState:UIControlStateNormal];
            [_ThreeBtn setBackgroundImage:[UIImage imageNamed:@"circular4"] forState:UIControlStateNormal];
//          _ThreeBtn.hidden  = YES;
            _ThreeBtn.userInteractionEnabled = YES;
            
        }if(_shortcutsArray.count == 2) {
            Scene * info1 = _shortcutsArray[0];
            Scene * info2 = _shortcutsArray[1];
            [_firstBtn setTitle:info1.sceneName forState:UIControlStateNormal];
            [_TwoBtn setTitle:info2.sceneName forState:UIControlStateNormal];
            _firstBtn.hidden = NO;
            _TwoBtn.hidden = NO;
            [_ThreeBtn setTitle:@"" forState:UIControlStateNormal];
            [_ThreeBtn setBackgroundImage:[UIImage imageNamed:@"circular4"] forState:UIControlStateNormal];
//           _ThreeBtn.hidden = YES;
            _ThreeBtn.userInteractionEnabled = YES;
        }
        if (_shortcutsArray.count == 3) {
            Scene * info1 = _shortcutsArray[0];
            Scene * info2 = _shortcutsArray[1];
            Scene * info3 = _shortcutsArray[2];
            [_firstBtn setTitle:info1.sceneName forState:UIControlStateNormal];
            [_TwoBtn setTitle:info2.sceneName forState:UIControlStateNormal];
            [_ThreeBtn setTitle:info3.sceneName forState:UIControlStateNormal];
            [_ThreeBtn setBackgroundImage:[UIImage imageNamed:@"circular3"] forState:UIControlStateNormal];
            _firstBtn.hidden = NO;
            _TwoBtn.hidden = NO;
            _ThreeBtn.hidden = NO;
        }
    }else{
        _ThreeBtn.center = CGPointMake(self.view.center.x, self.view.center.y);
        [_ThreeBtn setBackgroundImage:[UIImage imageNamed:@"circular4"] forState:UIControlStateNormal];
        [_ThreeBtn setTitle:@"" forState:UIControlStateNormal];
        _firstBtn.hidden = YES;
        _TwoBtn.hidden = YES;
        _ThreeBtn.hidden = YES;
        
    }
}

//社交平台的弹出事件
-(void)HeadDoTap:(UITapGestureRecognizer *)tap
{

    _baseTabbarController.tabbarPanel.hidden = YES;
     if (self.socialView.hidden) {
        self.socialView.hidden = NO;
//        _UserNameLabel.hidden = YES;
//        _WelcomeLabel.hidden = YES;
//         self.chatlabel.text = [NSString stringWithFormat:@"123:%d",_roomID++];
     
     }else{
         self.socialView.hidden = YES;
//        _UserNameLabel.hidden = NO;
//        _WelcomeLabel.hidden = NO;
        _baseTabbarController.tabbarPanel.hidden = NO;
         self.chatlabel.text = @"456";
    }
    
}
//中间大圆点击进入家庭主页
-(void)doTap:(UITapGestureRecognizer *)tap
{
        UIStoryboard *iPhoneStoryBoard  = [UIStoryboard storyboardWithName:@"Family" bundle:nil];
        FamilyHomeViewController *familyVC = [iPhoneStoryBoard instantiateViewControllerWithIdentifier:@"familyHomeVC"];
         familyVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:familyVC animated:YES];

}

- (void)setupNaviBar {
//    [self setNaviBarTitle:[UD objectForKey:@"homename"]]; //设置标题
    _naviMiddletBtn = [[UIButton alloc] init];
    [_naviMiddletBtn setTitle:[UD objectForKey:@"homename"] forState:UIControlStateNormal];
    [_naviMiddletBtn addTarget:self action:@selector(MiddleBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    _naviLeftBtn = [CustomNaviBarView createImgNaviBarBtnByImgNormal:@"clound_white" imgHighlight:@"clound_white" target:self action:@selector(leftBtnClicked:)];
    _naviRightBtn = [CustomNaviBarView createImgNaviBarBtnByImgNormal:@"music_white" imgHighlight:@"music_white" target:self action:@selector(rightBtnClicked:)];
    [self setNaviBarLeftBtn:_naviLeftBtn];
    [self setNaviBarRightBtn:_naviRightBtn];
    [self setNaviMiddletBtn:_naviMiddletBtn];
}
-(void)MiddleBtnClicked:(UIButton *)btn
{
    _naviMiddletBtn.selected = !_naviMiddletBtn.selected;
    if (_naviMiddletBtn.selected) {
        if (_hostListViewController == nil) {
            self.CoverView.hidden = NO;
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            
            _hostListViewController = [storyBoard instantiateViewControllerWithIdentifier:@"HostIDSController"];
            _hostListViewController.delegate = self;
            _hostListViewController.view.center = CGPointMake(self.view.center.x, self.view.center.y + 80);
            [self.view addSubview:_hostListViewController.view];
        }
        
    }else{
        if (_hostListViewController) {
            self.CoverView.hidden = YES;
            [_hostListViewController.view removeFromSuperview];
            _hostListViewController.delegate = nil;
            _hostListViewController = nil;
        }
    }

}

- (void)didSelectHostID {
    if (_hostListViewController) {
        [_hostListViewController.view removeFromSuperview];
        _hostListViewController.delegate = nil;
        _hostListViewController = nil;
    }
}

- (void)setupSlideButton {
    UIButton *menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    menuBtn.frame = CGRectMake(0, 0, 44, 44);
    [menuBtn setImage:[UIImage imageNamed:@"logo"] forState:UIControlStateNormal];
    [menuBtn addTarget:self action:@selector(menuBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menuBtn];
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

- (void)rightBtnClicked:(UIButton *)btn {
    
    UIStoryboard * HomeStoryBoard = [UIStoryboard storyboardWithName:@"Home" bundle:nil];
    
    if (_nowMusicController == nil) {
        _nowMusicController = [HomeStoryBoard instantiateViewControllerWithIdentifier:@"NowMusicController"];
        _nowMusicController.delegate = self;
        [self.view addSubview:_nowMusicController.view];
    }else {
        [_nowMusicController.view removeFromSuperview];
         _nowMusicController = nil;
    }
}

- (void)onBgButtonClicked:(UIButton *)sender {
    if (_nowMusicController) {
        [_nowMusicController.view removeFromSuperview];
        _nowMusicController = nil;
    }
}
//跳转到场景快捷键界面
- (IBAction)SceneShortcutBtn:(id)sender {
    
    self.socialView.hidden = YES;
    UIStoryboard * myInfoStoryBoard = [UIStoryboard storyboardWithName:@"MyInfo" bundle:nil];
    SceneShortcutsViewController * shortcutKeyVC = [myInfoStoryBoard instantiateViewControllerWithIdentifier:@"SceneShortcutsVC"];
    [self.navigationController pushViewController:shortcutKeyVC animated:YES];
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

    
    UIStoryboard * HomeStoryBoard = [UIStoryboard storyboardWithName:@"Home" bundle:nil];
    NowMusicController * nowMusicController = [HomeStoryBoard instantiateViewControllerWithIdentifier:@"NowMusicController"];
    [self.navigationController pushViewController:nowMusicController animated:YES];
    
}

//点击未读消息的事件
- (IBAction)UnreadButton:(id)sender {
    [self setRCIM];
}

//进入聊天页面
-(void)setRCIM
{
    NSString *groupID = [[UD objectForKey:@"HostID"] description];
    NSString *homename = [UD objectForKey:@"homename"];
    
    RCGroup *aGroupInfo = [[RCGroup alloc]initWithGroupId:groupID groupName:homename portraitUri:@""];
    ConversationViewController *_conversationVC = [[ConversationViewController alloc] init];
    _conversationVC.conversationType = ConversationType_GROUP;
    _conversationVC.targetId = aGroupInfo.groupId;
    [_conversationVC setTitle: [NSString stringWithFormat:@"%@",aGroupInfo.groupName]];
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUD];
        [self.navigationController pushViewController:_conversationVC animated:YES];
    });
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{

      self.socialView.hidden = YES;
    _baseTabbarController.tabbarPanel.hidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [self removeNotifications];
}

#pragma mark - TCP recv delegate
- (void)recv:(NSData *)data withTag:(long)tag
{
    [self updateInterfaceWithReachability];
}

@end
