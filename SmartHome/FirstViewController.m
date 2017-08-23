//
//  FirstViewController.m
//  
//
//  Created by zhaona on 2017/3/17.
//
//iphone首页

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
#import "RBStoryboardLink.h"
#import "IOManager.h"
#import "NowMusicController.h"
#import "UIImageView+WebCache.h"
#import "NetStatusManager.h"

@interface FirstViewController ()<RCIMReceiveMessageDelegate,HttpDelegate,TcpRecvDelegate>
@property (weak, nonatomic) IBOutlet UIImageView * SubImageView;//首页的日历大圆
@property (weak, nonatomic) IBOutlet UIView * BtnView;//全屋场景的按钮试图
@property (weak, nonatomic) IBOutlet UIImageView * IconeImageView;//提示消息的头像
@property (weak, nonatomic) IBOutlet UILabel * memberFamilyLabel;//家庭成员label
@property (weak, nonatomic) IBOutlet UIImageView * numberLabelView;//未读消息的视图
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;//未读消息的个数
@property (nonatomic,strong) NSMutableArray * bgmusicIDS;
@property (nonatomic,strong) NSMutableArray * bgmusicIDArr;
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
@property (weak, nonatomic) IBOutlet UIButton *doMessageBtn;//弹出聊天页面的按钮
@property (nonatomic,strong) NSMutableArray * unreadcountArr;
@property (weak, nonatomic) IBOutlet UILabel *ShowHeadImage;//是否有新消息的图标
@property (nonatomic,assign) int sum;

@end

@implementation FirstViewController

-(NSMutableArray *)unreadcountArr
{
    if (!_unreadcountArr) {
        _unreadcountArr = [NSMutableArray array];
    }
    
    return _unreadcountArr;
}
-(NSArray *)dataArr
{
    if (_dataArr == nil) {
        _dataArr =[NSArray array];
    }
    return _dataArr;
}

- (void)addNotifications {
    [NC addObserver:self selector:@selector(netWorkDidChangedNotification:) name:@"NetWorkDidChangedNotification" object:nil];
    [NC addObserver:self selector:@selector(SumNumber:) name:@"SumNumber" object:nil];
    [NC addObserver:self selector:@selector(changeHostRefreshFamilyNumNotification:) name:@"ChangeHostRefreshUINotification" object:nil];//  切换主机，刷新家庭成员数量
    [NC addObserver:self selector:@selector(loginExpiredNotification:) name:@"LoginExpiredNotification" object:nil];//登录过期的通知
}

- (void)loginExpiredNotification:(NSNotification *)noti {
    [UD removeObjectForKey:@"AuthorToken"];
    [UD synchronize];
    [[SocketManager defaultManager] cutOffSocket];
    
    [self gotoLoginViewController];
}

- (void)gotoLoginViewController {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    UIViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"loginNavController"];//进入登录页面
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.window.rootViewController = vc;
    [appDelegate.window makeKeyAndVisible];
}

//  切换主机，刷新家庭成员数量
- (void)changeHostRefreshFamilyNumNotification:(NSNotification *)noti {
    self.memberFamilyLabel.text = [NSString stringWithFormat:@"家庭成员（%@）", [UD objectForKey:@"familyNum"]];
}

