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
@interface IphoneMainController ()<UITableViewDelegate ,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *headView;
@property (nonatomic,strong) NSArray *titleArr;
//@property (nonatomic,strong) NSArray * titleImage;
@property (nonatomic, weak) UIViewController *selectController;

@property (nonatomic, strong) UIButton *cover;
@end

@implementation IphoneMainController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleArr = @[@"场景",@"实景",@"我的"];
//    self.titleImage = @[@"menu_scene",@"menu_room",@"menu_device"];
    
    self.tableView.tableFooterView = [UIView new];
    self.tableView.tableHeaderView = self.headView;
    [self setupChilderController];
    
    [self.view sendSubviewToBack:self.tableView];
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
    IphoneSceneController *scene = [[UIStoryboard storyboardWithName:@"iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"iphoneSceneController"];
    [self setupVc:scene title:@"场景"];
    
//    IphoneDeviceListController *deviceList = [[UIStoryboard storyboardWithName:@"iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"IphoneDeviceListController"];
//    [self setupVc:deviceList title:@"设备"];
    
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
    
    [button setTitle:@"菜单" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    button.bounds = CGRectMake(0, 0, 50, 30);
    
    
    [button addTarget:self action:@selector(leftButtonOnClick) forControlEvents:UIControlEventTouchUpInside];
    
    vc.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    
    [self addChildViewController:nav];
}


- (void)leftButtonOnClick {
    [UIView animateWithDuration:0.3 animations:^{
        UIView *showingView = self.selectController.view;
        
        showingView.transform = CGAffineTransformMakeTranslation(150, 0);
        
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
    return 3;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(!cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = self.titleArr[indexPath.row];
//    cell.imageView.image = [UIImage imageNamed:self.titleImage[indexPath.row]];
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
