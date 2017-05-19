//
//  MainController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/9/19.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "IphoneMainController.h"
#import "IphoneSceneController.h"
#import "IphoneDeviceListController.h"
#import "IphoneRealSceneController.h"
#import "IphoneProfileController.h"

#import "ProfileFaultsViewController.h"
#import "ServiceRecordViewController.h"
#import "MySubEnergyVC.h"
#import "IphoneFavorController.h"
#import "MSGController.h"
#import "MySettingViewController.h"

@interface IphoneMainController ()<UITableViewDelegate ,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *headView;
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (nonatomic,strong) NSArray *titleArr;
@property (nonatomic,strong) NSArray * titleImageArr;
@property (nonatomic, weak) UIViewController *selectController;
@property (nonatomic, strong) UISwipeGestureRecognizer *leftSwipeGestureRecognizer;
@property (nonatomic, strong) UISwipeGestureRecognizer *rightSwipeGestureRecognizer;
@property (nonatomic, strong) UIButton *cover;
@end

@implementation IphoneMainController

- (void)viewDidLoad {
    [super viewDidLoad];
    //,@"实景" ,@"live"
    
    self.headImageView.layer.cornerRadius = 50.0f; //圆角半径
    self.headImageView.layer.masksToBounds = YES; //圆角
      if ([[UD objectForKey:@"HostID"] intValue] == 258) {
              self.titleArr = @[@"家庭",@"场景",@"设备",@"我的"];
            self.titleImageArr = @[@"my",@"energy",@"record",@"store"];
      }else{
          self.titleArr = @[@"我的故障",@"我的保修记录",@"我的能耗",@"我的收藏",@"我的消息",@"设置"];
          self.titleImageArr = @[@"my",@"energy",@"record",@"store",@"message",@"shezhi4"];
      }
  

    self.tableView.tableFooterView = [UIView new];
    self.tableView.tableHeaderView = self.headView;
    [self setupChilderController];
//    self.tableView.backgroundColor = [UIColor lightGrayColor];
    [self.view sendSubviewToBack:self.tableView];
//    self.tableView.separatorStyle = NO;
    [self addNotifications];
}

- (void)addNotifications {
     [NC addObserver:self selector:@selector(selectVC:) name:@"SelectVC" object:nil];
     [NC addObserver:self selector:@selector(selectVC:) name:@"FamilyVC" object:nil];
     [NC addObserver:self selector:@selector(selectVC:) name:@"SceneVC" object:nil];
}

- (void)removeNotifications {
    [NC removeObserver:self];
}

- (void)selectVC:(NSNotification *)noti {
    NSNumber *index = (NSNumber *)noti.object;
    [self selectViewController:index.integerValue];
}

- (UIButton *)cover {
    if (_cover == nil) {
        UIButton *cover = [[UIButton alloc] init];
        [cover addTarget:self action:@selector(coverOnClick:) forControlEvents:UIControlEventTouchUpInside];
        _cover = cover;
    }
    return _cover;
}