- (void)netWorkDidChangedNotification:(NSNotification *)noti {
    [self refreshUI];
}
-(void)SumNumber:(NSNotification *)no
{
    NSString * sumNumber = no.object;
    _sum = [sumNumber intValue];
    
    if (_sum != 0) {
     [self showMassegeLabel];
    }
}
- (void)removeNotifications {
    [NC removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _baseTabbarController =  (BaseTabBarController *)self.tabBarController;
    _baseTabbarController.tabbarPanel.hidden = NO;
    _baseTabbarController.tabBar.hidden = YES;
    int userID = [[UD objectForKey:@"UserID"] intValue];
    _userInfomation = [SQLManager getUserInfo:userID];
    self.UserNameLabel.text = [NSString stringWithFormat:@"Hi! %@",_userInfomation.nickName];
    int unread = [[RCIMClient sharedRCIMClient] getTotalUnreadCount];
    [self addNotifications];
    [_bgmusicIDArr removeAllObjects];
    self.numberLabel.text = [NSString stringWithFormat:@"%d" ,unread<0?0:unread];
    
    if ([self.numberLabel.text isEqualToString:@"0"]) {
        self.ShowHeadImage.hidden = YES;
    }else{
        self.ShowHeadImage.hidden = NO;
        self.ShowHeadImage.text = [NSString stringWithFormat:@"%d" ,unread<0?0:unread];
    }
    [self getScenesFromPlist];
    [self getPlist];
    [self setBtn];
//    [self creatItemID];
    
    _sum = 0;
    for (int i = 0; i < self.unreadcountArr.count; i ++) {
        _sum += [self.unreadcountArr[i] integerValue];
        
    }
    [NC postNotificationName:@"SumNumber" object:[NSString stringWithFormat:@"%d",_sum]];
    SocketManager *sock=[SocketManager defaultManager];
    sock.delegate=self;
    _bgmusicIDS = [[NSMutableArray alloc] init];
    NSArray * roomArr = [SQLManager getAllRoomsInfo];
    for (int i = 0; i < roomArr.count; i ++) {
        Room * roomName = roomArr[i];
        if (![SQLManager isWholeHouse:roomName.rId]) {
            self.deviceid = [SQLManager singleDeviceWithCatalogID:bgmusic byRoom:roomName.rId];
        }
        if (self.deviceid.length != 0) {
            [_bgmusicIDS addObject:self.deviceid];
            //查询设备状态
            NSData *data = [[DeviceInfo defaultManager] query:self.deviceid];
            [sock.socket writeData:data withTimeout:1 tag:1];
            
        }
    }
    
    if (unread>0){
        self.chatlabel.text =[NSString stringWithFormat:@"%@" , @"您有新消息"];
    }else{
        self.chatlabel.text =[NSString stringWithFormat:@"%@" , @"暂无新消息"];
    }
    
 /////////////////////////////////////  Mask View  ////////////////////////////////////////
    NSString *KeyStr = [UD objectForKey:ShowMaskViewHomePageChatBtn];
    if (KeyStr.length <=0) {
        [LoadMaskHelper showMaskWithType:HomePageChatBtn onView:self.tabBarController.view delay:0.5 delegate:self];
    }else {
        NSString *KeyStr = [UD objectForKey:ShowMaskViewHomePageEnterChat];
        if (KeyStr.length <=0) {
            [LoadMaskHelper showMaskWithType:HomePageEnterChat onView:self.tabBarController.view delay:0.5 delegate:self];
        }else {
            NSString *KeyStr = [UD objectForKey:ShowMaskViewHomePageEnterFamily];
            if(KeyStr.length <=0) {
                [LoadMaskHelper showMaskWithType:HomePageEnterFamily onView:self.tabBarController.view delay:0.5 delegate:self];
            }else {
                NSString *KeyStr = [UD objectForKey:ShowMaskViewHomePageScene];
                if(KeyStr.length <=0){
                    [LoadMaskHelper showMaskWithType:HomePageScene onView:self.tabBarController.view delay:0.5 delegate:self];
                }else {
                    NSString *KeyStr = [UD objectForKey:ShowMaskViewHomePageDevice];
                    if(KeyStr.length <=0){
                        [LoadMaskHelper showMaskWithType:HomePageDevice onView:self.tabBarController.view delay:0.5 delegate:self];
                    }else {
                        NSString *KeyStr = [UD objectForKey:ShowMaskViewHomePageCloud];
                        if(KeyStr.length <=0){
                            [LoadMaskHelper showMaskWithType:HomePageCloud onView:self.tabBarController.view delay:0.5 delegate:self];
                        }
                    }
                }
            }
        }
    }
     [self setupNaviBar];
}
-(void)creatItemID
{
    NSString *url = [NSString stringWithFormat:@"%@Cloud/notify.aspx",[IOManager httpAddr]];
    NSString *auothorToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"AuthorToken"];
    if (auothorToken) {
        NSDictionary *dict = @{@"token":auothorToken,@"optype":[NSNumber numberWithInteger:2]};
        HttpManager *http=[HttpManager defaultManager];
        http.tag = 1;
        http.delegate = self;
        [http sendPost:url param:dict];
    }
}


-(void)httpHandler:(id)responseObject tag:(int)tag
{
    [self.unreadcountArr removeAllObjects];
    if (tag == 1) {
        if ([responseObject[@"result"] intValue]==0)
        {
            
            NSArray *dic = responseObject[@"notify_type_list"];
            
            if ([dic isKindOfClass:[NSArray class]]) {
                for(NSDictionary *dicDetail in dic)
                {
                    
                    [self.unreadcountArr addObject:dicDetail[@"unreadcount"]];
                }
            }
        }else{
            [MBProgressHUD showError:responseObject[@"Msg"]];
        }
        
    }
    
}
-(void)getPlist
{
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
        self.markedWordsLabel.text = detail[0];
    }
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
    [self connect];
   _bgmusicIDArr = [[NSMutableArray alloc] init];
    [self showNetStateView];
    [self setUIMessage];
    [self chatConnect];
    [self getScenesFromPlist];
    //[self setBtn];
    
    //开启网络状况监听器
    [self updateInterfaceWithReachability];
}

