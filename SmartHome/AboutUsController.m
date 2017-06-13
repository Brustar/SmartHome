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

@end

@implementation AboutUsController

- (void)viewDidLoad {
    [super viewDidLoad];
  
    [self setNaviBarTitle:@"关于我们"];
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
        
        WebManager * web = [[WebManager alloc] initWithUrl:@"http://115.28.151.85:8082/article.aspx" title:@"版本说明"];
        
        [self.navigationController pushViewController:web animated:YES];
        
    }if (indexPath.row == 1) {
        
        WebManager * web = [[WebManager alloc] initWithUrl:@"http://115.28.151.85:8082/article.aspx" title:@"隐私与安全政策"];
    
        [self.navigationController pushViewController:web animated:YES];
        
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
