//
//  IpadFirstViewController.m
//  SmartHome
//
//  Created by zhaona on 2017/5/22.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "IpadFirstViewController.h"
#import "BaseTabBarController.h"
#import "VoiceOrderController.h"

@interface IpadFirstViewController ()
@property (nonatomic,strong) BaseTabBarController *baseTabbarController;
@property (nonatomic, readonly) UIButton *naviRightBtn;
@property (nonatomic, readonly) UIButton *naviLeftBtn;
@property (nonatomic, readonly) UIButton *naviMiddletBtn;
@property (nonatomic,strong) NSString * weekStr;
@property (weak, nonatomic) IBOutlet UIView *MessageView;//聊天的视图
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;//显示未读消息的Label
@property (weak, nonatomic) IBOutlet UIButton *MessageBtnDo;//点击弹出聊天页面的按钮
@property (weak, nonatomic) IBOutlet UILabel *TimerLabel;//显示日期的label
@property (weak, nonatomic) IBOutlet UILabel *temperatureLabel;//温度
@property (weak, nonatomic) IBOutlet UILabel *weekDayLabel;

@property (weak, nonatomic) IBOutlet UIView *CoverView;
@property (nonatomic,strong) NSString * WeekDayStr;
@property (nonatomic,strong) NSString * locationString;

@property (weak, nonatomic) IBOutlet UIButton * firstBtn;
@property (weak, nonatomic) IBOutlet UIButton * TwoBtn;
@property (weak, nonatomic) IBOutlet UIButton * ThreeBtn;
@property (weak, nonatomic) IBOutlet UIButton *VoiceBtn;//点击进入语音

@property (weak, nonatomic) IBOutlet UILabel *remindLabel;//每日提醒的label


@end

@implementation IpadFirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addNotifications];
    [self connect];
    self.imageView.userInteractionEnabled = YES;
    self.messageLabel.layer.cornerRadius = self.messageLabel.bounds.size.width/2;
    self.messageLabel.layer.masksToBounds = YES;
     UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doTap:)];
    [self.imageView addGestureRecognizer:tap];
    [self setupNaviBar];
    [self showNetStateView];
    [self setTimer];
    [self getWeekdayStringFromDate];
    
    //开启网络状况监听器
    [self updateInterfaceWithReachability];
    
    
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

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _baseTabbarController =  (BaseTabBarController *)self.tabBarController;
    _baseTabbarController.tabbarPanel.hidden = NO;
    _baseTabbarController.tabBar.hidden = YES;
    
    [self getScenesFromPlist];
    [self setBtn];

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
        }
    }else{
        _ThreeBtn.center = CGPointMake(self.view.center.x, self.view.center.y);
        [_ThreeBtn setBackgroundImage:[UIImage imageNamed:@"circular4"] forState:UIControlStateNormal];
        [_ThreeBtn setTitle:@"" forState:UIControlStateNormal];
        _firstBtn.hidden = YES;
        _TwoBtn.hidden = YES;
        _ThreeBtn.hidden = NO;
        
    }
}