-(void)setUIMessage
{
    self.FourBtnView.userInteractionEnabled = YES;
    _IconeImageView.layer.masksToBounds = YES;
    _IconeImageView.layer.cornerRadius = _IconeImageView.bounds.size.height/2;
    _numberLabel.layer.masksToBounds = YES;
    _numberLabel.layer.cornerRadius = _numberLabelView.bounds.size.height / 2;
    self.ShowHeadImage.layer.masksToBounds = YES;
    self.ShowHeadImage.layer.cornerRadius = self.ShowHeadImage.width /2;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doTap:)];
    UITapGestureRecognizer *Headtap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(HeadDoTap:)];
    _HeadImageView.userInteractionEnabled = YES;
    _familyNum = [UD objectForKey:@"familyNum"];
    self.memberFamilyLabel.text = [NSString stringWithFormat:@"家庭成员（%@）",_familyNum];
//    self.UserNameLabel.text = [NSString stringWithFormat:@"Hi! %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"Account"]];
   
    [_HeadImageView addGestureRecognizer:Headtap];
    [self.doMessageBtn addTarget:self action:@selector(HeadDoTap:) forControlEvents:UIControlEventTouchUpInside];
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
    NSUInteger unitFlags=NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear;
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
    _calenderYearLabel.text = [NSString stringWithFormat:@"%ld",(long)year];
    if (([UIScreen mainScreen].bounds.size.height == 568.0)) {
        _DayLabelUpConstraint.constant = -10;
        _DayLabelLeftConstraint.constant = -5;
        _YLabelrightConstraint.constant = 0;
        _NLabelrightConstraint.constant = 0;
        _calenderDayLabel.font = [UIFont systemFontOfSize:70];
    }if (([UIScreen mainScreen].bounds.size.height == 667.0)) {
        _calenderDayLabel.font = [UIFont systemFontOfSize:113];
    }
    _calenderDayLabel.text = [NSString stringWithFormat:@"%ld",(long)day];

}

- (void)connect
{
    SocketManager *sock = [SocketManager defaultManager];
    if ([[UD objectForKey:@"HostType"] intValue]) {
        [sock connectUDP:[IOManager C4Port]];
    }else{
        [sock connectUDP:[IOManager crestronPort]];
    }
    sock.delegate = self;
}

-(void)actionTap:(UIGestureRecognizer *)tap
{
    [self setRCIM];
}

