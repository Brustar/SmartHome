//
//  AboutUsView.m
//  SmartHome
//
//  Created by 逸云科技 on 16/7/18.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "AboutUsController.h"
#import "WebManager.h"

@interface AboutUsController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSArray *titles;

@property (weak, nonatomic) IBOutlet UILabel *version;
@property (weak, nonatomic) IBOutlet UIImageView *headImg;
@property (weak, nonatomic) IBOutlet UIView *footView;
@property (weak, nonatomic) IBOutlet UIView *headView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ViewConstraint;//版权的视图到底部父视图的距离
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewConstraintTrailing;//tableView到右边父视图的距离
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewConstraintLeading;//tableView到左边父视图的距离
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *View1ConstraintLeading;//线1到左边父视图的距离
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *View1ConstraintTrailing;//线1到右边父视图的距离

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *View2ConstraintLeading;//线2到左边父视图的距离
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *View2ConstraintTrailing;//线2到右边父视图的距离

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *HeadImageTopConstraint;//headImage到顶部的距离
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewConstraintTop;//tableview到headimage的距离
@property (weak, nonatomic) IBOutlet UIView *View3;

@end

@implementation AboutUsController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (ON_IPAD) {
        
        self.ViewConstraint.constant = 120;
        self.tableViewConstraintTrailing.constant = 20;
        self.tableViewConstraintLeading.constant = 20;
        self.View1ConstraintLeading.constant = 20;
        self.View1ConstraintTrailing.constant = 20;
        self.View2ConstraintLeading.constant = 20;
        self.View2ConstraintTrailing.constant = 20;
        self.HeadImageTopConstraint.constant = 150;
        self.tableViewConstraintTop.constant = 180;
        self.View3.hidden = NO;
    }else{
        self.View3.hidden = YES;
    }

}

- (void)viewDidLoad {
    [super viewDidLoad];
  
    [self setNaviBarTitle:@"关于我们"];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self adjustNaviBarFrameForSplitView];
        [self adjustTitleFrameForSplitView];
    }
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.tableHeaderView = self.headView;
    self.titles = @[@"版本说明",@"隐私与安全政策"];
    self.version.text =[NSString stringWithFormat:@"版本号%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
//    self.tableView.allowsSelection = NO;
    
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.titles.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor colorWithRed:29/255.0 green:30/255.0 blue:34/255.0 alpha:1];
    cell.textLabel.text = self.titles[indexPath.row];
    
    
    //cell的点击颜色
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 50)];
    view.backgroundColor = [UIColor clearColor];
    
    cell.selectedBackgroundView = view;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if (indexPath.row == 0) {
        NSString *addr = [NSString stringWithFormat:@"%@about_app.aspx", [IOManager httpAddr]];
        WebManager * web = [[WebManager alloc] initWithUrl:addr title:@"版本说明"];
        web.isShowInSplitView = YES;
        [self.navigationController pushViewController:web animated:YES];
        
    }if (indexPath.row == 1) {
        NSString *addr = [NSString stringWithFormat:@"%@article.aspx", [IOManager httpAddr]];
        WebManager * web = [[WebManager alloc] initWithUrl:addr title:@"隐私与安全政策"];
        web.isShowInSplitView = YES;
        [self.navigationController pushViewController:web animated:YES];
        
    }

}

-(void)viewDidLayoutSubviews

{
    
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        
        [self.tableView setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
        
    }
    
    
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        
        [self.tableView setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
        
    }
    
}



-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath

{
    
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        
        [cell setSeparatorInset:UIEdgeInsetsZero];
        
    }
    
    
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        
        [cell setLayoutMargins:UIEdgeInsetsZero];
        
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
