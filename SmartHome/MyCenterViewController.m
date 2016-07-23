//
//  MyCenterViewController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/7/6.
//  Copyright © 2016年 Brustar. All rights reserved.
//
#define widtht self.scrollView.bounds.size.width
#define hight self.scrollView.bounds.size.height

#import "MyCenterViewController.h"
#import "MyCenterTableViewCell.h"
#import "MSGController.h"
#import "FavorController.h"
#import "ProfieFaultsViewController.h"
#import "MySettingViewController.h"
#import "ServiceRecordViewController.h"
#import "MyEnergyViewController.h"

@interface MyCenterViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong) NSArray *titlArr;
@property(nonatomic,strong) NSArray *images;


@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIView *headView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;


@end

@implementation MyCenterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titlArr = @[@"我的故障",@"我的保修记录",@"我的能耗",@"我的收藏",@"我的消息",@"设置"];
    self.images = @[@"my",@"energy",@"record",@"store",@"message",@"setting"];
    self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    [self setUpScrollerView];
    
}
-(void)setUpScrollerView
{
    self.scrollView.frame = CGRectMake(200, 0, self.view.frame.size.width - 200, self.view.frame.size.height);
    self.scrollView.contentSize = CGSizeMake(widtht *self.titlArr.count, hight);
    [self addSubController:@"MyDefaultViewController" withNum:0];
    [self addSubController:@"ServiceRecordViewController" withNum:1];
    [self addSubController:@"MyEnergyViewController" withNum:2];
    [self addSubController:@"favorController" withNum:3];
    [self addSubController:@"msgController" withNum:4];
    [self addSubController:@"settingViewController" withNum:5];
    
    
}

- (void)addSubController:(NSString *)controllerName withNum:(int) num
{
    UIStoryboard *sy = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    UIViewController *childController = [sy instantiateViewControllerWithIdentifier:controllerName];
    [self addSubViewAndController:childController withNum:num];
}

-(void) addSubViewAndController:(UIViewController*)subVC withNum:(int)i
{
    subVC.view.frame = CGRectMake(widtht * i, 0, widtht, hight);
    [self.scrollView addSubview:subVC.view];
    [self addChildViewController:subVC];
    
}


#pragma mark -UITableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  self.titlArr.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MyCenterTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"myCell" forIndexPath:indexPath];
    
    cell.label.text = self.titlArr[indexPath.row];
    cell.imgView.image = [UIImage imageNamed:self.images[indexPath.row]];
    return  cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (5 == indexPath.row) {
        
        MySettingViewController *settingVC = self.childViewControllers[5];
        [settingVC removeAllSubViewFromMySettingController];
        
    }
    if(2 == indexPath.row)
    {
        MyEnergyViewController *enegrgyVC = self.childViewControllers[2];
        [enegrgyVC removeAllSubViewFromMyEnergyViewController];
    }
    self.scrollView.contentOffset = CGPointMake(widtht * indexPath.row, 0);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


@end