- (void)refreshUI {
    DeviceInfo *info = [DeviceInfo defaultManager];
    if([[AFNetworkReachabilityManager sharedManager] isReachableViaWWAN]) { //手机自带网络
        if (info.connectState == offLine) {
            [self setNetState:netState_notConnect];
            self.SubImageView.image = [UIImage imageNamed:@"UNcircular"];
            [self.baseTabbarController.tabbarPanel.sliderBtn setBackgroundImage:[UIImage  imageNamed:@"slider"] forState:UIControlStateNormal];
            NSLog(@"离线模式");
        }else{
            [self setNetState:netState_outDoor_4G];
            self.SubImageView.image = [UIImage imageNamed:@"circular"];
            [self.baseTabbarController.tabbarPanel.sliderBtn setBackgroundImage:[UIImage imageNamed:@"Scene-selected"] forState:UIControlStateNormal];
            NSLog(@"外出模式-4G");
        }
    }else if ([[AFNetworkReachabilityManager sharedManager] isReachableViaWiFi]) { //WIFI
        
        if (info.connectState == atHome) {
            [self setNetState:netState_atHome_WIFI];
            self.SubImageView.image = [UIImage imageNamed:@"circular"];
            [self.baseTabbarController.tabbarPanel.sliderBtn setBackgroundImage:[UIImage imageNamed:@"Scene-selected"] forState:UIControlStateNormal];
            NSLog(@"在家模式-WIFI");
            
            
        }else if (info.connectState == outDoor){
            [self setNetState:netState_outDoor_WIFI];
            self.SubImageView.image = [UIImage imageNamed:@"circular"];
            [self.baseTabbarController.tabbarPanel.sliderBtn setBackgroundImage:[UIImage imageNamed:@"Scene-selected"] forState:UIControlStateNormal];
            NSLog(@"外出模式-WIFI");
            
        }else if (info.connectState == offLine) {
            [self setNetState:netState_notConnect];
            self.SubImageView.image = [UIImage imageNamed:@"UNcircular"];
            [self.baseTabbarController.tabbarPanel.sliderBtn setBackgroundImage:[UIImage imageNamed:@"slider"] forState:UIControlStateNormal];
            NSLog(@"离线模式");
        }
        
    }else {  //没有网络(断网)
        [self setNetState:netState_notConnect];
        self.SubImageView.image = [UIImage imageNamed:@"UNcircular"];
        [self.baseTabbarController.tabbarPanel.sliderBtn setBackgroundImage:[UIImage imageNamed:@"slider"] forState:UIControlStateNormal];
        NSLog(@"离线模式");
    }
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
            if (info.connectState == offLine) {
                [FirstBlockSelf setNetState:netState_notConnect];
                FirstBlockSelf.SubImageView.image = [UIImage imageNamed:@"UNcircular"];
                [FirstBlockSelf.baseTabbarController.tabbarPanel.sliderBtn setBackgroundImage:[UIImage imageNamed:@"slider"] forState:UIControlStateNormal];
                NSLog(@"离线模式");
                
            }else{
                [FirstBlockSelf setNetState:netState_outDoor_4G];
                FirstBlockSelf.SubImageView.image = [UIImage imageNamed:@"circular"];
                [FirstBlockSelf.baseTabbarController.tabbarPanel.sliderBtn setBackgroundImage:[UIImage imageNamed:@"Scene-selected"] forState:UIControlStateNormal];
                NSLog(@"外出模式-4G");
                
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
        if ([[DeviceInfo defaultManager] pushToken]) {
            [[RCIMClient sharedRCIMClient] setDeviceToken:[[DeviceInfo defaultManager] pushToken]];
        }
    } error:nil tokenIncorrect:nil];
}

- (void)onRCIMReceiveMessage:(RCMessage *)message left:(int)left
{
    NSArray *info = [SQLManager queryChat:message.senderUserId];
    NSString *nickname = [info firstObject];
    NSString *protrait = [info lastObject];
    int unread = [[RCIMClient sharedRCIMClient] getTotalUnreadCount];
    NSString *tip=@"您有新消息";
    if ([message.objectName isEqualToString:RCTextMessageTypeIdentifier]) {
        tip = message.content.conversationDigest;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self.chatlabel.text =[NSString stringWithFormat:@"%@ : %@" , nickname, tip];
        self.numberLabel.text = [NSString stringWithFormat:@"%d" ,unread<0?0:unread];
        if ([self.numberLabel.text isEqualToString:@"0"]) {
            self.ShowHeadImage.hidden = YES;
        }else{
            self.ShowHeadImage.hidden = NO;
            self.ShowHeadImage.text = [NSString stringWithFormat:@"%d" ,unread<0?0:unread];
        }
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
                    info.roomID = [scene[@"roomID"] intValue];
                    info.roomName = scene[@"roomName"];
                    
                    [_shortcutsArray addObject:info];
                }
            }
        }
    }
}

