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
#import "IphoneFamilyViewController.h"

@interface IphoneMainController ()<UITableViewDelegate ,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *headView;
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
    self.titleArr = @[@"家庭",@"场景",@"设备",@"实景",@"我的"];
    self.titleImageArr = @[@"family-Mysetting",@"scene-MySetting",@"device_MySetting",@"live",@"me-Mysetting"];
    self.tableView.tableFooterView = [UIView new];
    self.tableView.tableHeaderView = self.headView;
    [self setupChilderController];
//    self.tableView.backgroundColor = [UIColor lightGrayColor];
    [self.view sendSubviewToBack:self.tableView];
    self.tableView.separatorStyle = NO;
  
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
    
    IphoneFamilyViewController * familyVC = [[UIStoryboard storyboardWithName:@"iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"iphoneFamilyViewController"];
    [self setupVc:familyVC title:@"家庭"];
    IphoneSceneController *scene = [[UIStoryboard storyboardWithName:@"iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"iphoneSceneController"];
    [self setupVc:scene title:@"场景"];
   
    IphoneDeviceListController *deviceList = [[UIStoryboard storyboardWithName:@"iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"IphoneDeviceListController"];
    [self setupVc:deviceList title:@"设备"];
    
    IphoneRealSceneController *realVC = [[UIStoryboard storyboardWithName:@"iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"IphoneRealSceneController"];
    [self setupVc:realVC title:@"实景"];
    
    IphoneProfileController *profireList = [[UIStoryboard storyboardWithName:@"iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"IphoneProfileController"];
    [self setupVc:profireList title:@"我的"];
    
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
            
            showingView.transform = CGAffineTransformMakeTranslation(self.view.bounds.size.width-60, 0);
            
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
        showingView.transform = CGAffineTransformMakeTranslation(self.view.bounds.size.width-60, 0);
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
    [self.selectController.view removeFromSuperview];
    
    UIViewController *showViewController = self.childViewControllers[indexPath.row];
    
    [self.view addSubview:showViewController.view];
    
    [self.view bringSubviewToFront:showViewController.view];
    
    showViewController.view.transform = CGAffineTransformMakeTranslation(150, 0);
    
    self.selectController = showViewController;
    
    [self coverOnClick:self.cover];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
