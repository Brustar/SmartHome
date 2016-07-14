//
//  ServiceRecordViewController.m
//  SmartHome
//
//  Created by 逸云科技 on 16/7/13.
//  Copyright © 2016年 Brustar. All rights reserved.
//

#import "ServiceRecordViewController.h"
#import "ServiceRecordCell.h"
@interface ServiceRecordViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSArray *recordArr;
@property (weak, nonatomic) IBOutlet UIView *coverView;
@property (weak, nonatomic) IBOutlet UIView *commentView;

- (IBAction)clickGoodCommnet:(id)sender;

- (IBAction)clickStillHaveFault:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *faultLabel;

@end

@implementation ServiceRecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.recordArr = @[@"主卧电视无信号",@"主卧壁灯不亮",@"客厅窗帘不能正常控制"];
    self.tableView.tableFooterView = [UIView new];
    self.coverView.hidden = YES;
    self.commentView.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.recordArr.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ServiceRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ServiceRecordCell" forIndexPath:indexPath];
    cell.title.text = self.recordArr[indexPath.row];
    cell.subTitle.text = @"维修时间：2016-7-12";
    cell.evaluateBtn.tag = indexPath.row;
    [cell.evaluateBtn addTarget:self action:@selector(goToComment:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}
-(void)goToComment:(UIButton *)btn
{
    self.coverView.hidden = NO;
    self.commentView.hidden = NO;
    self.faultLabel.text = self.recordArr[btn.tag];
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}
- (IBAction)clickGoodCommnet:(id)sender {
}

- (IBAction)clickStillHaveFault:(id)sender {
}
@end