- (void)setupChilderController {

    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIStoryboard *iphoneBoard  = [UIStoryboard storyboardWithName:@"iPhone" bundle:nil];
   // ProfileFaultsViewController * profileFaultsVC = [storyBoard instantiateViewControllerWithIdentifier:@"MyDefaultViewController"];
    //IphoneFamilyViewController * familyVC = [[UIStoryboard storyboardWithName:@"iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"iphoneFamilyViewController"];
   // [self setupVc:profileFaultsVC title:@"我的故障"];
    //[self setupVc:familyVC title:@"家庭"];
    
    IphoneSceneController *scene = [[UIStoryboard storyboardWithName:@"iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"iphoneSceneController"];
    //ServiceRecordViewController * serviceRecordVC = [storyBoard instantiateViewControllerWithIdentifier:@"ServiceRecordViewController"];
    //[self setupVc:scene title:@"我的保修记录"];
    [self setupVc:scene title:@"场景"];
   
    IphoneDeviceListController *deviceList = [[UIStoryboard storyboardWithName:@"iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"IphoneDeviceListController"];
    //MySubEnergyVC * mySubEnergyVC = [storyBoard instantiateViewControllerWithIdentifier:@"MyEnergyViewController"];
    //[self setupVc:mySubEnergyVC title:@"我的能耗"];
    [self setupVc:deviceList title:@"设备"];
    
//    IphoneRealSceneController *realVC = [[UIStoryboard storyboardWithName:@"iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"IphoneRealSceneController"];
    IphoneFavorController * favorVC = [iphoneBoard instantiateViewControllerWithIdentifier:@"IphoneFavorController"];
    [self setupVc:favorVC title:@"我的收藏"];
    
//    IphoneProfileController *profireList = [[UIStoryboard storyboardWithName:@"iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"IphoneProfileController"];
    
    MSGController * msgVC = [storyBoard instantiateViewControllerWithIdentifier:@"MSGController"];
    [self setupVc:msgVC title:@"我的消息"];
    
    MySettingViewController * mysettingVC = [storyBoard instantiateViewControllerWithIdentifier:@"MySettingViewController"];
    [self setupVc:mysettingVC title:@"设置"];
    
     if ([[UD objectForKey:@"HostID"] intValue] == 258) {
        //IphoneFamilyViewController * familyVC = [[UIStoryboard storyboardWithName:@"iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"iphoneFamilyViewController"];
           //[self setupVc:familyVC title:@"家庭"];
         IphoneSceneController *scene = [[UIStoryboard storyboardWithName:@"iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"iphoneSceneController"];
         [self setupVc:scene title:@"场景"];
             IphoneDeviceListController *deviceList = [[UIStoryboard storyboardWithName:@"iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"IphoneDeviceListController"];
           [self setupVc:deviceList title:@"设备"];
        IphoneProfileController *realVC = [[UIStoryboard storyboardWithName:@"iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"IphoneProfileController"];
          [self setupVc:realVC title:@"我的"];
     }else{
         UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
         UIStoryboard *iphoneBoard  = [UIStoryboard storyboardWithName:@"iPhone" bundle:nil];
         ProfileFaultsViewController * profileFaultsVC = [storyBoard instantiateViewControllerWithIdentifier:@"MyDefaultViewController"];
         [self setupVc:profileFaultsVC title:@"我的故障"];
         ServiceRecordViewController * serviceRecordVC = [storyBoard instantiateViewControllerWithIdentifier:@"ServiceRecordViewController"];
         [self setupVc:serviceRecordVC title:@"我的保修记录"];
         MySubEnergyVC * mySubEnergyVC = [storyBoard instantiateViewControllerWithIdentifier:@"MyEnergyViewController"];
         [self setupVc:mySubEnergyVC title:@"我的能耗"];
         IphoneFavorController * favorVC = [iphoneBoard instantiateViewControllerWithIdentifier:@"IphoneFavorController"];
         [self setupVc:favorVC title:@"我的收藏"];
         MSGController * msgVC = [storyBoard instantiateViewControllerWithIdentifier:@"MSGController"];
         [self setupVc:msgVC title:@"我的消息"];
         MySettingViewController * mysettingVC = [storyBoard instantiateViewControllerWithIdentifier:@"MySettingViewController"];
         [self setupVc:mysettingVC title:@"设置"];
     }

    self.selectController = self.childViewControllers[0];
    [self.view addSubview:self.selectController.view];
    [self.view bringSubviewToFront:self.selectController.view];
}

- (void)setupVc:(UIViewController *)vc title:(NSString *)title
{
    
    vc.title = title;
    
    UIButton *button = [[UIButton alloc] init];
    
//    [button setTitle:@"菜单" forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"More"] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    button.bounds = CGRectMake(0, 0, 50, 30);
    self.leftSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipes:)];
    self.rightSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipes:)];
    
    self.leftSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    self.rightSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    
    [self.view addGestureRecognizer:self.leftSwipeGestureRecognizer];
    [self.view addGestureRecognizer:self.rightSwipeGestureRecognizer];
    
    [button addTarget:self action:@selector(leftButtonOnClick) forControlEvents:UIControlEventTouchUpInside];
    
    vc.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    
    [self addChildViewController:nav];
    
    
}
- (void)handleSwipes:(UISwipeGestureRecognizer *)sender
{
    if (sender ==self.rightSwipeGestureRecognizer) {
        
        [UIView animateWithDuration:0.3 animations:^{
            UIView *showingView = self.selectController.view;
            
            showingView.transform = CGAffineTransformMakeTranslation(2*self.view.bounds.size.width/3, 0);
            
            self.cover.frame = showingView.bounds;
            [showingView addSubview:self.cover];
        }];
       
    }
    
    if (sender == self.leftSwipeGestureRecognizer) {
       
        [UIView animateWithDuration:0.3 animations:^{
            self.selectController.view.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            [self.cover removeFromSuperview];
        }];
    }
    
}

- (void)leftButtonOnClick {
    [UIView animateWithDuration:0.3 animations:^{
        UIView *showingView = self.selectController.view;
        showingView.transform = CGAffineTransformMakeTranslation(2*self.view.bounds.size.width/3, 0);
        self.cover.frame = showingView.bounds;
        [showingView addSubview:self.cover];
    }];
}
- (void)coverOnClick:(UIButton *)cover {
    [UIView animateWithDuration:0.3 animations:^{
        self.selectController.view.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        [self.cover removeFromSuperview];
    }];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.titleArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(!cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = self.titleArr[indexPath.row];
    
//    cell.backgroundColor = [UIColor lightGrayColor];
    cell.imageView.image = [UIImage imageNamed:self.titleImageArr[indexPath.row]];
    return cell;
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self selectViewController:indexPath.row];
}

- (void)selectViewController:(NSInteger)index {
    
    [self.selectController.view removeFromSuperview];
    
    UIViewController *showViewController = self.childViewControllers[index];
    
    [self.view addSubview:showViewController.view];
    
    [self.view bringSubviewToFront:showViewController.view];
    
    showViewController.view.transform = CGAffineTransformMakeTranslation(150, 0);
    
    self.selectController = showViewController;
    
    [self coverOnClick:self.cover];
}

- (void)dealloc {
    [self removeNotifications];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