-(void)doTap:(UIGestureRecognizer *)dap
{
    UIStoryboard *planeGraphStoryBoard  = [UIStoryboard storyboardWithName:@"PlaneGraph" bundle:nil];
    PlaneGraphViewController *planeGraphVC = [planeGraphStoryBoard instantiateViewControllerWithIdentifier:@"PlaneGraphVC"];
    planeGraphVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:planeGraphVC animated:YES];

}
- (void)addNotifications {
    [NC addObserver:self selector:@selector(netWorkDidChangedNotification:) name:@"NetWorkDidChangedNotification" object:nil];
}
- (void)netWorkDidChangedNotification:(NSNotification *)noti {
    [self refreshUI];
}
- (void)refreshUI {
    DeviceInfo *info = [DeviceInfo defaultManager];
    if([[AFNetworkReachabilityManager sharedManager] isReachableViaWWAN]) { //手机自带网络
        if (info.connectState == offLine) {
            [self setNetState:netState_notConnect];
            [self.baseTabbarController.tabbarPanel.sliderBtn setBackgroundImage:[UIImage  imageNamed:@"slider"] forState:UIControlStateNormal];
            NSLog(@"离线模式");
        }else{
            [self setNetState:netState_outDoor_4G];
            [self.baseTabbarController.tabbarPanel.sliderBtn setBackgroundImage:[UIImage imageNamed:@"Scene-selected"] forState:UIControlStateNormal];
            NSLog(@"外出模式-4G");
        }
    }else if ([[AFNetworkReachabilityManager sharedManager] isReachableViaWiFi]) { //WIFI
        
        if (info.connectState == atHome) {
            [self setNetState:netState_atHome_WIFI];
            [self.baseTabbarController.tabbarPanel.sliderBtn setBackgroundImage:[UIImage imageNamed:@"Scene-selected"] forState:UIControlStateNormal];
            NSLog(@"在家模式-WIFI");
            
            
        }else if (info.connectState == outDoor){
            [self setNetState:netState_outDoor_WIFI];
            [self.baseTabbarController.tabbarPanel.sliderBtn setBackgroundImage:[UIImage imageNamed:@"Scene-selected"] forState:UIControlStateNormal];
            NSLog(@"外出模式-WIFI");
            
        }else if (info.connectState == offLine) {
            [self setNetState:netState_notConnect];
            [self.baseTabbarController.tabbarPanel.sliderBtn setBackgroundImage:[UIImage imageNamed:@"slider"] forState:UIControlStateNormal];
            NSLog(@"离线模式");
        }
        
    }else {
        [self setNetState:netState_notConnect];
        [self.baseTabbarController.tabbarPanel.sliderBtn setBackgroundImage:[UIImage imageNamed:@"slider"] forState:UIControlStateNormal];
        NSLog(@"离线模式");
    }
}
//处理连接改变后的情况
- (void)updateInterfaceWithReachability
{
    __block IpadFirstViewController * FirstBlockSelf = self;
    
    _afNetworkReachabilityManager = [AFNetworkReachabilityManager sharedManager];
    
    [_afNetworkReachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        DeviceInfo *info = [DeviceInfo defaultManager];
        if(status == AFNetworkReachabilityStatusReachableViaWWAN) //手机自带网络
        {
            if (info.connectState == offLine) {
                [FirstBlockSelf setNetState:netState_notConnect];
                [FirstBlockSelf.baseTabbarController.tabbarPanel.sliderBtn setBackgroundImage:[UIImage  imageNamed:@"slider"] forState:UIControlStateNormal];
                NSLog(@"离线模式");
            }else{
                [FirstBlockSelf setNetState:netState_outDoor_4G];
                [FirstBlockSelf.baseTabbarController.tabbarPanel.sliderBtn setBackgroundImage:[UIImage imageNamed:@"Scene-selected"] forState:UIControlStateNormal];
                NSLog(@"外出模式-4G");
            }
        }
        else if(status == AFNetworkReachabilityStatusReachableViaWiFi) //WIFI
        {
            if (info.connectState == atHome) {
                [FirstBlockSelf setNetState:netState_atHome_WIFI];
                [FirstBlockSelf.baseTabbarController.tabbarPanel.sliderBtn setBackgroundImage:[UIImage imageNamed:@"Scene-selected"] forState:UIControlStateNormal];
                NSLog(@"在家模式-WIFI");
                
                
            }else if (info.connectState == outDoor){
                [FirstBlockSelf setNetState:netState_outDoor_WIFI];
                [FirstBlockSelf.baseTabbarController.tabbarPanel.sliderBtn setBackgroundImage:[UIImage imageNamed:@"Scene-selected"] forState:UIControlStateNormal];
                NSLog(@"外出模式-WIFI");
                
            }else if (info.connectState == offLine) {
                [FirstBlockSelf setNetState:netState_notConnect];
                [FirstBlockSelf.baseTabbarController.tabbarPanel.sliderBtn setBackgroundImage:[UIImage imageNamed:@"slider"] forState:UIControlStateNormal];
                NSLog(@"离线模式");
                
                
            }
        }else if(status == AFNetworkReachabilityStatusNotReachable){ //没有网络(断网)
            [FirstBlockSelf setNetState:netState_notConnect];
            [FirstBlockSelf.baseTabbarController.tabbarPanel.sliderBtn setBackgroundImage:[UIImage imageNamed:@"slider"] forState:UIControlStateNormal];
            NSLog(@"离线模式");
            
        }else if (status == AFNetworkReachabilityStatusUnknown) { //未知网络
            [FirstBlockSelf setNetState:netState_notConnect];
            [FirstBlockSelf.baseTabbarController.tabbarPanel.sliderBtn setBackgroundImage:[UIImage imageNamed:@"slider"] forState:UIControlStateNormal];
            NSLog(@"离线模式");
            
        }
    }];
    
    [_afNetworkReachabilityManager startMonitoring];//开启网络监视器；
    
}
- (void)setupNaviBar {
    
   [self setNaviBarTitle:[UD objectForKey:@"homename"]]; //设置标题
    _naviMiddletBtn = [[UIButton alloc] init];
    [_naviMiddletBtn setTitle:[UD objectForKey:@"homename"] forState:UIControlStateNormal];
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
//    [self setNaviMiddletBtn:_naviMiddletBtn];:(NSDate*)inputDate
}
-(void)rightBtnClicked:(UIButton *)btn
{
    
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
- (void)leftBtnClicked:(UIButton *)btn {
    
    self.MessageView.hidden = YES;
    self.CoverView.hidden = YES;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        iPadMyViewController *myVC = [[iPadMyViewController alloc] init];
        [self.navigationController pushViewController:myVC animated:YES];
    }else {
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
   
    
}
-(void)getWeekdayStringFromDate {
    
    
    NSDate*date = [NSDate date];
    
    NSCalendar*calendar = [NSCalendar currentCalendar];
    
    NSDateComponents*comps;
    
    comps =[calendar components:(NSWeekCalendarUnit | NSWeekdayCalendarUnit |NSWeekdayOrdinalCalendarUnit)
            
                       fromDate:date];
    NSInteger weekday = [comps weekday]; // 星期几（注意，周日是“1”，周一是“2”。。。。）
    if (weekday == 1) {
        self.WeekDayStr = @"周日";
    }if (weekday == 2) {
        self.WeekDayStr = @"周一";
    }if (weekday == 3) {
        self.WeekDayStr = @"周二";
    }if (weekday == 4) {
        self.WeekDayStr = @"周三";
    }if (weekday == 5) {
        self.WeekDayStr = @"周四";
    }if (weekday == 6) {
        self.WeekDayStr = @"周五";
    }if (weekday == 7) {
        self.WeekDayStr = @"周六";
    }
    self.weekDayLabel.text = self.WeekDayStr;
    
}
-(void)setTimer
{
    //获取系统时间
    NSDate * senddate=[NSDate date];
    
    NSDateFormatter *dateformatter=[[NSDateFormatter alloc] init];
    
    [dateformatter setDateFormat:@"HH:mm"];
    
    _locationString=[dateformatter stringFromDate:senddate];
    
    NSLog(@"-------%@",_locationString);
    
    int result= [_locationString compare:@"19:00"];
    if(result>0){
        self.imageView.image = [UIImage imageNamed:@"IpadSceneBg-night"];
    }else{
        self.imageView.image = [UIImage imageNamed:@"IpadSceneBg"];
    }
    NSCalendar * cal=[NSCalendar currentCalendar];
    NSUInteger unitFlags=NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit;
    NSDateComponents * conponent= [cal components:unitFlags fromDate:senddate];
    NSInteger year=[conponent year];
    NSInteger month=[conponent month];
    NSInteger day=[conponent day];
    self.TimerLabel.text = [NSString stringWithFormat:@"%ld.%ld.%ld",year,month,day];

}
//弹出聊天框
- (IBAction)MessageBtnDo:(id)sender {
    
    _baseTabbarController.tabbarPanel.hidden = YES;
    if (self.CoverView.hidden) {
        self.CoverView.hidden = NO;
        self.MessageView.hidden = NO;
    }else{
        self.CoverView.hidden = YES;
        self.MessageView.hidden = YES;
        _baseTabbarController.tabbarPanel.hidden = NO;
//        self.chatlabel.text = @"456";
    }
}

//回复消息的按钮
- (IBAction)replyBtn:(id)sender {
    
    
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
        self.MessageView.hidden = YES;
        self.CoverView.hidden = YES;
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
- (IBAction)VoiceBtn:(id)sender {
    
    UIStoryboard * iphoneStoryBoard = [UIStoryboard storyboardWithName:@"iPhone" bundle:nil];
    VoiceOrderController * voiceVC = [iphoneStoryBoard instantiateViewControllerWithIdentifier:@"VoiceOrderController"];
    
    [self.navigationController pushViewController:voiceVC animated:YES];
    
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    self.CoverView.hidden = YES;
     self.MessageView.hidden = YES;
    _baseTabbarController.tabbarPanel.hidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
