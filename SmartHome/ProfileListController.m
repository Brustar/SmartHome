//
//  ProfireListController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/7/30.
//  Copyright © 2016年 Brustar. All rights reserved.
//
#define backGroudColour [UIColor colorWithRed:55/255.0 green:73/255.0 blue:91/255.0 alpha:1]
#define selectedColour  [UIColor colorWithRed:30/255.0 green:52/255.0 blue:70/255.0 alpha:1]
#import "ProfileListController.h"

@interface ProfileListController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *headView;
@property (nonatomic,strong) NSArray *titlArr;
@property (nonatomic,strong) NSArray *images;

@property (weak, nonatomic) IBOutlet UILabel *userName;


@end

@implementation ProfileListController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.userName.text = [[NSUserDefaults  standardUserDefaults] objectForKey:@"UserName"];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.titlArr = @[@"我的故障",@"我的保修记录",@"我的能耗",@"我的收藏",@"我的消息",@"设置"];
    self.images = @[@"my",@"energy",@"record",@"store",@"message",@"setting"];
    self.splitViewController.maximumPrimaryColumnWidth = 250;
    
    self.navigationController.navigationBar.backgroundColor = [UIColor lightGrayColor];
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = backGroudColour;
    self.headView.backgroundColor = backGroudColour;
    self.tableView.tableHeaderView = self.headView;
    [self.tableView setSeparatorColor:[UIColor clearColor]];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSInteger selectedIndex = self.titlArr.count - 1;
    
    NSIndexPath *selectedIndexPath = [NSIndexPath indexPathForRow:selectedIndex inSection:0];
    
    [self.tableView selectRowAtIndexPath:selectedIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    
    if([self.delegate respondsToSelector:@selector(ProfileListController:selected:)])
    {
        [self.delegate ProfileListController:self selected:selectedIndexPath.row ];
    }
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return  1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  self.titlArr.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];

    if(!cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    cell.textLabel.text = self.titlArr[indexPath.row];
    cell.imageView.image = [UIImage imageNamed:self.images[indexPath.row]];
    cell.selectedBackgroundView = [[UIView alloc]initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = selectedColour;
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    cell.backgroundColor = backGroudColour;
    
    cell.textLabel.textColor = [UIColor colorWithRed:152/255.0 green:172/255.0 blue:195/255.0 alpha:1];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if([self.delegate respondsToSelector:@selector(ProfileListController:selected:)])
    {
        [self.delegate ProfileListController:self selected:indexPath.row];
    }
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
