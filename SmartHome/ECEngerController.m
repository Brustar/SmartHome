//
//  ECEngerController.m
//  SmartHome
//
//  Created by zhaona on 2017/2/23.
//  Copyright © 2017年 Brustar. All rights reserved.
//

#import "ECEngerController.h"
#import "ECPickDataViewController.h"
#import "IphoneProfileController.h"

@interface ECEngerController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (nonatomic,strong) ECPickDataViewController *pickerDateVC;
@property (weak, nonatomic) IBOutlet UIView *coverView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *overData;
@property(nonatomic,strong) NSArray *months;
@property (nonatomic,strong) NSArray *overDates;
@property (nonatomic,strong) NSArray *totleEngers;
@property (weak, nonatomic) IBOutlet UILabel *totleEg;
@property (weak, nonatomic) IBOutlet UIImageView *monthImgs;
@property (weak, nonatomic) IBOutlet UIImageView *totalImgs;
@property (nonatomic,strong) NSArray *imgs;
@property (nonatomic,strong) NSArray *total_Imgs;
@end

@implementation ECEngerController

-(ECPickDataViewController *)pickerDateVC
{
    
    if(!_pickerDateVC)
    {
        _pickerDateVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ECPickDataViewController"];
    }
    return _pickerDateVC;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"我的能耗";
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{
       NSForegroundColorAttributeName:[UIColor blackColor]}];
    self.overDates = @[@"45.9%",@"21.7%",@"38.4%",@"36.9%",@"54.3%"];
    self.totleEngers = @[@"406.28",@"842.5",@"798.4",@"1031.9",@"537.9"];
    self.months = @[@"2016年08月",@"2016年07月",@"2016年06月",@"2016年05月",@"2016年04月"];
    self.imgs = @[@"8.jpg",@"7.jpg",@"6.jpg",@"5.jpg",@"4.jpg"];
    self.total_Imgs = @[@"all_8.jpg",@"all_7.jpg",@"all_6.jpg",@"all_5.jpg",@"all_4.jpg"];
    self.overData.text = self.overDates[0];
    self.dateLabel.text = self.months[0];
    self.totleEg.text = self.totleEngers[0];
    self.monthImgs.image = [UIImage imageNamed:self.imgs[0]];
    self.totalImgs.image = [UIImage imageNamed:self.total_Imgs[0]];
//    self.navigationController.navigationBar.backgroundColor = [UIColor blackColor];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.months.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(!cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = self.months[indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    return cell;
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.dateLabel.text = self.months[indexPath.row];
    self.totleEg.text = self.totleEngers[indexPath.row];
    self.overData.text =self.overDates[indexPath.row];
    self.monthImgs.image = [UIImage imageNamed:self.imgs[indexPath.row]];
    self.totalImgs.image = [UIImage imageNamed:self.total_Imgs[indexPath.row]];
    
    self.coverView.hidden = YES;
    self.tableView.hidden = YES;
}
- (IBAction)clickSetttingDate:(UIButton *)sender {

    self.coverView.hidden = NO;
    self.tableView.hidden = NO;

}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    self.tableView.hidden = YES;
    self.coverView.hidden = YES;
}
-(void )pickDate:(ECPickDataViewController *)pickerVC date:(NSString *)dateStr
{
    self.dateLabel.text = dateStr;
}
- (IBAction)goReturn:(id)sender {
//    [self dismissViewControllerAnimated:YES completion:nil];
    UIStoryboard *iphoneBoard  = [UIStoryboard storyboardWithName:@"iPhone" bundle:nil];
    IphoneProfileController * profileVC  = [iphoneBoard instantiateViewControllerWithIdentifier:@"IphoneProfileController"];
      [self.navigationController pushViewController:profileVC animated:YES];
}

@end
