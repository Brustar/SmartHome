//
//  ECPickDataViewController.m
//  SmartHome
//
//  Created by zhaona on 2017/2/23.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "ECPickDataViewController.h"

@interface ECPickDataViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) NSArray *dates;
@end

@implementation ECPickDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dates = @[@"2016年01月",@"2016年02月",@"2016年03月",@"2016年04月",@"2016年05月",@"2016年06月",@"2016年07月",@"2016年08月",@"2016年09月",@"2016年10月",@"2016年11月",@"2016年12月"];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dates.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(!cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = self.dates[indexPath.row];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [self.delegate pickDate:self date:self.dates[indexPath.row]];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