-(void)setBtn
{
      _firstBtn.titleLabel.font = [UIFont systemFontOfSize:10];
      _TwoBtn.titleLabel.font = [UIFont systemFontOfSize:10];
      _ThreeBtn.titleLabel.font = [UIFont systemFontOfSize:10];
    if (_shortcutsArray.count != 0) {
        if (_shortcutsArray.count == 1) {
            _info1 = _shortcutsArray[0];
            [_firstBtn setTitle:_info1.sceneName forState:UIControlStateNormal];
            _firstBtn.titleLabel.font = [UIFont systemFontOfSize:10];
            _firstBtn.hidden = NO;
            _TwoBtn.hidden = YES;
            _ThreeBtn.hidden = NO;
            [_ThreeBtn setTitle:@"" forState:UIControlStateNormal];
            [_ThreeBtn setBackgroundImage:[UIImage imageNamed:@"circular4"] forState:UIControlStateNormal];
            self.threeBtnLeadingConstraint.constant = 30;
        }if(_shortcutsArray.count == 2) {
            _info1 = _shortcutsArray[0];
            _info2 = _shortcutsArray[1];
            [_firstBtn setTitle:_info1.sceneName forState:UIControlStateNormal];
            [_TwoBtn setTitle:_info2.sceneName forState:UIControlStateNormal];
            _firstBtn.hidden = NO;
            _TwoBtn.hidden = NO;
            _ThreeBtn.hidden = NO;
            [_ThreeBtn setTitle:@"" forState:UIControlStateNormal];
            [_ThreeBtn setBackgroundImage:[UIImage imageNamed:@"circular4"] forState:UIControlStateNormal];
            self.threeBtnLeadingConstraint.constant = 30;
        
        }if (_shortcutsArray.count == 3) {
            _info1 = _shortcutsArray[0];
            _info2 = _shortcutsArray[1];
             _info3 = _shortcutsArray[2];
            [_firstBtn setTitle:_info1.sceneName forState:UIControlStateNormal];
            [_TwoBtn setTitle:_info2.sceneName forState:UIControlStateNormal];
            [_ThreeBtn setTitle:_info3.sceneName forState:UIControlStateNormal];
            [_ThreeBtn setBackgroundImage:[UIImage imageNamed:@"circular3"] forState:UIControlStateNormal];
            _firstBtn.hidden = NO;
            _TwoBtn.hidden = NO;
            _ThreeBtn.hidden = NO;
            self.threeBtnLeadingConstraint.constant = 30;
        }
    }else{
        [_ThreeBtn setBackgroundImage:[UIImage imageNamed:@"circular4"] forState:UIControlStateNormal];
        [_ThreeBtn setTitle:@"" forState:UIControlStateNormal];
        _firstBtn.hidden = YES;
        _TwoBtn.hidden = YES;
        _ThreeBtn.hidden = NO;
        self.threeBtnLeadingConstraint.constant = -45;
    }
}

