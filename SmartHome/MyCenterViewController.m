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
    UIStoryboard *sy = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    ProfieFaultsViewController *faultVC = [sy instantiateViewControllerWithIdentifier:@"MyDefaultViewController"];
    [self addSubViewAndController:faultVC withNum:0];
    
    ServiceRecordViewController *recordVC = [sy instantiateViewControllerWithIdentifier:@"ServiceRecordViewController"];
    [self addSubViewAndController:recordVC withNum:1];
    
    MyEnergyViewController *energyVC = [sy instantiateViewControllerWithIdentifier:@"MyEnergyViewController"];
    [self addSubViewAndController:energyVC withNum:2];
    
    FavorController *favor = [sy instantiateViewControllerWithIdentifier:@"favorController"];
    [self addSubViewAndController:favor withNum:3];
    
    MSGController *msgVC = [sy instantiateViewControllerWithIdentifier:@"msgController"];
    [self addSubViewAndController:msgVC withNum:4];
    
    MySettingViewController *settingVC = [sy instantiateViewControllerWithIdentifier:@"settingViewController"];
    [self addSubViewAndController:settingVC withNum:5];
    
    
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
    
    self.scrollView.contentOffset = CGPointMake(widtht * indexPath.row, 0);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


@end
