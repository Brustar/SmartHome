//
//  systemInfomationController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/7/18.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "SystemInfomationController.h"
#import "HttpManager.h"


@interface SystemInfomationController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSArray *titles;
@property (nonatomic,strong) NSMutableArray * dicArr;

@end

@implementation SystemInfomationController
-(NSMutableArray *)dicArr
{
    if (!_dicArr) {
        _dicArr = [NSMutableArray array];
    }
    
    return _dicArr;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"系统信息";
    self.automaticallyAdjustsScrollViewInsets = NO;
    
//  UIBarButtonItem *returnItem = [[UIBarButtonItem alloc]initWithTitle:@"设置" style:UIBarButtonItemStylePlain target:self action:@selector(clickRetunBtn:)];
//    self.navigationItem.leftBarButtonItem = returnItem;

       self.titles = @[@"家庭名称",@"主机编号",@"主机品牌",@"主机型号"];
       self.tableView.tableFooterView = [UIView new];

}
-(void)viewDidLayoutSubviews {
    
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
        
    }
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)])  {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPat{
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]){
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.titles.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *array;
    DeviceInfo *device = [DeviceInfo defaultManager];
    if ([device.db isEqualToString:SMART_DB]){
    NSArray  *paths  =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    
    NSString *docDir = [paths objectAtIndex:0];
    
    NSString *filePath = [docDir stringByAppendingPathComponent:@"gainHome.plist"];
    
      array = [[NSArray alloc] initWithContentsOfFile:filePath];
    }else{
        
        array = @[@"逸云智家",@"2",@"快思聪",@"CP3"];
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = self.titles[indexPath.row];
    cell.backgroundColor = [UIColor clearColor];
    if ([cell.textLabel.text isEqualToString:@"家庭名称"]) {
         cell.detailTextLabel.text = array[0];
    }else if ([cell.textLabel.text isEqualToString:@"主机编号"]){
       cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",array[1]];
    }else if ([cell.textLabel.text isEqualToString:@"主机品牌"]){
        cell.detailTextLabel.text = array[2];
    }else if ([cell.textLabel.text isEqualToString:@"主机型号"]){
        cell.detailTextLabel.text = array[3];
    }
   
    return  cell;
}
//- (IBAction)clickRetunBtn:(id)sender {
//    [self.navigationController popViewControllerAnimated:NO];
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


@end