//社交平台的弹出事件
-(void)HeadDoTap:(UITapGestureRecognizer *)tap
{
         _baseTabbarController.tabbarPanel.hidden = YES;
     if (self.socialView.hidden) {
        self.socialView.hidden = NO;
     }else{
         self.socialView.hidden = YES;
        _baseTabbarController.tabbarPanel.hidden = NO;
         self.chatlabel.text = @"暂无新消息";
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
    [self setNaviBarTitle:[UD objectForKey:@"homename"]]; //设置标题
    
    _naviMiddletBtn = [[UIButton alloc] init];
//    [_naviMiddletBtn setTitle:[UD objectForKey:@"homename"] forState:UIControlStateNormal];
//    [_naviMiddletBtn addTarget:self action:@selector(MiddleBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    _naviLeftBtn = [CustomNaviBarView createImgNaviBarBtnByImgNormal:@"clound_white" imgHighlight:@"clound_white" target:self action:@selector(leftBtnClicked:)];
    
    NSString *music_icon = nil;
    NSInteger isPlaying = [[UD objectForKey:@"IsPlaying"] integerValue];
    if (isPlaying) {
        music_icon = @"Ipad-NowMusic-red";
    }else {
        music_icon = @"Ipad-NowMusic";
    }
    
    _naviRightBtn = [CustomNaviBarView createImgNaviBarBtnByImgNormal:music_icon imgHighlight:music_icon target:self action:@selector(rightBtnClicked:)];
    if (isPlaying) {
        UIImageView * imageView = _naviRightBtn.imageView ;
        
        imageView.animationImages = [NSArray arrayWithObjects:
                                     [UIImage imageNamed:@"Ipad-NowMusic-red2"],
                                     [UIImage imageNamed:@"Ipad-NowMusic-red3"],
                                     [UIImage imageNamed:@"Ipad-NowMusic-red4"],
                                     [UIImage imageNamed:@"Ipad-NowMusic-red5"],
                                     [UIImage imageNamed:@"Ipad-NowMusic-red6"],
                                     [UIImage imageNamed:@"Ipad-NowMusic-red7"],
                                     [UIImage imageNamed:@"Ipad-NowMusic-red8"],
                                     [UIImage imageNamed:@"Ipad-NowMusic-red9"],
                                     [UIImage imageNamed:@"Ipad-NowMusic-red10"],
                                     [UIImage imageNamed:@"Ipad-NowMusic-red11"],
                                     [UIImage imageNamed:@"Ipad-NowMusic-red12"],
                                     [UIImage imageNamed:@"Ipad-NowMusic-red13"],
                                     [UIImage imageNamed:@"Ipad-NowMusic-red14"],
                                     [UIImage imageNamed:@"Ipad-NowMusic-red15"],
                                     [UIImage imageNamed:@"Ipad-NowMusic-red16"],
                                     [UIImage imageNamed:@"Ipad-NowMusic-red17"],
                                     [UIImage imageNamed:@"Ipad-NowMusic-red18"],
                                     [UIImage imageNamed:@"Ipad-NowMusic-red19"],
                                     
                                     nil];
        
        //设置动画总时间
        imageView.animationDuration = 2.0;
        //设置重复次数，0表示无限
        imageView.animationRepeatCount = 0;
        //开始动画
        if (! imageView.isAnimating) {
            [imageView startAnimating];
        }
    }
    
    [self setNaviBarLeftBtn:_naviLeftBtn];
    [self setNaviBarRightBtn:_naviRightBtn];
    [self setNaviMiddletBtn:_naviMiddletBtn];
}
-(void)MiddleBtnClicked:(UIButton *)btn
{
   /* _naviMiddletBtn.selected = !_naviMiddletBtn.selected;
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
    }*/

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
    
    self.socialView.hidden = YES;
    _baseTabbarController.tabbarPanel.hidden = NO;
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
    
    NSInteger isPlaying = [[UD objectForKey:@"IsPlaying"] integerValue];
    if (isPlaying == 0) {
        [MBProgressHUD showError:@"没有正在播放的设备"];
        return;
    }
    
    UIStoryboard * HomeStoryBoard = [UIStoryboard storyboardWithName:@"Home" bundle:nil];
    
    
    if (_nowMusicController == nil) {
        _nowMusicController = [HomeStoryBoard instantiateViewControllerWithIdentifier:@"NowMusicController"];
        _nowMusicController.delegate = self;
        _nowMusicController.bgmusicIDarray = _bgmusicIDArr;
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
    
    self.socialView.hidden = YES;
    _baseTabbarController.tabbarPanel.hidden = NO;
    
    [self setRCIM];
}

//进入聊天页面
-(void)setRCIM
{
    NSString *groupID = [[UD objectForKey:@"HostID"] description];
    NSString *homename = [UD objectForKey:@"homename"];
    
    RCGroup *aGroupInfo = [[RCGroup alloc]initWithGroupId:groupID groupName:homename portraitUri:@""];
    ConversationViewController *conversationVC = [[ConversationViewController alloc] init];
    conversationVC.conversationType = ConversationType_GROUP;
    conversationVC.targetId = aGroupInfo.groupId;
    [conversationVC setTitle: [NSString stringWithFormat:@"%@",aGroupInfo.groupName]];
    
    RCUserInfo *user = [[RCIM sharedRCIM] currentUserInfo];
    NSArray *info = [SQLManager queryChat:user.userId];
    NSString *nickname = [info firstObject];
    NSString *protrait = [info lastObject];

    [[RCIM sharedRCIM] refreshUserInfoCache:[[RCUserInfo alloc] initWithUserId:user.userId name:nickname portrait:protrait] withUserId:user.userId];
    [self.navigationController pushViewController:conversationVC animated:YES];
}

- (IBAction)FirstBtn:(id)sender {
     _firstBtn.selected = !_firstBtn.selected;
    if (_firstBtn.selected) {
        [_firstBtn setBackgroundImage:[UIImage imageNamed:@"circular2"] forState:UIControlStateSelected];
        [_firstBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [[SceneManager defaultManager] startScene:_info1.sceneID];
        [SQLManager updateSceneStatus:1 sceneID:_info1.sceneID];//更新数据库
    }else{
        [_firstBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_firstBtn setBackgroundImage:[UIImage imageNamed:@"circular3"] forState:UIControlStateNormal];
        [[SceneManager defaultManager] poweroffAllDevice:_info1.sceneID];
        [SQLManager updateSceneStatus:0 sceneID:_info1.sceneID];//更新数据库
    }
}

- (IBAction)TwoBtn:(id)sender {
     _TwoBtn.selected = !_TwoBtn.selected;
    if (_TwoBtn.selected) {
        [_TwoBtn setBackgroundImage:[UIImage imageNamed:@"circular2"] forState:UIControlStateSelected];
        [_TwoBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [[SceneManager defaultManager] startScene:_info2.sceneID];
        [SQLManager updateSceneStatus:1 sceneID:_info2.sceneID];//更新数据库
    }else{
        [_TwoBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_TwoBtn setBackgroundImage:[UIImage imageNamed:@"circular3"] forState:UIControlStateNormal];
        [[SceneManager defaultManager] poweroffAllDevice:_info2.sceneID];
        [SQLManager updateSceneStatus:0 sceneID:_info2.sceneID];//更新数据库
    }
    
}
- (IBAction)ThreeBtn:(id)sender {
      _ThreeBtn.selected = !_ThreeBtn.selected;
    if ([_ThreeBtn.currentTitle isEqualToString:@""]) {
        self.socialView.hidden = YES;
        UIStoryboard * myInfoStoryBoard = [UIStoryboard storyboardWithName:@"MyInfo" bundle:nil];
        SceneShortcutsViewController * shortcutKeyVC = [myInfoStoryBoard instantiateViewControllerWithIdentifier:@"SceneShortcutsVC"];
        [self.navigationController pushViewController:shortcutKeyVC animated:YES];
    }else{
        if (_ThreeBtn.selected) {
            [_ThreeBtn setBackgroundImage:[UIImage imageNamed:@"circular2"] forState:UIControlStateSelected];
            [_ThreeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [[SceneManager defaultManager] startScene:_info3.sceneID];
            [SQLManager updateSceneStatus:1 sceneID:_info3.sceneID];//更新数据库
        }else{
             [_ThreeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [_ThreeBtn setBackgroundImage:[UIImage imageNamed:@"circular3"] forState:UIControlStateNormal];
            [[SceneManager defaultManager] poweroffAllDevice:_info3.sceneID];
            [SQLManager updateSceneStatus:0 sceneID:_info3.sceneID];//更新数据库
        }
    }
    
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
-(void)recv:(NSData *)data withTag:(long)tag
{
    Proto proto=protocolFromData(data);
    
    if (CFSwapInt16BigToHost(proto.masterID) != [[DeviceInfo defaultManager] masterID]) {
        return;
    }
    for (int i = 0; i <self.bgmusicIDS.count; i ++) {
        if (proto.cmd==0x01) {
            NSString *devID=[SQLManager getDeviceIDByENumber:CFSwapInt16BigToHost(proto.deviceID)];
            if ([devID intValue]==[self.bgmusicIDS[i] intValue]) {
                if (proto.action.state == PROTOCOL_VOLUME) {
                    NSLog(@"有音量");
                }if (proto.action.state == PROTOCOL_ON) {
                    NSLog(@"开启状态");
                    [IOManager writeUserdefault:@"1" forKey:@"IsPlaying"];
                    
                     [_bgmusicIDArr addObject:devID];
                    
                }if (proto.action.state == PROTOCOL_OFF) {
                    NSLog(@"关闭状态");
                    [IOManager writeUserdefault:@"0" forKey:@"IsPlaying"];
                }
            }
        }
    }
      [self setupNaviBar];
}


#pragma mark - SingleMaskViewDelegate
- (void)onNextButtonClicked:(UIButton *)btn pageType:(PageTye)pageType {
    if (pageType == HomePageChatBtn) {
        _baseTabbarController.tabbarPanel.hidden = YES;
        if (self.socialView.hidden) {
            self.socialView.hidden = NO;
        }else{
            self.socialView.hidden = YES;
            _baseTabbarController.tabbarPanel.hidden = NO;
            self.chatlabel.text = @"456";
        }
        
        [LoadMaskHelper showMaskWithType:HomePageEnterChat onView:self.tabBarController.view delay:0.5 delegate:self];
    }else if (pageType == HomePageEnterChat) {
        self.socialView.hidden = YES;
        _baseTabbarController.tabbarPanel.hidden = NO;
        
        [self setRCIM];
    }else if (pageType == HomePageEnterFamily) {
        UIStoryboard *iPhoneStoryBoard  = [UIStoryboard storyboardWithName:@"Family" bundle:nil];
        FamilyHomeViewController *familyVC = [iPhoneStoryBoard instantiateViewControllerWithIdentifier:@"familyHomeVC"];
        familyVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:familyVC animated:YES];
        
    }else if (pageType == HomePageScene) {
        [NC postNotificationName:@"TabbarPanelClickedNotification" object:nil];
        
    }else if (pageType == HomePageDevice) {
        [NC postNotificationName:@"TabbarPanelClickedNotificationDevice" object:nil];
        
    }else if (pageType == HomePageCloud) {
        self.socialView.hidden = YES;
        _baseTabbarController.tabbarPanel.hidden = NO;
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        if (appDelegate.LeftSlideVC.closed)
        {
            [appDelegate.LeftSlideVC openLeftView];
        }
        else
        {
            [appDelegate.LeftSlideVC closeLeftView];
        }
        
        [NC postNotificationName:@"ShowMaskViewNotification" object:nil];
    }
}

- (void)onSkipButtonClicked:(UIButton *)btn pageType:(PageTye)pageType {
    
    if (pageType == HomePageChatBtn || pageType == HomePageEnterChat) {
        [UD setObject:@"haveShownMask" forKey:ShowMaskViewHomePageChatBtn];
        [UD setObject:@"haveShownMask" forKey:ShowMaskViewHomePageEnterChat];
        [UD setObject:@"haveShownMask" forKey:ShowMaskViewChatView];
        [UD synchronize];
        
        [LoadMaskHelper showMaskWithType:HomePageEnterFamily onView:self.tabBarController.view delay:0.5 delegate:self];
        
        return;
    }
    
    if (pageType == HomePageEnterFamily) {
        [UD setObject:@"haveShownMask" forKey:ShowMaskViewFamilyHome];
        [UD setObject:@"haveShownMask" forKey:ShowMaskViewFamilyHomeDetail];
        [UD synchronize];
        
        [LoadMaskHelper showMaskWithType:HomePageScene onView:self.tabBarController.view delay:0.5 delegate:self];
        return;
    }
    
    if (pageType == HomePageScene) {
        [UD setObject:@"haveShownMask" forKey:ShowMaskViewSceneAdd];
        [UD setObject:@"haveShownMask" forKey:ShowMaskViewScene];
        [UD setObject:@"haveShownMask" forKey:ShowMaskViewSceneDetail];
        [UD synchronize];
        
        [LoadMaskHelper showMaskWithType:HomePageDevice onView:self.tabBarController.view delay:0.5 delegate:self];
        return;
    }
    
    if (pageType == HomePageDevice) {
        [UD setObject:@"haveShownMask" forKey:ShowMaskViewDevice];
        [UD setObject:@"haveShownMask" forKey:ShowMaskViewDeviceAir];
        [UD synchronize];
        
        [LoadMaskHelper showMaskWithType:HomePageCloud onView:self.tabBarController.view delay:0.5 delegate:self];
        return;
    }
    
    if (pageType == HomePageCloud) {
        [UD setObject:@"haveShownMask" forKey:ShowMaskViewLeftView];
        [UD setObject:@"haveShownMask" forKey:ShowMaskViewSettingView];
        [UD setObject:@"haveShownMask" forKey:ShowMaskViewAccessControl];
        [UD synchronize];
    }
    
}

- (void)onTransparentBtnClicked:(UIButton *)btn {
    if (btn.tag == 1) { //聊天按钮
        _baseTabbarController.tabbarPanel.hidden = YES;
        if (self.socialView.hidden) {
            self.socialView.hidden = NO;
        }else{
            self.socialView.hidden = YES;
            _baseTabbarController.tabbarPanel.hidden = NO;
            self.chatlabel.text = @"456";
        }
        
        [LoadMaskHelper showMaskWithType:HomePageEnterChat onView:self.tabBarController.view delay:0.5 delegate:self];
    }else if (btn.tag == 2) { //进入聊天
        self.socialView.hidden = YES;
        _baseTabbarController.tabbarPanel.hidden = NO;
        
        [self setRCIM];
    }else if (btn.tag == 3) { //进入家庭
        UIStoryboard *iPhoneStoryBoard  = [UIStoryboard storyboardWithName:@"Family" bundle:nil];
        FamilyHomeViewController *familyVC = [iPhoneStoryBoard instantiateViewControllerWithIdentifier:@"familyHomeVC"];
        familyVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:familyVC animated:YES];
    }else if (btn.tag == 4) {  // 进入场景
        [NC postNotificationName:@"TabbarPanelClickedNotification" object:nil];
    }else if (btn.tag == 5) {  //进入设备
        [NC postNotificationName:@"TabbarPanelClickedNotificationDevice" object:nil];
    }else if (btn.tag == 6) {  //点击“云”，进入侧滑页面
        self.socialView.hidden = YES;
        _baseTabbarController.tabbarPanel.hidden = NO;
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        if (appDelegate.LeftSlideVC.closed)
        {
            [appDelegate.LeftSlideVC openLeftView];
        }
        else
        {
            [appDelegate.LeftSlideVC closeLeftView];
        }
        
        [NC postNotificationName:@"ShowMaskViewNotification" object:nil];
    }
}

@end
